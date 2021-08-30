/*!
 * This file is part of WatchFlower.
 * COPYRIGHT (C) 2020 Emeric Grange - All Rights Reserved
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * \date      2018
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "SettingsManager.h"
#include "SystrayManager.h"

#include <QCoreApplication>
#include <QSettings>
#include <QLocale>
#include <QDebug>

/* ************************************************************************** */

SettingsManager *SettingsManager::instance = nullptr;

SettingsManager *SettingsManager::getInstance()
{
    if (instance == nullptr)
    {
        instance = new SettingsManager();
    }

    return instance;
}

SettingsManager::SettingsManager()
{
    readSettings();
}

SettingsManager::~SettingsManager()
{
    //
}

/* ************************************************************************** */
/* ************************************************************************** */

bool SettingsManager::readSettings()
{
    bool status = false;

    QSettings settings(QCoreApplication::organizationName(), QCoreApplication::applicationName());

    if (settings.status() == QSettings::NoError)
    {
        if (settings.contains("ApplicationWindow/x"))
            m_appPosition.setWidth(settings.value("ApplicationWindow/x").toInt());
        if (settings.contains("ApplicationWindow/y"))
            m_appPosition.setHeight(settings.value("ApplicationWindow/y").toInt());
        if (settings.contains("ApplicationWindow/width"))
            m_appSize.setWidth(settings.value("ApplicationWindow/width").toInt());
        if (settings.contains("ApplicationWindow/height"))
            m_appSize.setHeight(settings.value("ApplicationWindow/height").toInt());
        if (settings.contains("ApplicationWindow/visibility"))
            m_appVisibility = settings.value("ApplicationWindow/visibility").toUInt();

        if (settings.contains("settings/appTheme"))
            m_appTheme = settings.value("settings/appTheme").toString();

        if (settings.contains("settings/appThemeAuto"))
            m_appThemeAuto = settings.value("settings/appThemeAuto").toBool();

        if (settings.contains("settings/appLanguage"))
            m_appLanguage = settings.value("settings/appLanguage").toString();

        if (settings.contains("settings/bluetoothControl"))
            m_bluetoothControl = settings.value("settings/bluetoothControl").toBool();

        if (settings.contains("settings/bluetoothLimitScanningRange"))
            m_bluetoothLimitScanningRange = settings.value("settings/bluetoothLimitScanningRange").toBool();
        else
        {
#if defined(Q_OS_LINUX) || defined(Q_OS_MACOS) || defined(Q_OS_WINDOWS)
            // these platforms may not be mobile device
            m_bluetoothLimitScanningRange = false;
#else
            m_bluetoothLimitScanningRange = true;
#endif
        }

        if (settings.contains("settings/bluetoothSimUpdates"))
            m_bluetoothSimUpdates = settings.value("settings/bluetoothSimUpdates").toUInt();
        else
        {
#if defined(Q_OS_ANDROID)
            // too many weak devices on Android...
            m_bluetoothSimUpdates = 2;
#elif defined(Q_OS_IOS)
            // iOS is better
            m_bluetoothSimUpdates = 3;
#else
            // desktops are usually good with simultaneous updates
            m_bluetoothSimUpdates = 4;
#endif
        }

        if (settings.contains("settings/startMinimized"))
            m_startMinimized = settings.value("settings/startMinimized").toBool();

        if (settings.contains("settings/trayEnabled"))
            m_systrayEnabled = settings.value("settings/trayEnabled").toBool();

        if (settings.contains("settings/notifsEnabled"))
            m_notificationsEnabled = settings.value("settings/notifsEnabled").toBool();

        if (settings.contains("settings/updateIntervalPlant"))
            m_updateIntervalPlant = settings.value("settings/updateIntervalPlant").toInt();

        if (settings.contains("settings/updateIntervalThermo"))
            m_updateIntervalThermo = settings.value("settings/updateIntervalThermo").toInt();

        if (settings.contains("settings/tempUnit"))
            m_tempUnit = settings.value("settings/tempUnit").toString();
        else
        {
            // If we have no measurement system saved, use system's one
            // TODO: i18n may not have been set yet?
            QLocale lo;
            if (lo.measurementSystem() == QLocale::MetricSystem)
                m_tempUnit = "C";
            else
                m_tempUnit = "F";
        }

        if (settings.contains("settings/graphHistory"))
            m_graphHistogram = settings.value("settings/graphHistory").toString();

        if (settings.contains("settings/graphThermometer"))
            m_graphThermometer = settings.value("settings/graphThermometer").toString();

        if (settings.contains("settings/graphShowDots"))
            m_graphShowDots = settings.value("settings/graphShowDots").toBool();

        if (settings.contains("settings/compactView"))
            m_compactView = settings.value("settings/compactView").toBool();
        else
        {
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined(Q_OS_MACOS)
            // these platforms have HiDPI screens
            m_compactView = true;
#else
            m_compactView = false;
#endif
        }

        if (settings.contains("settings/bigIndicator"))
            m_bigIndicator = settings.value("settings/bigIndicator").toBool();

        if (settings.contains("settings/dynaScale"))
            m_dynaScale = settings.value("settings/dynaScale").toBool();

        if (settings.contains("settings/orderBy"))
            m_orderBy = settings.value("settings/orderBy").toString();

        if (settings.contains("database/enabled"))
            m_externalDb = settings.value("database/enabled").toBool();

        if (settings.contains("database/host"))
            m_externalDbHost = settings.value("database/host").toString();

        if (settings.contains("database/port"))
            m_externalDbPort = settings.value("database/port").toInt();

        if (settings.contains("database/name"))
            m_externalDbName = settings.value("database/name").toString();

        if (settings.contains("database/user"))
            m_externalDbUser = settings.value("database/user").toString();

        if (settings.contains("database/password"))
            m_externalDbPassword = settings.value("database/password").toString();

        status = true;
    }
    else
    {
        qWarning() << "SettingsManager::readSettings() error:" << settings.status();
    }

    return status;
}

/* ************************************************************************** */

bool SettingsManager::writeSettings()
{
    bool status = false;

    QSettings settings(QCoreApplication::organizationName(), QCoreApplication::applicationName());

    if (settings.isWritable())
    {
        settings.setValue("settings/appTheme", m_appTheme);
        settings.setValue("settings/appThemeAuto", m_appThemeAuto);
        settings.setValue("settings/appLanguage", m_appLanguage);
        settings.setValue("settings/bluetoothControl", m_bluetoothControl);
        settings.setValue("settings/bluetoothLimitScanningRange", m_bluetoothLimitScanningRange);
        settings.setValue("settings/bluetoothSimUpdates", m_bluetoothSimUpdates);
        settings.setValue("settings/startMinimized", m_startMinimized);
        settings.setValue("settings/trayEnabled", m_systrayEnabled);
        settings.setValue("settings/notifsEnabled", m_notificationsEnabled);
        settings.setValue("settings/updateIntervalPlant", m_updateIntervalPlant);
        settings.setValue("settings/updateIntervalThermo", m_updateIntervalThermo);
        settings.setValue("settings/graphHistory", m_graphHistogram);
        settings.setValue("settings/graphThermometer", m_graphThermometer);
        settings.setValue("settings/graphShowDots", m_graphShowDots);
        settings.setValue("settings/bigIndicator", m_bigIndicator);
        settings.setValue("settings/compactView", m_compactView);
        settings.setValue("settings/tempUnit", m_tempUnit);
        settings.setValue("settings/dynaScale", m_dynaScale);
        settings.setValue("settings/orderBy", m_orderBy);

        settings.setValue("database/enabled", m_externalDb);
        settings.setValue("database/host", m_externalDbHost);
        settings.setValue("database/port", m_externalDbPort);
        settings.setValue("database/name", m_externalDbName);
        settings.setValue("database/user", m_externalDbUser);
        settings.setValue("database/password", m_externalDbPassword);

        if (settings.status() == QSettings::NoError)
        {
            status = true;
        }
        else
        {
            qWarning() << "SettingsManager::writeSettings() error:" << settings.status();
        }
    }
    else
    {
        qWarning() << "SettingsManager::writeSettings() error: read only file?";
    }

    return status;
}

/* ************************************************************************** */

void SettingsManager::resetSettings()
{
    m_appTheme = "green";
    Q_EMIT appThemeChanged();
    m_appThemeAuto = false;
    Q_EMIT appThemeAutoChanged();
    m_appThemeCSD = false;
    Q_EMIT appThemeCSDChanged();
    m_appUnits = 0;
    Q_EMIT appUnitsChanged();
    m_appLanguage = "auto";
    Q_EMIT appLanguageChanged();

    m_startMinimized = false;
    Q_EMIT minimizedChanged();
    m_systrayEnabled = true;
    Q_EMIT systrayChanged();
    m_notificationsEnabled = true;
    Q_EMIT notifsChanged();
    m_updateIntervalPlant = PLANT_UPDATE_INTERVAL;
    Q_EMIT updateIntervalPlantChanged();
    m_updateIntervalThermo = THERMO_UPDATE_INTERVAL;
    Q_EMIT updateIntervalThermoChanged();

    m_bluetoothControl = false;
    Q_EMIT bluetoothControlChanged();

#if defined(Q_OS_LINUX) || defined(Q_OS_MACOS) || defined(Q_OS_WINDOWS)
    // these platforms may not be mobile device
    m_bluetoothLimitScanningRange = false;
#else
    m_bluetoothLimitScanningRange = true;
#endif
    Q_EMIT bluetoothLimitScanningRangeChanged();
    m_bluetoothSimUpdates = 2;
    Q_EMIT bluetoothSimUpdatesChanged();

    QLocale lo;
    if (lo.measurementSystem() == QLocale::MetricSystem)
        m_tempUnit = "C";
    else
        m_tempUnit = "F";
    Q_EMIT tempUnitChanged();

    m_graphHistogram = "monthly";
    Q_EMIT graphHistogramChanged();
    m_graphThermometer = "minmax";
    Q_EMIT graphThermometerChanged();
    m_graphShowDots = false;
    Q_EMIT graphShowDotsChanged();

#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined(Q_OS_MACOS)
    // these platforms have HiDPI screens
    m_compactView = true;
#else
    m_compactView = false;
#endif
    Q_EMIT compactViewChanged();

    m_bigIndicator = false;
    Q_EMIT bigIndicatorChanged();
    m_dynaScale = false;
    Q_EMIT dynaScaleChanged();
    m_orderBy = "model";
    Q_EMIT orderByChanged();

    m_externalDb = false;
    m_externalDbHost = "";
    m_externalDbPort = 3306;
    m_externalDbName = "watchflower";
    m_externalDbUser = "watchflower";
    m_externalDbPassword = "watchflower";
    Q_EMIT externalDbChanged();
}

/* ************************************************************************** */
/* ************************************************************************** */

void SettingsManager::setSysTray(const bool value)
{
    if (m_systrayEnabled != value)
    {
        bool trayEnable_saved = m_systrayEnabled;
        m_systrayEnabled = value;
        writeSettings();

        SystrayManager *st = SystrayManager::getInstance();
        if (st)
        {
            if (trayEnable_saved == true && m_systrayEnabled == false)
            {
                st->removeSystray();
                Q_EMIT systrayChanged();
            }
            else if (trayEnable_saved == false && m_systrayEnabled == true)
            {
                st->installSystray();
                Q_EMIT systrayChanged();
            }
        }
    }
}

void SettingsManager::setAppTheme(const QString &value)
{
    if (m_appTheme != value)
    {
        m_appTheme = value;
        writeSettings();
        Q_EMIT appThemeChanged();
    }
}

void SettingsManager::setAppThemeAuto(const bool value)
{
    if (m_appThemeAuto != value)
    {
        m_appThemeAuto = value;
        writeSettings();
        Q_EMIT appThemeAutoChanged();
    }
}

void SettingsManager::setAppThemeCSD(const bool value)
{
    if (m_appThemeCSD != value)
    {
        m_appThemeCSD = value;
        writeSettings();
        Q_EMIT appThemeCSDChanged();
    }
}

void SettingsManager::setAppUnits(const unsigned value)
{
    if (m_appUnits != value)
    {
        m_appUnits = value;
        writeSettings();
        Q_EMIT appUnitsChanged();
    }
}

void SettingsManager::setAppLanguage(const QString &value)
{
    if (m_appLanguage != value)
    {
        m_appLanguage = value;
        writeSettings();
        Q_EMIT appLanguageChanged();
    }
}

void SettingsManager::setMinimized(const bool value)
{
    if (m_startMinimized != value)
    {
        m_startMinimized = value;
        writeSettings();
        Q_EMIT minimizedChanged();
    }
}

void SettingsManager::setNotifs(const bool value)
{
    if (m_notificationsEnabled != value)
    {
        m_notificationsEnabled = value;
        writeSettings();
        Q_EMIT notifsChanged();
    }
}

void SettingsManager::setBluetoothControl(const bool value)
{
    if (m_bluetoothControl != value)
    {
        m_bluetoothControl = value;
        writeSettings();
        Q_EMIT bluetoothControlChanged();
    }
}
void SettingsManager::setBluetoothLimitScanningRange(const bool value)
{
    if (m_bluetoothLimitScanningRange != value)
    {
        m_bluetoothLimitScanningRange = value;
        writeSettings();
        Q_EMIT bluetoothLimitScanningRangeChanged();
    }
}

void SettingsManager::setBluetoothSimUpdates(const unsigned value)
{
    if (m_bluetoothSimUpdates != value)
    {
        m_bluetoothSimUpdates = value;
        writeSettings();
        Q_EMIT bluetoothSimUpdatesChanged();
    }
}

void SettingsManager::setUpdateIntervalPlant(const unsigned value)
{
    if (m_updateIntervalPlant != value)
    {
        m_updateIntervalPlant = value;
        writeSettings();
        Q_EMIT updateIntervalPlantChanged();
    }
}

void SettingsManager::setUpdateIntervalThermo(const unsigned value)
{
    if (m_updateIntervalThermo!= value)
    {
        m_updateIntervalThermo = value;
        writeSettings();
        Q_EMIT updateIntervalThermoChanged();
    }
}

void SettingsManager::setTempUnit(const QString &value)
{
    if (m_tempUnit != value)
    {
        m_tempUnit = value;
        writeSettings();
        Q_EMIT tempUnitChanged();
    }
}

void SettingsManager::setGraphHistogram(const QString &value)
{
    if (m_graphHistogram != value)
    {
        m_graphHistogram = value;
        writeSettings();
        Q_EMIT graphHistogramChanged();
    }
}

void SettingsManager::setGraphThermometer(const QString &value)
{
    if (m_graphThermometer != value)
    {
        m_graphThermometer = value;
        writeSettings();
        Q_EMIT graphThermometerChanged();
    }
}

void SettingsManager::setGraphShowDots(const bool value)
{
    if (m_graphShowDots != value)
    {
        m_graphShowDots = value;
        writeSettings();
        Q_EMIT graphShowDotsChanged();
    }
}

void SettingsManager::setCompactView(const bool value)
{
    if (m_compactView != value)
    {
        m_compactView = value;
        writeSettings();
        Q_EMIT compactViewChanged();
    }
}

void SettingsManager::setBigIndicator(const bool value)
{
    if (m_bigIndicator != value)
    {
        m_bigIndicator = value;
        writeSettings();
        Q_EMIT bigIndicatorChanged();
    }
}

void SettingsManager::setDynaScale(const bool value)
{
    if (m_dynaScale != value)
    {
        m_dynaScale = value;
        writeSettings();
        Q_EMIT dynaScaleChanged();
    }
}

void SettingsManager::setOrderBy(const QString &value)
{
    if (m_orderBy != value)
    {
        m_orderBy = value;
        writeSettings();
        Q_EMIT orderByChanged();
    }
}

void SettingsManager::setExternalDb(const bool value)
{
    if (m_externalDb != value)
    {
        m_externalDb = value;
        writeSettings();
        Q_EMIT externalDbChanged();
    }
}

void SettingsManager::setExternalDbHost(const QString &value)
{
    if (m_externalDbHost != value)
    {
        m_externalDbHost = value;
        writeSettings();
        Q_EMIT externalDbChanged();
    }
}

void SettingsManager::setExternalDbPort(const int value)
{
    if (m_externalDbPort != value)
    {
        m_externalDbPort = value;
        writeSettings();
        Q_EMIT externalDbChanged();
    }
}

void SettingsManager::setExternalDbUser(const QString &value)
{
    if (m_externalDbUser != value)
    {
        m_externalDbUser = value;
        writeSettings();
        Q_EMIT externalDbChanged();
    }
}

void SettingsManager::setExternalDbPassword(const QString &value)
{
    if (m_externalDbPassword != value)
    {
        m_externalDbPassword = value;
        writeSettings();
        Q_EMIT externalDbChanged();
    }
}

/* ************************************************************************** */
