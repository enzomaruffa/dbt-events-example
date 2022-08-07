{{ config(
  materialized = 'incremental',
  unique_key = 'eid',
) }}

WITH source_data AS (
  SELECT
    eid,
    uid,
    event_name,
    CAST(value AS NUMERIC) AS rate_given,
    event_timestamp
  FROM
    {{ ref('events_data') }} AS events_data
  WHERE
    event_name = "Rate Given"
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
    *
  FROM
    source_data
)

SELECT * FROM final
