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

#include <QtQuick>

#include <sailfishapp.h>

#include "process.h"
#include "settings.h"
#include "network.h"

#include <QDebug>

static QObject* settings_singletontype_provider(QQmlEngine*, QJSEngine*)
{
    return Settings::instance();
}

static QObject* network_singletontype_provider(QQmlEngine*, QJSEngine*)
{
    return Network::instance();
}

int main(int argc, char *argv[])
{
    qmlRegisterType<Process>("Process", 1,0, "Process");
    qmlRegisterSingletonType<Settings>("Settings", 1,0, "Settings", settings_singletontype_provider);
    qmlRegisterSingletonType<Network>("Network", 1,0, "Network", network_singletontype_provider);

    int result = SailfishApp::main(argc, argv);

    Settings::instance()->saveChanges();

    return result;
}
