#ifndef QAVKONHELPER_H
#define QAVKONHELPER_H

#include <QObject>
#include <QApplication>
#include <QClipboard>

class ClipboardAdapter : public QObject
{
    Q_OBJECT
public:
    explicit ClipboardAdapter(QObject *parent = 0) : QObject(parent) {
        clipboard = QApplication::clipboard();
    }

    Q_INVOKABLE void setText(QString text){
        clipboard->setText(text, QClipboard::Clipboard);
        clipboard->setText(text, QClipboard::Selection);
    }

private:
    QClipboard *clipboard;
};

#endif // QAVKONHELPER_H
