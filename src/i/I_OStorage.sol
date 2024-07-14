// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface I_OStorage {

    /// @notice Executes specified operation on the values inside provided storage locations
    /// @dev Stores the result in the first storage location
    /// @param _op Operation ID
    /// @param _loc0 First storage location
    /// @param _loc1 Second storage location
    /// @return Success of the applied operation
    function exec(uint _op, uint _loc0, uint _loc1) external returns (bool);

    /// @notice Reads the provided storage location
    /// @param _loc Storage location to be read
    /// @return Value at the `loc` storage location
    function read(uint _loc) external view returns (uint);

    /// @notice Writes the provided value to the storage location
    /// @param _loc Storage location to be written to
    /// @param _val Value to be written
    /// @return Write success status
    function write(uint _loc, uint _val) external returns (bool);
}
