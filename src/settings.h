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

#ifndef SETTINGS_H
#define SETTINGS_H

#include <QObject>
#include <QVariant>
#include <QStringList>
#include <QSettings>

class Settings : public QObject
{
    Q_OBJECT
private:
    explicit Settings(QObject *parent = 0);
public:
    virtual ~Settings();

    static Settings* instance();

signals:
    void valueChanged(const QString &name);

public slots:
    QString homeDir() const;
    QString configDir() const;
    QString joinFile(const QString &dir, const QString &file) const;
    QString joinPath(const QStringList &path) const;
    QStringList splitPath(const QString &path) const;
    bool fileExists(const QString &file) const;
    bool dirExists(const QString &dir) const;
    QString expandPath(const QString &path) const;
    QString randomPassword(int length = 8);

    QVariantMap values() const;
    void setValues(const QVariantMap& values);

    bool hasValue(const QString &name) const;
    QVariant value(const QString &name, const QVariant &defaultValue = QVariant()) const;
    void setValue(const QString &name, const QVariant &value);

    QVariantList valueList(const QString &name) const;
    void setValueList(const QString &name, const QVariantList &value);

    QVariantMap valueMap(const QString &name) const;
    void setValueMap(const QString &name, const QVariantMap &value);

    void saveChanges();

private:
    QVariantMap m_settings;
    bool m_modified;
    mutable QString m_imageDirectory;

    void readGroup(QSettings &settings, QVariantMap &map);
    void writeGroup(QSettings &settings, QVariantMap &map);
};


#endif // SETTINGS_H
