# zkid_nft_001.aleo

## Original Steps
### Admin
1. Initialize collection (public total: u128, public symbol: u128, public base_uri: BaseURI)
2. Add NFT (public tokenId: TokenId, public edition: scalar) *delete
3. Add minter (private minter: address, public amount: u8) *delete

### User
1. mint (nft_mint: NFT_mint, private hiding_nonce: scalar) *delete 
2. claim_nft (nft_claim: NFT_claim, private tokenId: TokenId, private edition: scalar) *delete
3. prove_ownership (private nft: NFT, private prove_to: address)

## Our Steps
### Admin
1. Initialize collection (public symbol: u128)
2. issue_zkid (private requester: address, private personal_info: BaseURI)

### User
1. prove_ownership (private nft: NFT, private prove_to: address)
2. transfer_private (nft: NFT, private receiver: address)