#include "DatabaseManager.h"
#include <QFile>
#include <QSqlRecord>
#include <QSqlField>
#include <QDebug>
#include <QSqlDatabase>


//--------------------------------
// SQL QUERY MODEL
//
// DOES SOME FUN STUFF TO DISPLAY STUFF IN QML
//--------------------------------

SqlQueryModel::SqlQueryModel(QObject *parent) :
    QSqlQueryModel(parent) {
}

void SqlQueryModel::setQuery(const QString &query, const QSqlDatabase &db) {
    if (db.isOpen())
        QSqlQueryModel::setQuery(query,db);
    generateRoleNames();
}

void SqlQueryModel::setQuery(const QSqlQuery & query) {
    QSqlQueryModel::setQuery(query);
    generateRoleNames();
}

QHash<int, QByteArray> SqlQueryModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[Qt::UserRole + 1] = "id";
    roles[Qt::UserRole + 2] = "service";
    roles[Qt::UserRole + 3] = "name";
    roles[Qt::UserRole + 4] = "secretKey";
    return roles;
}

void SqlQueryModel::generateRoleNames() {
    QHash<int, QByteArray> roles;
    for( int i = 0; i < record().count(); i++) {
    #if QT_VERSION < 0x050000
        roles[Qt::UserRole + i + 1] = record().fieldName(i).toAscii();
    #else
        roles[Qt::UserRole + i + 1] = record().fieldName(i).toLatin1();
    #endif
    }
    #if QT_VERSION < 0x050000
    setRoleNames(roles);
    #endif
}

QVariant SqlQueryModel::data(const QModelIndex &index, int role) const {
    QVariant value = QSqlQueryModel::data(index, role);
    if(role < Qt::UserRole) {
        value = QSqlQueryModel::data(index, role);
    } else {
        int columnIdx = role - Qt::UserRole - 1;
        QModelIndex modelIndex = this->index(index.row(), columnIdx);
        value = QSqlQueryModel::data(modelIndex, Qt::DisplayRole);
    }
    return value;
}

//--------------------------------
// DATABASE
// MANAGER
//
// APPENDS DATA TO TEH DATABSE AND DOES OTHER USEFUL STUFF
//--------------------------------

DatabaseManager::DatabaseManager(QObject *parent) :
    QObject(parent)
{
    if ( !QSqlDatabase::contains("Database")) {
        db = QSqlDatabase::addDatabase("QSQLITE","Database");
        db.setDatabaseName("com.tessera.db");
    } else {
        db = QSqlDatabase::database("Database");
        db.setDatabaseName("com.tessera.db");
    }

    if ( !db.isOpen() )
    {
        if (!db.open()) {
            qWarning() << "Unable to connect to database, giving up:" << db.lastError().text();
            databaseOpen = false;
            return;
        }
    }
    databaseOpen = true;

    // set up some pragma parameters to get this thing working faster
    QSqlQuery("PRAGMA journal_mode = OFF",db);
    QSqlQuery("PRAGMA page_size = 16384",db);
    QSqlQuery("PRAGMA cache_size = 163840",db);
    QSqlQuery("PRAGMA temp_store = MEMORY",db);
    QSqlQuery("PRAGMA locking_mode = EXCLUSIVE",db);
    sqlAccounts = new SqlQueryModel( 0 );
}

DatabaseManager::~DatabaseManager() {
}

QSqlError DatabaseManager::lastError()
{
    return db.lastError();
}

bool DatabaseManager::deleteDB()
{
    // Close database
    db.close();

    // Remove created database binary file
    return QFile::remove("com.tessera.db");
}

bool DatabaseManager::initDB()
{
    mkAccTable();

    emit finished();

    return true;
}

bool DatabaseManager::mkAccTable()
{
    bool ret = false;
    if (db.isOpen()) {
        QSqlQuery query(db);
        ret = query.exec("create table accounts "
                         "(id integer primary key, "
                         "service varchar(254), "
                         "name varchar(254), "
                         "secretKey varchar(254));");

    }
    emit finished();
    return ret;
}

bool DatabaseManager::insertAccount(QString service,
                                    QString name,
                                    QString secretKey)
{
    bool ret = false;
    QSqlQuery query(db);
    ret = query.prepare("INSERT INTO accounts (service, name, secretKey) "
                        "VALUES (:service, :name, :secret)");
    if (ret) {
        query.bindValue(":service", service);
        query.bindValue(":name", name);
        query.bindValue(":secret", secretKey);
        ret = query.exec();

    }
    emit finished();
    return ret;
}

bool DatabaseManager::deleteAccount(int id)
{
    bool ret = false;
    QSqlQuery query(db);
    if (databaseOpen)
        ret = query.exec("DELETE FROM accounts WHERE id='" + QString::number(id) + "'");

    emit finished();
    return ret;
}

SqlQueryModel* DatabaseManager::getAccounts()
{
    sqlAccounts->setQuery("select * from accounts", db);
    qDebug() << sqlAccounts->lastError();
    return sqlAccounts;
}
