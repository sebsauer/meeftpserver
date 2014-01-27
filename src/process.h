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

#ifndef PROCESS_H
#define PROCESS_H

#include <QObject>
#include <QProcess>

class Process : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString program READ program WRITE setProgram NOTIFY programChanged)
    Q_PROPERTY(QStringList arguments READ arguments WRITE setArguments NOTIFY argumentsChanged)
    Q_PROPERTY(QString state READ state NOTIFY stateChanged)

public:
    explicit Process(QObject *parent = 0);
    virtual ~Process();

    QString program() const;
    void setProgram(const QString &program);

    QStringList arguments() const;
    void setArguments(const QStringList &arguments);

    QString state() const;

Q_SIGNALS:
    void programChanged();
    void argumentsChanged();

    void started();
    void stopped();
    void stateChanged();

    void output(const QString &message);

public Q_SLOTS:
    void start();
    void stop();

    QByteArray readData() const;
    void writeData(const QByteArray &data);
    void closeWriteChannel();

    bool waitForStarted(int msecs = 30000);
    bool waitForFinished(int msecs = 30000);

    QString errorString() const;
    int exitCode() const;

    QString execute(const QString &program, const QStringList &arguments = QStringList());

private Q_SLOTS:
    void slotError(QProcess::ProcessError);
    void slotStateChanged(QProcess::ProcessState state);
    void slotReadyReadStandardError();
    void slotReadStandardOutput();
    void slotReadyRead();

private:
    QProcess *m_process;
    QString m_program;
    QStringList m_arguments;
    bool m_starting;
};

#endif // PROCESS_H
