echo "==========Send credits to Admin Address==========="
snarkos developer execute --private-key APrivateKey1zkpBjpEgLo4arVUkQmcLdKQMiAKGaHAQVVwmF8HQby8vdYs --query http://localhost:3030 \
credits.aleo transfer_public "aleo1fjmx66zrmfxx288udrw93re4x9xvxkuszwuegmf78prt3shc2yrscf6shw" "50000000u64" \
--broadcast http://localhost:3030/testnet3/transaction/broadcast
sleep 3

echo "==========Check Balance==========="
curl http://localhost:3030/testnet3/program/credits.aleo/mapping/account/aleo1fjmx66zrmfxx288udrw93re4x9xvxkuszwuegmf78prt3shc2yrscf6shw
echo -e "\n"
sleep 3

echo "=============Deploying zkID_NFT============="
snarkos developer deploy --private-key APrivateKey1zkpDZLpPdRhc2xNgyhbgPB7LY2KCfk1Yakn1RVwtaAEQAqe --query http://localhost:3030 \
--priority-fee 600 zkid_nft_001.aleo --path ./zkid_nft_001/build/ --broadcast http://localhost:3030/testnet3/transaction/broadcast
sleep 3

echo "=============Deploying zkID_LP============="
snarkos developer deploy --private-key APrivateKey1zkpDZLpPdRhc2xNgyhbgPB7LY2KCfk1Yakn1RVwtaAEQAqe --query http://localhost:3030 \
--priority-fee 600 zkid_lp_001.aleo --path ./liquidity_pool/build/ --broadcast http://localhost:3030/testnet3/transaction/broadcast
sleep 3

echo "=============Deploying zkID_Auction============="
snarkos developer deploy --private-key APrivateKey1zkpDZLpPdRhc2xNgyhbgPB7LY2KCfk1Yakn1RVwtaAEQAqe --query http://localhost:3030 \
--priority-fee 600 zkid_auction_001.aleo --path ./zkid_auction_001/build/ --broadcast http://localhost:3030/testnet3/transaction/broadcast
sleep 3
