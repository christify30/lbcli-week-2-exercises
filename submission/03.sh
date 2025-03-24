# Created a SegWit address.
SegwitWalletAddress=$(bitcoin-cli -regtest -rpcwallet="btrustwallet" getnewaddress "" "bech32")

if [ -z "$SegwitWalletAddress" ]; then
  echo "Error: No address was generated. Check if the wallet exists and supports SegWit."
  exit 1
fi


# Add funds to the address.
bitcoin-cli -regtest generatetoaddress 101 "$SegwitWalletAddress"
# Return only the Address
echo "$SegwitWalletAddress"
