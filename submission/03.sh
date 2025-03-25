# Created a SegWit address.
SegwitWalletAddress=$(bitcoin-cli -regtest -rpcwallet="btrustwallet" getnewaddress "" "bech32")
# Add funds to the address.
AddFunds=$(bitcoin-cli -regtest generatetoaddress 101 "$SegwitWalletAddress")
# Return only the Address
echo "$SegwitWalletAddress"
