// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {SignatureChecker} from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

contract MerkleAirdrop is EIP712 {
    // Purpose:
    // 1. Manage a list of addresses and corresponding token amounts eligible for the airdrop.
    // 2. Provide a mechanism for eligible users to claim their allocated tokens.

    using SafeERC20 for IERC20;

    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__InvalidSignature();

    event Claim(address indexed account, uint256 amount);

    bytes32 private constant MESSAGE_TYPEHASH =
        keccak256("AirdropClaim(address to,uint256 amount)");
    bytes32 public immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    mapping(address cliamant => bool) private s_hasClaimed;

    struct AirdropClaim {
        address to;
        uint256 amount;
    }

    constructor(
        bytes32 merkleRoot,
        IERC20 airdropToken
    ) EIP712("MerkleAirdrop", "1") {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    function getMessage(
        address to,
        uint256 amount
    ) public view returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(MESSAGE_TYPEHASH, AirdropClaim({to: to, amount: amount}))
        );
        return _hashTypedDataV4(structHash);
    }

    function getMessageHash(
        address to,
        uint256 amount
    ) public view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        MESSAGE_TYPEHASH,
                        AirdropClaim({to: to, amount: amount})
                    )
                )
            );
    }

    function claim(
        address to,
        uint256 amount,
        bytes32[] calldata merkleProof,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        if (s_hasClaimed[to]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }

        // bytes32 digest = getMessageHash(to, amount);
        if (!_isValidSignature(to, getMessageHash(to, amount), v, r, s)) {
            revert MerkleAirdrop__InvalidSignature();
        }

        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encodePacked(to, amount)))
        );
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }

        s_hasClaimed[to] = true;
        emit Claim(to, amount);
        i_airdropToken.safeTransfer(to, amount);
    }

    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdropToken() external view returns (IERC20) {
        return i_airdropToken;
    }

    // function _isValidSignature(
    //     address expectedSigner,
    //     bytes32 digest,
    //     uint8 v,
    //     bytes32 r,
    //     bytes32 s
    // ) internal pure returns (bool) {
    //     address (address actualSigner,
    //         /*ECDSA.RecoverError recoverError*/
    //         ,
    //         /*bytes32 signatureLength*/) = ECDSA.tryRecover(digest, v, r, s);
    //     return actualSigner != address(0) && actualSigner == expectedSigner;
    // }

    function _isValidSignature(
        address signer,
        bytes32 digest,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) internal view returns (bool) {
        bytes memory signature = abi.encode(_v, _r, _s);
        return SignatureChecker.isValidSignatureNow(signer, digest, signature);
    }
}
