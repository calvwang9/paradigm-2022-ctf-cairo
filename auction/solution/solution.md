# Cairo-auction solution

Flag: current_winner of auction (id=1) = player_address

## Setup:

Accounts:

- `owner = 123456789`
- `bidder_1 = 123`
- `bidder_2 = 456`
- `player = 1111`

Contracts:

- ERC20 contract with 6 decimals and an initial supply of 1,000,000 minted to `owner`.
- Auction contract with `owner = 123456789`, and `token_address` = deployed ERC20 address.

State:

- Transfer 100,000 tokens from `owner` to `bidder_1`
- Transfer 100,000 tokens from `owner` to `bidder_2`
- Transfer 50,000 tokens from `owner` to `player`
- Start auction, (id=1)
- `bidder_1` approves auction contract to spend 100,000 tokens
- `bidder_1` calls `increase_credit` and `raise_bid` for 100,000 tokens
- `bidder_2` approves auction contract to spend 100,000 tokens
- `bidder_2` calls `increase_credit` and `raise_bid` for 100,000 tokens

## Solution:

There is a lack of sanitisation on the Uint256 input amount across all of the auction functions, which means invalid inputs can be passed in to invoke unexpected behaviour.
Using the invalid uint256 `amount = Uint256(2**128 + 1, 0)` as the input to `raise_bid`, we can pass both the 'enough balance' check as well as the 'is_new_winning_bid' check,
resulting in the player being set as the `current_winner` and passing the challenge.

### Passing the 'enough balance' check:

```
let (enough_balance) = uint256_le(amount, unlocked_balance)
assert enough_balance = 1
```

Breaking down `uint256_le`:

- `uint256_le(a, b)` returns the negation of `uint256_lt(b, a)`
- `uint256_lt` compares the `low` field of the inputs (if high is the same) -> `is_le(a.low + 1, b.low)`
- `is_le(a, b)` returns the result of `is_nn(b - a)`
- `is_nn` returns `1` if `(b-a) >= 0` (or more precisely `0 <= (b-a) < RANGE_CHECK_BOUND`), `0` otherwise

We ultimately want `is_nn` to return `0`, which results in `uint256_le` returning `1` (TRUE):

- `RANGE_CHECK_BOUND = 2^128`
- `unlocked_balance = Uint256(0, 0)` (upon initialization)
- `amount = Uint256(2**128 + 1, 0)` (invalid Uint256 input amount)
- `is_nn: (2**128 + 1) - 1 == 2**128 !< RANGE_CHECK_BOUND` -> returns `0`

### Passing the 'is_new_winning_bid' check:

```
let (winning_bid) = _winning_bid.read(auction_id)
let (is_new_winning_big) = uint256_lt(winning_bid, new_balance)
if is_new_winning_big == 1:
    _winning_bid.write(auction_id=auction_id, value=new_balance)
    _current_winner.write(auction_id=auction_id, value=caller)
```

With input `amount = Uint256(2**128 + 1, 0)`:

- `winning_bid = 100,000` (from `bidder_1`)
- `is_nn: (2**128 + 1) - 100000 == 2**128 - 99999 < RANGE_CHECK_BOUND` -> return `1`
- `uint256_lt` returns `1`, write `player` to `_current_winner`
- $ profit $

## Takeaways

- Always sanitise/check validity of inputs - in the case of Uint256, use `uint256_check` from the uint256 stlib
