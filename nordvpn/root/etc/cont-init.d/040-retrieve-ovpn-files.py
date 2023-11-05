#!/command/with-contenv python

import IvoNet

__author__ = "Ivo Woltring"
__copyright__ = "Copyright (c) 2021 Ivo Woltring"
__license__ = "Apache 2.0"


def get_ovpn_config_files(url):
    """
    retrieve the ovpn files from the provider if thy do not exist

    :param url: the ovpn files endpoint
    """
    if not IvoNet.has_ext(IvoNet.ovpn_tpc_dir(), ".ovpn"):
        print("Retrieving OVPN config files. This may take a while...")
        IvoNet.unzip(url, IvoNet.ovpn_dir())
    else:
        print("Config files found...")


def main():
    IvoNet.create_folder(IvoNet.ovpn_dir())
    get_ovpn_config_files(IvoNet.ovpn_url())


if __name__ == '__main__':
    main()
