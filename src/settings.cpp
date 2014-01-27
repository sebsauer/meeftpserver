/*
    Copyright (C) 2012-2014 Sebastian Sauer <dipesh@gmx.de>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301, USA.
*/

#include "settings.h"

#include <QFileInfo>
#include <QDir>
#include <QTime>
#include <QStandardPaths>
#include <QDebug>

Settings::Settings(QObject *parent)
    : QObject(parent)
    , m_modified(false)
{
    QSettings settings("org.dipe.meeftpserver");
    //settings.beginGroup("Settings");
    readGroup(settings, m_settings);
    //settings.endGroup();
}

Settings::~Settings()
{
    saveChanges();
}

Settings* Settings::instance()
{
    static Settings *settings = 0;
    if (!settings)
        settings = new Settings();
    return settings;
}

QString Settings::homeDir() const
{
    return QDir::homePath();
}

QString Settings::configDir() const
{
    QString dir = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation);
#if 0
    if (dir.isEmpty())
        dir = QStandardPaths::writableLocation(QStandardPaths::GenericConfigLocation);
#endif
    return dir;
}

QString Settings::joinFile(const QString &dir, const QString &file) const
{
    return QFileInfo(dir, file).absoluteFilePath();
}

QString Settings::joinPath(const QStringList &path) const
{
    QString r;
    if (!path.isEmpty())
        r = QFileInfo(path.join(QDir::separator())).absoluteFilePath();
    return r;
}

QStringList Settings::splitPath(const QString &path) const
{
    QFileInfo fi(path);
    return QStringList() << fi.absolutePath() << fi.fileName();
}

bool Settings::fileExists(const QString &file) const
{
    QFileInfo fi(file);
    return fi.isFile() && fi.exists();
}

bool Settings::dirExists(const QString &dir) const
{
    QDir d(dir);
    return d.exists();
}

QString Settings::expandPath(const QString &path) const
{
    QString p = path;
    if (p.startsWith("~") || p.startsWith("$HOME")) {
        QDir d(QDir::home());
        if (d.exists()) {
            p = p.startsWith("~") ? p.mid(1) : p.mid(5);
            if (p.startsWith(QDir::separator()))
                p = p.mid(1);
            p = d.absolutePath() + p;
        }
    }
    return p;
}

QString Settings::randomPassword(int length)
{
    QString r;
    QTime time = QTime::currentTime();
    qsrand((uint)time.msec());
    int min = 48;
    int max = 126;
    for (int i = 0; i < length; ++i)
        r += QChar((qrand() % (max - min) + 1) + min);
    return r;
}

QVariantMap Settings::values() const
{
    return m_settings;
}

void Settings::setValues(const QVariantMap& values)
{
    m_modified = true;
    m_settings = values;
    emit valueChanged(QString());
}

bool Settings::hasValue(const QString &name) const
{
    return m_settings.contains(name);
}

QVariant Settings::value(const QString &name, const QVariant &defaultValue) const
{
    QVariantMap::ConstIterator it = m_settings.constFind(name);
    if (it == m_settings.constEnd())
        return defaultValue;
    QVariant v = it.value();
    if (defaultValue.isValid()) {
        switch (defaultValue.type()) {
            case QVariant::Bool:
                v = v.toBool();
                break;
            case QVariant::Int:
                v = v.toInt();
                break;
            default:
                break;
        }
    }
    return v;
}

void Settings::setValue(const QString &name, const QVariant &value)
{
    QVariantMap::Iterator it = m_settings.find(name);
    if (value.isNull() && it == m_settings.end())
        return;
    if (it != m_settings.end() && value == it.value())
        return;
    m_modified = true;
    if (value.isNull())
        m_settings.erase(it);
    else
        m_settings[name] = value;
    emit valueChanged(name);
}

QVariantList Settings::valueList(const QString &name) const
{
    QVariant v = value(name);
    if (!v.isValid())
        return QVariantList();
    return v.toList();
}

void Settings::setValueList(const QString &name, const QVariantList &value)
{
    setValue(name, value);
}

QVariantMap Settings::valueMap(const QString &name) const
{
    QVariant v = value(name);
    if (!v.isValid())
        return QVariantMap();
    return v.toMap();
}

void Settings::setValueMap(const QString &name, const QVariantMap &value)
{
    setValue(name, value);
}

void Settings::saveChanges()
{
    if (m_modified) {
        m_modified = false;
        qDebug() << "Saving settings now cause they got modified";

        QSettings settings("org.dipe.meeftpserver");
        settings.clear();
        //settings.beginGroup("Settings");
        writeGroup(settings, m_settings);
        //settings.endGroup();
        settings.sync();
    }
}

void Settings::readGroup(QSettings &settings, QVariantMap &map)
{
    Q_FOREACH(const QString &key, settings.childKeys()) {
        QVariant v = settings.value(key);
        if (v.isNull())
            continue;
        map[key] = v;
    }
    Q_FOREACH(const QString &group, settings.childGroups()) {
        settings.beginGroup(group);
        QVariantMap groupMap;
        readGroup(settings, groupMap);
        if (!groupMap.isEmpty()) {
            map[group] = groupMap;
        }
        settings.endGroup();
    }
}

void Settings::writeGroup(QSettings &settings, QVariantMap &map)
{
    QStringList maps;
    for(QVariantMap::ConstIterator it = map.constBegin(); it != map.constEnd(); ++it) {
        QVariant v = it.value();
        if (it.value().type() == QVariant::Map) {
            maps.append(it.key());
        } else {
            settings.setValue(it.key(), it.value());
        }
    }
    Q_FOREACH(const QString &key, maps) {
        QVariantMap m = map[key].toMap();
        if (m.isEmpty())
            continue;
        settings.beginGroup(key);
        writeGroup(settings, m);
        settings.endGroup();
    }
}
