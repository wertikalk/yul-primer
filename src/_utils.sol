// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
 * @title Utils
 * @notice Utility constants for the Yul-based stack execution environment
 * @author Wertikalk
 */
library Utils {
    uint256 constant OP_UADD = 0x01;
    uint256 constant OP_MAX = 0xf2;
    uint256 constant OP_XORC = 0xee;
}
