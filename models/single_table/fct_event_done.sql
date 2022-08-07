{{ config(
  materialized = 'incremental',
  unique_key = 'eid',
) }}

WITH source_data AS (
  SELECT
    eid,
    uid,
    event_name,
    value,
    event_timestamp
  FROM
    {{ ref('events_data') }} AS events_data
  {% if is_incremental() %}
    WHERE
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
    CASE
        WHEN event_name = 'Purchase Done' THEN {{ purchase_done_value_detail() }}
        WHEN event_name = 'File Uploaded' THEN {{ file_uploaded() }}
        ELSE ""
    END AS value_detail
  FROM
    source_data
)

SELECT * FROM final
