DROP FUNCTION IF EXISTS MET_AP_9_column(TEXT, TEXT);

CREATE OR REPLACE FUNCTION MET_AP_9_column(
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
        'SELECT COUNT(*) FROM %I WHERE LENGTH(%I) BETWEEN 3 AND 40',
        table_name, column_name
    ) INTO v_valid;

    v_density := v_valid::FLOAT / v_total;
    RETURN v_density;
END;
$$;

DROP FUNCTION IF EXISTS MET_AP_9_cell(TEXT, TEXT, TEXT);

CREATE OR REPLACE FUNCTION MET_AP_9_cell(
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
            CASE WHEN LENGTH(%I) BETWEEN 3 AND 40 THEN 1.0 ELSE 0.0 END AS value
        FROM %I
    $f$, pk_name, column_name, table_name);

    RETURN QUERY EXECUTE sql;
END;
$$;

select * from MET_AP_9_column('users', 'name');


select
    b.isbn,
    b.ratings_count,
    case when b.isbn is null or b.ratings_count is null or b.ratings_count != count(r._id)
        then 0
        else 1
    end as result

from books b
left join ratings r on r.isbn = b.isbn
group by b._id

select *
from books b
join ratings r on r.isbn = b.isbn
where b.isbn is not null and b.ratings_count is not null


SELECT
    b._id,
    CASE
        WHEN b.isbn IS NULL OR b.ratings_count IS NULL OR b.ratings_count != r.rating_count THEN 0
        ELSE 1
    END AS result
FROM books b
LEFT JOIN (
    SELECT isbn, COUNT(*) AS rating_count
    FROM ratings
    GROUP BY isbn
) r ON r.isbn = b.isbn

