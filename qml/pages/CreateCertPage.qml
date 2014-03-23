import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: createCertPage

    signal certCreated(string certfile, string keyfile)

    function initCert(certfile, keyfile) {
        errorLabel.text = ''
        tlsCertFileEdit.text = certfile
        tlsKeyFileEdit.text = keyfile
    }

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentWidth: Math.max(column.width, parent.width)
        contentHeight: column.height
        clip: true

        Column {
            id: column
            spacing: Theme.paddingSmall

            Button {
                id: logConfigButton
                text: qsTr("Create")
                onClicked: {
                    var certfile = tlsCertFileEdit.text.trim()
                    var keyfile = tlsKeyFileEdit.text.trim()

                    var args = []
                    args.push("create_tlscertfile=" + certfile)
                    args.push("create_tlskeyfile=" + keyfile)
                    args.push("create_C=" + tlsCountryEdit.text.trim())
                    args.push("create_ST=" + tlsStateEdit.text.trim())
                    args.push("create_L=" + tlsCityEdit.text.trim())
                    args.push("create_O=" + tlsCompanyEdit.text.trim())
                    args.push("create_OU=" + tlsOrganizationEdit.text.trim())
                    args.push("create_CN=" + tlsHostEdit.text.trim())
                    //args.push("create_serial=1000")

                    var p = Qt.createQmlObject("import Process 1.0\nProcess {}", createCertPage, "createCertProcess")
                    p.program = ftpServer.program
                    p.arguments = ftpServer.arguments
                    p.output.connect( function(message) { errorLabel.text = errorLabel.text + message + "\n" } )
                    p.start()
                    if (!p.waitForStarted()) {
                        console.error("Failed Process.waitForStarted")
                        return;
                    }
                    for(var i in args) {
                        p.writeData(args[i] + "\n")
                    }
                    p.closeWriteChannel()
                    if (!p.waitForFinished()) {
                        console.error("Failed Process.waitForFinished")
                        return;
                    }
                    if (p.exitCode() != 0) {
                        console.error("Failed to execute Process, exitCode=" + p.exitCode())
                        return;
                    }

                    certCreated(certfile, keyfile)
                }
            }

            Label {
                id: errorLabel
                width: createCertPage.width
                visible: text.length > 0
                color: Theme.highlightColor
                font.bold: true
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: ''
            }

            Grid {
                spacing: Theme.paddingSmall
                columns: 2

                Label {
                    //horizontalAlignment: Text.AlignRight
                    text: qsTr("Cert File:")
                }
                TextField {
                    id: tlsCertFileEdit
                    inputMethodHints: Qt.ImhNoPredictiveText
                    text: ''
                }

                Label {
                    //horizontalAlignment: Text.AlignRight
                    text: qsTr("Key File:")
                }
                TextField {
                    id: tlsKeyFileEdit
                    inputMethodHints: Qt.ImhNoPredictiveText
                    text: ''
                }

                Label {
                    //horizontalAlignment: Text.AlignRight
                    text: qsTr("Country:")
                }
                TextField {
                    id: tlsCountryEdit
                    inputMethodHints: Qt.ImhNoPredictiveText
                    text: 'US'
                }

                Label {
                    //horizontalAlignment: Text.AlignRight
                    text: qsTr("State:")
                }
                TextField {
                    id: tlsStateEdit
                    inputMethodHints: Qt.ImhNoPredictiveText
                    text: 'Minnesota'
                }

                Label {
                    //horizontalAlignment: Text.AlignRight
                    text: qsTr("City:")
                }
                TextField {
                    id: tlsCityEdit
                    inputMethodHints: Qt.ImhNoPredictiveText
                    text: 'Minnetonka'
                }

                Label {
                    //horizontalAlignment: Text.AlignRight
                    text: qsTr("Company:")
                }
                TextField {
                    id: tlsCompanyEdit
                    inputMethodHints: Qt.ImhNoPredictiveText
                    text: 'My Company'
                }

                Label {
                    //horizontalAlignment: Text.AlignRight
                    text: qsTr("Organization:")
                }
                TextField {
                    id: tlsOrganizationEdit
                    inputMethodHints: Qt.ImhNoPredictiveText
                    text: 'My Organization'
                }

                Label {
                    //horizontalAlignment: Text.AlignRight
                    text: qsTr("Hostname:")
                }
                TextField {
                    id: tlsHostEdit
                    inputMethodHints: Qt.ImhNoPredictiveText
                    text: ''
                }
            }
        }
    }
}
