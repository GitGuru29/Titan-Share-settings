#pragma once
#include <QObject>
#include <QStringList>

class WallpaperManager : public QObject {
    Q_OBJECT

    Q_PROPERTY(QString currentWallpaper READ currentWallpaper WRITE setCurrentWallpaper NOTIFY currentWallpaperChanged)
    Q_PROPERTY(QStringList wallpaperList READ wallpaperList NOTIFY wallpaperListChanged)

public:
    explicit WallpaperManager(QObject *parent = nullptr);

    QString currentWallpaper() const;
    void setCurrentWallpaper(const QString &path);
    QStringList wallpaperList() const;

    Q_INVOKABLE void scanWallpapers();
    Q_INVOKABLE void openFilePicker();

signals:
    void currentWallpaperChanged();
    void wallpaperListChanged();

private:
    QString m_currentWallpaper;
    QStringList m_wallpaperList;
};
