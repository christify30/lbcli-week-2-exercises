# Created a SegWit address.
SegwitWalletAddress=$(bitcoin-cli -regtest -rpcwallet="btrustwallet" getnewaddress "" "bech32")
echo "the created walet"
echo "$SegwitWalletAddress"

# Add funds to the address.
bitcoin-cli -regtest generatetoaddress 101 "$SegwitWalletAddress"
# Return only the Address
echo "$SegwitWalletAddress"
