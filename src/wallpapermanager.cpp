#include "wallpapermanager.h"
#include <QProcess>
#include <QDir>
#include <QStandardPaths>

WallpaperManager::WallpaperManager(QObject *parent) : QObject(parent) {
    // Try to read current wallpaper from swww or config file
    QProcess p;
    p.start("bash", {"-c", "cat ~/.config/swww/current 2>/dev/null || echo ''"});
    p.waitForFinished(500);
    m_currentWallpaper = p.readAllStandardOutput().trimmed();
    scanWallpapers();
}

QString WallpaperManager::currentWallpaper() const { return m_currentWallpaper; }
void WallpaperManager::setCurrentWallpaper(const QString &path) {
    if (m_currentWallpaper == path) return;
    m_currentWallpaper = path;
    // Apply with swww
    QProcess::startDetached("bash", {"-c",
        QString("swww img '%1' --transition-type wipe --transition-duration 1 2>/dev/null; "
                "mkdir -p ~/.config/swww && echo '%1' > ~/.config/swww/current").arg(path)});
    emit currentWallpaperChanged();
}

QStringList WallpaperManager::wallpaperList() const { return m_wallpaperList; }

void WallpaperManager::scanWallpapers() {
    m_wallpaperList.clear();
    QStringList searchDirs = {
        "/usr/share/backgrounds/archtitan",
        "/usr/share/wallpapers",
        QDir::homePath() + "/Pictures/Wallpapers",
        QDir::homePath() + "/Pictures"
    };

    QStringList exts = {"*.jpg","*.jpeg","*.png","*.webp"};
    for (const QString &dir : searchDirs) {
        QDir d(dir);
        if (!d.exists()) continue;
        for (const QString &f : d.entryList(exts, QDir::Files))
            m_wallpaperList.append(d.absoluteFilePath(f));
    }
    emit wallpaperListChanged();
}

void WallpaperManager::openFilePicker() {
    // This must be called from a non-GUI thread via QFileDialog signal
    // Since QML can invoke this, we use QProcess to open a portal
    QProcess p;
    p.start("bash", {"-c", "zenity --file-selection --file-filter='Images | *.png *.jpg *.jpeg *.webp' 2>/dev/null"});
    p.waitForFinished(30000);
    QString chosen = p.readAllStandardOutput().trimmed();
    if (!chosen.isEmpty()) setCurrentWallpaper(chosen);
}
