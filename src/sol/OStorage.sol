// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { I_OStorage } from '../i/I_OStorage.sol';
import { Utils } from '../_utils.sol';

/**
 * @title OStorage
 * @notice Implements a simple storage-based execution environment
 * @author Wertikalk
 */
contract OStorage is I_OStorage {
    /// @inheritdoc I_OStorage
    function exec(uint256 _op, uint256 _loc0, uint256 _loc1) public returns (bool) {
        uint256[2] memory _cache = [read(_loc0), read(_loc1)];

        if (_op == Utils.OP_UADD) {
            unchecked {
                return write(_loc0, _cache[0] + _cache[1]);
            }
        } else if (_op == Utils.OP_MAX) {
            return write(_loc0, _cache[0] < _cache[1] ? _cache[1] : _cache[0]);
        } else if (_op == Utils.OP_XORC) {
            _cache[1] = _cache[0] ^ _cache[1];
            _cache[0] = 0;
            for (uint256 i = 0; i < 32; ++i) {
                _cache[0] += 1 & (_cache[1] >> i);
            }
            return write(_loc0, _cache[0]);
        }

        revert();
    }

    /// @inheritdoc I_OStorage
    function read(uint256 _loc) public view returns (uint256) {
        return s_vals[_loc];
    }

    /// @inheritdoc I_OStorage
    function write(uint256 _loc, uint256 _val) public returns (bool) {
        s_vals[_loc] = _val;
        return true;
    }

    // ------------------------------------------- Internals

    mapping(uint256 => uint256) s_vals;
}
