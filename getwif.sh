#!/bin/bash
###################
# creates generator wallet in, gets an address, dumps its WIF privkey to standard out.
# Parameter $1 = command for bitcoin-cli (ie "bitcoin-cli" or "/snap/bitcoin-core/current/bin/./bitcoin-cli")
# -rpcport=17600 needed on Tails
# bitcoin-qt --server or bitcoind must already be running.
###################

temp=$(mktemp)	# /tmp directory
key=$(head -c64 /dev/urandom | base64)	# 64 byte wallet encryption key
$1 createwallet $temp false false "$key" false false &>1
$1 -rpcwallet=$temp walletpassphrase "$key" 1	# unlocks generator wallet for 1 second
printf $($1 -rpcwallet="$temp" dumpprivkey $($1 -rpcwallet="$temp" getnewaddress))
$1 -rpcwallet=$temp walletlock
$1 -rpcwallet=$temp unloadwallet &>1
rm $temp
unset $key $temp #deletes encryption key from memory so the wallet cannot be recovered
