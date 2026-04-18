from pathlib import Path

from fastapi import FastAPI
from fastapi.responses import RedirectResponse
from fastapi.staticfiles import StaticFiles

from app.api.routes import router, ui_router
from app.core.config import settings
from app.db import ensure_schema_compatibility, engine

app = FastAPI(title=settings.app_name, version="0.2.0")
ensure_schema_compatibility(engine)
app.include_router(router)

_flutter_web_dir = (
    Path(__file__).resolve().parents[1] / "../flutter_app/build/web"
).resolve()

if _flutter_web_dir.exists():
    app.mount("/app", StaticFiles(directory=str(_flutter_web_dir), html=True), name="gym_app_web")
else:
    app.include_router(ui_router)


@app.get("/", include_in_schema=False)
def root() -> RedirectResponse:
    return RedirectResponse(url="/app", status_code=307)
