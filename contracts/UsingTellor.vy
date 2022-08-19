# @version ^0.3.0

# import interfaces.ITellor as tellor

interface Tellor:
    def getTimestampCountById(query_id:bytes32) -> uint256:view
    def getNewValueCountbyQueryId(query_id:bytes32) -> uint256: view
    def getReportTimestampByIndex(query_id:bytes32, idx:uint256) -> uint256: view
    def retrieveData(query_id:bytes32, timestamp:uint256) -> Bytes[100]:view
    def getValueByTimestamp(query_id:bytes32, timestamp:uint256) -> Bytes[100]:view
    def getTimestampbyQueryIdandIndex(query_id:bytes32, timestamp:uint256) -> uint256:view


tellor_address: public(address)
tellor_interface: Tellor
governance: Tellor

@external
def __init__(_tellor_address: address):
    """
    @dev the constructor sets the tellor address in storage
    @param _tellor_address is the TellorMaster address
    """
    self.tellor_address = _tellor_address
    self.tellor_interface = Tellor(self.tellor_address)


@view
@external
def getCurrentValue(query_id: bytes32) -> (bool, Bytes[100], uint256):
    """
    @dev Allows the user to get the latest value for the queryId specified
    @param query_id is the id to look up the value for
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
    '''
    @dev Retrieves the latest value for the queryId before the specified timestamp
    @param query_id is the queryId to look up the value for
    @param _timestamp before which to search for latest value
    @return _ifRetrieve bool true if able to retrieve a non-zero value
    @return _value the value retrieved
    @return _timestampRetrieved the value's timestamp
     '''
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
    '''
    @dev Retrieves latest array index of data before the specified timestamp for the queryId
    @param query_id is the queryId to look up the index for
    @param _timestamp is the timestamp before which to search for the latest index
    @return _found whether the index was found
    @return _index the latest index found before the specified timestamp
    '''

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
        for i in range(100000000):
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
    '''
    @dev Counts the number of values that have been submitted for the queryId
    @param _queryId the id to look up
    @return uint256 count of the number of values received for the queryId
    '''

    if self.tellor_address == 0x18431fd88adF138e8b979A7246eb58EA7126ea16 or self.tellor_address == 0xe8218cACb0a5421BC6409e498d9f8CC8869945ea:
        print("here1")
        return self.tellor_interface.getTimestampCountById(query_id)
    else:
        print("here2")
        return self.tellor_interface.getNewValueCountbyQueryId(query_id)

@view
@internal
def getTimestampbyQueryIdandIndex(query_id: bytes32, index: uint256) -> uint256:
    '''
    @dev Gets the timestamp for the value based on their index
    @param _queryId is the id to look up
    @param _index is the value index to look up
    @return uint256 timestamp
    '''
    
    if self.tellor_address == 0x18431fd88adF138e8b979A7246eb58EA7126ea16 or self.tellor_address == 0xe8218cACb0a5421BC6409e498d9f8CC8869945ea:
        return self.tellor_interface.getReportTimestampByIndex(query_id, index)
    else:
        return self.tellor_interface.getTimestampbyQueryIdandIndex(query_id, index)

@view
@internal
def retrieveData(query_id: bytes32, _timestamp: uint256) -> Bytes[100]:
    '''
    @dev Retrieve value from oracle based on queryId/timestamp
    @param _queryId being requested
    @param _timestamp to retrieve data/value from
    @return bytes value for query/timestamp submitted
    '''
    if self.tellor_address == 0x18431fd88adF138e8b979A7246eb58EA7126ea16 or self.tellor_address == 0xe8218cACb0a5421BC6409e498d9f8CC8869945ea:
        return self.tellor_interface.getValueByTimestamp(query_id, _timestamp)
    else:
        return self.tellor_interface.retrieveData(query_id, _timestamp)