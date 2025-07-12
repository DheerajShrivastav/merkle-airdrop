//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 private s_merkleRoot =
        0xf30d5b84fa4d98e15975269eff95a775a609d4a4402251b99426461050704ad8;
    uint256 private s_amountToTransfer = 4 * 25 * 1e18;

    function depoloyMerkleAirdrop() internal returns (s_merkleRoot, IERC20(address(token))) {
        vm.startBroadcast();

        BagelToken bagelToken = new BagelToken();
        MerkleAirdrop airdrop = new MerkleAirdrop(
            s_merkleRoot,
            IERC20(address(token)),
        );

        token.mint(token.owner(), s_amountToTransfer);
        token.transfer(address(airdrop), s_amountToTransfer);

        vm.stopBroadcast();
        return (airdrop,token);
    }
    function run() external returns (MerkleAirdrop, BagelToken) {
        return depoloyMerkleAirdrop();
    }
}
