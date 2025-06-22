// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Test, console } from 'forge-std/Test.sol';

import { I_OStorage } from '../src/i/I_OStorage.sol';
import { OStorage } from '../src/sol/OStorage.sol';
import { Deployer as YulDeployer } from './yul/Deployer.sol';
import { Utils } from '../src/_utils.sol';

/**
 * @title OStorage_Test
 * @notice Tests for the OStorage contract, which implements a simple storage-based execution environment
 * @dev Performs fuzz & diff. tests between the Solidity and Yul implementations
 * @author Wertikalk
 */
contract OStorage_Test is Test {
    function testFuzz_SolImpl_UADD(uint256 _loc0, uint256 _val0, uint256 _loc1, uint256 _val1) public {
        _testFuzz_UADD(solImpl, _loc0, _val0, _loc1, _val1);
    }

    function testFuzz_YulImpl_UADD(uint256 _loc0, uint256 _val0, uint256 _loc1, uint256 _val1) public {
        _testFuzz_UADD(yulImpl, _loc0, _val0, _loc1, _val1);
    }

    function testFuzz_SolImpl_MAX(uint256 _loc0, uint256 _val0, uint256 _loc1, uint256 _val1) public {
        _testFuzz_MAX(solImpl, _loc0, _val0, _loc1, _val1);
    }

    function testFuzz_YulImpl_MAX(uint256 _loc0, uint256 _val0, uint256 _loc1, uint256 _val1) public {
        _testFuzz_MAX(yulImpl, _loc0, _val0, _loc1, _val1);
    }

    function testFuzz_SolImpl_XORC(uint256 _loc0, uint256 _val0, uint256 _loc1, uint256 _val1) public {
        _testFuzz_XORC(solImpl, _loc0, _val0, _loc1, _val1);
    }

    function testFuzz_YulImpl_XORC(uint256 _loc0, uint256 _val0, uint256 _loc1, uint256 _val1) public {
        _testFuzz_XORC(yulImpl, _loc0, _val0, _loc1, _val1);
    }

    function _testFuzz_UADD(I_OStorage impl, uint256 _loc0, uint256 _val0, uint256 _loc1, uint256 _val1) public {
        assertEq(impl.write(_loc0, _val0), true);
        assertEq(impl.read(_loc0), _val0);

        assertEq(impl.write(_loc1, _val1), true);
        assertEq(impl.read(_loc1), _val1);

        //note: handling the case when `loc0` == `loc1`
        uint256 _valAtLoc0 = impl.read(_loc0);
        uint256 _valAtLoc1 = impl.read(_loc1);

        assertEq(impl.exec(Utils.OP_UADD, _loc0, _loc1), true);

        unchecked {
            assertEq(_valAtLoc0 + _valAtLoc1, impl.read(_loc0));
        }
    }

    function _testFuzz_MAX(I_OStorage impl, uint256 _loc0, uint256 _val0, uint256 _loc1, uint256 _val1) public {
        assertEq(impl.write(_loc0, _val0), true);
        assertEq(impl.read(_loc0), _val0);

        assertEq(impl.write(_loc1, _val1), true);
        assertEq(impl.read(_loc1), _val1);

        //note: handling the case when `loc0` == `loc1`
        uint256 _valAtLoc0 = impl.read(_loc0);
        uint256 _valAtLoc1 = impl.read(_loc1);

        assertEq(impl.exec(Utils.OP_MAX, _loc0, _loc1), true);

        uint256 _max = _valAtLoc0 < _valAtLoc1 ? _valAtLoc1 : _valAtLoc0;

        assertEq(_max, impl.read(_loc0));
    }

    function _testFuzz_XORC(I_OStorage impl, uint256 _loc0, uint256 _val0, uint256 _loc1, uint256 _val1) public {
        assertEq(impl.write(_loc0, _val0), true);
        assertEq(impl.read(_loc0), _val0);

        assertEq(impl.write(_loc1, _val1), true);
        assertEq(impl.read(_loc1), _val1);

        //note: handling the case when `loc0` == `loc1`
        uint256 _valAtLoc0 = impl.read(_loc0);
        uint256 _valAtLoc1 = impl.read(_loc1);

        assertEq(impl.exec(Utils.OP_XORC, _loc0, _loc1), true);

        uint256 _xor_result = _valAtLoc0 ^ _valAtLoc1;
        uint256 _count = 0;
        for (uint256 i = 0; i < 32; ++i) {
            _count += 1 & (_xor_result >> i);
        }

        assertEq(_count, impl.read(_loc0));
    }

    function setUp() public {
        solImpl = I_OStorage(address(new OStorage()));

        YulDeployer yulDeployer = new YulDeployer();
        yulImpl = I_OStorage(address(yulDeployer.deployContract('OStorage')));
    }

    I_OStorage public solImpl;
    I_OStorage public yulImpl;
}
