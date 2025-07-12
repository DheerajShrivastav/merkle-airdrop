//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BagelToken} from "../src/BagelToken.sol";

contract MerkleAirdropTest is Test {
    MerkleAirdrop public airdrop;
    BagelToken public token;

    bytes32 public ROOT =
        0xf30d5b84fa4d98e15975269eff95a775a609d4a4402251b99426461050704ad8;

    uint256 public AMOUNT_TO_CLAIM = 25 * 1e18;
    uint256 public AMOUNT_TO_SEND;

    address user;
    uint256 userPrivKey;

    // bytes32 proofOne;
    // bytes32 proofTwo;
    // bytes32[2] public PROOF;

    bytes32 proofOne =
        0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proofTwo =
        0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public PROOF = [proofOne, proofTwo];

    function setUp() public {
        token = new BagelToken();

        (user, userPrivKey) = makeAddrAndKey("testUser");

        airdrop = new MerkleAirdrop(ROOT, token);

        AMOUNT_TO_SEND = AMOUNT_TO_CLAIM * 4;
        address owner = address(this);
        token.mint(owner, AMOUNT_TO_SEND);

        token.approve(address(airdrop), AMOUNT_TO_SEND);
        token.transfer(address(airdrop), AMOUNT_TO_SEND);
    }

    function testUsersCanClaim() public {
        console.log("User address: %s", user);
        uint256 startingBalance = token.balanceOf(user);
        vm.prank(user);

        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF);
        uint256 endingBalance = token.balanceOf(user);

        console.log("User's Ending Balance: ", endingBalance);
        assertEq(
            endingBalance - startingBalance,
            AMOUNT_TO_CLAIM,
            "User did not receive the correct amount of tokens"
        );
    }
}
