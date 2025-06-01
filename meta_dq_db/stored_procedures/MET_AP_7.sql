DROP FUNCTION IF EXISTS MET_AP_7_cell(TEXT, TEXT, TEXT);

CREATE OR REPLACE FUNCTION MET_AP_7_cell(
    pk_name TEXT,
    table_name TEXT,
    column_name TEXT
)
RETURNS TABLE(row_id INTEGER, value NUMERIC)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        b._id AS row_id,
        CASE
            WHEN b.isbn IS NULL OR b.ratings_count IS NULL OR b.ratings_count != r.rating_count THEN 0.0
            ELSE 1.0
        END AS value
    FROM books b
    LEFT JOIN (
        SELECT isbn, COUNT(*) AS rating_count
        FROM ratings
        GROUP BY isbn
    ) r ON r.isbn = b.isbn;
END;
$$;
DROP FUNCTION IF EXISTS MET_AP_7_column(TEXT, TEXT);

CREATE OR REPLACE FUNCTION MET_AP_7_column(
    table_name TEXT,
    column_name TEXT
)
RETURNS FLOAT
LANGUAGE plpgsql
AS $$
DECLARE
    v_total BIGINT;
    v_matches BIGINT;
BEGIN
    -- Total number of books
    SELECT COUNT(*) INTO v_total FROM books;

    IF v_total = 0 THEN
        RETURN 0.0;
    END IF;

    -- Number of books with matching ratings_count
    SELECT COUNT(*) INTO v_matches
    FROM books b
    LEFT JOIN (
        SELECT isbn, COUNT(*) AS rating_count
        FROM ratings
        GROUP BY isbn
    ) r ON r.isbn = b.isbn
    WHERE b.isbn IS NOT NULL
      AND b.ratings_count IS NOT NULL
      AND b.ratings_count = r.rating_count;

    RETURN v_matches::FLOAT / v_total;
END;
$$;
