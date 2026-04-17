from sqlalchemy import text
from sqlalchemy.engine import Connection

from app.models.exercise import Exercise


_EXERCISE_COLUMNS = """
    id,
    name,
    muscle_group,
    difficulty,
    equipment,
    description,
    instructions,
    default_sets,
    default_reps
"""

_EXERCISE_LIST_QUERY = text(
    f"""
    SELECT {_EXERCISE_COLUMNS}
    FROM exercises
    ORDER BY created_at ASC, name ASC
    """
)

_EXERCISE_DETAIL_QUERY = text(
    f"""
    SELECT {_EXERCISE_COLUMNS}
    FROM exercises
    WHERE id = :exercise_id
    """
)


def list_exercises(connection: Connection) -> list[Exercise]:
    rows = connection.execute(_EXERCISE_LIST_QUERY).mappings().all()
    return [Exercise(**row) for row in rows]


def get_exercise(connection: Connection, exercise_id: str) -> Exercise | None:
    row = connection.execute(
        _EXERCISE_DETAIL_QUERY,
        {"exercise_id": exercise_id},
    ).mappings().first()

    if row is None:
        return None

    return Exercise(**row)
