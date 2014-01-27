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

import QtQuick 2.0
import Sailfish.Silica 1.0
import "cover"
import "pages"

ApplicationWindow
{
    id: appRootWindow

    MainPage {
        id: _mainpage
        onServerStateChanged: {
            _coverpage.serverState = _mainpage.serverState()
        }
    }

    CoverPage {
        id: _coverpage
        onStartTriggered: {
            _mainpage.startServer()
        }
        onStopTriggered: {
            _mainpage.stopServer()
        }
    }

    initialPage: _mainpage
    cover: _coverpage
}
