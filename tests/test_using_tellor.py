import pytest

from brownie import Contract, UsingTellor, accounts
from brownie.convert import to_bytes

import boa

tellor_address = "0x88dF592F8eb5D7Bd38bFeF7dEb0fBc02cf3778a0"

@pytest.fixture
def tellor():
    yield Contract.from_explorer(tellor_address)

@pytest.fixture
def using_tellor():
    return boa.load("contracts/UsingTellor.vy", tellor_address)
def test_deployment(using_tellor):
    assert using_tellor.tellor_address() == tellor_address.lower()

def test_get_current_value(using_tellor):
    # query_id = "0x9cc19baefd2378ba58d7810a68dce05557818a8ce750b65c5a78e968ce0b28d7"
    query_id = to_bytes("0x1")
    v = using_tellor.getCurrentValue(query_id)
    assert v > 0