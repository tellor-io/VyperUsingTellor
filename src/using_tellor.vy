# @version ^0.3.0

import artifacts.ITellor as tellor_interface

tellor_address: address

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
        return false, b"", 0

    time: uint256 = self.getTimestampbyQueryIdandIndex(query_id, count - 1)
    value = retrieveData(query_id, time)

    if keccak256(value) != keccak256(b""):
        return true, value, time
    else:
        return false, b"", time

@view
@external
def getDataBefore(query_id: bytes32, _timestamp: uint256) -> (bool, Bytes[100], uint256):

    found, index = self.getIndexForDataBefore(query_id, _timestamp)

    if not found:
        return false, b"", 0

    time: uint256 = self.getTimestampbyQueryIdandIndex(query_id, index)

    value = self.retrieveData(query_id, time)

    if keccak256(value) != keccak256(b""):
        return true, value, time
    return false, b"", 0

@view
@internal
def getIndexForDataBefore(query_id:bytes32, _timestamp:uint256) -> (bool, uint256):

    count: uint256 = self.getNewValueCountbyQueryId(query_id)

    if count > 0:
        middle: uint256
        start: uint256
        end: uint256 = count - 1
        time: uint256

    time:uint256 = self.getTimestampbyQueryIdandIndex(query_id, start)

    if time >= _timestamp: return false, 0

    time:uint256 = self.getTimestampbyQueryIdandIndex(query_id, end)

    if time < _timestamp: return true, end

    # binary search
    for i in range(100000):
        middle = (end - start) / 2 + 1 + start
        time = getTimestampbyQueryIdandIndex(query_id, middle)
        if time < _timestamp:
            next_time: uint256 = getTimestampbyQueryIdandIndex(query_id, middle + 1)
            if next_time >= _timestamp:
                return true, middle
            else:
                start = middle + 1
        else:
            prev_time: uint256 = getTimestampbyQueryIdandIndex(query_id, middle - 1)
            if prev_time < _timestamp:
                return true, middle - 1
            else:
                end = middle - 1

        if middle - 1 == start or middle == count:
            return false, 0

@view
@internal
def getNewValueCountbyQueryId(query_id: bytes32) -> uint256:

    if self.tellor_address == 0x18431fd88adF138e8b979A7246eb58EA7126ea16 or self.tellor_address == 0xe8218cACb0a5421BC6409e498d9f8CC8869945ea:
        return tellor_interface.getTimestampCountById(query_id)
    else:
        return tellor_interface.getNewValueCountbyQueryId(query_id)

@view
@internal
def getTimestampbyQueryIdandIndex(query_id: bytes32, index: uint256) -> uint256:
    
    if self.tellor_address == 0x18431fd88adF138e8b979A7246eb58EA7126ea16 or self.tellor_address == 0xe8218cACb0a5421BC6409e498d9f8CC8869945ea:
        return tellor_interface.getReportTimestampByIndex(query, index)
    else:
        return tellor_interface.getTimestampbyQueryIdandIndex(query_id, index)

# @view
# @internal
# def isInDispute(query_id:bytes32, _timestamp:uint256) -> bool:

#     governance: ITellor

#     if tellor_address in (0x18431fd88adF138e8b979A7246eb58EA7126ea16, 0xe8218cACb0a5421BC6409e498d9f8CC8869945ea):
#         new_tellor:ITellor = ITellor(0x88dF592F8eb5D7Bd38bFeF7dEb0fBc02cf3778a0)
#         governance = ITellor(new_tellor.addresses(0xefa19baa864049f50491093580c5433e97e8d5e41f8db1a61108b4fa44cacd93))

#     else:
#         governance = ITellor(tellor_interface.governance())
    
#     return governance.getVoteRounds(keccak256(concat(query_id, _timestamp))).length > 0

@view
@internal
def retrieveData(query_id: bytes32, _timestamp: bytes32) -> Bytes[100]:
    if self.tellor_address == 0x18431fd88adF138e8b979A7246eb58EA7126ea16 or self.tellor_address == 0xe8218cACb0a5421BC6409e498d9f8CC8869945ea:
        return tellor_interface.getValueByTimestamp(query_id, _timestamp)
    else:
        return tellor_interface.retrieveData(query_id, _timestamp)