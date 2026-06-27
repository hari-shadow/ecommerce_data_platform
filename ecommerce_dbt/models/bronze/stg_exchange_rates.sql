WITH source AS (
    SELECT
        rate_date,
        base_currency,
        target_currency,
        rate,
        _loaded_at AS _stg_load_time
    FROM ECOMMERCE_BRONZE_DB.FRANKFURTER.EXCHANGE_RATES_RAW
)

SELECT * FROM source