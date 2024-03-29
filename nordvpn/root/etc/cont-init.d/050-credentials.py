#!/usr/bin/with-contenv python
#  -*- coding: utf-8 -*-

import os

import IvoNet

from shutil import copyfile

__author__ = "Ivo Woltring"
__copyright__ = "Copyright (c) 2019 Ivo Woltring"
__license__ = "Apache 2.0"
__doc__ = """

Retrieves the credentials either from the Environment or from the credentials.txt 
file if configured. One of the two must be provided for this image to work.

"""


class NoCredentialsError(Exception):
    pass


def username():
    return IvoNet.environment("USER", None)


def password():
    return IvoNet.environment("PASS", None)


def credentials():
    if username() and password():
        with open("/vpn/auth", "w") as auth:
            auth.write(username() + "\n")
            auth.write(password())
    elif os.path.isfile("/credentials/credentials.txt"):
        copyfile("/credentials/credentials.txt", "/vpn/auth")
    else:
        raise NoCredentialsError("No credentials found :(")
    os.chmod("/vpn/auth", 0o600)


if __name__ == '__main__':
    credentials()
