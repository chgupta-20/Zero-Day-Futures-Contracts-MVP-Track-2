module futures_addr::quant_futures {
    use std::signer;
    use aptos_framework::timestamp;
    use aptos_framework::event;

    const E_INVALID_AMOUNT: u64 = 1;
    const E_POSITION_NOT_FOUND: u64 = 2;
    const E_ALREADY_SETTLED: u64 = 3;
    const E_INVALID_LEVERAGE: u64 = 4;

    struct Position has key {
        margin: u64,
        leverage: u8,
        entry_price: u64,
        is_long: bool,
        expiry_timestamp: u64,
        is_settled: bool,
        payout: u64,
        is_liquidated: bool,
    }

    #[event]
    struct PositionOpened has drop, store {
        user: address,
        margin: u64,
        leverage: u8,
        entry_price: u64,
        is_long: bool,
    }

    #[event]
    struct PositionSettled has drop, store {
        user: address,
        final_price: u64,
        payout: u64,
        is_liquidated: bool,
    }

    public entry fun open_position(
        account: &signer,
        margin: u64,
        leverage: u8,
        current_price: u64,
        is_long: bool
    ) acquires Position {
        let addr = signer::address_of(account);
        assert!(margin > 0, E_INVALID_AMOUNT);
        assert!(leverage >= 1 && leverage <= 10, E_INVALID_LEVERAGE);

        let expiry = timestamp::now_seconds() + 86400;

        if (exists<Position>(addr)) {
            let pos = borrow_global_mut<Position>(addr);
            pos.margin = margin;
            pos.leverage = leverage;
            pos.entry_price = current_price;
            pos.is_long = is_long;
            pos.expiry_timestamp = expiry;
            pos.is_settled = false;
            pos.payout = 0;
            pos.is_liquidated = false;
        } else {
            move_to(account, Position {
                margin,
                leverage,
                entry_price: current_price,
                is_long,
                expiry_timestamp: expiry,
                is_settled: false,
                payout: 0,
                is_liquidated: false,
            });
        };

        event::emit(PositionOpened {
            user: addr,
            margin,
            leverage,
            entry_price: current_price,
            is_long
        });
    }

    public entry fun settle_position(
        account: &signer,
        simulated_final_price: u64
    ) acquires Position {
        let addr = signer::address_of(account);
        assert!(exists<Position>(addr), E_POSITION_NOT_FOUND);
        
        let pos = borrow_global_mut<Position>(addr);
        assert!(!pos.is_settled, E_ALREADY_SETTLED);

        let price_diff = if (simulated_final_price > pos.entry_price) {
            simulated_final_price - pos.entry_price
        } else {
            pos.entry_price - simulated_final_price
        };

        let pnl_delta = (pos.margin * (pos.leverage as u64) * price_diff) / pos.entry_price;

        let is_profit = if (pos.is_long) {
            simulated_final_price > pos.entry_price
        } else {
            simulated_final_price < pos.entry_price
        };

        if (is_profit) {
            pos.payout = pos.margin + pnl_delta;
        } else {
            if (pnl_delta >= pos.margin) {
                pos.payout = 0; 
                pos.is_liquidated = true;
            } else {
                pos.payout = pos.margin - pnl_delta;
            }
        };

        pos.is_settled = true;
        event::emit(PositionSettled {
            user: addr,
            final_price: simulated_final_price,
            payout: pos.payout,
            is_liquidated: pos.is_liquidated
        });
    }

    #[view]
    public fun get_position(addr: address): (u64, u8, u64, bool, u64, bool, u64, bool) acquires Position {
        let pos = borrow_global<Position>(addr);
        (pos.margin, pos.leverage, pos.entry_price, pos.is_long, pos.expiry_timestamp, pos.is_settled, pos.payout, pos.is_liquidated)
    }
}
