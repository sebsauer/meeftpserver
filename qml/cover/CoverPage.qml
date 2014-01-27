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

CoverBackground {
    id: cover

    property string serverState: 'stopped'

    signal startTriggered
    signal stopTriggered

    Column {
        anchors.centerIn: parent
        Label {
            id: captionLabel
            anchors.horizontalCenter: parent.horizontalCenter
            //font.pixelSize: Theme.fontSizeMedium
            color: Theme.highlightColor
            text: qsTr("FTP Server")
        }
        Label {
            id: statusLabel
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: Theme.fontSizeSmall
            font.italic: true
            text: cover.serverState === "stopped" ? qsTr("Stopped") : qsTr("Running")
        }
    }

    CoverActionList {
        id: coverAction
        CoverAction {
            id: startAction
            iconSource: cover.serverState === "stopped" ? "image://theme/icon-cover-play" : "image://theme/icon-cover-pause"
            onTriggered: {
                if (cover.serverState === "stopped") {
                    cover.startTriggered()
                } else {
                    cover.stopTriggered()
                }
            }
        }
    }
}


