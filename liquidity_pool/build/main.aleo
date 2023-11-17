import credits.aleo;
program liquidity_pool.aleo;


struct Pool:
    current_loaned_token as u64;
    reserve_token as u64;

struct Loan:
    amount as u64;
    duration as u128;


mapping balance:
	key as field.public;
	value as u64.public;


mapping loan:
	key as field.public;
	value as u64.public;


mapping pool:
	key as field.public;
	value as Pool.public;

function add_liquidity:
    input r0 as u64.private;
    input r1 as credits.aleo/credits.record;
    assert.neq r0 0u64;
    call credits.aleo/transfer_private r1 aleo1fjmx66zrmfxx288udrw93re4x9xvxkuszwuegmf78prt3shc2yrscf6shw r0 into r2 r3;
    hash.bhp256 self.caller into r4 as field;
    async add_liquidity r4 r0 into r5;
    output r2 as credits.aleo/credits.record;
    output r3 as credits.aleo/credits.record;
    output r5 as liquidity_pool.aleo/add_liquidity.future;

finalize add_liquidity:
    input r0 as field.public;
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
    hash.bhp256 self.caller into r1 as field;
    async remove_liquidity r1 r0 into r2;
    output r2 as liquidity_pool.aleo/remove_liquidity.future;

finalize remove_liquidity:
    input r0 as field.public;
    input r1 as u64.public;
    cast 0u64 0u64 into r2 as Pool;
    get.or_use pool[0field] r2 into r3;
    get.or_use balance[r0] 0u64 into r4;
    add r4 r1 into r5;
    set r5 into balance[r0];
    add r3.reserve_token r1 into r6;
    cast r3.current_loaned_token r6 into r7 as Pool;
    set r7 into pool[0field];
