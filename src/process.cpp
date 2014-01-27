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

#include "process.h"

#include <QDebug>

Process::Process(QObject *parent)
    : QObject(parent)
    , m_process(0)
    , m_starting(false)
{
}

Process::~Process()
{
    if (m_process && m_process->state() != QProcess::NotRunning) {
        m_starting = false;
        m_process->kill();
        m_process->waitForFinished();
    }
}

QString Process::program() const
{
    return m_program;
}

void Process::setProgram(const QString &program)
{
    if (m_program == program)
        return;
    m_program = program;
    Q_EMIT programChanged();
}

QStringList Process::arguments() const
{
    return m_arguments;
}

void Process::setArguments(const QStringList &arguments)
{
    if (m_arguments == arguments)
        return;
    m_arguments = arguments;
    Q_EMIT argumentsChanged();
}

void Process::start()
{
    qDebug() << Q_FUNC_INFO;

    if (m_process && m_process->state() != QProcess::NotRunning) {
        m_starting = false;
        m_process->kill();
        m_process->waitForFinished();
    }

    if (!m_process) {
        m_process = new QProcess(this);

        //m_process->setReadChannel(QProcess::StandardOutput);
        //m_process->setProcessChannelMode(QProcess::SeparateChannels);
        m_process->setProcessChannelMode(QProcess::MergedChannels);
        //m_process->setProcessChannelMode(QProcess::ForwardedChannels);

        connect(m_process, SIGNAL(started()), this, SIGNAL(started()));
        connect(m_process, SIGNAL(error(QProcess::ProcessError)), this, SLOT(slotError(QProcess::ProcessError)));
        connect(m_process, SIGNAL(finished(int,QProcess::ExitStatus)), this, SIGNAL(stopped()));
        connect(m_process, SIGNAL(stateChanged(QProcess::ProcessState)), this, SLOT(slotStateChanged(QProcess::ProcessState)));
        connect(m_process, SIGNAL(readyReadStandardError()), this, SLOT(slotReadyReadStandardError()));
        connect(m_process, SIGNAL(readyReadStandardOutput()), this, SLOT(slotReadStandardOutput()));
        connect(m_process, SIGNAL(readyRead()), this, SLOT(slotReadyRead()));
    }

    m_starting = true;

    qDebug() << Q_FUNC_INFO << m_program << m_arguments;
    m_process->start(m_program, m_arguments, QIODevice::ReadWrite);
}

void Process::stop()
{
    m_starting = false;

    if (!m_process) {
        qWarning() << Q_FUNC_INFO << "Program already stopped";
        return;
    }

    qDebug() << Q_FUNC_INFO;

    m_process->kill();
    // No m_process->waitForFinished() but leave immediately.
}

bool Process::waitForStarted(int msecs)
{
    return m_process ? m_process->waitForStarted(msecs) : false;
}

bool Process::waitForFinished(int msecs)
{
    return m_process ? m_process->waitForFinished(msecs) : false;
}

QString Process::errorString() const
{
    return m_process ? m_process->errorString() : QString();
}

int Process::exitCode() const
{
    return m_process ? m_process->exitCode() : 0;
}

QString stateToString(QProcess::ProcessState state)
{
    QString s;
    switch (state) {
        case QProcess::NotRunning: s = "stopped"; break;
        case QProcess::Starting: s = "starting"; break;
        case QProcess::Running: s = "running"; break;
    }
    return s;
}

QString Process::state() const
{
    return m_process ? stateToString(m_process->state()) : "stopped";
}

QByteArray Process::readData() const
{
    qDebug() << Q_FUNC_INFO;
    Q_ASSERT(m_process);
    Q_ASSERT(m_process->state() == QProcess::Running);
    return m_process->readAll();
}

void Process::writeData(const QByteArray &data)
{
    qDebug() << Q_FUNC_INFO << data;
    Q_ASSERT(m_process);
    Q_ASSERT(m_process->state() == QProcess::Running);
    m_process->write(data);
}

void Process::closeWriteChannel()
{
    qDebug() << Q_FUNC_INFO;
    Q_ASSERT(m_process);
    Q_ASSERT(m_process->state() == QProcess::Running);
    //m_process->waitForBytesWritten();
    m_process->closeWriteChannel();
}

QString Process::execute(const QString &program, const QStringList &arguments)
{
    qDebug() << Q_FUNC_INFO << program << arguments;

    QProcess p;
    p.setProcessChannelMode(QProcess::MergedChannels);
    p.start(program, arguments);
    p.waitForFinished();
    if (p.exitCode() != 0) {
        qWarning() << Q_FUNC_INFO << p.errorString();
        return QString();
    }
    return p.readAll().trimmed();
}

void Process::slotError(QProcess::ProcessError err)
{
    Q_ASSERT(m_process);

    qDebug() << Q_FUNC_INFO << "error=" << err << "started=" << m_starting;

    if (!m_starting) {
        // e.g. QProcess::Crashed will/may emitted everytime we stop() the
        // process using kill(). Just ignore all errors on shutdown.
        return;
    }

    QString m;
    switch (err) {
        case QProcess::FailedToStart:
            m = tr("The process failed to start. Either the invoked program is missing, or you may have insufficient permissions to invoke the program.");
            break;
        case QProcess::Crashed:
            m = tr("The process crashed some time after starting successfully.");
            break;
        case QProcess::Timedout:
            m = tr("Execution timed out.");
            break;
        case QProcess::WriteError:
            m = tr("An error occurred when attempting to write to the process.");
            break;
        case QProcess::ReadError:
            m = tr("An error occurred when attempting to read from the process.");
            break;
        case QProcess::UnknownError:
            m = tr("An unknown error occurred.");
            break;
    }
    Q_EMIT output(m + "\n");
}

void Process::slotStateChanged(QProcess::ProcessState state)
{
    qDebug() << Q_FUNC_INFO << "state=" << stateToString(state);
    Q_ASSERT(m_process);
    Q_ASSERT(m_process->state() == state);
    Q_EMIT stateChanged();
}

void Process::slotReadyReadStandardError()
{
    QByteArray err = m_process->readAllStandardError();
    qDebug() << Q_FUNC_INFO << "error=" << err;
    Q_EMIT output(QString(err));
}

void Process::slotReadStandardOutput()
{
    QByteArray out = m_process->readAllStandardOutput();
    qDebug() << Q_FUNC_INFO << "out=" << out;
    Q_EMIT output(QString(out));
}

void Process::slotReadyRead()
{
    qDebug() << Q_FUNC_INFO;
    //while(m_process->canReadLine()) {
    //    QByteArray line = m_process->readLine();
    //    qDebug() << Q_FUNC_INFO << "line=" << line;
    //    Q_EMIT output(QString(line));
    //}
}
