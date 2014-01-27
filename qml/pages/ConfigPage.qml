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

import Settings 1.0

Page {
    id: configPage

    signal createCertClicked

    property alias certFile: tlsCertFileEdit.text
    property alias keyFile: tlsKeyFileEdit.text

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        //contentHeight: Math.max(page.height - anchors.margins*2, column.height)
        contentHeight: column.height
        //contentWidth: Math.max(page.width - anchors.margins*2, column.width)
        clip: true

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingMedium

            property int labelColumnWidth: Math.max(addressLabel.contentWidth,
                                                    portLabel.contentWidth,
                                                    rootDirLabel.contentWidth,
                                                    tlsCertFileLabel.contentWidth,
                                                    tlsKeyFileLabel.contentWidth,
                                                    usernameLabel.contentWidth,
                                                    userpassLabel.contentWidth)

            Separator { width: parent.width; color: Theme.secondaryColor; }

            Label {
                id: addressDescriptionLabel
                width: parent.width
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
                text: qsTr("The address the FTP Server listens on for incoming connections. An address of 0.0.0.0 means listen to all addresses (default). 127.0.0.1 means accept FTP client connections from localhost only.")
            }

            Row {
                id: addressRow
                spacing: Theme.paddingSmall
                Label {
                    id: addressLabel
                    width: column.labelColumnWidth
                    anchors.verticalCenter: addressEdit.top
                    anchors.verticalCenterOffset: addressEdit.textVerticalCenterOffset
                    horizontalAlignment: Text.AlignRight
                    text: qsTr("Address:")
                }
                TextField {
                    id: addressEdit
                    inputMethodHints: Qt.ImhNoPredictiveText
                }
            }

            Separator { width: parent.width; color: Theme.secondaryColor; }

            Label {
                id: portDescriptionLabel
                width: parent.width
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
                text: qsTr("The port the FTP Server listens on for incoming connections. The port should be equal or bigger as 1024.")
            }

            Row {
                id: portRow
                spacing: Theme.paddingSmall
                Label {
                    id: portLabel
                    width: column.labelColumnWidth
                    anchors.verticalCenter: portEdit.top
                    anchors.verticalCenterOffset: portEdit.textVerticalCenterOffset
                    horizontalAlignment: Text.AlignRight
                    text: qsTr("Port:")
                }
                TextField {
                    id: portEdit
                    inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhDigitsOnly
                    validator: IntValidator { bottom: 0; top: 32767 }
                }
            }

            Separator { width: parent.width; color: Theme.secondaryColor; }

            Label {
                id: onlineDescriptionLabel
                width: parent.width
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
                text: qsTr("When the FTP-server is started the application tries to go online and keeps the online-connection open and alive as long as the FTP-server is running.")
            }

            TextSwitch {
                id: onlineCheckbox
                width: parent.width
                text: qsTr("Stay online while running")
                checked: false
            }

            Separator { width: parent.width; color: Theme.secondaryColor; }

            Label {
                id: tlsDescriptionLabel
                width: parent.width
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
                text: qsTr("SFTP allows a secure FTP connection between FTP-server and FTP-client. The server and client will use a TLS/SSLv3 encrypted connection.")
            }

            TextSwitch {
                id: tlsCheckbox
                width: parent.width
                text: qsTr("Enable SFTP")
                checked: false
            }

            Label {
                id: tlsFileDescriptionLabel
                width: parent.width
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
                text: qsTr("A TLS/SSLv3 encrypted connection needs a PEM certification file to encrypt the connection with. This also needs the private key either embedded in the Cert File or as extra Key File.")
                visible: tlsCheckbox.checked
            }

            Row {
                id: tlsCertFileRow
                spacing: Theme.paddingSmall
                visible: tlsCheckbox.checked
                Label {
                    id: tlsCertFileLabel
                    width: column.labelColumnWidth
                    anchors.verticalCenter: tlsCertFileEdit.top
                    anchors.verticalCenterOffset: tlsCertFileEdit.textVerticalCenterOffset
                    horizontalAlignment: Text.AlignRight
                    text: qsTr("Cert File:")
                }
                TextField {
                    id: tlsCertFileEdit
                    inputMethodHints: Qt.ImhNoPredictiveText
                }
            }

            Row {
                id: tlsKeyFileRow
                spacing: Theme.paddingSmall
                visible: tlsCheckbox.checked
                Label {
                    id: tlsKeyFileLabel
                    width: column.labelColumnWidth
                    anchors.verticalCenter: tlsKeyFileEdit.top
                    anchors.verticalCenterOffset: tlsKeyFileEdit.textVerticalCenterOffset
                    horizontalAlignment: Text.AlignRight
                    text: qsTr("Key File:")
                }
                TextField {
                    id: tlsKeyFileEdit
                    inputMethodHints: Qt.ImhNoPredictiveText
                }
            }

            Button {
                anchors.right: parent.right
                text: qsTr("Create Certificate")
                visible: tlsCheckbox.checked
                onClicked: {
                    createCertClicked()
                }
            }

            TextSwitch {
                id: tlsControlCheckbox
                width: parent.width
                text: qsTr("Encrypt control channel")
                visible: tlsCheckbox.checked
                checked: false
            }
            TextSwitch {
                id: tlsDataCheckbox
                width: parent.width
                text: qsTr("Encrypt data channel")
                visible: tlsCheckbox.checked
                checked: false
            }

            Separator { width: parent.width; color: Theme.secondaryColor; }

            Label {
                id: rootDirDescriptionLabel
                width: parent.width
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
                text: qsTr("The root directory that will be accessible by FTP clients. This includes all sub directories. Directories above this directory are not accessible.")
            }

            Row {
                id: rootDirRow
                spacing: Theme.paddingSmall
                Label {
                    id: rootDirLabel
                    width: column.labelColumnWidth
                    anchors.verticalCenter: rootDirEdit.top
                    anchors.verticalCenterOffset: rootDirEdit.textVerticalCenterOffset
                    horizontalAlignment: Text.AlignRight
                    text: qsTr("Directory:")
                }
                TextField {
                    id: rootDirEdit
                    inputMethodHints: Qt.ImhNoPredictiveText
                }
            }

            Separator { width: parent.width; color: Theme.secondaryColor; }

            Label {
                id: anonymousDescriptionLabel
                width: parent.width
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
                text: qsTr("Allow anybody to connect without name and password. The anonymous FTP client has ready-only access.")
            }

            TextSwitch {
                id: anonymousCheckbox
                width: parent.width
                text: qsTr("Allow read-only anonymous login")
                checked: false
            }

            Separator { width: parent.width; color: Theme.secondaryColor; }

            Label {
                id: loginDescriptionLabel
                width: parent.width
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
                text: qsTr("The login credentials needed by the FTP client to successfully login into our FTP server. The user has full read and write access.")
            }

            Row {
                id: usernameRow
                spacing: Theme.paddingSmall
                Label {
                    id: usernameLabel
                    width: column.labelColumnWidth
                    anchors.verticalCenter: usernameEdit.top
                    anchors.verticalCenterOffset: usernameEdit.textVerticalCenterOffset
                    horizontalAlignment: Text.AlignRight
                    text: qsTr("Name:")
                }
                TextField {
                    id: usernameEdit
                    inputMethodHints: Qt.ImhNoPredictiveText
                }
            }

            Row {
                id: userpassRow
                spacing: Theme.paddingSmall
                Label {
                    id: userpassLabel
                    width: column.labelColumnWidth
                    anchors.verticalCenter: userpassEdit.top
                    anchors.verticalCenterOffset: userpassEdit.textVerticalCenterOffset
                    horizontalAlignment: Text.AlignRight
                    text: qsTr("Password:")
                }
                TextField {
                    id: userpassEdit
                    inputMethodHints: Qt.ImhNoPredictiveText
                    //echoMode: TextInput.PasswordEchoOnEdit
                }
            }


        }
    }

    Component.onCompleted: {
        if (!Settings.hasValue("serverAddress")) {
            // Nothing saved yet so set some sane default values.

            Settings.setValue("serverAddress", "0.0.0.0")
            Settings.setValue("serverPort", 2121)
            Settings.setValue("serverRootDir", "~/")
            Settings.setValue("serverUsername", "user")
            Settings.setValue("serverUserpass", Settings.randomPassword(6))
            Settings.setValue("serverAllowAnonymous", false)
            Settings.setValue("autoOnline", false)

            Settings.setValue("serverTlsEnabled", false)
            Settings.setValue("serverTlsCertFile", "") // e.g. '/etc/ssl/certs/sailfish-ca.pem'
            Settings.setValue("serverTlsKeyFile", "")
            Settings.setValue("tlsControlChannel", true)
            Settings.setValue("tlsDataChannel", false)

            // Save those default values asap.
            Settings.saveChanges()
        }

        // Set the edit-fields to the saved settings.
        addressEdit.text = Settings.value("serverAddress")
        portEdit.text = Settings.value("serverPort", 2121)
        rootDirEdit.text = Settings.value("serverRootDir")
        usernameEdit.text = Settings.value("serverUsername")
        userpassEdit.text = Settings.value("serverUserpass")
        anonymousCheckbox.checked = Settings.value("serverAllowAnonymous", false)
        onlineCheckbox.checked = Settings.value("autoOnline", false)
        tlsCheckbox.checked = Settings.value("serverTlsEnabled", false)
        tlsCertFileEdit.text = Settings.value("serverTlsCertFile")
        tlsKeyFileEdit.text = Settings.value("serverTlsKeyFile")
        tlsControlCheckbox.checked = Settings.value("tlsControlChannel", false)
        tlsDataCheckbox.checked = Settings.value("tlsDataChannel", false)

        // Connect the changed-signals from the edit-fields to
        // save modifications to the settings back.
        addressEdit.onTextChanged.connect(function () {
            Settings.setValue("serverAddress", addressEdit.text)
        })
        portEdit.onTextChanged.connect(function () {
            Settings.setValue("serverPort", portEdit.text)
        })
        tlsCheckbox.onCheckedChanged.connect(function () {
            Settings.setValue("serverTlsEnabled", tlsCheckbox.checked)
        })
        tlsCertFileEdit.onTextChanged.connect(function () {
            Settings.setValue("serverTlsCertFile", tlsCertFileEdit.text)
        })
        tlsKeyFileEdit.onTextChanged.connect(function () {
            Settings.setValue("serverTlsKeyFile", tlsKeyFileEdit.text)
        })
        tlsControlCheckbox.onCheckedChanged.connect(function () {
            Settings.setValue("tlsControlChannel", tlsControlCheckbox.checked)
        })
        tlsDataCheckbox.onCheckedChanged.connect(function () {
            Settings.setValue("tlsDataChannel", tlsDataCheckbox.checked)
        })
        onlineCheckbox.onCheckedChanged.connect(function () {
            Settings.setValue("autoOnline", onlineCheckbox.checked)
        })
        rootDirEdit.onTextChanged.connect(function () {
            Settings.setValue("serverRootDir", rootDirEdit.text)
        })
        anonymousCheckbox.onCheckedChanged.connect(function () {
            Settings.setValue("serverAllowAnonymous", anonymousCheckbox.checked)
        })
        usernameEdit.onTextChanged.connect(function () {
            Settings.setValue("serverUsername", usernameEdit.text)
        })
        userpassEdit.onTextChanged.connect(function () {
            Settings.setValue("serverUserpass", userpassEdit.text)
        })
    }
}





