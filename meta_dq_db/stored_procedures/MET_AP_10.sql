DROP FUNCTION IF EXISTS MET_AP_10_cell(TEXT, TEXT, TEXT);

CREATE OR REPLACE FUNCTION MET_AP_10_cell(
    pk_name TEXT,
    table_name TEXT,
    column_name TEXT
)
RETURNS TABLE(row_id INTEGER, value NUMERIC)
LANGUAGE plpgsql
AS $$
DECLARE
    sql TEXT;
BEGIN
    sql := format($f$
        SELECT
            b.%1$I AS row_id,
            CASE
                WHEN dup.count > 1 or dup.%3$I is NULL THEN 0.0
                ELSE 1.0
            END AS value
        FROM %2$I b
        LEFT JOIN (
            SELECT %3$I, COUNT(*) AS count
            FROM %2$I
            WHERE %3$I IS NOT NULL
            GROUP BY %3$I
        ) dup ON dup.%3$I = b.%3$I
    $f$, pk_name, table_name, column_name);

    RETURN QUERY EXECUTE sql;
END;
$$;
-- we named in 11
DROP FUNCTION IF EXISTS MET_AP_11_column(TEXT, TEXT);

CREATE OR REPLACE FUNCTION MET_AP_11_column(
    table_name TEXT,
    column_name TEXT
)
RETURNS FLOAT
LANGUAGE plpgsql
AS $$
DECLARE
    sql TEXT;
    v_total BIGINT;
    v_unique BIGINT;
BEGIN
    -- Total number of rows in the table
    EXECUTE format('SELECT COUNT(*) FROM %I', table_name) INTO v_total;

    IF v_total = 0 THEN
        RETURN 0.0;
    END IF;

    -- Number of rows where the value is unique
    sql := format($f$
        SELECT COUNT(*)
        FROM %1$I b
        LEFT JOIN (
            SELECT %2$I, COUNT(*) AS count
            FROM %1$I
            WHERE %2$I IS NOT NULL
            GROUP BY %2$I
        ) dup ON dup.%2$I = b.%2$I
        WHERE dup.count = 1
    $f$, table_name, column_name);

    EXECUTE sql INTO v_unique;

    RETURN v_unique::FLOAT / v_total;
END;
$$;
