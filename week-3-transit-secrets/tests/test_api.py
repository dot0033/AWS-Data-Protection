from fastapi.testclient import TestClient

from src.api import app

client = TestClient(app)


def test_health_endpoint():
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_protected_endpoint_without_token(monkeypatch):
    monkeypatch.setattr(
        "src.api.API_TOKEN",
        "pytest-demo-token",
    )

    response = client.get("/protected")

    assert response.status_code == 401


def test_protected_endpoint_when_token_is_not_configured(monkeypatch):
    monkeypatch.setattr("src.api.API_TOKEN", None)

    response = client.get("/protected")

    assert response.status_code == 503


def test_protected_endpoint_with_valid_token(monkeypatch):
    monkeypatch.setattr(
        "src.api.API_TOKEN",
        "pytest-demo-token",
    )

    response = client.get(
        "/protected",
        headers={
            "Authorization": "Bearer pytest-demo-token"
        },
    )

    assert response.status_code == 200
    assert response.json() == {
        "message": "Authorized access"
    }


def test_protected_endpoint_with_invalid_token(monkeypatch):
    monkeypatch.setattr(
        "src.api.API_TOKEN",
        "pytest-demo-token",
    )

    response = client.get(
        "/protected",
        headers={
            "Authorization": "Bearer incorrect-token"
        },
    )

    assert response.status_code == 401