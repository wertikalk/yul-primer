object "OStorage" {

  code {
    // Constructor

    // returns the runtime code using the special functions
    datacopy(0, dataoffset("runtime"), datasize("runtime"))
    return(0, datasize("runtime"))
  }

  object "runtime" {
    code {

      // Protection against sending Ether - to all of the contract methods
      _require(iszero(callvalue()))

      // Dispatcher - determines, and enters the wanted contract function
      switch _selector()

        case 0x9273ad4e /* exec(...) */ {
          let _op := _extractWord(0)
          let _loc0 := _extractWord(1)
          let _loc1 := _extractWord(2)

          let _cache0 := _read(_loc0)
          let _cache1 := _read(_loc1)

          switch _op
            case 0x01 /* OP_UADD */ {
              _returnUint(_write(_loc0, add(_cache0, _cache1)))
            }

            case 0xf2 /* OP_MAX */ {
              if lt(_cache0, _cache1) {
                _cache0 := _cache1
              }
              _returnUint(_write(_loc0, _cache0))
            }

            case 0xee /* OP_XORC */ {
              _cache1 := xor(_cache0, _cache1)
              _cache0 := 0
              for { let i := 0 } lt(i, 0x20) { i := add(i, 1) } {

                // note: extracts bits as (xor_result >> i) & 1 and adds them together
                _cache0 := add(_cache0, and(shr(i, _cache1), 1))
              }
              _returnUint(_write(_loc0, _cache0))
            }
        }

        case 0xed2e5a97 /* read(...) */{
          let _loc := _extractWord(0)
          
          _returnUint(_read(_loc))
        }

        case 0x9c0e3f7a /* write(...) */{
          let _loc := _extractWord(0)
          let _val := _extractWord(1)

          _returnUint(_write(_loc, _val))
        }

        default {
          revert(0, 0)
        }

      // ----------- Logic

      function _read (_loc) -> val {
        val := sload(_locToStorageOffset(_loc))
      }

      function _write (_loc, _val) -> success {
        sstore(_locToStorageOffset(_loc), _val)
        success := 1
      }
    
      // ----------- Helpers
      function _selector() -> s {
        
        // note: extracts top 4 bytes of calldata (function selector)
        s := div(
          calldataload(0), 
          0x100000000000000000000000000000000000000000000000000000000 // := 2**(32-4 + 1)
        )
      }

      function _require(condition) {

        // note: revert message is empty
        if iszero(condition) { revert(0, 0) }
      }

      function _extractWord(offset) -> v {

        // note: the `4` being added corresponds to length of fcn.selector
        let pos := add(4, mul(offset, 0x20)) 

        // note: checks if there's enough data (0x20 = 32 Bytes) needed for one word
        if lt(calldatasize(), add(pos, 0x20)) {
            revert(0, 0)
        }
        v := calldataload(pos)
      }

      function _returnUint(v) {

        // note: overwrites whatever is in memory[0:31] because the contract call
        //       is ending, and the memory is no longer needed
        mstore(0, v)
        return(0, 0x20)
      }

      function _locToStorageOffset(_loc) -> offset {

        // note: creates an `offset` corresponding `_loc`
        //       - initial 0x1000 offset is arb. choosen
        offset := add(0x1000, _loc)
      }
    }
  }
}