WITH source AS (
    SELECT
        _raw_data,
        _stg_file_name,
        _stg_load_time
    FROM ECOMMERCE_BRONZE_DB.OLIST.CUSTOMERS_RAW
)

SELECT
    _raw_data:customer_id::TEXT          AS customer_id,
    _raw_data:customer_unique_id::TEXT   AS customer_unique_id,
    _raw_data:customer_zip_code_prefix::TEXT AS customer_zip_code_prefix,
    _raw_data:customer_city::TEXT        AS customer_city,
    _raw_data:customer_state::TEXT       AS customer_state,
    _raw_data:created_at::TIMESTAMPTZ    AS created_at,
    _stg_file_name,
    _stg_load_time
FROM source