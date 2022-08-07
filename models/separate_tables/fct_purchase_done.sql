{{ config(
  materialized = 'incremental',
  unique_key = 'eid',
) }}

WITH source_data AS (
  SELECT
    eid,
    uid,
    event_name,
    CAST(value AS NUMERIC) AS revenue,
    event_timestamp
  FROM
    {{ ref('events_data') }} AS events_data
  WHERE
    event_name = "Purchase Done"
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
    REGEXP_EXTRACT(CAST(revenue AS STRING), r'\.[0-9]*') AS revenue_decimals
  FROM
    source_data
)

SELECT * FROM final
