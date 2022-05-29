#!/usr/bin/env python3
###################
# Gets WIF Bitcoin seed from standard input, prints corresponding master xprv to standard output
# Leaves no filesystem traces behind unlike "sethdseed" plus "dumpwallet" method in Bitcoin core.
# Call this script with 'bash getwif.sh [Path to bitcoin-cli] | python3 wif2xprv.py' or
# 'python3 wif2xprv.py', then paste WIF and hit enter
# Avoid using 'echo "WIF" | python3 wif2xprv.py' as it will log the WIF in ~/.bash_history
###################

import hashlib
import hmac

BASE58_ALPHABET = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'

def decode58(s):
    decoded = 0
    multi = 1
    s = s[::-1]
    for char in s:
        decoded += multi * BASE58_ALPHABET.index(char)
        multi = multi * 58
    return decoded

def base58_encode(s):
    s = s + hashlib.sha256(hashlib.sha256(s).digest()).digest()[:4]
    num = int.from_bytes(s, 'big')
    result = ''
    while num > 0:
        num, mod = divmod(num, 58)
        result = BASE58_ALPHABET[mod] + result
    return result

def xpriv(s):
    prefix = bytes.fromhex("0488ADE4000000000000000000")
    i = hmac.digest( b'Bitcoin seed', s, hashlib.sha512)
    return base58_encode(prefix + i[32:] + b'\x00' + i[:32])

print(xpriv(decode58(input()).to_bytes(38, "big" )[1:33]))
