#!/usr/bin/env python

from passlib.hash import ldap_salted_sha1 as digest
from getpass import getpass

msg = "Please, provide your SSO password (not echoed): "
print(digest.hash(getpass(prompt=msg)))
