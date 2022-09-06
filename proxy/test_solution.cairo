%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_contract_address

@contract_interface
namespace IERC20:
    func initialize(owner_account : felt, initial_supply : Uint256) -> ():
    end

    func balanceOf(account : felt) -> (balance : Uint256):
    end

    func transfer(recipient : felt, amount : Uint256):
    end

    func burn(account : felt, amount : Uint256):
    end

    func mint(recipient : felt, amount : Uint256):
    end
end

@contract_interface
namespace IUtils:
    func auth_read_storage(auth_account : felt, address : felt) -> (value : felt):
    end

    func auth_write_storage(auth_account : felt, address : felt, value : felt):
    end
end

@view
func __setup__{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    local proxy
    %{
        class_hash = declare("./proxy/contracts/almost_erc20.cairo").class_hash
        context.erc20 = deploy_contract("./proxy/contracts/almost_erc20.cairo").contract_address
        context.proxy = deploy_contract("./proxy/contracts/proxy.cairo", [class_hash]).contract_address
        ids.proxy = context.proxy
    %}

    let owner_account = 123456789
    let initial_supply = Uint256(50000000000000000000000, 0)
    %{ stop_prank_callable = start_prank(ids.owner_account, ids.proxy) %}
    IERC20.initialize(proxy, owner_account, initial_supply)
    IERC20.transfer(proxy, 1337, Uint256(25000000000000000000000, 0))
    IERC20.transfer(proxy, 7331, Uint256(25000000000000000000000, 0))
    %{ stop_prank_callable() %}
    return ()
end

@view
func test_solution{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    alloc_locals
    local proxy
    %{ ids.proxy = context.proxy %}
    let player = 123

    # Add your solution here

    is_solved(proxy, player)
    return ()
end

func is_solved{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    erc20 : felt, player : felt
):
    let (player_balance : Uint256) = IERC20.balanceOf(erc20, player)
    assert Uint256(50000000000000000000000, 0) = player_balance
    return ()
end
