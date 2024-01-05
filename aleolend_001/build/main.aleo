import credits.aleo;
import zkid_nft_001.aleo;
program aleolend_001.aleo;





struct Pool:
    current_loaned_token as u64;
    reserve_token as u64;

struct Loan:
    borrower as address;
    amount as u64;
    duration as u32;
    sent as boolean;
    repaid as boolean;
    on_auction as boolean;


mapping balance:
	key as address.public;
	value as u64.public;


mapping loan_id_inc:
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


mapping acc_interest:
	key as field.public;
	value as u64.public;

function add_liquidity:
    input r0 as u64.private;
    input r1 as credits.aleo/credits.record;
    assert.neq r0 0u64;
    call credits.aleo/transfer_private r1 aleo1fjmx66zrmfxx288udrw93re4x9xvxkuszwuegmf78prt3shc2yrscf6shw r0 into r2 r3;
    async add_liquidity self.caller r0 into r4;
    output r2 as credits.aleo/credits.record;
    output r3 as credits.aleo/credits.record;
    output r4 as aleolend_001.aleo/add_liquidity.future;

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
    output r1 as aleolend_001.aleo/remove_liquidity.future;

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
    output r5 as aleolend_001.aleo/withdrawal.future;

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
    output r3 as zkid_nft_001.aleo/NFT.record;
    output r4 as aleolend_001.aleo/get_loan.future;

finalize get_loan:
    input r0 as address.public;
    input r1 as u64.public;
    input r2 as u32.public;
    get.or_use loan_id_inc[0field] 0u128 into r3;
    get pool[0field] into r4;
    sub r4.reserve_token r4.current_loaned_token into r5;
    gte r5 r1 into r6;
    assert.eq r6 true;
    cast r0 r1 r2 false false false into r7 as Loan;
    set r7 into loan[r3];
    add r4.current_loaned_token r1 into r8;
    cast r8 r4.reserve_token into r9 as Pool;
    set r9 into pool[0field];
    add r3 1u128 into r10;
    set r10 into loan_id_inc[0field];


function return_id_without_loan:
    input r0 as u128.private;
    input r1 as zkid_nft_001.aleo/NFT.record;
    call zkid_nft_001.aleo/zkid_transfer_private r1 r1.id_owner into r2;
    async return_id_without_loan r0 into r3;
    output r2 as zkid_nft_001.aleo/NFT.record;
    output r3 as aleolend_001.aleo/return_id_without_loan.future;

finalize return_id_without_loan:
    input r0 as u128.public;
    get loan[r0] into r1;
    gt r1.duration block.height into r2;
    assert.eq r2 true;


function send_loan:
    input r0 as u128.private;
    input r1 as u64.private;
    input r2 as credits.aleo/credits.record;
    input r3 as zkid_nft_001.aleo/NFT.record;
    mul r1 3u64 into r4;
    div r4 100u64 into r5;
    is.eq r5 0u64 into r6;
    ternary r6 1u64 r5 into r7;
    sub r1 r7 into r8;
    call credits.aleo/transfer_private r2 r3.owner r8 into r9 r10;
    async send_loan r0 r3.owner r1 r7 into r11;
    output r3 as zkid_nft_001.aleo/NFT.record;
    output r9 as credits.aleo/credits.record;
    output r10 as credits.aleo/credits.record;
    output r11 as aleolend_001.aleo/send_loan.future;

finalize send_loan:
    input r0 as u128.public;
    input r1 as address.public;
    input r2 as u64.public;
    input r3 as u64.public;
    assert.neq r2 0u64;
    get loan[r0] into r4;
    assert.neq r4.sent true;
    assert.eq r4.amount r2;
    cast r4.borrower r4.amount r4.duration true r4.repaid r4.on_auction into r5 as Loan;
    set r5 into loan[r0];
    get.or_use acc_interest[0field] 0u64 into r6;
    add r6 r3 into r7;
    set r7 into acc_interest[0field];


function repay_loan:
    input r0 as u128.private;
    input r1 as u64.private;
    input r2 as credits.aleo/credits.record;
    call credits.aleo/transfer_private r2 aleo1fjmx66zrmfxx288udrw93re4x9xvxkuszwuegmf78prt3shc2yrscf6shw r1 into r3 r4;
    async repay_loan r0 self.caller r1 into r5;
    output r3 as credits.aleo/credits.record;
    output r4 as credits.aleo/credits.record;
    output r5 as aleolend_001.aleo/repay_loan.future;

finalize repay_loan:
    input r0 as u128.public;
    input r1 as address.public;
    input r2 as u64.public;
    get loan[r0] into r3;
    assert.neq r3.repaid true;
    assert.eq r3.amount r2;
    cast r3.borrower r3.amount r3.duration r3.sent true r3.on_auction into r4 as Loan;
    set r4 into loan[r0];


function return_id:
    input r0 as u128.private;
    input r1 as address.private;
    input r2 as zkid_nft_001.aleo/NFT.record;
    call zkid_nft_001.aleo/zkid_transfer_private r2 r2.id_owner into r3;
    async return_id r0 r1 r2.id_owner into r4;
    output r3 as zkid_nft_001.aleo/NFT.record;
    output r4 as aleolend_001.aleo/return_id.future;

finalize return_id:
    input r0 as u128.public;
    input r1 as address.public;
    input r2 as address.public;
    assert.eq r1 r2;
    get loan[r0] into r3;
    assert.eq r3.repaid true;


function liquidate:
    input r0 as u128.private;
    async liquidate r0 into r1;
    output r1 as aleolend_001.aleo/liquidate.future;

finalize liquidate:
    input r0 as u128.public;
    get loan[r0] into r1;
    assert.eq r1.on_auction false;
    gt r1.duration block.height into r2;
    assert.eq r2 true;
    cast r1.borrower r1.amount r1.duration r1.sent r1.repaid true into r3 as Loan;
    set r3 into loan[r0];
