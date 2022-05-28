#!/usr/bin/env bash
###################
# Creates generator wallet, gets address, dumps its WIF key, leaves no traces behind.
# Parameter $1 = command path for bitcoin-cli ie 'bitcoin-cli' or 
# '/snap/bitcoin-core/current/bin/bitcoin-cli'. Tails usually needs '-rpcport=17600')
# Call this script with 'bash getwif.sh [Path to bitcoin-cli]'
# Note: bitcoind must already be running or 'Enable RPC Server' checked in GUI options and restart.
###################

temp=$(mktemp)	# creates temporary file, stores path in temp
key=$(head -c64 /dev/urandom | base64)	# 64 byte wallet encryption key to crypto-shred the wallet
$1 createwallet $temp false false "$key" false false >/dev/null
$1 -rpcwallet=$temp walletpassphrase "$key" 1	# unlocks generator wallet for 1 second
$1 -rpcwallet="$temp" dumpprivkey $($1 -rpcwallet="$temp" getnewaddress)
$1 -rpcwallet=$temp walletlock
$1 -rpcwallet=$temp unloadwallet >/dev/null
rm $temp
unset $key $temp #deletes encryption key from memory so the wallet private keys cannot be recovered
