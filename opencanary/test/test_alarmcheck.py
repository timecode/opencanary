"""
Tests the cases for the Alarmcheck module.

The Alarmcheck module should return a simple 'ring, ring' for interaction of any
verb (HEAD, GET, POST, DELETE, etc). More importantly, the logs should show evidence
of the alarmcheck by way of a unique logger code (101) and identification to enable later filtering.
"""

import requests
import pytest

from helpers import get_last_log


PORT = 1211
URL = f"http://localhost:{PORT}/"
EXPECTED_SERVER_HEADER = "Alarmcheck Test"
EXPECTED_RESPONSE_TEXT = "ring, ring"
EXPECTED_LOG_TYPE = 101
EXPECTED_LOG_TEXT = "ALARMCHECK"
EXPECTED_PORT = PORT


def assert_alarmcheck_log():
    last_log = get_last_log()
    assert last_log["dst_port"] == EXPECTED_PORT
    assert last_log["logtype"] == EXPECTED_LOG_TYPE
    assert EXPECTED_LOG_TEXT in str(last_log["logdata"])


def test_head_alarmcheck_response():
    """
    Test the HEAD request to the alarmcheck endpoint.
    """
    response = requests.head(URL)

    assert response.status_code == 200
    assert EXPECTED_SERVER_HEADER in response.headers.get("Server")
    assert_alarmcheck_log()


@pytest.mark.parametrize("method", [requests.get, requests.post, requests.delete], ids=["get", "post", "delete"])
def test_alarmcheck_response(method):
    """
    Test GET, POST, and DELETE requests to the alarmcheck endpoint.
    """
    response = method(URL)

    assert response.status_code == 200
    assert EXPECTED_RESPONSE_TEXT in response.text
    assert EXPECTED_SERVER_HEADER in response.headers.get("Server")
    assert_alarmcheck_log()
