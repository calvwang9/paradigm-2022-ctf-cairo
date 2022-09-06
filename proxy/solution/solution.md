# Cairo-proxy solution

Flag: player's balance = 50,000 ERC20 tokens

## Setup:

Deploy ERC20 and deploy proxy contract pointing to the ERC20 contract. ERC20 owner initialized to `owner_account = 123456789` with an initial supply of 50,000 tokens. Owner transfers 25,000 tokens each to accounts `1337` and `7331`.

## Solution 1:

Bug in ERC20 `burn` balance check means that we can burn any arbitrary amount greater than player's balance. Underflow `uint256_sub` to set player balance to exactly `50,000` by burning `(maxUint256 - 50,000)` tokens, thus passing the flag.

## Solution 2:

The imported `utils` file contains external functions which are unintentionally imported into main contract, allowing anyone to call these authorized read/write functions without access restrictions. Calculate the address for the `balance` storage variable for the player's address and
overwrite it using `auth_write_storage` to the required token amount.

## Takeaways

- Be aware of declaring external functions in imported files as they will also be exposed.
- Also be aware of storage variable collisions, such as with `owner` in this case
- Note: both of these issues are no longer possible in Cairo v0.10 and above
