# Create a transaction whose fee can be later updated to a higher fee if it is stuck or doesn't get mined on time

# Amount of 20,000,000 satoshis to this address: 2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP 
# Use the UTXOs from the transaction below
# Raw transaction as given
# raw_tx="01000000000101c8b0928edebbec5e698d5f86d0474595d9f6a5b2e4e3772cd9d1005f23bdef772500000000ffffffff0276b4fa0000000000160014f848fe5267491a8a5d32423de4b0a24d1065c6030e9c6e000000000016001434d14a23d2ba08d3e3edee9172f0c97f046266fb0247304402205fee57960883f6d69acf283192785f1147a3e11b97cf01a210cf7e9916500c040220483de1c51af5027440565caead6c1064bac92cb477b536e060f004c733c45128012102d12b6b907c5a1ef025d0924a29e354f6d7b1b11b5a7ddff94710d6f0042f3da800000000"
# g=$(bitcoin-cli -regtest generatetoaddress 101 $(bitcoin-cli -regtest getnewaddress))
# # Extract the txid and vout from the raw transaction
# utxo_txid_1=$(bitcoin-cli -regtest decoderawtransaction "$raw_tx" | jq -r '.vin[0].txid')
# utxo_vout_0_amount=$(bitcoin-cli -regtest decoderawtransaction "$raw_tx" | jq -r '.vout[0].value')
# utxo_vout_1_amount=$(bitcoin-cli -regtest decoderawtransaction "$raw_tx" | jq -r '.vout[1].value')

# # Calculate the total input amount
# total_input=$(echo "$utxo_vout_0_amount + $utxo_vout_1_amount" | bc)

# # Create the new raw transaction
# recipient="2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP"
# new_tx=$(bitcoin-cli -regtest createrawtransaction '[{"txid": "'$utxo_txid_1'", "vout": 0, "sequence": 4294967294}, {"txid": "'$utxo_txid_1'", "vout": 1, "sequence": 4294967294}]' '{"'$recipient'": 0.2, "change_address": '"$(echo "$total_input - 0.2 - 0.0001" | bc)"'}')

# # Fund the raw transaction with fee rate and replaceable flag
# funded_tx=$(bitcoin-cli -regtest fundrawtransaction "$new_tx" '{"feeRate": 0.00001, "replaceable": true}' | jq -r '.hex')

# # Sign the transaction with the wallet
# signed_tx=$(bitcoin-cli -regtest signrawtransactionwithwallet "$funded_tx" | jq -r '.hex')

# # Output the signed transaction
# echo "$signed_tx"

# Generate blocks to ensure funds are available (regtest only)
g=$(bitcoin-cli -regtest generatetoaddress 101 $(bitcoin-cli -regtest getnewaddress))

# Define raw transaction and recipient address
raw_tx="01000000000101c8b0928edebbec5e698d5f86d0474595d9f6a5b2e4e3772cd9d1005f23bdef772500000000ffffffff0276b4fa0000000000160014f848fe5267491a8a5d32423de4b0a24d1065c6030e9c6e000000000016001434d14a23d2ba08d3e3edee9172f0c97f046266fb0247304402205fee57960883f6d69acf283192785f1147a3e11b97cf01a210cf7e9916500c040220483de1c51af5027440565caead6c1064bac92cb477b536e060f004c733c45128012102d12b6b907c5a1ef025d0924a29e354f6d7b1b11b5a7ddff94710d6f0042f3da800000000"
recipient="2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP"

# Get the actual transaction ID of the raw transaction (FIXED)
utxo_txid_1=$(bitcoin-cli -regtest decoderawtransaction "$raw_tx" | jq -r '.txid')

# Get UTXO values (proper JSON parsing)
vout0_amount=$(bitcoin-cli -regtest decoderawtransaction "$raw_tx" | jq -r '.vout[0].value')
vout1_amount=$(bitcoin-cli -regtest decoderawtransaction "$raw_tx" | jq -r '.vout[1].value')

# Create transaction inputs with proper RBF sequence (FIXED sequence number)
inputs=$(jq -n \
  --arg txid "$utxo_txid_1" \
  '[{"txid": $txid, "vout": 0, "sequence": 1}, {"txid": $txid, "vout": 1, "sequence": 1}]')

# Create outputs with proper JSON formatting (FIXED)
outputs=$(jq -n \
  --arg recipient "$recipient" \
  --argjson amount 0.2 \
  '{"($recipient)": $amount}' | sed 's/"(//g; s/)"//g')

# Create raw transaction
new_tx=$(bitcoin-cli -regtest createrawtransaction "$inputs" "$outputs")

# Fund transaction with automatic change handling (REMOVED manual change calculation)
funded_tx=$(bitcoin-cli -regtest fundrawtransaction "$new_tx" '{
    "feeRate": 0.00001,
    "replaceable": true,
    "changeAddress": "'$(bitcoin-cli -regtest getrawchangeaddress)'"
}' | jq -r '.hex')

# Sign transaction
signed_tx=$(bitcoin-cli -regtest signrawtransactionwithwallet "$funded_tx" | jq -r '.hex')

# Output result
echo "$signed_tx"



