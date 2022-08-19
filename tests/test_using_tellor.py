import pytest

from brownie import Contract, UsingTellor, accounts, chain
from brownie.convert import to_bytes, to_int

import boa

tellor_address = "0xe8218cACb0a5421BC6409e498d9f8CC8869945ea"

@pytest.fixture
def tellor():
    yield Contract.from_explorer(tellor_address)

@pytest.fixture
def using_tellor():
    # return boa.load("contracts/UsingTellor.vy", tellor_address)
    yield UsingTellor.deploy(tellor_address, {"from": accounts[0]})
def test_deployment(using_tellor):
    assert using_tellor.tellor_address() == tellor_address.lower()

def test_get_current_value(using_tellor):
    query_id = to_bytes("0x1")
    success, value, timestamp = using_tellor.getCurrentValue(query_id)

    assert success
    assert to_int(value) > 0
    assert timestamp > 0

def test_get_data_before(using_tellor):
    query_id = to_bytes("0x1")
    timestamp_in = 1660922409
    success, value, timestamp_out = using_tellor.getDataBefore(query_id, timestamp_in)
    print(success, value, timestamp_out)

    assert success
    assert to_int(value) > 0
    assert timestamp_out - timestamp_in < 500