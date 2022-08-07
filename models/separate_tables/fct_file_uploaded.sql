{{ config(
  materialized = 'incremental',
  unique_key = 'eid',
) }}

WITH source_data AS (
  SELECT
    eid,
    uid,
    event_name,
    value AS file_name,
    event_timestamp
  FROM
    {{ ref('events_data') }} AS events_data
  WHERE
    event_name = "File Uploaded"
  {% if is_incremental() %}
    AND
      event_timestamp > COALESCE(
        (
          SELECT MAX(event_timestamp)
          FROM
            {{ this }}
        ),
        0
      )
  {% endif %}
),

final AS (
  SELECT
    FARM_FINGERPRINT(CONCAT(eid, uid)) AS surrogate_key,
    *,
    REGEXP_EXTRACT(file_name, r'\.[a-zA-Z]*') AS file_extension
  FROM
    source_data
)

SELECT * FROM final
