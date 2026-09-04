/****************************************************************************
 *
 * (c) 2009-2026 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#pragma once

#include <QtCore/QObject>
#include <QtCore/QStringList>

/// Custom build: lists saved telemetry logs and exports them off the device.
/// On Android the logs live in app-scoped storage which no other app can
/// browse, so exporting goes through the system share sheet (Google Drive,
/// email, etc.) via the FileProvider already declared in the manifest.
/// On desktop builds "share" simply reveals the telemetry folder.
class LogExportController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList logFiles     READ logFiles       NOTIFY logFilesChanged)
    Q_PROPERTY(QString     telemetryDir READ telemetryDir   CONSTANT)

public:
    explicit LogExportController(QObject *parent = nullptr);

    QStringList logFiles() const { return _logFiles; }
    QString telemetryDir() const;

    Q_INVOKABLE void refresh();
    Q_INVOKABLE QString logSizeText(const QString &fileName) const;

    /// Android: opens the share sheet for the log file. Desktop: opens the folder.
    Q_INVOKABLE bool shareLog(const QString &fileName);

signals:
    void logFilesChanged();

private:
    QStringList _logFiles;

    static constexpr int kMaxListedLogs = 30;
};
