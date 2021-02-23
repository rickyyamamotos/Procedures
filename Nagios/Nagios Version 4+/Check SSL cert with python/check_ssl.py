#!/usr/bin/env python3.6
import sys
import socket
import ssl
import datetime

# based on https://serverlesscode.com/post/ssl-expiration-alerts-with-lambda/
#
# Usage: check_ssl_expiry.py <hostname> [port] [gracetime_days]
#        port             Port to check (defaults to 443)
#        gracetime_days   Warn if certificate is valid for less than nr of days(defaults to 14)
#
#
# Examples:
# $ check_ssl_expiry.py ok.example.com
# OK - ok.example.com: valid for 60 days (until 2016-12-01 06:00:00)
#
# $ check_ssl_expiry.py warn.example.com
# WARNING - warn.example.com: expires in 10 days (on 2016-10-20 06:00:00)
#
# $ check_ssl_expiry.py invalid.example.com
# CRITICAL - invalid.example.com: expired 2 days ago (on 2016-10-08 06:00:00)
#

def ssl_expiry_datetime(hostname, port):
    ssl_date_fmt = r'%b %d %H:%M:%S %Y %Z'

    context = ssl.create_default_context()
    conn = context.wrap_socket(
        socket.socket(socket.AF_INET),
        server_hostname=hostname,
    )
    conn.settimeout(15.0)
    conn.connect((hostname, port))
    ssl_info = conn.getpeercert()
    # parse the string from the certificate into a Python datetime object
    return datetime.datetime.strptime(ssl_info['notAfter'], ssl_date_fmt)
if __name__ == '__main__':
    try:
        hostname = sys.argv[1]
    except IndexError:
        print("UNKNOWN - no hostname given")
        sys.exit(3)
    try:
        port = int(sys.argv[2])
    except:
        port = 443

    try:
        gracetime_days = int(sys.argv[3])
    except:
        gracetime_days = 10
    # get remaining time
    try:
        now = datetime.datetime.utcnow()
        expires = ssl_expiry_datetime(hostname, port)
        # timedelta
        remaining = expires - now
    except:
        print("Critical - %s:%s: connection refused" % (hostname, port))
        sys.exit(1)
    vremaining1=remaining.days
    if vremaining1 < 0:
        # cert has already expired
        exitcode = 2
        print("Critical: - %s: expired %s days ago (on %s)" % (hostname, remaining.days, expires))
        sys.exit(exitcode)
    elif vremaining1 < gracetime_days:
        exitcode = 2
        # cert expires sooner that gracetime_days
        print("Critical: - %s: expires in %s days (on %s)" % (hostname, remaining.days, expires))
        sys.exit(exitcode)
    else:
        # cert is valid and does not expire within gracetime_days
        exitcode = 0
        print("OK: - %s: valid for %s days (until %s)" % (hostname, remaining.days, expires))
        sys.exit(exitcode)

