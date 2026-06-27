WITH source AS (
    SELECT _raw_data, _stg_file_name, _stg_load_time
    FROM ECOMMERCE_BRONZE_DB.OLIST.SELLERS_RAW
)

SELECT
    _raw_data:seller_id::TEXT               AS seller_id,
    _raw_data:seller_zip_code_prefix::TEXT  AS seller_zip_code_prefix,
    _raw_data:seller_city::TEXT             AS seller_city,
    _raw_data:seller_state::TEXT            AS seller_state,
    _stg_file_name,
    _stg_load_time
FROM source