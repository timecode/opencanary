"""
Tests the cases for the Heartbeat module.

The Heartbeat module should return a simple 'thump, thump' for interaction of any
verb (HEAD, GET, POST, DELETE, etc). More importantly, the logs should show evidence
of heartbeat by way of a unique logger code (100) and identification to enable later filtering.
"""

import requests
import pytest

from helpers import get_last_log


PORT = 1210
URL = f"http://localhost:{PORT}/"
EXPECTED_SERVER_HEADER = "Heartbeat Test"
EXPECTED_RESPONSE_TEXT = "thump, thump"
EXPECTED_LOG_TYPE = 100
EXPECTED_LOG_TEXT = "HEARTBEAT"
EXPECTED_PORT = PORT


def assert_heartbeat_log():
    last_log = get_last_log()
    assert last_log["dst_port"] == EXPECTED_PORT
    assert last_log["logtype"] == EXPECTED_LOG_TYPE
    assert EXPECTED_LOG_TEXT in str(last_log["logdata"])


def test_head_heartbeat_response():
    """
    Test the HEAD request to the heartbeat endpoint.
    """
    response = requests.head(URL)

    assert response.status_code == 200
    assert EXPECTED_SERVER_HEADER in response.headers.get("Server")
    assert_heartbeat_log()


@pytest.mark.parametrize("method", [requests.get, requests.post, requests.delete], ids=["get", "post", "delete"])
def test_heartbeat_response(method):
    """
    Test GET, POST, and DELETE requests to the heartbeat endpoint.
    """
    response = method(URL)

    assert response.status_code == 200
    assert EXPECTED_RESPONSE_TEXT in response.text
    assert EXPECTED_SERVER_HEADER in response.headers.get("Server")
    assert_heartbeat_log()
