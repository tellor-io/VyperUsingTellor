# VyperUsingTellor
Implementation of UsingTellor using Vyper language. Uses the same interface as UsingTellor in solidity, except this Vyper implementation does not include `IsInDispute()`, a function for checking dispute status on a `queryId`. **Note** UsingTellor must be deployed instead of inherited (as one would in Solidity) because Vyper does not support inheritance.

## Setup
1. Deploy UsingTellor, pointing the contract to the address of Tellor on your chain of choice
2. Implement the UsingTellor interface (see sample below) and point it to the address of your deployed UsingTellor contract

## Reading a value
1. Call `GetCurrentValue()` or `getDataBefore()` on a queryId of your choice (can also be built using abi encoding in-line)
2. Ensure request is successful
3. Ensure request meets safety checks and sanity checks (of your choosing)
4. Integrate returned Tellor value into contract

## Sample ETH/USD price integration 

```python3
interface UsingTellor:
    def getCurrentValue(query_id: bytes32) -> (bool, Bytes[100], uint256): view
    def getDataBefore(query_id: bytes32, _timestamp: uint256) -> (bool, Bytes[100], uint256): view
    
@external
def __init__(tellor_address: address):
  self.using_tellor_address = using_tellor_address # point to UsingTellor deployment
  
@internal
def newETHPrice() -> uint256:
  newPrice: uint256 = 0
  # read current eth price from tellor
  success: bool = False
  value: Bytes[100] = b""
  _timestamp: uint256 = 0
  (success, value, _timestamp) = UsingTellor(self.tellor_address).getCurrentValue(0x0000000000000000000000000000000000000000000000000000000000000001)
  if success:
      newPrice = extract32(value, 0, output_type=uint256)
      return newPrice
  else:
      raise "unable to retrieve ETH price from Tellor"
```