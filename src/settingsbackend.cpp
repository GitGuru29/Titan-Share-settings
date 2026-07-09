#include "settingsbackend.h"
#include <QProcess>
#include <QDebug>

SettingsBackend::SettingsBackend(QObject *parent)
    : QObject(parent)
    , m_settings(QStringLiteral("ArchTitan"), QStringLiteral("archtitan-settings"))
{
    loadSettings();
}

void SettingsBackend::loadSettings() {
    m_colorTheme   = m_settings.value("appearance/colorTheme",   "Dark").toString();
    m_accentColor  = m_settings.value("appearance/accentColor",  "#7AA2F7").toString();
    m_glassmorphism= m_settings.value("appearance/glassmorphism", true).toBool();
    m_panelOpacity = m_settings.value("appearance/panelOpacity",  0.88).toDouble();
    m_iconTheme    = m_settings.value("appearance/iconTheme",    "Papirus-Dark").toString();
    m_fontFamily   = m_settings.value("appearance/fontFamily",   "Inter").toString();
    m_fontSize     = m_settings.value("appearance/fontSize",     13).toInt();

    m_screenTimeout  = m_settings.value("power/screenTimeout",  300).toInt();
    m_suspendTimeout = m_settings.value("power/suspendTimeout", 600).toInt();
    m_powerProfile   = m_settings.value("power/profile",        "Balanced").toString();

    m_autolockEnabled = m_settings.value("security/autolockEnabled", true).toBool();
    m_autolockDelay   = m_settings.value("security/autolockDelay",   300).toInt();
}

void SettingsBackend::applyAndSave() {
    m_settings.setValue("appearance/colorTheme",   m_colorTheme);
    m_settings.setValue("appearance/accentColor",  m_accentColor);
    m_settings.setValue("appearance/glassmorphism",m_glassmorphism);
    m_settings.setValue("appearance/panelOpacity", m_panelOpacity);
    m_settings.setValue("appearance/iconTheme",    m_iconTheme);
    m_settings.setValue("appearance/fontFamily",   m_fontFamily);
    m_settings.setValue("appearance/fontSize",     m_fontSize);
    m_settings.setValue("power/screenTimeout",     m_screenTimeout);
    m_settings.setValue("power/suspendTimeout",    m_suspendTimeout);
    m_settings.setValue("power/profile",           m_powerProfile);
    m_settings.setValue("security/autolockEnabled",m_autolockEnabled);
    m_settings.setValue("security/autolockDelay",  m_autolockDelay);
    m_settings.sync();

    // Apply power profile via powerprofilesctl if available
    if (m_powerProfile != "Custom") {
        QString prof = m_powerProfile.toLower().replace(" ", "-");
        QProcess::startDetached("powerprofilesctl", {"set", prof});
    }

    emit settingsSaved();
}

void SettingsBackend::resetToDefaults() {
    m_settings.clear();
    loadSettings();
    emit colorThemeChanged();
    emit accentColorChanged();
    emit glassmorphismChanged();
    emit panelOpacityChanged();
    emit iconThemeChanged();
    emit fontFamilyChanged();
    emit fontSizeChanged();
    emit screenTimeoutChanged();
    emit suspendTimeoutChanged();
    emit powerProfileChanged();
    emit autolockEnabledChanged();
    emit autolockDelayChanged();
}

// ── Getters / Setters ──────────────────────────────────────────────────────

QString SettingsBackend::colorTheme() const { return m_colorTheme; }
void SettingsBackend::setColorTheme(const QString &v) {
    if (m_colorTheme == v) return;
    m_colorTheme = v;
    emit colorThemeChanged();
}

QString SettingsBackend::accentColor() const { return m_accentColor; }
void SettingsBackend::setAccentColor(const QString &v) {
    if (m_accentColor == v) return;
    m_accentColor = v;
    emit accentColorChanged();
}

bool SettingsBackend::glassmorphism() const { return m_glassmorphism; }
void SettingsBackend::setGlassmorphism(bool v) {
    if (m_glassmorphism == v) return;
    m_glassmorphism = v;
    emit glassmorphismChanged();
}

double SettingsBackend::panelOpacity() const { return m_panelOpacity; }
void SettingsBackend::setPanelOpacity(double v) {
    if (qFuzzyCompare(m_panelOpacity, v)) return;
    m_panelOpacity = v;
    emit panelOpacityChanged();
}

QString SettingsBackend::iconTheme() const { return m_iconTheme; }
void SettingsBackend::setIconTheme(const QString &v) {
    if (m_iconTheme == v) return;
    m_iconTheme = v;
    emit iconThemeChanged();
}

QString SettingsBackend::fontFamily() const { return m_fontFamily; }
void SettingsBackend::setFontFamily(const QString &v) {
    if (m_fontFamily == v) return;
    m_fontFamily = v;
    emit fontFamilyChanged();
}

int SettingsBackend::fontSize() const { return m_fontSize; }
void SettingsBackend::setFontSize(int v) {
    if (m_fontSize == v) return;
    m_fontSize = v;
    emit fontSizeChanged();
}

int SettingsBackend::screenTimeout() const { return m_screenTimeout; }
void SettingsBackend::setScreenTimeout(int v) {
    if (m_screenTimeout == v) return;
    m_screenTimeout = v;
    emit screenTimeoutChanged();
}

int SettingsBackend::suspendTimeout() const { return m_suspendTimeout; }
void SettingsBackend::setSuspendTimeout(int v) {
    if (m_suspendTimeout == v) return;
    m_suspendTimeout = v;
    emit suspendTimeoutChanged();
}

QString SettingsBackend::powerProfile() const { return m_powerProfile; }
void SettingsBackend::setPowerProfile(const QString &v) {
    if (m_powerProfile == v) return;
    m_powerProfile = v;
    emit powerProfileChanged();
}

bool SettingsBackend::autolockEnabled() const { return m_autolockEnabled; }
void SettingsBackend::setAutolockEnabled(bool v) {
    if (m_autolockEnabled == v) return;
    m_autolockEnabled = v;
    emit autolockEnabledChanged();
}

int SettingsBackend::autolockDelay() const { return m_autolockDelay; }
void SettingsBackend::setAutolockDelay(int v) {
    if (m_autolockDelay == v) return;
    m_autolockDelay = v;
    emit autolockDelayChanged();
}
