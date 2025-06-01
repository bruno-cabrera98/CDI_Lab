DROP FUNCTION IF EXISTS MET_2_cell(TEXT, TEXT, TEXT, TEXT);
CREATE OR REPLACE FUNCTION MET_2_cell(
    pk_name TEXT,
    table_name TEXT,
    column_name TEXT,
    regex TEXT
)
RETURNS TABLE(row_id INTEGER, value INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    sql TEXT;
BEGIN
    sql := format($f$
        SELECT
            b.%1$I AS row_id,
            CASE WHEN b2.%3$I IS NULL THEN 0 ELSE 1 END AS value
        FROM %2$I b
        LEFT JOIN %2$I b2 ON b.%1$I = b2.%1$I AND b2.%3$I ~ %4$L
    $f$, pk_name, table_name, column_name, regex);

    RETURN QUERY EXECUTE sql;
END;
$$;

-- Applied methods (USE PREVIOUS FUNCTION)
-- MET_AP_2_CELL -> ^\[(?:"[^"]*"(?:\s*,\s*"[^"]*")*)?\]$
DROP FUNCTION IF EXISTS MET_AP_2_cell(TEXT, TEXT, TEXT, TEXT);
CREATE OR REPLACE FUNCTION MET_AP_2_cell(
    pk_name TEXT,
    table_name TEXT,
    column_name TEXT
)
RETURNS TABLE(row_id INTEGER, value INTEGER)
LANGUAGE plpgsql
AS $$

DECLARE
    sql TEXT;
BEGIN
    sql := format($f$
        SELECT * FROM MET_2_cell(
            %L, %L, %L, %L
        )
    $f$, pk_name, table_name, column_name, '^\[(?:"[^"]*"(?:\s*,\s*"[^"]*")*)?\]$');

    RETURN QUERY EXECUTE sql;
END;
$$;

DROP FUNCTION IF EXISTS MET_AP_2_column(TEXT, TEXT, TEXT);
CREATE OR REPLACE FUNCTION MET_AP_2_column(
    table_name TEXT,
    column_name TEXT
)
RETURNS FLOAT
LANGUAGE plpgsql
AS $$
DECLARE
    sql TEXT;
    v_density NUMERIC;
BEGIN
    -- Build dynamic SQL to calculate density for the specified column
    sql := format($f$
        SELECT
            CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM %I) AS density
        FROM %I b
        WHERE b.%I ~ %L
    $f$, table_name, table_name, column_name, '^\[(?:"[^"]*"(?:\s*,\s*"[^"]*")*)?\]$');

    EXECUTE sql INTO v_density;

    RETURN v_density;
END;
$$;

DROP FUNCTION IF EXISTS MET_AP_3_cell(TEXT, TEXT, TEXT);

CREATE OR REPLACE FUNCTION MET_AP_3_cell(
    pk_name TEXT,
    table_name TEXT,
    column_name TEXT
)
RETURNS TABLE(row_id INTEGER, value INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    sql TEXT;
BEGIN
    sql := format($f$
        SELECT * FROM MET_2_cell(
            %L, %L, %L, %L
        )
    $f$, pk_name, table_name, column_name, '^\d{4}-\d{2}-\d{2}$');

    RETURN QUERY EXECUTE sql;
END;
$$;
DROP FUNCTION IF EXISTS MET_AP_3_column(TEXT, TEXT);

CREATE OR REPLACE FUNCTION MET_AP_3_column(
    table_name TEXT,
    column_name TEXT
)
RETURNS FLOAT
LANGUAGE plpgsql
AS $$
DECLARE
    sql TEXT;
    v_density NUMERIC;
BEGIN
    sql := format($f$
        SELECT
            CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM %I) AS density
        FROM %I b
        WHERE b.%I ~ %L
    $f$, table_name, table_name, column_name, '^\d{4}-\d{2}-\d{2}$');

    EXECUTE sql INTO v_density;
    RETURN v_density;
END;
$$;

DROP FUNCTION IF EXISTS MET_AP_4_cell(TEXT, TEXT, TEXT);

CREATE OR REPLACE FUNCTION MET_AP_4_cell(
    pk_name TEXT,
    table_name TEXT,
    column_name TEXT
)
RETURNS TABLE(row_id INTEGER, value INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    sql TEXT;
BEGIN
    sql := format($f$
        SELECT * FROM MET_2_cell(
            %L, %L, %L, %L
        )
    $f$, pk_name, table_name, column_name, '^[0-9]{9}[0-9X]$');

    RETURN QUERY EXECUTE sql;
END;
$$;
DROP FUNCTION IF EXISTS MET_AP_4_column(TEXT, TEXT);

CREATE OR REPLACE FUNCTION MET_AP_4_column(
    table_name TEXT,
    column_name TEXT
)
RETURNS FLOAT
LANGUAGE plpgsql
AS $$
DECLARE
    sql TEXT;
    v_density NUMERIC;
BEGIN
    sql := format($f$
        SELECT
            CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM %I) AS density
        FROM %I b
        WHERE b.%I ~ %L
    $f$, table_name, table_name, column_name, '^[0-9]{9}[0-9X]$');

    EXECUTE sql INTO v_density;
    RETURN v_density;
END;
$$;
DROP FUNCTION IF EXISTS MET_AP_5_cell(TEXT, TEXT, TEXT);

CREATE OR REPLACE FUNCTION MET_AP_5_cell(
    pk_name TEXT,
    table_name TEXT,
    column_name TEXT
)
RETURNS TABLE(row_id INTEGER, value INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    sql TEXT;
BEGIN
    sql := format($f$
        SELECT * FROM MET_2_cell(
            %L, %L, %L, %L
        )
    $f$, pk_name, table_name, column_name, '^.+,.+,.+$');

    RETURN QUERY EXECUTE sql;
END;
$$;
DROP FUNCTION IF EXISTS MET_AP_5_column(TEXT, TEXT);

CREATE OR REPLACE FUNCTION MET_AP_5_column(
    table_name TEXT,
    column_name TEXT
)
RETURNS FLOAT
LANGUAGE plpgsql
AS $$
DECLARE
    sql TEXT;
    v_density NUMERIC;
BEGIN
    sql := format($f$
        SELECT
            CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM %I) AS density
        FROM %I b
        WHERE b.%I ~ %L
    $f$, table_name, table_name, column_name, '^.+,.+,.+$');

    EXECUTE sql INTO v_density;
    RETURN v_density;
END;
$$;

