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

Page {
    id: logPage

    property variant log: outputEdit

    Flickable {
        anchors { fill: parent; }
        clip: true
        height: parent.height
        contentHeight: Math.max(logPage.height, outputEdit.implicitHeight)
        TextArea {
            id: outputEdit
            //anchors { fill: parent; margins: 0; }
            width: parent.width
            height: Math.max(implicitHeight, parent.height)
            textMargin: 0
            readOnly: true
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            font.pixelSize: Theme.fontSizeExtraSmall
            text: ""
        }
        onContentHeightChanged: {
            contentX = 0
            if (outputEdit.implicitHeight > height) {
                // When a new log-message was added, and hence the
                // contentHeight changed, then adjust the offset
                // to be sure the new log-message is proper visible.
                contentY = outputEdit.implicitHeight - height

                // Prevent infinite growing outputEdit by only appending
                // new log-messages all of the time by removing the oldest
                // messages once the log reaches a certain length.
                if (outputEdit.implicitHeight > height*10) {
                    var pos = outputEdit.positionAt(0, height*5)
                    if (pos < 0 || pos >= outputEdit.text.length) {
                        // fallback just in case of a situation that
                        // should never have happened.
                        pos = outputEdit.text.length / 2
                    }
                    outputEdit.text = outputEdit.text.substring(pos)
                }
            } else {
                contentY = 0
            }
        }
    }
}
