# CDI Lab

This project contains a minimal setup for evaluating data quality metrics in a PostgreSQL database. It ships with several PL/pgSQL stored procedures and a Jupyter notebook that demonstrate how to measure completeness, accuracy and other quality dimensions.

## Database initialization

Create the metadata tables and load reference information by executing the initialization script. Run the following command from the repository root:

```bash
psql -d <your_database> -f meta_dq_db/init.sql
```

This will create the dimension, factor and metric tables as well as auxiliary tables referenced by the stored procedures.

## Running stored procedures

The stored procedure definitions live in `meta_dq_db/stored_procedures`. You can load them individually with `psql -f` and invoke them either from the `CDI_evaluation.ipynb` notebook or any script that connects to the database.

- **Notebook**: use the helper functions `execute_stored_procedure_column` and `execute_stored_procedure_cell` defined in the notebook to run a procedure and fetch results.
- **SQL shell**: call the procedure directly, e.g. `SELECT MET_AP_1_column('books', 'title');`.

## Database configuration

The `CDI_evaluation.ipynb` notebook reads the database connection settings from environment variables. Define the following variables before running the notebook:

- `DB_NAME`: name of the PostgreSQL database
- `DB_USER`: database username
- `DB_PASSWORD`: password for the user

You can set them in your shell or place them in a `.env` file at the repository root. The notebook uses `python-dotenv` to automatically load the file.
