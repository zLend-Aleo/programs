echo "==========Send credits to Admin Address==========="
snarkos developer execute --private-key APrivateKey1zkpBjpEgLo4arVUkQmcLdKQMiAKGaHAQVVwmF8HQby8vdYs --query http://localhost:3030 \
credits.aleo transfer_public "aleo1fjmx66zrmfxx288udrw93re4x9xvxkuszwuegmf78prt3shc2yrscf6shw" "50000000u64" \
--broadcast http://localhost:3030/testnet3/transaction/broadcast
echo -e "\n"
sleep 3

echo "=============Deploying============="
snarkos developer deploy --private-key APrivateKey1zkpDZLpPdRhc2xNgyhbgPB7LY2KCfk1Yakn1RVwtaAEQAqe --query http://localhost:3030 \
--priority-fee 600 zkid_lp_001.aleo --path ./build/ --broadcast http://localhost:3030/testnet3/transaction/broadcast
echo -e "\n"