#include "uimodel.h"
#include "jsonparser.h"
#include <QDateTime>

UiModel::UiModel(QObject *parent)
    : QObject(parent)
    , m_jsonParser(nullptr)
    , m_currentPageIndex(-1)
    , m_initialized(false)
{
    m_currentPageColor = QColor("blue");
}

void UiModel::setJsonParser(JsonParser *parser)
{
    if (m_jsonParser == parser)
        return;

    if (m_jsonParser) {
        disconnect(m_jsonParser, &JsonParser::dataLoaded, this, &UiModel::onJsonDataLoaded);
    }

    m_jsonParser = parser;

    if (m_jsonParser) {
        connect(m_jsonParser, &JsonParser::dataLoaded, this, &UiModel::onJsonDataLoaded);
    }
}

void UiModel::initialize()
{
    if (!m_jsonParser) {
        qWarning() << "UiModel: JsonParser not set!";
        return;
    }

    if (m_jsonParser->hasData()) {
        onJsonDataLoaded();
    } else {
        qDebug() << "UiModel: No JSON data available yet";
        // Ждем сигнала dataLoaded
    }
}

void UiModel::onJsonDataLoaded()
{
    if (!m_jsonParser) return;

    qDebug() << "UiModel: JSON data loaded, initializing UI...";

    updatePageNames();

    if (!m_pageNames.isEmpty()) {
        // Загружаем первую страницу из JSON данных
        loadPageByIndex(0);
        qDebug() << "UiModel: Loaded first page from JSON:" << m_pageNames[0];
    } else {
        qDebug() << "UiModel: No pages found in JSON data";
        // Не создаем пустую страницу автоматически - ждем выбора пользователя
        m_initialized = true;
        emit isInitializedChanged();
        qDebug() << "UiModel: Initialization completed, no pages available";
        return;
    }

    m_initialized = true;
    emit isInitializedChanged();

    qDebug() << "UiModel: Initialization completed, pages count:" << m_pageNames.size();
}

void UiModel::updatePageNames()
{
    if (!m_jsonParser) return;

    m_pageNames.clear();

    // Получаем имена страниц из JSON парсера
    QStringList availablePages = m_jsonParser->getAvailablePages();
    for (const QString &pageKey : availablePages) {
        QVariantMap pageData = m_jsonParser->getPageData(pageKey);
        if (pageData.contains("pageName")) {
            QString pageName = pageData["pageName"].toString();
            m_pageNames.append(pageName);
            qDebug() << "UiModel: Added page:" << pageName << "from key:" << pageKey;
        }
    }

    qDebug() << "UiModel: Total pages found:" << m_pageNames.size();

    emit pageNamesChanged();
    emit hasPagesChanged();
}

void UiModel::loadPage(const QString &pageName)
{
    if (!m_jsonParser) {
        qWarning() << "UiModel: JsonParser not available!";
        return;
    }

    QString baseName = getBasePageName(pageName);

    // Ищем страницу в JSON данных
    bool foundInJson = false;
    QStringList availablePages = m_jsonParser->getAvailablePages();
    for (const QString &pageKey : availablePages) {
        QVariantMap pageData = m_jsonParser->getPageData(pageKey);
        if (pageData.contains("pageName")) {
            QString jsonPageName = pageData["pageName"].toString();
            if (getBasePageName(jsonPageName) == baseName) {
                // Нашли страницу в JSON - используем её данные
                m_currentPageData = pageData;
                m_currentPageData["pageName"] = pageName;
                m_currentPageName = pageName;

                // Сохраняем layout
                if (pageData.contains("layout")) {
                    m_currentPageLayout = pageData["layout"].toMap();
                } else {
                    m_currentPageLayout = QVariantMap();
                }

                foundInJson = true;
                qDebug() << "UiModel: Loaded page from JSON:" << pageName;
                break;
            }
        }
    }

    if (!foundInJson) {
        // Страница не найдена в JSON - создаем пустую
        m_currentPageData = createEmptyPageData(pageName);
        m_currentPageName = pageName;
        m_currentPageLayout = QVariantMap();

        qDebug() << "UiModel: Created empty page (not found in JSON):" << pageName;
    }

    emit currentPageDataChanged();
    emit currentPageNameChanged();
    emit currentPageLayoutChanged();
    emit pageLoaded(pageName);

    updateCurrentPageColor();
}

void UiModel::loadPageByIndex(int index)
{
    if (index >= 0 && index < m_pageNames.size()) {
        m_currentPageIndex = index;
        QString pageName = m_pageNames[index];
        loadPage(pageName);
        emit currentPageIndexChanged();
        qDebug() << "UiModel: Loaded page by index:" << index << "name:" << pageName;
    } else {
        qWarning() << "UiModel: Invalid page index:" << index << ", available pages:" << m_pageNames.size();
        // Устанавливаем индекс в -1 если нет страниц
        if (m_pageNames.isEmpty()) {
            m_currentPageIndex = -1;
            emit currentPageIndexChanged();
        }
    }
}

void UiModel::createNewPage(const QString &pageName)
{
    QString newPageName = pageName.isEmpty() ? "Новая страница" : pageName;

    // Проверяем уникальность имени
    QString finalPageName = newPageName;
    int copyNumber = 1;
    while (m_pageNames.contains(finalPageName)) {
        finalPageName = newPageName + " - " + QString::number(copyNumber);
        copyNumber++;
    }

    m_pageNames.append(finalPageName);
    emit pageNamesChanged();
    emit hasPagesChanged();

    // Загружаем новую страницу (будет создана пустая, так как её нет в JSON)
    loadPage(finalPageName);
    m_currentPageIndex = m_pageNames.size() - 1;
    emit currentPageIndexChanged();
    emit pageAdded(finalPageName);

    qDebug() << "UiModel: Created new page:" << finalPageName;
}

void UiModel::deletePage(int index)
{
    if (index < 0 || index >= m_pageNames.size()) {
        qWarning() << "UiModel: Invalid delete index:" << index;
        return;
    }

    QString pageNameToDelete = m_pageNames[index];
    m_pageNames.removeAt(index);

    emit pageNamesChanged();
    emit hasPagesChanged();
    emit pageRemoved(index);

    // Обновляем текущую страницу если нужно
    if (m_currentPageIndex == index) {
        if (m_pageNames.isEmpty()) {
            // Нет больше страниц
            m_currentPageData = QVariantMap();
            m_currentPageName = "";
            m_currentPageLayout = QVariantMap();
            m_currentPageIndex = -1;

            emit currentPageDataChanged();
            emit currentPageNameChanged();
            emit currentPageLayoutChanged();
            emit currentPageIndexChanged();
        } else {
            int newIndex = qMin(index, m_pageNames.size() - 1);
            loadPageByIndex(newIndex);
        }
    } else if (m_currentPageIndex > index) {
        m_currentPageIndex--;
        emit currentPageIndexChanged();
    }

    qDebug() << "UiModel: Deleted page:" << pageNameToDelete << "at index:" << index;
}

void UiModel::duplicatePage(int index)
{
    if (index < 0 || index >= m_pageNames.size()) {
        qWarning() << "UiModel: Invalid duplicate index:" << index;
        return;
    }

    QString originalName = m_pageNames[index];
    QString copyName = generateCopyName(originalName);

    createNewPage(copyName);
    qDebug() << "UiModel: Duplicated page:" << originalName << "to:" << copyName;
}

QString UiModel::generateCopyName(const QString &originalName)
{
    QString baseName = getBasePageName(originalName);
    int copyNumber = 1;

    // Считаем копии
    for (const QString &pageName : m_pageNames) {
        if (getBasePageName(pageName) == baseName) {
            copyNumber++;
        }
    }

    QString newName = baseName;
    if (copyNumber > 1) {
        newName += " - " + QString::number(copyNumber);
    }

    return newName;
}

QVariantMap UiModel::collectPageData()
{
    QVariantMap collectedData;

    if (m_currentPageName.isEmpty() || m_currentPageData.isEmpty()) {
        qWarning() << "UiModel: No current page data to collect";
        return collectedData;
    }

    collectedData["pageName"] = m_currentPageName;
    collectedData["basePageName"] = getBasePageName(m_currentPageName);
    collectedData["timestamp"] = QDateTime::currentDateTime().toString(Qt::ISODate);

    // Собираем данные элементов
    QVariantList items;
    if (m_currentPageData.contains("items") && m_currentPageData["items"].canConvert<QVariantList>()) {
        QVariantList pageItems = m_currentPageData["items"].toList();
        for (const QVariant &itemVar : pageItems) {
            if (itemVar.canConvert<QVariantMap>()) {
                QVariantMap item = itemVar.toMap();
                QVariantMap itemData;
                itemData["name"] = item.value("name", "");
                itemData["type"] = item.value("type", "");
                itemData["label"] = item.value("label", "");
                itemData["enabled"] = item.value("enabled", true);
                itemData["value"] = item.value("default", "");
                items.append(itemData);
            }
        }
    }

    collectedData["items"] = items;

    emit pageDataCollected(m_currentPageName, collectedData);

    qDebug() << "UiModel: Collected data for page:" << m_currentPageName << "items:" << items.size();

    return collectedData;
}

void UiModel::setCurrentPageIndex(int index)
{
    if (m_currentPageIndex == index) return;

    m_currentPageIndex = index;
    if (index >= 0 && index < m_pageNames.size()) {
        loadPage(m_pageNames[index]);
    } else if (m_pageNames.isEmpty()) {
        // Если нет страниц, сбрасываем текущие данные
        m_currentPageData = QVariantMap();
        m_currentPageName = "";
        m_currentPageLayout = QVariantMap();

        emit currentPageDataChanged();
        emit currentPageNameChanged();
        emit currentPageLayoutChanged();
    }
    emit currentPageIndexChanged();
}

void UiModel::updateCurrentPageColor()
{
    static const QList<QColor> colors = {
        QColor("blue"), QColor("green"), QColor("red"),
        QColor("purple"), QColor("orange"), QColor("teal")
    };

    if (m_currentPageIndex >= 0 && m_currentPageIndex < colors.size()) {
        m_currentPageColor = colors[m_currentPageIndex];
    } else {
        m_currentPageColor = QColor("blue");
    }

    emit currentPageColorChanged();
}

// ... существующий код ...

int UiModel::findPageIndex(const QString &pageName) const
{
    return m_pageNames.indexOf(pageName);
}

// ... существующий код ...

QStringList UiModel::getAllAvailablePageNames() const
{
    QStringList allPages;

    if (!m_jsonParser) {
        qWarning() << "UiModel: JsonParser not available!";
        return allPages;
    }

    // Получаем все доступные страницы из JSON
    QStringList availablePages = m_jsonParser->getAvailablePages();
    for (const QString &pageKey : availablePages) {
        QVariantMap pageData = m_jsonParser->getPageData(pageKey);
        if (pageData.contains("pageName")) {
            allPages.append(pageData["pageName"].toString());
        }
    }

    qDebug() << "UiModel: All available pages from JSON:" << allPages;
    return allPages;
}

QStringList UiModel::getCurrentPageNames() const
{
    return m_pageNames;
}

void UiModel::addPagesFromSelection(const QStringList &selectedPages)
{
    if (selectedPages.isEmpty()) {
        qDebug() << "UiModel: No pages to add from selection";
        return;
    }

    bool changesMade = false;

    for (const QString &pageName : selectedPages) {
        // Проверяем, есть ли уже такая страница
        if (!m_pageNames.contains(pageName)) {
            m_pageNames.append(pageName);
            changesMade = true;
            qDebug() << "UiModel: Added page from selection:" << pageName;
        }
    }

    if (changesMade) {
        emit pageNamesChanged();
        emit hasPagesChanged();
        emit pagesSynchronized();

        // Загружаем первую добавленную страницу если нет текущей
        if (m_currentPageIndex == -1 && !m_pageNames.isEmpty()) {
            loadPageByIndex(0);
        }

        qDebug() << "UiModel: Pages synchronized, total:" << m_pageNames.size();
    }
}

QString UiModel::getBasePageName(const QString &fullPageName) const
{
    QString baseName = fullPageName;
    int dashIndex = baseName.indexOf(" - ");
    if (dashIndex != -1) {
        baseName = baseName.left(dashIndex);
    }
    return baseName;
}

QVariantMap UiModel::createEmptyPageData(const QString &pageName) const
{
    QVariantMap pageData;
    pageData["pageName"] = pageName;

    QVariantMap layout;
    layout["columns"] = 5;
    layout["rows"] = 6;
    layout["cellWidth"] = 200;
    layout["cellHeight"] = 100;
    pageData["layout"] = layout;

    QVariantList items;
    QVariantMap emptyItem;
    emptyItem["name"] = "emptyField";
    emptyItem["type"] = "textfield";
    emptyItem["label"] = "Пустое поле";
    emptyItem["enabled"] = true;
    emptyItem["default"] = "Введите данные";

    QVariantMap position;
    position["x"] = 1;
    position["y"] = 1;
    position["width"] = 1;
    position["height"] = 1;
    emptyItem["position"] = position;

    items.append(emptyItem);
    pageData["items"] = items;

    return pageData;
}
