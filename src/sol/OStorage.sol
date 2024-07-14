// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { I_OStorage } from '../i/I_OStorage.sol';

import { Utils } from '../_utils.sol';

contract OStorage is I_OStorage {

    /// @inheritdoc I_OStorage
    function exec(uint _op, uint _loc0, uint _loc1) public returns (bool) {
        uint[2] memory _cache = [read(_loc0), read(_loc1)];

        if (_op == Utils.OP_UADD) {
            
            unchecked {
                return write(_loc0, _cache[0] + _cache[1]);
            }
        } else if (_op == Utils.OP_MAX) {

            return write(_loc0, _cache[0] < _cache[1] ? _cache[1] : _cache[0]);
        } else if (_op == Utils.OP_XORC) {

            _cache[1] = _cache[0] ^ _cache[1];
            _cache[0] = 0;
            for (uint i = 0; i < 32; ++i) {
                _cache[0] += 1 & (_cache[1] >> i);
            }
            return write(_loc0, _cache[0]);
        }
        
        revert();
    }

    /// @inheritdoc I_OStorage
    function read(uint _loc) public view returns (uint) {
        return s_vals[_loc];
    }

    /// @inheritdoc I_OStorage
    function write(uint _loc, uint _val) public returns (bool) {
        s_vals[_loc] = _val;
        return true;
    }

    // ------------------------------------------- Internals

    mapping(uint => uint) s_vals;
}
