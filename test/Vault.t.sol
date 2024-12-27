// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Vault.sol";

contract VaultTest is Test {
    Vault vault;

    function setUp() public {
        vault = new Vault();
    }

    function testDeposit() public {
        uint256 depositAmount = 1 ether;
        vm.deal(address(this), depositAmount);

        vault.deposit{value: depositAmount}();
        assertEq(vault.getBalance(), depositAmount);
    }

    function testWithdraw() public {
        uint256 depositAmount = 1 ether;
        uint256 withdrawAmount = 0.5 ether;
        vm.deal(address(this), depositAmount);

        vault.deposit{value: depositAmount}();
        vault.withdraw(withdrawAmount);

        assertEq(vault.getBalance(), depositAmount - withdrawAmount);
    }

    function testWithdrawRevert() public {
        uint256 withdrawAmount = 1 ether;

        vm.expectRevert("Insufficient balance");
        vault.withdraw(withdrawAmount);
    }
}