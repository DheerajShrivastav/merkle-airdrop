// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
​
import {ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
contract MerkleAirdrop {
    // Purpose:
    // 1. Manage a list of addresses and corresponding token amounts eligible for the airdrop.
    // 2. Provide a mechanism for eligible users to claim their allocated tokens.

    using SafeERC20 for IERC20;

    error MerkleAirdrop__InvalidProof();

    event Claim(address indexed account, uint256 amount);

    bytes32 public immutable i_merkleRoot;
    ERC20 private immutable i_airdropToken;
    constructor(bytes32 merkleRoot, address airdropToken) {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    function claim(
        address to,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external {
        bytes32 leaf = keccak256(bytes.concat(
            keccak256(abi.encode(account, amount));
        ));
        if(!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }

        
        emit Claim(account, amount);
        i_airdropToken.safeTransfer(account, amount);
    }
}