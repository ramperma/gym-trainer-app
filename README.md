# Gym Trainer App

Estado actual: aplicación real arrancable en esta Raspberry, con backend FastAPI sobre PostgreSQL y Flutter compilando para Linux desktop.

## Decisión de repositorio
Se publica como **monorepo**.

Motivo: backend, app Flutter, SQL y documentación siguen siendo un solo producto con releases acopladas. Separarlo ahora añadiría fricción sin beneficio claro.

Referencia breve: `docs/repository-strategy.md`.

## Qué incluye

### Backend (`backend/`)
- FastAPI con estructura modular por `app/`
- Variables de entorno con `.env.example`
- PostgreSQL real mediante SQLAlchemy + psycopg
- Frontend web mínimo servido por FastAPI como fallback de inspección rápida
- Endpoints:
  - `GET /` → redirige a `/app`
  - `GET /app`
  - `GET /app/exercises/{id}`
  - `GET /api/v1/health`
  - `GET /api/v1/exercises`
  - `GET /api/v1/exercises/{id}`
  - `GET /api/v1/workout-sessions`
  - `GET /api/v1/workout-sessions/{id}`
  - `POST /api/v1/workout-sessions`
  - `GET /api/v1/user-profile`
  - `PUT /api/v1/user-profile`
  - `GET /api/v1/ai/status`
- `docker-compose.yml` para levantar PostgreSQL local
- `db/schema.sql` con tabla `exercises` y seed inicial con descripción, instrucciones y prescripción base

### Flutter (`flutter_app/`)
- App Flutter compilable en Linux desktop y Android
- Lista real de ejercicios desde backend
- Detalle real de ejercicio
- Guardado real de sesión de entrenamiento y refresco automático de la lista
- Historial visible de sesiones persistidas en PostgreSQL
- Pestaña de perfil/configuración con datos personales relevantes para personalización futura
- Estado IA visible desde backend, sin guardar claves sensibles en la app

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

Demo web local:

```bash
xdg-open http://localhost:8000/app
```

Ejemplo manual:

```bash
curl http://localhost:8000/api/v1/exercises/ex-001
```

### Flutter

```bash
cd flutter_app
PATH=/home/ramni/sdk/flutter/bin:$PATH flutter pub get
PATH=/home/ramni/sdk/flutter/bin:$PATH flutter run -d linux --dart-define=API_BASE_URL=http://localhost:8000/api/v1
```

Para Android Emulator:

```bash
PATH=/home/ramni/sdk/flutter/bin:$PATH flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

Build validada en esta Raspberry:

```bash
cd flutter_app
PATH=/home/ramni/sdk/flutter/bin:$PATH flutter build linux --debug --dart-define=API_BASE_URL=http://localhost:8000/api/v1
./build/linux/arm64/debug/bundle/gym_trainer_app
```

## Qué funciona ya
- Backend sirviendo catálogo y detalle de ejercicios desde PostgreSQL real.
- Backend sirviendo creación y lectura de sesiones de entrenamiento en PostgreSQL real.
- Backend sirviendo lectura y guardado de perfil de usuario single-user.
- Backend exponiendo estado conceptual de IA por backend (`AI_PROVIDER`, `AI_ENABLED`) sin exponer secretos al cliente.
- Flutter compila en esta Raspberry para Linux desktop.
- Flutter muestra catálogo, detalle y listado de sesiones guardadas.
- Flutter incluye pestaña de perfil con edad, peso, altura, sexo, objetivo, lesiones y observaciones médicas.
- Desde el detalle se puede guardar una sesión real y volver a verla en la pantalla inicial.
- Frontend web visible en navegador dentro de la red local.
- Healthcheck validando conexión a base de datos.
- Seed inicial persistido para ejercicios, una sesión de ejemplo y un perfil base.
- Make targets mínimos para levantar, resetear y comprobar el slice.

## Cómo probar el flujo real mínimo

1. Arranca backend si no está arriba: `make backend-run`
2. Arranca Flutter Linux con el comando de arriba.
3. En la app, toca un ejercicio.
4. Pulsa **Guardar sesión real**.
5. Vuelve atrás. La sesión aparece en **Sesiones guardadas**.

También puedes validar por API:

```bash
curl http://localhost:8000/api/v1/workout-sessions
curl http://localhost:8000/api/v1/user-profile
curl http://localhost:8000/api/v1/ai/status
curl -X PUT http://localhost:8000/api/v1/user-profile \
  -H 'Content-Type: application/json' \
  -d '{"display_name":"Ramón","age":33,"weight_kg":78.5,"height_cm":178,"goal":"ganar_musculo","injuries":"Molestia hombro derecho","medical_notes":"Progresión prudente","ai_personalization_enabled":true}'
curl -X POST http://localhost:8000/api/v1/workout-sessions \
  -H 'Content-Type: application/json' \
  -d '{"exercise_id":"ex-002","performed_at":"2026-04-17T15:00:00Z","sets_completed":4,"reps_completed":"8-10","notes":"Sesión real creada en validación."}'
```

## Limitaciones reales ahora mismo
- No hay auth ni usuarios todavía.
- No hay tests automáticos aún.
- La persistencia actual es single-user y sin planificación avanzada.
- El estado IA actual es preparatorio, todavía sin generación de rutinas o nutrición.
- La recreación completa de esquema sigue siendo el camino más simple si se quiere resembrar la base desde cero.

## Siguiente paso recomendado
1. Añadir usuario/sesión real para no mezclar entrenamientos entre personas.
2. Permitir crear una sesión con varios ejercicios en vez de una sola entrada rápida.
3. Montar tests API + smoke test Flutter.
