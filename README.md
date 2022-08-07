Hey! This is a small sample project for a specific use case: a table that contains information for multiple events, with the same column having different meanings.

## Project Overview
The project showcases two different ways to handle this case: output as a single table or separate tables.

The project can be separated in three pieces: seeds, models and macros. Long story short:
- seeds are .csv files that are transformed into a table. In this case, we have only one seed, for the events (`events_done.csv`).
- models are .sql files that are going to be materialized in tables/views. In this case, we have 4 models.
    - `single_table/fct_event_done.sql`: Model that basically gets all the events in the `events_done` seed and enrichens them, by adding a surrogate key and a event-specific transformation into a column called `event_detail`
    - `separate_tables/`: In this other approach, each event gets it's own table
        - `fct_file_uploaded.sql`: Event for when a file is uploaded. The `value` is transformed into `file_name`, with a `file_extension` column being added.
        - `fct_purchased_done.sql`: Event for when a purchase is completed. The `value` is transformed into `revenue`, with a `revenue_decimals` column being added.
        - `fct_rate_given.sql`: Event for when a file is uploaded. The `value` is transformed into `rate_given`, the number of stars a user rated the content with.
- macros are .sql files that are templated in other .sql files. These can receive multiple parameters and template them. In this case, they are only being used in the `single_table/fct_event_done.sql`, acting as a separator of the logic from the main .sql file. In this specific PoC, the transformations are very simple and could be done on the `single_table/fct_event_done.sql` file.

## Running the project
Running the project requires the setup of a `profiles.yml` file in `~/.dbt/profiles.yml`. Then, the following commands can be used:
- `dbt seed`
- `dbt run`

## Extra stuff
The models were done using incremental models, which means that they compare against the existing table before running to only process the new events