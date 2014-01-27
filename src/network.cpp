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

#include "network.h"

//#include <QSslCertificate>
//#include <QSslKey>
//#include <QDateTime>
#include <QDebug>

Network::Network(QObject *parent)
    : QObject(parent)
{
    m_networkConfigManager = new QNetworkConfigurationManager(this);
    m_networkSession = 0;

    connect(m_networkConfigManager, SIGNAL(onlineStateChanged(bool)), this, SLOT(slotOnlineChanged()));
    connect(m_networkConfigManager, SIGNAL(updateCompleted()), this, SLOT(slotNetworkUpdated()));
}

Network* Network::instance()
{
    static Network *network = 0;
    if (!network)
        network = new Network();
    return network;
}

void Network::openSession()
{
    qDebug() << Q_FUNC_INFO;
    if (!m_networkSession) {
        QNetworkConfiguration networkConfig = m_networkConfigManager->defaultConfiguration();
        if (!networkConfig.isValid()) {
            qDebug() << "Default network configuration invalid. Cannot go online.";
        } else {
            // Note that we only create the QNetworkSession once and then later adapt if the configuration
            // changes. This is the prefered way and it seems to be a bad idea to delete and recreate the
            // QNetworkSession instance manually since that can have all kind of "funny" side-effects
            // including a stack-corruption on the N9 with Pr1.2 :-/
            m_networkSession = new QNetworkSession(networkConfig, m_networkConfigManager);
            connect(m_networkSession, SIGNAL(opened()), this, SLOT(slotSessionOpened()));
            connect(m_networkSession, SIGNAL(closed()), this, SLOT(slotSessionClosed()));
            connect(m_networkSession, SIGNAL(stateChanged(QNetworkSession::State)), this, SLOT(slotSessionStateChanged(QNetworkSession::State)));
            connect(m_networkSession, SIGNAL(error(QNetworkSession::SessionError)), this, SLOT(slotSessionError(QNetworkSession::SessionError)));
            connect(m_networkSession, SIGNAL(newConfigurationActivated()), this, SLOT(slotSessionNewActivated()));
            connect(m_networkSession, SIGNAL(preferredConfigurationChanged(QNetworkConfiguration,bool)), this, SLOT(slotSessionPreferredChanged(QNetworkConfiguration,bool)));
            connect(m_networkSession, SIGNAL(usagePoliciesChanged(QNetworkSession::UsagePolicies)), this, SLOT(slotUsagePoliciesChanged(QNetworkSession::UsagePolicies)));
        }
    }
    if (m_networkSession)
        m_networkSession->open();
}

void Network::closeSession()
{
    qDebug() << Q_FUNC_INFO;
    if (m_networkSession && m_networkSession->isOpen())
        m_networkSession->close();
}

void Network::slotOnlineChanged()
{
    qDebug() << Q_FUNC_INFO;
    Q_EMIT onlineChanged();
}

void Network::slotNetworkUpdated()
{
    qDebug() << Q_FUNC_INFO;
    Q_EMIT networkUpdated();
}

void Network::slotSessionOpened()
{
    qDebug() << Q_FUNC_INFO;
    Q_EMIT sessionOpened();
}

void Network::slotSessionClosed()
{
    qDebug() << Q_FUNC_INFO;
    Q_EMIT sessionClosed();
}

void Network::slotSessionStateChanged(QNetworkSession::State state)
{
    qDebug() << Q_FUNC_INFO << "state=" << state;
}

void Network::slotSessionError(QNetworkSession::SessionError error)
{
    qDebug() << Q_FUNC_INFO << "error=" << error;
    //stop();
}

void Network::slotSessionNewActivated()
{
    qDebug() << Q_FUNC_INFO;
    m_networkSession->accept();
}

void Network::slotSessionPreferredChanged(const QNetworkConfiguration &config, bool isSeamless)
{
    if (config.isValid())
        qDebug() << Q_FUNC_INFO << "bearerTypeName=" << config.bearerTypeName() << "configIdentifier=" << config.identifier() << "configName=" << config.name() << "isSeamless=" << isSeamless;
    else
        qDebug() << Q_FUNC_INFO << "Invalid network configuration - isSeamless=" << isSeamless;
    //stop();
    m_networkSession->migrate();
}

void Network::slotUsagePoliciesChanged(QNetworkSession::UsagePolicies usagePolicies)
{
    qDebug() << Q_FUNC_INFO << "usagePolicies=" << usagePolicies;
}
