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

#ifndef NETWORK_H
#define NETWORK_H

#include <QObject>
#include <QStringList>
#include <QNetworkConfigurationManager>
#include <QNetworkSession>
#include <QNetworkInterface>

class Network : public QObject
{
    Q_OBJECT

public:
    explicit Network(QObject *parent = 0);

    static Network* instance();

Q_SIGNALS:
    void onlineChanged();
    void networkUpdated();

    void sessionOpened();
    void sessionClosed();

public Q_SLOTS:
    void openSession();
    void closeSession();

    QStringList runningInterfaceAddresses() const;

private Q_SLOTS:
    void slotOnlineChanged();
    void slotNetworkUpdated();
    void slotSessionOpened();
    void slotSessionClosed();
    void slotSessionStateChanged(QNetworkSession::State);
    void slotSessionError(QNetworkSession::SessionError error);
    void slotSessionNewActivated();
    void slotSessionPreferredChanged(const QNetworkConfiguration &config, bool isSeamless);
    void slotUsagePoliciesChanged(QNetworkSession::UsagePolicies usagePolicies);

private:
    QNetworkConfigurationManager *m_networkConfigManager;
    QNetworkSession *m_networkSession;
};

#endif // NETWORK_H
