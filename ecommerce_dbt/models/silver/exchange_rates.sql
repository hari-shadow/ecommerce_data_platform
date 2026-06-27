{{ config(
    materialized='incremental',
    unique_key='rate_date',
    on_schema_change='sync_all_columns',
    database='ECOMMERCE_SILVER_DB',
    schema='FINANCE'
) }}

WITH source AS (
    SELECT * FROM {{ ref('stg_exchange_rates') }}
    {% if is_incremental() %}
        WHERE _stg_load_time > (SELECT COALESCE(MAX(t._silver_loaded_at), '1900-01-01'::TIMESTAMP) FROM {{ this }} t)
    {% endif %}
),

deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY rate_date ORDER BY _stg_load_time DESC) AS rn
    FROM source
),

final AS (
    SELECT
        rate_date,
        base_currency,
        target_currency,
        rate,
        CURRENT_TIMESTAMP() AS _silver_loaded_at
    FROM deduped
    WHERE rn = 1
)

SELECT * FROM final