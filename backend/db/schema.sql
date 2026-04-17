DROP TABLE IF EXISTS exercises;

CREATE TABLE exercises (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    muscle_group TEXT NOT NULL,
    difficulty TEXT NOT NULL,
    equipment TEXT NOT NULL,
    description TEXT NOT NULL,
    instructions TEXT NOT NULL,
    default_sets INTEGER NOT NULL,
    default_reps TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO exercises (
    id,
    name,
    muscle_group,
    difficulty,
    equipment,
    description,
    instructions,
    default_sets,
    default_reps
)
VALUES
    (
        'ex-001',
        'Sentadilla goblet',
        'piernas',
        'principiante',
        'mancuerna',
        'Ejercicio base para piernas y core con una sola carga frontal.',
        'Sujeta una mancuerna al pecho, baja con la espalda neutra hasta romper paralelo y sube empujando el suelo.',
        4,
        '10-12'
    ),
    (
        'ex-002',
        'Press banca con mancuernas',
        'pecho',
        'intermedio',
        'mancuernas',
        'Empuje horizontal para pecho, tríceps y estabilidad escapular.',
        'Apoya escápulas en el banco, baja controlado hasta 90 grados y empuja arriba sin chocar mancuernas.',
        4,
        '8-10'
    ),
    (
        'ex-003',
        'Remo con polea baja',
        'espalda',
        'principiante',
        'polea',
        'Tirón horizontal para espalda media y control postural.',
        'Saca pecho, tira de la empuñadura hacia el ombligo y vuelve lento manteniendo hombros abajo.',
        3,
        '12-15'
    );
