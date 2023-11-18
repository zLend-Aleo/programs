import credits.aleo;
import zkid_nft_001.aleo;
program liquidity_pool.aleo;





struct Pool:
    current_loaned_token as u64;
    reserve_token as u64;

struct Loan:
    borrower as address;
    amount as u64;
    duration as u32;


mapping balance:
	key as address.public;
	value as u64.public;


mapping loan_id:
	key as field.public;
	value as u128.public;


mapping loan:
	key as u128.public;
	value as Loan.public;


mapping pool:
	key as field.public;
	value as Pool.public;


mapping withdraw:
	key as address.public;
	value as u64.public;

function add_liquidity:
    input r0 as u64.private;
    input r1 as credits.aleo/credits.record;
    assert.neq r0 0u64;
    call credits.aleo/transfer_private r1 aleo1fjmx66zrmfxx288udrw93re4x9xvxkuszwuegmf78prt3shc2yrscf6shw r0 into r2 r3;
    async add_liquidity self.caller r0 into r4;
    output r2 as credits.aleo/credits.record;
    output r3 as credits.aleo/credits.record;
    output r4 as liquidity_pool.aleo/add_liquidity.future;

finalize add_liquidity:
    input r0 as address.public;
    input r1 as u64.public;
    cast 0u64 0u64 into r2 as Pool;
    get.or_use pool[0field] r2 into r3;
    get.or_use balance[r0] 0u64 into r4;
    add r4 r1 into r5;
    set r5 into balance[r0];
    add r3.reserve_token r1 into r6;
    cast r3.current_loaned_token r6 into r7 as Pool;
    set r7 into pool[0field];


function remove_liquidity:
    input r0 as u64.private;
    assert.neq r0 0u64;
    async remove_liquidity self.caller r0 into r1;
    output r1 as liquidity_pool.aleo/remove_liquidity.future;

finalize remove_liquidity:
    input r0 as address.public;
    input r1 as u64.public;
    get pool[0field] into r2;
    get balance[r0] into r3;
    sub r3 r1 into r4;
    set r4 into balance[r0];
    sub r2.reserve_token r1 into r5;
    cast r2.current_loaned_token r5 into r6 as Pool;
    set r6 into pool[0field];
    set r1 into withdraw[r0];


function withdrawal:
    input r0 as address.private;
    input r1 as u64.private;
    input r2 as credits.aleo/credits.record;
    assert.eq self.caller aleo1fjmx66zrmfxx288udrw93re4x9xvxkuszwuegmf78prt3shc2yrscf6shw;
    call credits.aleo/transfer_private r2 r0 r1 into r3 r4;
    async withdrawal r0 r1 into r5;
    output r3 as credits.aleo/credits.record;
    output r4 as credits.aleo/credits.record;
    output r5 as liquidity_pool.aleo/withdrawal.future;

finalize withdrawal:
    input r0 as address.public;
    input r1 as u64.public;
    get withdraw[r0] into r2;
    assert.eq r2 r1;
    sub r2 r1 into r3;
    set r3 into withdraw[r0];


function get_loan:
    input r0 as u64.private;
    input r1 as u32.private;
    input r2 as zkid_nft_001.aleo/NFT.record;
    assert.neq r0 0u64;
    call zkid_nft_001.aleo/zkid_transfer_private r2 aleo1fjmx66zrmfxx288udrw93re4x9xvxkuszwuegmf78prt3shc2yrscf6shw into r3;
    async get_loan self.caller r0 r1 into r4;
    output r4 as liquidity_pool.aleo/get_loan.future;

finalize get_loan:
    input r0 as address.public;
    input r1 as u64.public;
    input r2 as u32.public;
    get.or_use loan_id[0field] 0u128 into r3;
    get pool[0field] into r4;
    sub r4.reserve_token r4.current_loaned_token into r5;
    gte r5 r1 into r6;
    assert.eq r6 true;
    cast r0 r1 r2 into r7 as Loan;
    set r7 into loan[r3];
    add r4.current_loaned_token r1 into r8;
    cast r8 r4.reserve_token into r9 as Pool;
    set r9 into pool[0field];
    add r3 1u128 into r10;
    set r10 into loan_id[0field];
