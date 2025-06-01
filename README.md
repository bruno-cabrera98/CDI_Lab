## Database configuration

The `CDI_evaluation.ipynb` notebook reads the database connection settings from environment variables. Define the following variables before running the notebook:

- `DB_NAME`: name of the PostgreSQL database
- `DB_USER`: database username
- `DB_PASSWORD`: password for the user

You can set them in your shell or place them in a `.env` file at the repository root. The notebook uses `python-dotenv` to automatically load the file.
