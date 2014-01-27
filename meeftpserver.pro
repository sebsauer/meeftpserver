# The name of your app.
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - corresponding QML filename must be changed
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed
TARGET = meeftpserver

CONFIG += sailfishapp

SOURCES += src/main.cpp \
    src/process.cpp \
    src/settings.cpp \
    src/network.cpp

HEADERS += \
    src/process.h \
    src/settings.h \
    src/network.h

PYFILES = server/server.py \
    server/pyftpdlib/__init__.py \
    server/pyftpdlib/ftpserver.py \
    server/pyftpdlib/contrib/__init__.py \
    server/pyftpdlib/contrib/authorizers.py \
    server/pyftpdlib/contrib/filesystems.py \
    server/pyftpdlib/contrib/handlers.py

OTHER_FILES += qml/meeftpserver.qml \
    qml/cover/CoverPage.qml \
    rpm/meeftpserver.spec \
    rpm/meeftpserver.yaml \
    meeftpserver.desktop \
    qml/pages/CreateCertPage.qml \
    qml/pages/ConfigPage.qml \
    qml/pages/LogPage.qml \
    qml/pages/MainPage.qml \
    $$PYFILES

server_folder.files = server
server_folder.path = /usr/share/$${TARGET}
#server_folder.target = .
#DEPLOYMENTFOLDERS += server_folder
INSTALLS += server_folder
