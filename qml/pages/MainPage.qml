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

import Process 1.0
import Settings 1.0
import Network 1.0

Page {
    id: mainPage

    signal serverStateChanged

    Process {
        id: ftpServer
        program: ''
        arguments: []

        function initialize() {
            //mainPage.clearLog()

            ftpServer.program = ftpServer.execute("which", ["python"])
            if (ftpServer.program === null || ftpServer.program === undefined || ftpServer.program.length < 1) {
                ftpServer.program = findExistingFile(['/usr/bin/python', '/usr/local/bin/python'])
                if (ftpServer.program === null || ftpServer.program === undefined || ftpServer.program.length < 1) {
                    mainPage.addError(qsTr("Error: No python installed.\n\nPlease install python >=2.7 by opening a terminal and executing \"pkcon install python\" to install python from the Jolla-repository.\n"))
                    return false
                }
            }
            mainPage.addLog("Python: " + ftpServer.program + "\n")

            var version = ftpServer.execute(ftpServer.program, ["--version"])
            if (version === null || version === undefined || version.length < 1) {
                mainPage.addError(qsTr("Error: Failed to execute \"python --version\".\n"))
                ftpServer.program = ''
                return false
            }
            mainPage.addLog("Version: " + version + "\n")

            var script = findExistingFile([
                '/home/sailfish/src/meeftpserver/server/server.py',
                '/usr/share/harbour-meeftpserver/server/server.py',
                '/usr/share/meeftpserver/server/server.py'])
            if (script === null || script === undefined || script.length < 1) {
                mainPage.addError(qsTr("Error: Failed to find \"server.py\" python script. That script is part of this application.\n"))
                ftpServer.program = ''
                return false
            }
            mainPage.addLog("Script: " + script + "\n\n")

            ftpServer.arguments = [script, "--stdin=1"]

            return true
        }

        function sendConfigs() {
            var args = []

            args.push("address=" + Settings.value("serverAddress", "0.0.0.0"))
            args.push("port=" + Settings.value("serverPort", "2121"))
            args.push("rootdir=" + Settings.expandPath(Settings.value("serverRootDir", "~/")))

            var username = Settings.value("serverUsername", "")
            if (username !== null && username !== undefined && username.length > 0) {
                args.push("username=" + username)
                var userpass = Settings.value("serverUserpass", "")
                if (userpass !== null && userpass !== undefined && userpass.length > 0)
                    args.push("userpass=" + userpass)
            }

            if (Settings.value("serverAllowAnonymous", false))
                args.push("allow_anon=1")

            if (Settings.value("serverTlsEnabled", false)) {
                var tlscertfile = Settings.value("serverTlsCertFile")
                if (tlscertfile !== null && tlscertfile !== undefined && tlscertfile.length > 0) {
                    args.push("tlscertfile=" + tlscertfile)
                    var tlskeyfile = Settings.value("serverTlsKeyFile")
                    if (tlskeyfile !== null && tlskeyfile !== undefined && tlskeyfile.length > 0)
                        args.push("tlskeyfile=" + tlskeyfile)
                } else {
                    var tlspem = Settings.value("serverTlsPem")
                    if (tlspem !== null && tlspem !== undefined && tlspem.length > 0)
                        args.push("tlspem=" + tlspem)
                }

                var tlscontrol = Settings.value("tlsControlChannel", true)
                if (tlscontrol !== null && tlscontrol !== undefined && tlscontrol)
                    args.push("tlscontrol=" + tlscontrol)
                var tlsdata = Settings.value("tlsDataChannel", true)
                if (tlsdata !== null && tlsdata !== undefined && tlsdata)
                    args.push("tlsdata=" + tlsdata)
            }

            for(var i in args) {
                var a = args[i]
                ftpServer.writeData(a + "\n")
            }
            ftpServer.closeWriteChannel()
        }

        onStarted: {
            console.log("ftpServer.onStarted")
            mainPage.addLog(qsTr("FTP Server running\n\n"))

            ftpServer.sendConfigs()

            if (Settings.value("autoOnline", false)) {
                Network.openSession()
            }

            var addresslist = []
            var port = Settings.value("serverPort", "2121")
            var addresses = Network.runningInterfaceAddresses()
            for(var i in addresses) addresslist.push(addresses[i] + ":" + port)
            if (addresslist.length > 0) {
                mainPage.addLog("    * " + addresslist.join("\n    * ") + "\n\n")
            }
        }
        onStopped: {
            console.log("ftpServer.onStopped")
            mainPage.addLog(qsTr("FTP Server quit\n"))
            Network.closeSession()
        }
        onStateChanged: {
            console.log("ftpServer.onStateChanged state=" + ftpServer.state)
            mainPage.serverStateChanged()
        }
        onOutput: {
            mainPage.addLog(message)
        }
    }

    PageStack {
        id: centralPageStack
        anchors { left: parent.left; right: parent.right; top: parent.top; bottom: parent.bottom; margins: Theme.paddingMedium; }

        Page {
            id: centralPage

            Row {
                id: buttonRow
                anchors { left: parent.left; right: parent.right; top: parent.top; }
                spacing: Theme.paddingSmall
                Button {
                    id: startStopButton
                    text: ftpServer.state === "stopped" ?  qsTr("Start") : qsTr("Stop")
                    onClicked: {
                        if (ftpServer.state === "stopped") {
                            mainPage.startServer()
                        } else {
                            mainPage.stopServer()
                        }
                    }
                }
                Button {
                    id: logConfigButton
                    text: pageStack.currentPage === logPage ? qsTr("Config") : qsTr("Log")
                    onClicked: {
                        if (pageStack.currentPage === logPage) {
                            configPage.activatePage()
                        } else {
                            logPage.activatePage()
                        }
                    }
                }
            }

            PageStack {
                id: pageStack
                anchors { left: parent.left; right: parent.right; top: buttonRow.bottom; bottom: parent.bottom; }
                LogPage {
                    id: logPage
                    function activatePage() {
                        if (pageStack.currentPage !== logPage)
                            pageStack._replace(logPage)
                    }
                }
                ConfigPage {
                    id: configPage
                    function activatePage() {
                        if (pageStack.currentPage !== configPage)
                            pageStack._replace(configPage)
                    }
                    onCreateCertClicked: {
                        var certfile = configPage.certFile
                        var keyfile = configPage.keyFile
                        if (certfile.length < 1)
                            certfile = Settings.joinFile(Settings.configDir(), 'meeftpservercert.pem')
                        if (keyfile.length < 1)
                            keyfile = Settings.joinFile(Settings.configDir(), 'meeftpservercert.key')
                        createCertPage.initCert(certfile, keyfile)
                        centralPageStack._push(createCertPage)
                    }
                }

            }
        }

        CreateCertPage {
            id: createCertPage
            onCertCreated: {
                configPage.certFile= certfile
                configPage.keyFile = keyfile
                centralPageStack.pop(centralPage)
            }
        }
    }

    function clearLog() {
        logPage.log.text = ''
    }

    function addLog(message) {
        logPage.log.text += message
    }

    function addError(message) {
        addLog(message)
        logPage.activatePage()
    }

    function startServer() {
        if (ftpServer.state !== "stopped")
            return

        mainPage.clearLog()
        logPage.activatePage()

        if (!ftpServer.initialize())
            return

        //startButton.enabled = false
        mainPage.addLog(qsTr("Starting FTP Server...\n"))
        ftpServer.start()
    }
    function stopServer() {
        if (ftpServer.state === "stopped")
            return

        //startButton.enabled = false
        mainPage.addLog(qsTr("Stopping FTP Server...\n"))
        ftpServer.stop()
    }
    function serverState() {
        return ftpServer.state
    }

    function findExistingFile(possibilities) {
        for(var i in possibilities) {
            var f = possibilities[i]
            if (Settings.fileExists(f))
                return f
        }
        return ''
    }

    Component.onCompleted: {
        centralPageStack._push(centralPage)
        pageStack._push(configPage)
        ftpServer.initialize()
    }
}
