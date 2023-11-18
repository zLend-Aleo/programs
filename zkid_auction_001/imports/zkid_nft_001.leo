// The 'zkid_nft_001' program.
program zkid_nft_001.aleo {
    // dummy address, ie the aleo address equivalent of 0: aleo1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq3ljyzc
    // struct TokenId {
    //     data1: u128, // Part 1 of the image data -- i.e., a way to link this nft to image or aws
    //     data2: u128,
    // }

    // base uri ascii bits. Include as many data pieces as necessary to encapsulate the uri. Padded with 0s at the end.
    struct URI {
        data0: u128, // Part 1 of the base uri in bits. Bits should be the representation of the hexadecimal bytes for the ASCII text of the URL
        data1: u128,
        data2: u128,
        data3: u128
    }

    // struct SymbolBits {
    //     data: u128 // The sybmol's ascii text represented in bits, and the u128 value of the bitstring.
    // }

    record NFT {
        private owner: address,
        private id_owner: address,
        data0: u128, // Part 1 of the base uri in bits. Bits should be the representation of the hexadecimal bytes for the ASCII text of the URL
        data1: u128,
        data2: u128,
        data3: u128
        // private edition: scalar, // which edition of the nft this particular one is -- will be 0 for unique NFTs
    }

    // record NFT_mint {
    //     private owner: address,
    //     private amount: u8,
    // }

    // record NFT_claim {
    //     private owner: address,
    //     private claim: field
    // }

    // a way to prove ownership of an nft privately
    record NFT_ownership {
        private owner: address,
        private nft_owner: address,
        // private data: BaseURI,
        // private edition: scalar, // which edition of the nft this particular one is -- will be 0 for unique NFTs
    }

    // mapping nft_owners: field => address;

    // keys: setting index
    // values: setting value
    mapping general_settings: u8 => u128;

    // keys: index of the nft to mint
    // values: hash of the token id + edition
    // mapping nfts_to_mint: u128 => field;

    // keys: fields that represent claims for having minted an nft
    // values: fields that are the hash of the nft that was minted
    // mapping claims_to_nfts: field => field;

    // keys: just two, 0u8 which corresponds to different on/off settings for the contract, and 1u8
    // which corresponds to the mint block height.
    // values: the bitstring that represents the settings that can be toggled
    // in order of least significant bit index to most significant bit:
    // 0: collection has been initialized
    // 1: can minters mint
    // 2: do minters have to have a mint record (i.e. is the private whitelist a requirement)
    // 3: is the collection frozen
    mapping toggle_settings: u8 => u32;

    transition initialize_collection(
        // public total: u128,
        public symbol: u128,
        // public base_uri: BaseURI,
    ) {
        assert_eq(self.caller, aleo1fjmx66zrmfxx288udrw93re4x9xvxkuszwuegmf78prt3shc2yrscf6shw);
        return then finalize(symbol);
    }

    finalize initialize_collection(
        // public total: u128,
        public symbol: u128,
        // public base_uri: BaseURI,
    ) {
        // Ensure initialize cannot be called twice!
        let toggle_settings_status: u32 = toggle_settings.get_or_use(0u8, 0u32);
        let is_initialized: u32 = toggle_settings_status & 1u32;
        assert_eq(is_initialized, 0u32);

        // general_settings.set(0u8, 0u128); // number of mintable NFTs (all editions)
        // general_settings.set(1u8, total); // Number of total NFTs (first-editions) that can be minted
        general_settings.set(2u8, symbol); // Symbol for the NFT
        // general_settings.set(3u8, base_uri.data0); // Base URI for NFT
        // general_settings.set(4u8, base_uri.data1);
        // general_settings.set(5u8, base_uri.data2);
        // general_settings.set(6u8, base_uri.data3);
        // initialized flag = 0b0000...0001 = 1u32
        // minting flag = 0b0000...0010 = 2u32
        // whitelist flag = 0b0000...0100 = 4u32
        // frozen flag = 0b0000...1000 = 8u32
        // defaults -- not frozen, whitelist required, not minting, initialized
        // 0b0000...0101 = 5u32.

        // only initialize = 1u32
        toggle_settings.set(0u8, 1u32);
        toggle_settings.set(1u8, 0u32); // block height when mint is allowed
    }

    transition issue_zkid(private requester: address, private personal_info: URI) -> NFT {
        assert_eq(self.caller, aleo1fjmx66zrmfxx288udrw93re4x9xvxkuszwuegmf78prt3shc2yrscf6shw);
        return NFT {
            owner: requester,
            id_owner: requester,
            data0: personal_info.data0,
            data1: personal_info.data1,
            data2: personal_info.data2,
            data3: personal_info.data3,
        } then finalize ();
    }

    finalize issue_zkid() {
        // Ensure mint block height is less than current block height
        let mint_block: u32 = toggle_settings.get(1u8);
        let passed_height_check: bool = mint_block <= block.height;
        assert_eq(passed_height_check, true);

        // Ensure collection is not frozen, minting is allowed, and is initialized, 
        let toggle_settings_status: u32 = toggle_settings.get(0u8);
        // frozen & minting & initialized flags = 0b0000...1001 = 9u32
        // what the settings should be = 0b0000...0001 = 1u32
        let is_initialized_and_not_frozen: u32 = toggle_settings_status & 9u32;
        assert_eq(is_initialized_and_not_frozen, 1u32);
    }

    // call this function to toggle minting, the whitelist requirement, or to permanently freeze the contract
    transition update_toggle_settings(public toggle_settings_bitstring: u32) {
        assert_eq(self.caller, aleo1fjmx66zrmfxx288udrw93re4x9xvxkuszwuegmf78prt3shc2yrscf6shw);
        return then finalize(toggle_settings_bitstring);
    }

    finalize update_toggle_settings(public toggle_settings_bitstring: u32) {
        // Ensure collection is initialized and not frozen.
        let toggle_settings_status: u32 = toggle_settings.get(0u8);
        // initialized & frozen flags = 0b0000...1001 = 9u32
        // what the settings should be = 0b0000...0001 = 1u32
        let is_initialized_and_not_frozen: u32 = toggle_settings_status & 9u32;
        assert_eq(is_initialized_and_not_frozen, 1u32);

        // Ensure updated settings are not uninitializing the collection.
        let still_initialized: u32 = toggle_settings_bitstring & 1u32;
        assert_eq(still_initialized, 1u32);

        toggle_settings.set(0u8, toggle_settings_bitstring);
    }

    transition set_mint_block(public mint_block: u32) {
        assert_eq(self.caller, aleo1fjmx66zrmfxx288udrw93re4x9xvxkuszwuegmf78prt3shc2yrscf6shw);
        return then finalize(mint_block);
    }

    finalize set_mint_block(public mint_block: u32) {
        // Ensure collection is initialized and not frozen.
        let toggle_settings_status: u32 = toggle_settings.get(0u8);
        // initialized & frozen flags = 0b0000...1001 = 9u32
        // what the settings should be = 0b0000...0001 = 1u32
        let is_initialized_and_not_frozen: u32 = toggle_settings_status & 9u32;
        assert_eq(is_initialized_and_not_frozen, 1u32);

        toggle_settings.set(1u8, mint_block);
    }

    transition update_symbol(public symbol: u128) {
        assert_eq(self.caller, aleo1fjmx66zrmfxx288udrw93re4x9xvxkuszwuegmf78prt3shc2yrscf6shw);
        return then finalize(symbol);
    }

    finalize update_symbol(public symbol: u128) {
        // Ensure collection is initialized and not frozen.
        let toggle_settings_status: u32 = toggle_settings.get(0u8);
        // initialized & frozen flags = 0b0000...1001 = 9u32
        // what the settings should be = 0b0000...0001 = 1u32
        let is_initialized_and_not_frozen: u32 = toggle_settings_status & 9u32;
        assert_eq(is_initialized_and_not_frozen, 1u32);

        general_settings.set(2u8, symbol);
    }

    // Proof that you own an nft without revealing the nft.
    // this burn never actually destroys the nft as the finalize
    // block is guaranteed to fail.
    transition authorize(
        nft: NFT
    )
    {
        return then finalize();
    }

    finalize authorize(
    )
    {
        // fails on purpose, so that the nft is not burned.
        assert_eq(0u8, 1u8);
    }

    transition zkid_transfer_private(
        nft: NFT,
        private receiver: address
    ) -> NFT
    {
        return NFT {
            owner: receiver,
            id_owner: nft.id_owner,
            data0: nft.data0,
            data1: nft.data1,
            data2: nft.data2,
            data3: nft.data3,
        };
    }

    transition prove_ownership(private nft: NFT, private prove_to: address) -> (NFT, NFT_ownership) {
        return (
            NFT {
                owner: nft.owner,
                id_owner: nft.id_owner,
                data0: nft.data0,
                data1: nft.data1,
                data2: nft.data2,
                data3: nft.data3,
            },
            NFT_ownership {
                owner: prove_to,
                nft_owner: nft.owner,
            }
        );
    }
}
