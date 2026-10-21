import os
import secrets

from fastapi import FastAPI, Header, HTTPException

app = FastAPI(title="Week 3 Secure API")

API_TOKEN = os.getenv("DEMO_API_TOKEN")


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/protected")
def protected(
    authorization: str | None = Header(default=None),
):
    if not API_TOKEN:
        raise HTTPException(
            status_code=503,
            detail="Demo API token is not configured",
        )

    expected = f"Bearer {API_TOKEN}"

    if not authorization or not secrets.compare_digest(
        authorization, expected
    ):
        raise HTTPException(
            status_code=401,
            detail="Unauthorized",
        )

    return {"message": "Authorized access"}