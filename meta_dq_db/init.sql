-- AD id pk on books table
-- remove id as pk from books and add _id
--ALTER TABLE books ADD COLUMN _id SERIAL PRIMARY KEY;
--ALTER TABLE users ADD COLUMN _id SERIAL PRIMARY KEY;
--ALTER TABLE ratings ADD COLUMN _id SERIAL PRIMARY KEY;

-- DIMENSION TABLE
drop table if exists meta_dq_dimension cascade;
create table if not exists meta_dq_dimension
(
    id serial primary key,
    code text not null unique,
    name text not null,
    description text
);
-- DATA
INSERT INTO meta_dq_dimension (code, name, description)
VALUES
    ('DIM_1_COMP', 'Completitud', 'Evalua que se posean todos los datos'),
    ('DIM_2_EXAC', 'Exactitud', 'Evaluar precisión de datos'),
    ('DIM_3_CONS', 'Consistencia', 'Evalua satisfacción de reglas semánticas sobre los datos'),
    ('DIM_4_UNIC', 'Unicidad', 'Nivel de duplicación de los datos'),
    ('DIM_5_FRES', 'Frescura', 'Dimensión relacionada a la temporalidad de los datos'),
    ('DIM_6_RESP', 'Responsiveness', 'Tiempo de reacción');


-- FACTOR TABLE
drop table if exists meta_dq_factor cascade;
create table if not exists meta_dq_factor
(
    id serial primary key,
    code text not null unique,
    name text not null,
    description text,
    dimension_id integer not null references meta_dq_dimension(id),
    dimension_code text not null references meta_dq_dimension(code)
);
-- DATA
INSERT INTO meta_dq_factor (code, name, description, dimension_id, dimension_code)
SELECT t.code, t.name, t.description, mdq_d.id, t.dimension_code
FROM (
    VALUES
        ('FAC_1_DENS', 'Densidad', 'Evalua el porcentaje de valores no NULL', 'DIM_1_COMP'),
        ('FAC_2_SINT', 'Sintáctica', 'Mide sintacticamente si los valores coinciden con dominio', 'DIM_2_EXAC'),
        ('FAC_3_SEMA', 'Semántica', 'Mide semánticamente si los valores coinciden con dominio', 'DIM_2_EXAC'),
        ('FAC_4_IDOM', 'Integridad de dominio', 'Se cumplen reglas sobre un atributo', 'DIM_3_CONS'),
        ('FAC_5_IREL', 'Integridad inter-relación', 'Control de dependecias funcionales entre tablas', 'DIM_3_CONS'),
        ('FAC_6_NDUP', 'No Duplicación', 'Evalua que clave no se repita en tabla', 'DIM_4_UNIC'),
        ('FAC_7_ACTU', 'Actualidad', 'Evalua que tan acuales son los datos', 'DIM_5_FRES'),
        ('FAC_8_TRES', 'Tiempo de respuesta', 'Evalua el tiempo de respuesta se mantega en cierto parametro', 'DIM_6_RESP')
) AS t(code, name, description, dimension_code)
JOIN meta_dq_dimension mdq_d ON mdq_d.code = t.dimension_code;


-- METRICS TABLE
drop table if exists meta_dq_metric cascade;
create table if not exists meta_dq_metric
(
    id serial primary key,
    code text not null unique,
    name text not null,
    description text,
    granularity text not null,
    domain text not null,
    factor_id integer not null references meta_dq_factor(id),
    factor_code text not null references meta_dq_factor(code)
);
-- DATA
INSERT INTO meta_dq_metric (code, name, description, granularity, domain, factor_id, factor_code)
SELECT t.code, t.name, t.description, t.granularity, t.domain, mdq_f.id factor_id, t.factor_code
FROM (
    VALUES
        ('MTR_1_DEN_COL', 'Densidad-Columna', 'Mide densidad de valores no nulos en columna. 0 equivale a todos los valores son nulos.', 'COLUMN', '[0..1]', 'FAC_1_DENS'),
        ('MTR_2_EXASX_CEL', 'Exac-Sx-Formato-Celda', 'Mide si la celda presenta valores con el formato establecido.', 'CELL', '{0,1}', 'FAC_2_SINT'),
        ('MTR_3_EXASEM_CEL', 'Exac-Sem-Celda', 'Determina si el valor de celta es semánticamente correcto.', 'CELL', '{0,1}', 'FAC_3_SEMA'),
        ('MTR_4_CONDM_CEL', 'Consistencia-Dom-Celda', 'Mide si el valor de consistente según su dominio.', 'CELL', '{0,1}', 'FAC_4_IDOM'),
        ('MTR_5_CONIN_CEL', 'Consistencia-Int-Celda', 'Mide si el valor de consistente entre varias tablas.', 'CELL', '{0,1}', 'FAC_5_IREL'),
        ('MTR_6_NDUP_CEL', 'Unicidad-no-dup-celda', 'Mide si el valor no esta duplicado en la tabla.a', 'CELL', '{0,1}', 'FAC_6_NDUP'),
        ('MTR_7_NDUP_COL', 'Unicidad-no-dup-columna', 'Mide ratio de valores únicos frente a todos los valores de columna.', 'COLUMN', '[0..1]', 'FAC_6_NDUP'),
        ('MTR_8_ACTAÑO_TAB', 'Fres-Act-De-Año', 'Mide a nivel de tabla comparando la cantidad tuplas del año actual comparando con el promedio de cantidad de tuplas de cada año. (ver documento para mas detalles)', 'TABLE', '[0..1]', 'FAC_7_ACTU'),
        ('MTR_9_T_RESP_TAB', 'Tiempo-Resp-Consulta', 'Mide el tiempo de respuesta de una consulta en nuestra base de datos', 'TABLE', 'seconds', 'FAC_8_TRES')
) AS t(code, name, description, granularity, domain, factor_code)
JOIN meta_dq_factor mdq_f ON mdq_f.code = t.factor_code;


-- METHODS
drop table if exists meta_dq_method cascade;
create table if not exists meta_dq_method
(
    id serial primary key,
    code text not null unique,
    name text not null,
    description text,
    in_dtype text not null,
    out_dtype text not null,
    process text not null,
    metric_id integer not null references meta_dq_metric(id),
    metric_code text not null references meta_dq_metric(code)
);
-- DATA
INSERT INTO meta_dq_method (code, name, description, in_dtype, out_dtype, process, metric_id, metric_code)
SELECT t.code, t.name, t.description, t.in_dtype, t.out_dtype, t.process, mdq_m.id, t.metric_code
FROM (
    VALUES
        ('MET_1', 'Densidad-Columna-Contar', 'Mide el promedio (de 0 a 1) de la cantidad de celdas no nulas en una columna.', 'atributos', 'float', 'Se cuenta la cantidad de valores no nulos y se divide por la cantidad de valores totales.', 'MTR_1_DEN_COL'),
        ('MET_2', 'Met-Exac-Sx-Formato-Celda', 'Validar si una celda sigue un formato prestablecido para el attributo.', 'string', 'bool', 'Si el valor de la celda coincide con cierto patrón regex el resultado será 1 sino 0.', 'MTR_2_EXASX_CEL'),
        ('MET_3', 'Exac-Sem-Fecha', 'Determina si la fecha de publicación de un libro coincide con la real.', 'fecha', 'booleano', 'Compara la fecha de NL con la de un referencial válido.', 'MTR_3_EXASEM_CEL'),
        ('MET_4', 'Consistencia-Inter-Relación', 'Determina si el valor de una celda cumple la relación con los valores de otra tabla.', 'integer', 'booleano', 'Determina para cada tupla si el valor rating_count coincide con la cantidad de tuplas de ese mismo libro en la tabla ratings.', 'MTR_5_CONIN_CEL'),
        ('MET_5', 'Consistencia-Dom-Celda-Contar', 'Determina si el valor de una celda es inconsistente con el dominio.', 'integer, string', 'booleano', 'Consultar y determinar según atributo a medir si se trata de una inconsistencia.', 'MTR_4_CONDM_CEL'),
        ('MET_6', 'Unicidad-No-Dup-Celda', 'Determina si el valor de una celda está duplicado en el resto de la columna.', 'atributos', 'booleano', 'Busca si el valor a medir está duplicado en la misma columna.', 'MTR_6_NDUP_CEL'),
        ('MET_7', 'Unicidad-No-Dup-Columna', 'Calcula el porcentaje de valores duplicados en esa columna para un atributo.', 'atributos', '(0,1)', 'Divide los duplicados entre la cantidad de tuplas.', 'MTR_7_NDUP_COL'),
        ('MET_8', 'Fres-Act-De-Año', 'Se determina para el año actual si la cantidad de tuplas es cercana al promedio.', 'fecha', 'float', 'Se aplica la fórmula a nivel de tabla: min(1 - ((p - a)/p)^3, 1), donde p es el promedio agregado de cantidad de tuplas agrupadas por año y a es la cantidad de tuplas del año actual.', 'MTR_8_ACTAÑO_TAB')
) AS t(code, name, description, in_dtype, out_dtype, process, metric_code)
JOIN meta_dq_metric mdq_m ON mdq_m.code = t.metric_code;


-- APPLIED METHODS
DROP TABLE IF EXISTS meta_dq_applied_method CASCADE;
CREATE TABLE IF NOT EXISTS meta_dq_applied_method (
    id serial PRIMARY KEY,
    code text NOT NULL UNIQUE,
    method_id integer NOT NULL REFERENCES meta_dq_method(id),
    method_code text NOT NULL REFERENCES meta_dq_method(code),
    name text NOT NULL,
    type text NOT NULL,
    description text NOT NULL
);
-- DATA
INSERT INTO meta_dq_applied_method (code, method_id, method_code, name, type, description)
SELECT t.code, mdq_m.id, t.method_code, t.name, t.type, t.description
FROM (
    VALUES
        ('MET_AP_1', 'MET_1', 'Densidad en atributos', 'Medición',
         'Recibe el nombre de un atributo y cuenta la cantidad de valores no nulos en cierta columna y la divide por la cantidad de valores totales.'),
        ('MET_AP_2', 'MET_2', 'Formato tipo lista en string', 'Medición',
         'Compara un valor contra el patrón regex ^\\[(?:""[^""]*""(?:\\s*,\\s*""[^""]*"")*)?\\]$ para asegurar el formato [""test"", ""test""]'),
        ('MET_AP_3', 'MET_2', 'Formato ISO fecha', 'Medición',
         'Compara un valor contra el patrón regex ^\\d{4}-\\d{2}-\\d{2}$ para asegurar el formato YYYY-MM-DD'),
        ('MET_AP_4', 'MET_2', 'Formato ISBN-10', 'Medición',
         'Compara un valor contra el patrón regex ^[0-9]{9}[0-9X]$ para asegurar un formato ISBN válido'),
        ('MET_AP_5', 'MET_2', 'Formato locación ciudad,estado,país', 'Medición',
         'Compara un valor contra el patrón regex ^.+,.+,.+$ para asegurar el formato esperado de ubicación'),
        ('MET_AP_6', 'MET_3', 'Validación semántica de fecha', 'Medición',
         'Compara fecha con referencial válido; 1 si coincide, 0 si no'),
        ('MET_AP_7', 'MET_4', 'Validación de cantidad ratings', 'Medición',
         'Cuenta ratings reales y compara con el valor en la columna rating_count'),
        ('MET_AP_8', 'MET_5', 'Validación de edad válida', 'Medición',
         'Evalúa si el valor dado está entre 1 y 120'),
        ('MET_AP_9', 'MET_5', 'Validación de longitud de nombre', 'Medición',
         'Evalúa si el nombre tiene entre 3 y 40 caracteres'),
        ('MET_AP_10', 'MET_6', 'Detección de duplicados en ISBN', 'Medición',
         'Evalúa si el valor ISBN se encuentra duplicado en la tabla'),
        ('MET_AP_11', 'MET_7', 'Agregación de unicidad en atributos', 'Agregación',
         'Suma los resultados de duplicación y divide por la cantidad de tuplas'),
        ('MET_AP_12', 'MET_8', 'Frescura de datos por año', 'Medición',
         'Calcula p (promedio de tuplas por año) y a (tuplas año actual), luego evalúa min(1 - ((p - a)/p)^3, 1)')
) AS t(code, method_code, name, type, description)
JOIN meta_dq_method mdq_m ON mdq_m.code = t.method_code;

-- APPLIED METHODS
DROP TABLE IF EXISTS meta_dq_applied_method_applied_to_rel CASCADE;
CREATE TABLE IF NOT EXISTS meta_dq_applied_method_applied_to_rel (
    applied_method_id integer NOT NULL REFERENCES meta_dq_applied_method(id),
    table_name text NOT NULL,
    table_schema text NOT NULL,
    column_name text,
    granularity text NOT NULL DEFAULT 'column', -- 'cell', 'column', 'table'
    PRIMARY KEY (applied_method_id, table_name, table_schema, column_name, granularity)
);
-- DATA (only do for isbn, user_id, age and MET_AP_1 for now)
INSERT INTO meta_dq_applied_method_applied_to_rel (applied_method_id, table_name, table_schema, column_name, granularity)
SELECT mdq_am.id, t.table_name, t.table_schema, t.column_name, t.granularity
FROM (
    VALUES
        ('MET_AP_1', 'books', 'public', 'isbn', 'column'),
        ('MET_AP_1', 'users', 'public', 'id', 'column'),
        ('MET_AP_1', 'users', 'public', 'age', 'column'),
        ('MET_AP_2', 'books', 'public', 'authors', 'column'),
        ('MET_AP_2', 'books', 'public', 'categories', 'column'),

        ('MET_AP_3', 'books', 'public', 'published_date', 'column'),
        ('MET_AP_4', 'books', 'public', 'isbn', 'column'),
        ('MET_AP_5', 'users', 'public', 'location', 'column')
) AS t(met_ap_code, table_name, table_schema, column_name, granularity)
JOIN meta_dq_applied_method mdq_am ON mdq_am.code = t.met_ap_code;


-- RESULTS
DROP TABLE IF EXISTS meta_dq_measurement_report CASCADE;
CREATE TABLE IF NOT EXISTS meta_dq_measurement_report (
    id serial PRIMARY KEY,
    date timestamp DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS meta_dq_results CASCADE;
CREATE TABLE IF NOT EXISTS meta_dq_results (
    id serial PRIMARY KEY,
    report_id integer NOT NULL REFERENCES meta_dq_measurement_report(id),
    applied_method_id integer NOT NULL REFERENCES meta_dq_applied_method(id),
    granularity text NOT NULL, -- 'cell', 'column', 'table'
    table_schema text NOT NULL,
    table_name text NOT NULL,
    column_name text,
    row_id integer, -- For cell-level results
    result float,
    date timestamp DEFAULT CURRENT_TIMESTAMP
);
