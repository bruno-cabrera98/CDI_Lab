DROP FUNCTION IF EXISTS MET_AP_8_column(TEXT, TEXT);

CREATE OR REPLACE FUNCTION MET_AP_8_column(
    table_name TEXT,
    column_name TEXT
)
RETURNS FLOAT
LANGUAGE plpgsql
AS $$
DECLARE
    sql TEXT;
    v_total BIGINT;
    v_valid BIGINT;
    v_density FLOAT;
BEGIN
    EXECUTE format('SELECT COUNT(*) FROM %I', table_name) INTO v_total;

    IF v_total = 0 THEN
        RETURN 0.0;
    END IF;

    EXECUTE format(
        'SELECT COUNT(*) FROM %I WHERE %I BETWEEN 1 AND 120',
        table_name, column_name
    ) INTO v_valid;

    v_density := v_valid::FLOAT / v_total;
    RETURN v_density;
END;
$$;
DROP FUNCTION IF EXISTS MET_AP_8_cell(TEXT, TEXT, TEXT);

CREATE OR REPLACE FUNCTION MET_AP_8_cell(
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
            %I AS row_id,
            CASE WHEN %I BETWEEN 1 AND 120 THEN 1.0 ELSE 0.0 END AS value
        FROM %I
    $f$, pk_name, column_name, table_name);

    RETURN QUERY EXECUTE sql;
END;
$$;


