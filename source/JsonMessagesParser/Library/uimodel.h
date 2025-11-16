#ifndef UIMODEL_H
#define UIMODEL_H

#include <QObject>
#include <QString>
#include <QVariantMap>
#include <QVariantList>
#include <QStringList>
#include <QColor>

class JsonParser;

class UiModel : public QObject
{
    Q_OBJECT

    // Свойства для текущей страницы
    Q_PROPERTY(QVariantMap currentPageData READ currentPageData NOTIFY currentPageDataChanged)
    Q_PROPERTY(QString currentPageName READ currentPageName NOTIFY currentPageNameChanged)
    Q_PROPERTY(QVariantMap currentPageLayout READ currentPageLayout NOTIFY currentPageLayoutChanged)
    Q_PROPERTY(QColor currentPageColor READ currentPageColor NOTIFY currentPageColorChanged)

    // Свойства для списка страниц
    Q_PROPERTY(QStringList pageNames READ pageNames NOTIFY pageNamesChanged)
    Q_PROPERTY(int currentPageIndex READ currentPageIndex WRITE setCurrentPageIndex NOTIFY currentPageIndexChanged)

    // Свойства состояния
    Q_PROPERTY(bool hasPages READ hasPages NOTIFY hasPagesChanged)
    Q_PROPERTY(bool isInitialized READ isInitialized NOTIFY isInitializedChanged)

    // ... существующий код ...

    public:
        // ... существующие методы ...

        Q_INVOKABLE int findPageIndex(const QString &pageName) const;

    // ... существующий код ...

public:
    // ... существующие методы ...

    // Новые методы для работы с окном сообщений
    Q_INVOKABLE QStringList getAllAvailablePageNames() const;
    Q_INVOKABLE QStringList getCurrentPageNames() const;
    Q_INVOKABLE void addPagesFromSelection(const QStringList &selectedPages);

signals:
    // ... существующие сигналы ...

    // Новые сигналы для синхронизации
    void pagesSynchronized();

public:
    explicit UiModel(QObject *parent = nullptr);

    void setJsonParser(JsonParser *parser);

    // Q_INVOKABLE методы для управления UI
    Q_INVOKABLE void initialize();
    Q_INVOKABLE void loadPage(const QString &pageName);
    Q_INVOKABLE void loadPageByIndex(int index);
    Q_INVOKABLE void createNewPage(const QString &pageName = "");
    Q_INVOKABLE void deletePage(int index);
    Q_INVOKABLE void duplicatePage(int index);
    Q_INVOKABLE QString generateCopyName(const QString &originalName);
    Q_INVOKABLE QVariantMap collectPageData();

    // Геттеры
    QVariantMap currentPageData() const { return m_currentPageData; }
    QString currentPageName() const { return m_currentPageName; }
    QVariantMap currentPageLayout() const { return m_currentPageLayout; }
    QColor currentPageColor() const { return m_currentPageColor; }
    QStringList pageNames() const { return m_pageNames; }
    int currentPageIndex() const { return m_currentPageIndex; }
    bool hasPages() const { return !m_pageNames.isEmpty(); }
    bool isInitialized() const { return m_initialized; }

    // Сеттеры
    void setCurrentPageIndex(int index);

signals:
    void currentPageDataChanged();
    void currentPageNameChanged();
    void currentPageLayoutChanged();
    void currentPageColorChanged();
    void pageNamesChanged();
    void currentPageIndexChanged();
    void hasPagesChanged();
    void isInitializedChanged();

    // Сигналы для QML
    void pageDataCollected(const QString &pageName, const QVariantMap &data);
    void pageAdded(const QString &pageName);
    void pageRemoved(int index);
    void pageLoaded(const QString &pageName);

private slots:
    void onJsonDataLoaded();

private:
    void updatePageNames();
    void updateCurrentPageColor();
    QString getBasePageName(const QString &fullPageName) const;
    QVariantMap createEmptyPageData(const QString &pageName) const;

    JsonParser *m_jsonParser;
    QVariantMap m_currentPageData;
    QString m_currentPageName;
    QVariantMap m_currentPageLayout;
    QColor m_currentPageColor;
    QStringList m_pageNames;
    int m_currentPageIndex;
    bool m_initialized;
};

#endif // UIMODEL_H
