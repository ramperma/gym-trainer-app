# Gym Trainer App

Estado actual: vertical slice runnable con backend real en PostgreSQL y app Flutter preparada para lista + detalle.

## Decisión de repositorio
Se publica como **monorepo**.

Motivo: backend, app Flutter, SQL y documentación siguen siendo un solo producto con releases acopladas. Separarlo ahora añadiría fricción sin beneficio claro.

Referencia breve: `docs/repository-strategy.md`.

## Qué incluye

### Backend (`backend/`)
- FastAPI con estructura modular por `app/`
- Variables de entorno con `.env.example`
- PostgreSQL real mediante SQLAlchemy + psycopg
- Endpoints:
  - `GET /`
  - `GET /api/v1/health`
  - `GET /api/v1/exercises`
  - `GET /api/v1/exercises/{id}`
- `docker-compose.yml` para levantar PostgreSQL local
- `db/schema.sql` con tabla `exercises` y seed inicial con descripción, instrucciones y prescripción base

### Flutter (`flutter_app/`)
- Skeleton de app con pantalla inicial útil
- Llamada real al backend para lista y detalle de ejercicio
- Lista, recarga manual, pull-to-refresh y navegación a detalle
- Preparada para completar plataformas con `flutter create .`

## Estructura

```text
backend/
  app/
  db/schema.sql
  docker-compose.yml
flutter_app/
docs/
Makefile
README.md
```

## Arranque rápido

### Backend

```bash
cp backend/.env.example backend/.env
make backend-install
make backend-reset-db
make backend-run
```

Si no necesitas recrear volumen porque partes de cero, `make backend-up` también vale.

Checks:

```bash
make backend-check
```

Ejemplo manual:

```bash
curl http://localhost:8000/api/v1/exercises/ex-001
```

### Flutter

Requiere Flutter SDK instalado en la máquina:

```bash
cd flutter_app
flutter create .
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:8000/api/v1
```

Para Android Emulator:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

## Qué funciona ya
- Backend sirviendo catálogo y detalle de ejercicios desde PostgreSQL real.
- Healthcheck validando conexión a base de datos.
- Seed inicial persistido con campos útiles para una pantalla de detalle.
- Flutter preparado para mostrar datos reales y navegar de lista a detalle.
- Make targets mínimos para levantar, resetear y comprobar el slice.

## Limitaciones reales ahora mismo
- No hay auth ni usuarios todavía.
- No hay tests automáticos aún.
- En este entorno no está instalado Flutter SDK, así que no pude ejecutar `flutter create` ni `flutter run` aquí.
- La recreación de esquema se apoya en `docker compose down -v` porque el init script de Postgres solo corre al crear el volumen.

## Siguiente paso recomendado
1. Añadir entidad `workouts` y asignar ejercicios a una rutina del día.
2. Crear login mock o sesión mínima.
3. Montar CI básica para backend y lint Flutter.
