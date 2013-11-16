#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>
#include <QSqlQueryModel>
#include <QVariant>
#include <QStringList>

class SqlQueryModel : public QSqlQueryModel
{
    Q_OBJECT

    void generateRoleNames();

public:
    explicit SqlQueryModel(QObject *parent = 0);

    void setQuery(const QString &query, const QSqlDatabase &db = QSqlDatabase());
    void setQuery(const QSqlQuery &query);
    QVariant data(const QModelIndex &index, int role) const;

signals:

public slots:

};

class DatabaseManager: public QObject
{
    Q_OBJECT
    Q_PROPERTY( SqlQueryModel* accounts READ getAccounts NOTIFY finished)

public:
    DatabaseManager(QObject *parent = 0);
    ~DatabaseManager();

    signals:
        void finished();

    public:
        bool deleteDB();

        // create database structure
        bool mkAccTable();
        QSqlError lastError();
        SqlQueryModel* sqlAccounts;
        QSqlDatabase db;
        bool databaseOpen;
    public slots:
        Q_INVOKABLE bool initDB();
        Q_INVOKABLE bool insertAccount(QString service, QString name, QString secretKey);
        Q_INVOKABLE bool deleteAccount(int id);
        SqlQueryModel* getAccounts();

    };

#endif // DATABASEMANAGER_H
