// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
​
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
contract MerkleAirdrop {
    // Purpose:
    // 1. Manage a list of addresses and corresponding token amounts eligible for the airdrop.
    // 2. Provide a mechanism for eligible users to claim their allocated tokens.

    using SafeERC20 for IERC20;

    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();

    event Claim(address indexed account, uint256 amount);

    bytes32 public immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    mapping (address cliamant => bool) private s_hasClaimed;
    constructor(bytes32 merkleRoot, address airdropToken) {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    function claim(
        address to,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external {
        if (s_hasClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
            
        }
        bytes32 leaf = keccak256(bytes.concat(
            keccak256(abi.encode(account, amount));
        ));
        if(!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }


        s_hasClaimed[account] = true;
        emit Claim(account, amount);
        i_airdropToken.safeTransfer(account, amount);
    }

    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    getAirdropToken() external view returns (IERC20) {
        return i_airdropToken;
    }
}