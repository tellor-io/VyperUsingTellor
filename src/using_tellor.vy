# @version ^0.3.0

import artifacts.ITellor as tellor

tellor_address: address
tellor_interface: tellor
governance: tellor

@external
def __init__(_tellor_address: address):
    """
    @dev the constructor sets the tellor address in storage
    @param _tellor is the TellorMaster address
    """
    self.tellor_address = _tellor_address


@view
@external
def getCurrentValue(query_id: bytes32) -> (bool, Bytes[100], uint256):
    """
    @dev Allows the user to get the latest value for the queryId specified
    @param _queryId is the id to look up the value for
    @return _ifRetrieve bool true if non-zero value successfully retrieved
    @return _value the value retrieved
    @return _timestampRetrieved the retrieved value's timestamp
    """

    count: uint256 = self.getNewValueCountbyQueryId(query_id)

    if count == 0:
        return False, b"", 0

    time: uint256 = self.getTimestampbyQueryIdandIndex(query_id, count - 1)
    value: Bytes[100] = self.retrieveData(query_id, time)

    if keccak256(value) != keccak256(b""):
        return True, value, time
    else:
        return False, b"", time

@view
@external
def getDataBefore(query_id: bytes32, _timestamp: uint256) -> (bool, Bytes[100], uint256):

    found: bool = False
    index: uint256 = 0
    value: Bytes[100] = b""

    found, index = self.getIndexForDataBefore(query_id, _timestamp)

    if not found:
        return False, b"", 0

    time: uint256 = self.getTimestampbyQueryIdandIndex(query_id, index)

    value = self.retrieveData(query_id, time)

    if keccak256(value) != keccak256(b""):
        return True, value, time
    return False, b"", 0

@view
@internal
def getIndexForDataBefore(query_id:bytes32, _timestamp:uint256) -> (bool, uint256):

    count: uint256 = self.getNewValueCountbyQueryId(query_id)

    if count > 0:
        middle: uint256 = 0
        start: uint256 = 0
        end: uint256 = count - 1
        time: uint256 = 0

        time = self.getTimestampbyQueryIdandIndex(query_id, start)

        if time >= _timestamp: return False, 0

        time = self.getTimestampbyQueryIdandIndex(query_id, end)

        if time < _timestamp: return True, end

        # binary search
        for i in range(100000):
            middle = (end - start) / 2 + 1 + start
            time = self.getTimestampbyQueryIdandIndex(query_id, middle)
            if time < _timestamp:
                next_time: uint256 = self.getTimestampbyQueryIdandIndex(query_id, middle + 1)
                if next_time >= _timestamp:
                    return True, middle
                else:
                    start = middle + 1
            else:
                prev_time: uint256 = self.getTimestampbyQueryIdandIndex(query_id, middle - 1)
                if prev_time < _timestamp:
                    return True, middle - 1
                else:
                    end = middle - 1

            if middle - 1 == start or middle == count:
                return False, 0
        
    return False, 0

@view
@internal
def getNewValueCountbyQueryId(query_id: bytes32) -> uint256:

    if self.tellor_address == 0x18431fd88adF138e8b979A7246eb58EA7126ea16 or self.tellor_address == 0xe8218cACb0a5421BC6409e498d9f8CC8869945ea:
        return self.tellor_interface.getTimestampCountById(query_id)
    else:
        return self.tellor_interface.getNewValueCountbyQueryId(query_id)

@view
@internal
def getTimestampbyQueryIdandIndex(query_id: bytes32, index: uint256) -> uint256:
    
    if self.tellor_address == 0x18431fd88adF138e8b979A7246eb58EA7126ea16 or self.tellor_address == 0xe8218cACb0a5421BC6409e498d9f8CC8869945ea:
        return self.tellor_interface.getReportTimestampByIndex(query_id, index)
    else:
        return self.tellor_interface.getTimestampbyQueryIdandIndex(query_id, index)

# @view
# @external
# def isInDispute(query_id:bytes32, _timestamp:uint256) -> bool:

#     governance: tellor = tellor(0x88dF592F8eb5D7Bd38bFeF7dEb0fBc02cf3778a0)

#     if self.tellor_address == 0x18431fd88adF138e8b979A7246eb58EA7126ea16 or self.tellor_address == 0xe8218cACb0a5421BC6409e498d9f8CC8869945ea:
#         new_tellor:tellor = tellor(0x88dF592F8eb5D7Bd38bFeF7dEb0fBc02cf3778a0)
#         governance_address: address = new_tellor.addresses(0xefa19baa864049f50491093580c5433e97e8d5e41f8db1a61108b4fa44cacd93)
#         governance = tellor(governance_address)

#     else:
#         governance = tellor(self.tellor_interface.governance())
    
#     return governance.getVoteCount(keccak256(concat(query_id, _timestamp))) > 0

@view
@internal
def retrieveData(query_id: bytes32, _timestamp: uint256) -> Bytes[100]:
    if self.tellor_address == 0x18431fd88adF138e8b979A7246eb58EA7126ea16 or self.tellor_address == 0xe8218cACb0a5421BC6409e498d9f8CC8869945ea:
        return self.tellor_interface.getValueByTimestamp(query_id, _timestamp)
    else:
        return self.tellor_interface.retrieveData(query_id, _timestamp)