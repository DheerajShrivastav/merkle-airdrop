// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";

contract ClaimAirdrop is Script {
    error ClaimAirdropScript__InvalidSignatureLength();

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "MerkleAirdrop",
            block.chainid
        );
        claimAirdrop(mostRecentlyDeployed);
    }

    function claimAirdrop(address airdropContractAddress) public {
        address CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        uint256 CLAIMING_AMOUNT = 25 * 1e18; // 25 tokens
        bytes32 PROOF_ONE = 0x5c22b3319c305aa1689a9386137ec820cfb5c1068b6699db995bec4f913b3421;
        bytes32 PROOF_TWO = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
        bytes
            memory SIGNATURE = hex"6c87c4eb3c03f7fe11786cf3fc8e8c554b81f50a06f26f478f7ed8f80ca4e8fa22600008ca026efdd81890094ea01656bbcac1d8c79c6dd529ad4488e2397fe81b";

        bytes32[] memory proof = new bytes32[](2);
        proof[0] = PROOF_ONE;
        proof[1] = PROOF_TWO;

        vm.startBroadcast();
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE);
        MerkleAirdrop(airdropContractAddress).claim(
            CLAIMING_ADDRESS,
            CLAIMING_AMOUNT,
            proof,
            v,
            r,
            s
        );
        vm.stopBroadcast();
    }

    function splitSignature(
        bytes memory sig
    ) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        if (sig.length != 65) {
            revert ClaimAirdropScript__InvalidSignatureLength();
        }
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }
}
