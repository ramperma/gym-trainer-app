from fastapi import FastAPI
from fastapi.responses import RedirectResponse

from app.api.routes import router, ui_router
from app.core.config import settings

app = FastAPI(title=settings.app_name, version="0.2.0")
app.include_router(router)
app.include_router(ui_router)


@app.get("/", include_in_schema=False)
def root() -> RedirectResponse:
    return RedirectResponse(url="/app", status_code=307)
