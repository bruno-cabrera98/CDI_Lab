
DROP FUNCTION IF EXISTS MET_AP_1_column(TEXT, TEXT);
CREATE OR REPLACE FUNCTION MET_AP_1_column(
    table_name TEXT,
    column_name TEXT
)
RETURNS FLOAT
LANGUAGE plpgsql
AS $$
DECLARE
    sql_total TEXT;
    sql_non_null TEXT;
    v_total BIGINT;
    v_non_null BIGINT;
    v_density NUMERIC;
BEGIN
    -- Build dynamic SQL to get total row count
    sql_total := format('SELECT COUNT(*) FROM %I', table_name);
    EXECUTE sql_total INTO v_total;

    IF v_total = 0 THEN
        RETURN 0.0;  -- Avoid division by zero
    END IF;

    -- Build dynamic SQL to get non-null count of the specified column
    sql_non_null := format('SELECT COUNT(*) FROM %I WHERE %I IS NOT NULL', table_name, column_name);
    EXECUTE sql_non_null INTO v_non_null;

    -- Calculate density
    v_density := v_non_null::FLOAT / v_total;
    RETURN v_density;
END;
$$;

drop function if exists MET_AP_1_cell(TEXT, TEXT, TEXT);
-- 1 or 0
CREATE OR REPLACE FUNCTION MET_AP_1_cell(
    pk_name TEXT,
    table_name TEXT,
    column_name TEXT
)
-- returns row_id, and value
RETURNS TABLE(row_id INTEGER, value NUMERIC)
LANGUAGE plpgsql
AS $$
DECLARE
    sql TEXT;
BEGIN
    -- Build dynamic SQL to get row_id and density value for the specified column
    sql := format('SELECT %I, CASE WHEN %I IS NOT NULL THEN 1.0 ELSE 0.0 END AS value FROM %I', pk_name, column_name, table_name);
    RETURN QUERY EXECUTE sql;
END;
$$;