program zkid_nft_001.aleo;

struct URI:
    data0 as u128;
    data1 as u128;
    data2 as u128;
    data3 as u128;

record NFT:
    owner as address.private;
    id_owner as address.private;
    data0 as u128.private;
    data1 as u128.private;
    data2 as u128.private;
    data3 as u128.private;

record NFT_ownership:
    owner as address.private;
    nft_owner as address.private;


mapping general_settings:
	key as u8.public;
	value as u128.public;


mapping toggle_settings:
	key as u8.public;
	value as u32.public;

function initialize_collection:
    input r0 as u128.public;
    assert.eq self.caller aleo1fjmx66zrmfxx288udrw93re4x9xvxkuszwuegmf78prt3shc2yrscf6shw;
    async initialize_collection r0 into r1;
    output r1 as zkid_nft_001.aleo/initialize_collection.future;

finalize initialize_collection:
    input r0 as u128.public;
    get.or_use toggle_settings[0u8] 0u32 into r1;
    and r1 1u32 into r2;
    assert.eq r2 0u32;
    set r0 into general_settings[2u8];
    set 1u32 into toggle_settings[0u8];
    set 0u32 into toggle_settings[1u8];


function issue_zkid:
    input r0 as address.private;
    input r1 as URI.private;
    assert.eq self.caller aleo1fjmx66zrmfxx288udrw93re4x9xvxkuszwuegmf78prt3shc2yrscf6shw;
    cast r0 r0 r1.data0 r1.data1 r1.data2 r1.data3 into r2 as NFT.record;
    async issue_zkid into r3;
    output r2 as NFT.record;
    output r3 as zkid_nft_001.aleo/issue_zkid.future;

finalize issue_zkid:
    get toggle_settings[1u8] into r0;
    lte r0 block.height into r1;
    assert.eq r1 true;
    get toggle_settings[0u8] into r2;
    and r2 9u32 into r3;
    assert.eq r3 1u32;


function update_toggle_settings:
    input r0 as u32.public;
    assert.eq self.caller aleo1fjmx66zrmfxx288udrw93re4x9xvxkuszwuegmf78prt3shc2yrscf6shw;
    async update_toggle_settings r0 into r1;
    output r1 as zkid_nft_001.aleo/update_toggle_settings.future;

finalize update_toggle_settings:
    input r0 as u32.public;
    get toggle_settings[0u8] into r1;
    and r1 9u32 into r2;
    assert.eq r2 1u32;
    and r0 1u32 into r3;
    assert.eq r3 1u32;
    set r0 into toggle_settings[0u8];


function set_mint_block:
    input r0 as u32.public;
    assert.eq self.caller aleo1fjmx66zrmfxx288udrw93re4x9xvxkuszwuegmf78prt3shc2yrscf6shw;
    async set_mint_block r0 into r1;
    output r1 as zkid_nft_001.aleo/set_mint_block.future;

finalize set_mint_block:
    input r0 as u32.public;
    get toggle_settings[0u8] into r1;
    and r1 9u32 into r2;
    assert.eq r2 1u32;
    set r0 into toggle_settings[1u8];


function update_symbol:
    input r0 as u128.public;
    assert.eq self.caller aleo1fjmx66zrmfxx288udrw93re4x9xvxkuszwuegmf78prt3shc2yrscf6shw;
    async update_symbol r0 into r1;
    output r1 as zkid_nft_001.aleo/update_symbol.future;

finalize update_symbol:
    input r0 as u128.public;
    get toggle_settings[0u8] into r1;
    and r1 9u32 into r2;
    assert.eq r2 1u32;
    set r0 into general_settings[2u8];


function authorize:
    input r0 as NFT.record;
    async authorize into r1;
    output r1 as zkid_nft_001.aleo/authorize.future;

finalize authorize:
    assert.eq 0u8 1u8;


function zkid_transfer_private:
    input r0 as NFT.record;
    input r1 as address.private;
    cast r1 r0.id_owner r0.data0 r0.data1 r0.data2 r0.data3 into r2 as NFT.record;
    output r2 as NFT.record;


function prove_ownership:
    input r0 as NFT.record;
    input r1 as address.private;
    cast r0.owner r0.id_owner r0.data0 r0.data1 r0.data2 r0.data3 into r2 as NFT.record;
    cast r1 r0.owner into r3 as NFT_ownership.record;
    output r2 as NFT.record;
    output r3 as NFT_ownership.record;
