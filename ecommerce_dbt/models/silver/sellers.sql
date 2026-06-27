{{
    config(
        materialized='incremental',
        unique_key='seller_id',
        on_schema_change='sync_all_columns'
    )
}}

WITH source AS (
    SELECT * FROM {{ ref('stg_sellers') }}

    {% if is_incremental() %}
        WHERE _stg_load_time > (SELECT MAX(t._silver_loaded_at) FROM {{ this }} t)
    {% endif %}
),

deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY seller_id
            ORDER BY _stg_load_time DESC
        ) AS rn
    FROM source
    WHERE seller_id IS NOT NULL
),

final AS (
    SELECT
        seller_id,
        seller_zip_code_prefix,
        INITCAP(seller_city) AS seller_city,
        seller_state,
        CURRENT_TIMESTAMP() AS _silver_loaded_at
    FROM deduped
    WHERE rn = 1
)

SELECT * FROM final