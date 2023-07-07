// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {OurToken} from "../src/OurToken.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";

interface MintableToken {
    function mint(address, uint256) external;
}

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");
    uint256 public constant INITIAL_BALANCE = 1000 ether;

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        vm.prank(msg.sender);
        ourToken.transfer(bob, INITIAL_BALANCE);
    }

    function testBobBalance() public {
        assertEq(INITIAL_BALANCE, ourToken.balanceOf(bob));
    }

    function testAllowance() public {
        //transferFrom
        uint256 initialAllowance = 1000;

        vm.prank(bob);
        //bob approves alice to spend tokens on her behalf
        ourToken.approve(alice, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);

        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), INITIAL_BALANCE - transferAmount);
    }

    function testInitialSupply() public {
        assertEq(ourToken.totalSupply(), deployer.INITIAL_SUPPLY());
    }

    function testUsersCantMint() public {
        vm.expectRevert();
        MintableToken(address(ourToken)).mint(address(this), 1);
    }

    // function testBalanceAfterTransfer() public {
    //     uint256 amount = 100;
    //     vm.prank(bob);
    //     uint256 initial_balance = ourToken.balanceOf(bob);
    //     console.log(initial_balance);
    //     ourToken.transfer(alice, amount);
    //     assertEq(ourToken.balanceOf(bob), initial_balance - amount);
    // }

    // function testTransferFrom() public {
    //     uint256 amount = 100;
    //     vm.prank(bob);
    //     ourToken.approve(alice, amount);
    //     ourToken.transferFrom(bob, alice, amount);
    //     assertEq(ourToken.balanceOf(alice), amount);
    // }
}
