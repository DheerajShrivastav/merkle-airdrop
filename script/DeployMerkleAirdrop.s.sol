//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {MerkleAirdrop, IERC20} from "../src/MerkleAirdrop.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 private s_merkleRoot =
        0xf30d5b84fa4d98e15975269eff95a775a609d4a4402251b99426461050704ad8;
    uint256 private s_amountToTransfer = 4 * 25 * 1e18;

    function deployMerkleAirdrop() public returns (MerkleAirdrop, BagelToken) {
        vm.startBroadcast();

        BagelToken bagelToken = new BagelToken();
        MerkleAirdrop airdrop = new MerkleAirdrop(
            s_merkleRoot,
            IERC20(bagelToken)
        );

        bagelToken.mint(bagelToken.owner(), s_amountToTransfer);
        IERC20(bagelToken).transfer(address(airdrop), s_amountToTransfer);

        vm.stopBroadcast();
        return (airdrop, bagelToken);
    }

    function run() external returns (MerkleAirdrop, BagelToken) {
        return deployMerkleAirdrop();
    }
}
