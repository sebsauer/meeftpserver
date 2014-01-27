#!/usr/bin/python

import sys, os, traceback
from pyftpdlib import ftpserver

class FlushFile:
    def __init__(self, file):
        self.file = file
    def write(self, data):
        self.file.write(data)
        self.file.flush()
sys.stdout = FlushFile(sys.stdout)
sys.stderr = FlushFile(sys.stderr)

config = {
    'address': '127.0.0.1',
    'port': 2121,
    'rootdir': os.getcwd(),
    'username': '',
    'userpass': '',
    'allow_anon': False,
    'max_cons': 256,
    'max_cons_per_ip': 10,
    'tlspem': '',
    'tlscertfile': '',
    'tlskeyfile': '',
    'tlscontrol': False,
    'tlsdata': False,
    'stdin': False,

    'create_tlscertfile': None,
    'create_tlskeyfile': None,
    'create_C': 'US',
    'create_ST': 'Minnesota',
    'create_L': 'Minnetonka',
    'create_O': 'My Company',
    'create_OU': 'My Organization',
    'create_CN': None,
    'create_serial': 1000,
}

def setConfig(arg):
    try:
        (key, value) = arg.strip().split('=', 1)
    except ValueError:
        raise TypeError("Invalid argument='%s'\n" % arg)
    while key.startswith("-"):
        key = key[1:]
    if not key in config:
        raise TypeError("Invalid argument key='%s'\n" % key)
    config[key] = value

def hexToString(hexStr):
    bytes = []
    hexStr = ''.join(hexStr.split(" "))
    for i in range(0, len(hexStr), 2):
        bytes.append( chr( int (hexStr[i:i+2], 16 ) ) )
    return ''.join(bytes)

def createSelfSignedCertificate():
    # This method is used to allow creating self-signed pubkey+privkey
    # PEM certificates on the fly for later use with the SFTP-server.
    try:
        from OpenSSL import crypto, SSL
    except ImportError:
        raise TypeError("Error: No python OpenSSL installed.\n\nPlease install PyOpenSSL by opening a terminal and executing \"pkcon install pyopenssl\" to install python OpenSSL from the Jolla-repository.")
    from socket import gethostname
    from time import gmtime, mktime

    certfile = config['create_tlscertfile']
    try:
        (cdir, cfile) = os.path.split(certfile)
        if not os.path.exists(cdir):
            os.makedirs(cdir)
    except:
        exc_type, exc_value, exc_tb = sys.exc_info()
        raise TypeError("Error: Invalid cert file '%s'.\n%s" % (certfile,exc_value))

    keyfile = config['create_tlskeyfile']
    try:
        (kdir, kfile) = os.path.split(keyfile)
        if not os.path.exists(kdir):
            os.makedirs(kdir)
    except:
        exc_type, exc_value, exc_tb = sys.exc_info()
        raise TypeError("Error: Invalid key file '%s'.\n%s" % (keyfile,exc_value))

    k = crypto.PKey()
    k.generate_key(crypto.TYPE_RSA, 1024)
    cert = crypto.X509()
    cert.get_subject().C = config['create_C']
    cert.get_subject().ST = config['create_ST']
    cert.get_subject().L = config['create_L']
    cert.get_subject().O = config['create_O']
    cert.get_subject().OU = config['create_OU']
    cert.get_subject().CN = config['create_CN'] if config['create_CN'] else gethostname()
    cert.set_serial_number(config['create_serial'])
    cert.gmtime_adj_notBefore(0)
    cert.gmtime_adj_notAfter(10*365*24*60*60)
    cert.set_issuer(cert.get_subject())
    cert.set_pubkey(k)
    cert.sign(k, 'sha1')

    try:
        kf = open(keyfile, "wt")
        kf.write(crypto.dump_privatekey(crypto.FILETYPE_PEM, k))
    except:
        exc_type, exc_value, exc_tb = sys.exc_info()
        raise TypeError("Failed write key file '%s'.\n%s" % (keyfile,exc_value))

    try:
        cf = open(certfile, "wt")
        cf.write(crypto.dump_certificate(crypto.FILETYPE_PEM, cert))
    except:
        exc_type, exc_value, exc_tb = sys.exc_info()
        raise TypeError("Failed write cert file '%s'.\n%s" % (certfile,exc_value))

def main():
    # There are two ways the default configuration from above can be modifed.
    # 1. With commandline-arguments provided to this python script. We expect
    #    a "key=value" combination where different options are splitted by
    #    spaces. E.g. "server.py address=127.0.0.1 port=5555"
    # 2. By passing in arguments via stdin. For that the script needs to be
    #    started with "server.py stdin=1" as argument. The script will block till
    #    all of stdin is read.
    for i in range(1, len(sys.argv)):
        setConfig(sys.argv[i])
    if config['stdin']:
        for line in sys.stdin.readlines():
            setConfig(line)

    #print "FtpServer config: %s" % config

    if config['create_tlscertfile'] or config['create_tlskeyfile']:
        # Create a new self-signed openssl certificate
        createSelfSignedCertificate()
        # Job done, not continue.
        return

    # All the following logic deals with setting up and run the FTP server.

    # Instantiate a dummy authorizer for managing 'virtual' users
    authorizer = ftpserver.DummyAuthorizer()

    # Define a new user having full r/w permissions
    if config['username'] and len(config['username']) > 0:
        authorizer.add_user(config['username'], config['userpass'], config['rootdir'], perm='elradfmwM')

    # Allow read-only anonymous user
    if config['allow_anon']:
        authorizer.add_anonymous(config['rootdir'])

    ftp_handler = None
    if config['tlspem'] or config['tlscertfile']:
        try:
            from OpenSSL import SSL, crypto
        except ImportError:
            raise TypeError("Error: No python OpenSSL installed.\n\nPlease install PyOpenSSL by opening a terminal and executing \"pkcon install pyopenssl\" to install python OpenSSL from the Jolla-repository.")

        # Instantiate SFTP handler class
        from pyftpdlib.contrib.handlers import TLS_FTPHandler
        ftp_handler = TLS_FTPHandler

        if config['tlscontrol']:
            ftp_handler.tls_control_required = True
        if config['tlsdata']:
            ftp_handler.tls_data_required = True

        if config['tlspem']:
            # This passes the privkey and pubkey direct via stdin as one single
            # hex-encoded pem certificate.
            context = SSL.Context(SSL.SSLv23_METHOD)
            pem = hexToString(config['tlspem'])
            context.use_certificate(crypto.load_certificate(crypto.FILETYPE_PEM, pem))
            context.use_privatekey(crypto.load_privatekey(crypto.FILETYPE_PEM, pem))
            ftp_handler.ssl_context = context
        else:
            # cert-file and optionaly separated key-file are on the file-system
            # and just referenced here.
            ftp_handler.certfile = config['tlscertfile']
            if config['tlskeyfile']:
                ftp_handler.keyfile = config['tlskeyfile']
    else:
        # Instantiate FTP handler class
        ftp_handler = ftpserver.FTPHandler

    # Set the auhorizer
    ftp_handler.authorizer = authorizer

    # Define a customized banner (string returned when client connects)
    ftp_handler.banner = "Sailfish Ftp Server."

    # Specify a masquerade address and the range of ports to use for
    # passive connections.  Decomment in case you're behind a NAT.
    #ftp_handler.masquerade_address = '151.25.42.11'
    #ftp_handler.passive_ports = range(60000, 65535)

    # Instantiate FTP server class and listen to 0.0.0.0:2121
    host = (config['address'], config['port'])
    ftpd = ftpserver.FTPServer(host, ftp_handler)

    # Set a limit for connections
    ftpd.max_cons = config['max_cons']
    ftpd.max_cons_per_ip = config['max_cons_per_ip']

    # Start ftp server keeping this script running forever till terminated/killed
    ftpd.serve_forever()

if __name__ == '__main__':
    try:
        main()
    except:
        # Catch all exceptions and make sure the important part is passed on to the caller. We
        # do not send all of the backtrace cause that is an implementation-detail that may
        # scare users who never dealed with python exceptions before ;)
        exc_type, exc_value, exc_tb = sys.exc_info()
        sys.stderr.write("%s\n" % exc_value)
        #print traceback.print_exc()
        sys.exit(1)
