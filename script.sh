# Dev node Acc
#   Private Key  APrivateKey1zkpBjpEgLo4arVUkQmcLdKQMiAKGaHAQVVwmF8HQby8vdYs
#      View Key  AViewKey1iKKSsdnatHcm27goNC7SJxhqQrma1zkq91dfwBdxiADq
#       Address  aleo12ux3gdauck0v60westgcpqj7v8rrcr3v346e4jtq04q7kkt22czsh808v2

# Admin Acc
#   Private Key  APrivateKey1zkpDZLpPdRhc2xNgyhbgPB7LY2KCfk1Yakn1RVwtaAEQAqe
#      View Key  AViewKey1etkQbHePLByd9VqxLwey99nn6GHU8Xi13MT6y6MxYGpz
#       Address  aleo1fjmx66zrmfxx288udrw93re4x9xvxkuszwuegmf78prt3shc2yrscf6shw

# User Acc
#   Private Key  APrivateKey1zkp6tyvVpuuKDSc5J7WTFNaHPNx9UwSc2g7LA1xyVEau335
#      View Key  AViewKey1donmrSitoGkzg4RGJAEVZmS7ZUpL5uPUUXPvLEz4yktQ
#       Address  aleo1gf64vc4kxlpapnmfq72e0dshtshv43gezf7fnw555llm7mf5dqzsr6pf60



# echo "==========Send credits to Admin Address==========="
# snarkos developer execute --private-key APrivateKey1zkpBjpEgLo4arVUkQmcLdKQMiAKGaHAQVVwmF8HQby8vdYs --query http://localhost:3030 \
# credits.aleo transfer_public "aleo1fjmx66zrmfxx288udrw93re4x9xvxkuszwuegmf78prt3shc2yrscf6shw" "50000000u64" \
# --broadcast http://localhost:3030/testnet3/transaction/broadcast
# sleep 4

# echo "==========Check Balance==========="
# curl http://localhost:3030/testnet3/program/credits.aleo/mapping/account/aleo1fjmx66zrmfxx288udrw93re4x9xvxkuszwuegmf78prt3shc2yrscf6shw
# echo -e "\n"

# echo "=============Deploying zkID_NFT============="
# snarkos developer deploy --private-key APrivateKey1zkpDZLpPdRhc2xNgyhbgPB7LY2KCfk1Yakn1RVwtaAEQAqe --query http://localhost:3030 \
# --priority-fee 600 zkid_nft_001.aleo --path ./zkid_nft_001/build/ --broadcast http://localhost:3030/testnet3/transaction/broadcast

echo "=============Deploying zkID_LP============="
snarkos developer deploy --private-key APrivateKey1zkpDZLpPdRhc2xNgyhbgPB7LY2KCfk1Yakn1RVwtaAEQAqe --query http://localhost:3030 \
--priority-fee 600 zkid_lp_001.aleo --path ./liquidity_pool/build/ --broadcast http://localhost:3030/testnet3/transaction/broadcast

echo "=============Deploying zkID_Auction============="
snarkos developer deploy --private-key APrivateKey1zkpDZLpPdRhc2xNgyhbgPB7LY2KCfk1Yakn1RVwtaAEQAqe --query http://localhost:3030 \
--priority-fee 600 zkid_auction_001.aleo --path ./zkid_auction_001/build/ --broadcast http://localhost:3030/testnet3/transaction/broadcast
sleep 4

# echo "==========Check Deployments==========="
# curl http://localhost:3030/testnet3/program/zkid_auction_001.aleo
# echo -e "\n"

# echo "==========Send credits to User Address==========="
# snarkos developer execute --private-key APrivateKey1zkpBjpEgLo4arVUkQmcLdKQMiAKGaHAQVVwmF8HQby8vdYs --query http://localhost:3030 \
# credits.aleo transfer_public "aleo1gf64vc4kxlpapnmfq72e0dshtshv43gezf7fnw555llm7mf5dqzsr6pf60" "50000000u64" \
# --broadcast http://localhost:3030/testnet3/transaction/broadcast
# sleep 4

# echo "==========Check Balance==========="
# curl http://localhost:3030/testnet3/program/credits.aleo/mapping/account/aleo1gf64vc4kxlpapnmfq72e0dshtshv43gezf7fnw555llm7mf5dqzsr6pf60
# echo -e "\n"

# echo "==========Initialize zkID==========="
# snarkos developer execute --private-key APrivateKey1zkpDZLpPdRhc2xNgyhbgPB7LY2KCfk1Yakn1RVwtaAEQAqe --query http://localhost:3030 \
# zkid_nft_001.aleo initialize_collection "111u128" \
# --broadcast http://localhost:3030/testnet3/transaction/broadcast
# sleep 4

# echo "==========Issue zkID to User Address==========="
# snarkos developer execute --private-key APrivateKey1zkpDZLpPdRhc2xNgyhbgPB7LY2KCfk1Yakn1RVwtaAEQAqe --query http://localhost:3030 \
# zkid_nft_001.aleo issue_zkid "aleo12ux3gdauck0v60westgcpqj7v8rrcr3v346e4jtq04q7kkt22czsh808v2" "{data0: 0u128, data1: 1u128, data2: 2u128, data3: 3u128}" \
# --broadcast http://localhost:3030/testnet3/transaction/broadcast
# sleep 4

# echo "==========Scan for zkID record==========="
# snarkos developer scan --private-key APrivateKey1zkpBjpEgLo4arVUkQmcLdKQMiAKGaHAQVVwmF8HQby8vdYs --endpoint http://localhost:3030  --last 10

# echo "==========Convert credits to private==========="
# snarkos developer execute --private-key APrivateKey1zkpBjpEgLo4arVUkQmcLdKQMiAKGaHAQVVwmF8HQby8vdYs --query http://localhost:3030 \
# credits.aleo transfer_public_to_private "aleo12ux3gdauck0v60westgcpqj7v8rrcr3v346e4jtq04q7kkt22czsh808v2" "10000000u64" \
# --broadcast http://localhost:3030/testnet3/transaction/broadcast
# sleep 4

echo "==========Add liquidity==========="
snarkos developer execute --private-key APrivateKey1zkpBjpEgLo4arVUkQmcLdKQMiAKGaHAQVVwmF8HQby8vdYs --query http://localhost:3030 \
zkid_lp_001.aleo add_liquidity "10u64" "{  owner: aleo12ux3gdauck0v60westgcpqj7v8rrcr3v346e4jtq04q7kkt22czsh808v2.private,  microcredits: 10000000u64.private,  _nonce: 7455269198454805004634905518857350098632171531425869103609718119977571890542group.public}" \
--broadcast http://localhost:3030/testnet3/transaction/broadcast