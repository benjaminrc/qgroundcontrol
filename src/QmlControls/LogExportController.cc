/****************************************************************************
 *
 * (c) 2009-2026 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#include "LogExportController.h"
#include "AppSettings.h"
#include "QGCApplication.h"
#include "SettingsManager.h"

#include <QtCore/QDir>
#include <QtCore/QFileInfo>
#include <QtCore/QLocale>
#include <QtCore/QUrl>
#include <QtGui/QDesktopServices>

#ifdef Q_OS_ANDROID
#include <QtCore/QJniObject>
#endif

LogExportController::LogExportController(QObject *parent)
    : QObject(parent)
{
    refresh();
}

QString LogExportController::telemetryDir() const
{
    return SettingsManager::instance()->appSettings()->telemetrySavePath();
}

void LogExportController::refresh()
{
    _logFiles.clear();

    const QString dirPath = telemetryDir();
    if (!dirPath.isEmpty()) {
        QDir dir(dirPath);
        const QString filter = QStringLiteral("*.%1").arg(AppSettings::telemetryFileExtension);
        const QFileInfoList fileInfoList = dir.entryInfoList(QStringList(filter), QDir::Files, QDir::Time);
        for (const QFileInfo &fileInfo : fileInfoList) {
            _logFiles.append(fileInfo.fileName());
            if (_logFiles.count() >= kMaxListedLogs) {
                break;
            }
        }
    }

    emit logFilesChanged();
}

QString LogExportController::logSizeText(const QString &fileName) const
{
    const QFileInfo fileInfo(QDir(telemetryDir()), fileName);
    return QLocale().formattedDataSize(fileInfo.size(), 1, QLocale::DataSizeSIFormat);
}

bool LogExportController::shareLog(const QString &fileName)
{
    const QString dirPath = telemetryDir();
    if (dirPath.isEmpty()) {
        return false;
    }

#ifdef Q_OS_ANDROID
    const QString filePath = QDir(dirPath).absoluteFilePath(fileName);
    if (!QFileInfo::exists(filePath)) {
        qgcApp()->showAppMessage(tr("Log file no longer exists: %1").arg(fileName));
        return false;
    }
    const jboolean ok = QJniObject::callStaticMethod<jboolean>(
        "org/mavlink/qgroundcontrol/QGCActivity",
        "shareFile",
        "(Ljava/lang/String;Ljava/lang/String;)Z",
        QJniObject::fromString(filePath).object<jstring>(),
        QJniObject::fromString(tr("Share flight log")).object<jstring>());
    if (!ok) {
        qgcApp()->showAppMessage(tr("Unable to share log file: %1").arg(fileName));
    }
    return ok;
#else
    Q_UNUSED(fileName);
    // Desktop builds: the folder is freely accessible, so just open it
    return QDesktopServices::openUrl(QUrl::fromLocalFile(dirPath));
#endif
}
