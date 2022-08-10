# @version ^0.3.0

import artifacts.ITellor as ITellor

tellor: public(ITellor)

@external
def __init__(_tellor: address):
    """
    @dev the constructor sets the tellor address in storage
    @param _tellor is the TellorMaster address
    """
    self.tellor = _tellor


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

    count: uint256 = getNewValueCountbyQueryId(query_id)

    if count == 0:
        return false, b"", 0

    time: uint256 = getTimestampbyQueryIdandIndex(query_id, count - 1)
    value: uint256 = retrieveData(query_id, time)

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
@external
def getIndexForDataBefore(query_id:bytes32, _timestamp:uint256) -> (bool, uint256):

    count: uint256 = getNewValueCountbyQueryId(query_id)

    if count > 0:
        middle: uint256
        start: uint256
        end: uint256 = count - 1
        time: uint256

    time:uint256 = getTimestampbyQueryIdandIndex(query_id, start)

    if time >= _timestamp: return false, 0

    time:uint256 = getTimestampbyQueryIdandIndex(query_id, end)

    if time < _timestamp: return true, end

    # binary search
    while true:
        middle = (end - start) / 2 + 1 + start




    