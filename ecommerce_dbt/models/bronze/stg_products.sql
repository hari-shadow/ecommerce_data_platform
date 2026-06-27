WITH source AS (
    SELECT _raw_data, _stg_file_name, _stg_load_time
    FROM ECOMMERCE_BRONZE_DB.OLIST.PRODUCTS_RAW
)

SELECT
    _raw_data:product_id::TEXT                      AS product_id,
    _raw_data:product_category_name::TEXT           AS product_category_name,
    _raw_data:product_name_lenght::INTEGER          AS product_name_length,
    _raw_data:product_description_lenght::INTEGER   AS product_description_length,
    _raw_data:product_photos_qty::INTEGER           AS product_photos_qty,
    _raw_data:product_weight_g::NUMERIC(10,2)       AS product_weight_g,
    _raw_data:product_length_cm::NUMERIC(10,2)      AS product_length_cm,
    _raw_data:product_height_cm::NUMERIC(10,2)      AS product_height_cm,
    _raw_data:product_width_cm::NUMERIC(10,2)       AS product_width_cm,
    _stg_file_name,
    _stg_load_time
FROM source