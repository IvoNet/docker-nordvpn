#!/usr/bin/with-contenv python

import getopt
import json
import os
import random
import sys
from shutil import copyfile

import IvoNet

__author__ = "Ivo Woltring"
__copyright__ = "Copyright (c) 2019 Ivo Woltring"
__license__ = "Apache 2.0"

CONFIG_FILE = "/vpn/config.ovpn"

ISO_CODES = (
    'ad' 'ae' 'af' 'ag' 'ai' 'al' 'am' 'ao' 'aq' 'ar' 'as' 'at' 'au' 'aw' 'ax'
    'az' 'ba' 'bb' 'bd' 'be' 'bf' 'bg' 'bh' 'bi' 'bj' 'bl' 'bm' 'bn' 'bo' 'bq'
    'br' 'bs' 'bt' 'bv' 'bw' 'by' 'bz' 'ca' 'cc' 'cd' 'cf' 'cg' 'ch' 'ci' 'ck'
    'cl' 'cm' 'cn' 'co' 'cr' 'cu' 'cv' 'cw' 'cx' 'cy' 'cz' 'de' 'dj' 'dk' 'dm'
    'do' 'dz' 'ec' 'ee' 'eg' 'eh' 'er' 'es' 'et' 'fi' 'fj' 'fk' 'fm' 'fo' 'fr'
    'ga' 'gb' 'gd' 'ge' 'gf' 'gg' 'gh' 'gi' 'gl' 'gm' 'gn' 'gp' 'gq' 'gr' 'gs'
    'gt' 'gu' 'gw' 'gy' 'hk' 'hm' 'hn' 'hr' 'ht' 'hu' 'id' 'ie' 'il' 'im' 'in'
    'io' 'iq' 'ir' 'is' 'it' 'je' 'jm' 'jo' 'jp' 'ke' 'kg' 'kh' 'ki' 'km' 'kn'
    'kp' 'kr' 'kw' 'ky' 'kz' 'la' 'lb' 'lc' 'li' 'lk' 'lr' 'ls' 'lt' 'lu' 'lv'
    'ly' 'ma' 'mc' 'md' 'me' 'mf' 'mg' 'mh' 'mk' 'ml' 'mm' 'mn' 'mo' 'mp' 'mq'
    'mr' 'ms' 'mt' 'mu' 'mv' 'mw' 'mx' 'my' 'mz' 'na' 'nc' 'ne' 'nf' 'ng' 'ni'
    'nl' 'no' 'np' 'nr' 'nu' 'nz' 'om' 'pa' 'pe' 'pf' 'pg' 'ph' 'pk' 'pl' 'pm'
    'pn' 'pr' 'ps' 'pt' 'pw' 'py' 'qa' 're' 'ro' 'rs' 'ru' 'rw' 'sa' 'sb' 'sc'
    'sd' 'se' 'sg' 'sh' 'si' 'sj' 'sk' 'sl' 'sm' 'sn' 'so' 'sr' 'ss' 'st' 'sv'
    'sx' 'sy' 'sz' 'tc' 'td' 'tf' 'tg' 'th' 'tj' 'tk' 'tl' 'tm' 'tn' 'to' 'tr'
    'tt' 'tv' 'tw' 'tz' 'ua' 'ug' 'uk' 'um' 'us' 'uy' 'uz' 'va' 'vc' 've' 'vg'
    'vi' 'vn' 'vu' 'wf' 'ws' 'ye' 'yt' 'za' 'zm' 'zw'
)


def check_candidate_files_exist(candidates):
    """
    Checks if the physical ovpn file exists
    """
    protocol = IvoNet.environment('PROTOCOL', "tcp/udp").lower()
    print("Filtering in protocol %s..." % protocol)
    ret = []
    for candidate in candidates:
        tcp = None
        udp = None
        if "tcp" in protocol:
            tcp = os.path.join(IvoNet.ovpn_tpc_dir(), candidate + ".tcp.ovpn")
        if "udp" in protocol:
            udp = os.path.join(IvoNet.ovpn_udp_dir(), candidate + ".udp.ovpn")
        if tcp and os.path.isfile(tcp):
            ret.append(tcp)
        if udp and os.path.isfile(udp):
            ret.append(udp)
    return ret


def process(location, server, max_load):
    """
    This process will retrieve a server json from NordVPN with all the servers available and
    filter them on the max_load provided. Servers still in the list must have less then the max_load
    percentage.
    The list will be filtered again on the location if provided so that only the list based on location
    and max_load will be left.
    Just to be sure that the physical ovpn files match the servers gotten from the endpoint
    As a last step a random server will be chosen from that list and the configuration will be adjusted accordingly.

    :param location: ISO code as location
    :param server: deseired server name to connect
    :param max_load: the max load percentage allowed
    :return:
    """
    servers = IvoNet.url_get(IvoNet.api_server_stats())
    servers = json.loads(servers)
    global_candidates = [
        key for key in servers
        if servers[key]["percent"] < max_load or (server and key.startswith(server))
    ]
    if global_candidates:
        print("Servers found with less then %s capacity" % max_load)
    else:
        print("No servers found :(")
        sys.exit(1)
    if location:
        candidates = [item for item in global_candidates if item.startswith(location)]
        if candidates:
            print("Valid location based server candidates found.")
        else:
            print(
                "No valid location based servers found that adhere to the max capacity. Falling back to the global server candidates.")
            candidates = global_candidates
    else:
        candidates = global_candidates

    candidates = check_candidate_files_exist(candidates)
    if not candidates:
        print("No servers found :(")
        sys.exit(1)

    print("Found %s servers." % len(candidates))

    if server:
        print("Choosing %s... from %d servers" % (server, len(candidates)))
        substr = server + '.'
        candidates = [c for c in candidates if substr in c]
        if len(candidates) == 0:
            print('Cannot find given server on candidates.')
            sys.exit(1)
        elif len(candidates) > 1:
            print('Given server name is ambiguous: %s' % str(candidates))
            sys.exit(1)
        choice = candidates[0]
        print('Chosen: %s' % os.path.split(choice)[1])
    else:
        secure_random = random.SystemRandom()
        choice = secure_random.choice(candidates)
        print("Randomly chosen: %s" % os.path.split(choice)[1])

    copyfile(choice, CONFIG_FILE)

    config = open(CONFIG_FILE, "r").read()

    with open(CONFIG_FILE, "w") as conf:
        config = config.replace("ping-restart 0", "ping-restart 120")
        conf.write(config)
        conf.write('\npull-filter ignore "auth-token"')
        conf.write("\nscript-security 2")
        conf.write("\nup /etc/openvpn/up.sh")
        conf.write("\ndown /etc/openvpn/down.sh")
        conf.write("\n")


def main():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "hl:m:n:vs:", ["help", "location=", "max_load=", "server=", "verbose"])
    except getopt.GetoptError as err:
        print(err)
        sys.exit(2)
    max_load = None
    location = None
    server = None
    for o, a in opts:
        if o in ("-v", "--verbose"):
            global verbose
            verbose = True
        elif o in ("-h", "--help"):
            usage()
            sys.exit(0)
        elif o in ("-l", "--location"):
            if a in ISO_CODES:
                location = a.lower()
            else:
                print("ISO_CODE [%s] not recognised." % a)
                sys.exit(2)
        elif o in ("-s", "--server"):
            server = a.lower()
        elif o in ("-m", "--max_load"):
            try:
                max_load = int(a)
            except TypeError:
                print("-c option should be followed by a number.")
                sys.exit(1)
        else:
            assert False, "unhandled option"
    if not server:
        try:
            server = os.environ["SERVER"]
        except KeyError:
            server = None
    if not location:
        try:
            location = os.environ["LOCATION"]
        except KeyError:
            location = None

    if not max_load:
        try:
            max_load = int(os.environ["MAX_LOAD"])
        except KeyError:
            max_load = 30

    process(location, server, max_load)


if __name__ == "__main__":
    main()
