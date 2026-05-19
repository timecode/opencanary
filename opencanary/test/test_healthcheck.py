"""
Tests the cases for the Healthcheck module.

The Healthcheck module should return a simple 'OK' for interaction of any
verb (HEAD, GET, POST, DELETE, etc). Nothing should be logged.
"""

import requests
import pytest

from helpers import get_last_log

PORT = 1200
URL = f"http://localhost:{PORT}/"
EXPECTED_SERVER_HEADER = "Healthcheck Test"
EXPECTED_RESPONSE_TEXT = "OK"


def test_head_healthcheck_response():
    """
    Test the HEAD request to the healthcheck endpoint.
    """
    last_log_pre = get_last_log()
    response = requests.head(URL)

    assert response.status_code == 200
    assert EXPECTED_SERVER_HEADER in response.headers.get("Server")
    assert get_last_log() == last_log_pre


@pytest.mark.parametrize(
    "method",
    [requests.get, requests.post, requests.delete],
    ids=["get", "post", "delete"],
)
def test_healthcheck_response(method):
    """
    Test GET, POST, and DELETE requests to the healthcheck endpoint.
    """
    last_log_pre = get_last_log()
    response = method(URL)

    assert response.status_code == 200
    assert EXPECTED_RESPONSE_TEXT in response.text
    assert EXPECTED_SERVER_HEADER in response.headers.get("Server")
    assert get_last_log() == last_log_pre
