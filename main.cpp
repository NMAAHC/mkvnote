#include <QApplication>
#include <QMessageBox>
#include <QFileInfo>
#include <QFileDialog>
#include <QDir>
#include "mainwindow.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    app.setApplicationName("mkvnote");
    app.setApplicationVersion("1.0.0");
    app.setOrganizationName("NMAAHC");

    #if defined(Q_OS_MAC)
    QDir binDir("/usr/local/lib/mkvnote/bin");
    if (binDir.exists()) {
        qputenv("PATH", (binDir.absolutePath() + ":" + qgetenv("PATH")).toLocal8Bit());
    }
    #elif defined(Q_OS_LINUX)
    QDir binDir = QCoreApplication::applicationDirPath() + "/../libexec/mkvnote/bin";
    if (binDir.exists()) {
        qputenv("PATH", (binDir.absolutePath() + ":" + qgetenv("PATH")).toLocal8Bit());
    }
    #endif

    QString inputFile;
    if (argc >= 2) {
        inputFile = QString::fromLocal8Bit(argv[1]);
        QFileInfo fi(inputFile);
        if (!fi.exists() || !fi.isFile()) {
            QMessageBox::critical(nullptr, "mkvnote",
                QString("File not found: %1").arg(inputFile));
            return 1;
        }
    }

    MainWindow w(inputFile);
    w.show();
    return app.exec();
}
