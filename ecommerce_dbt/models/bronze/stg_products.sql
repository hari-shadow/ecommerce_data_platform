WITH source AS (
    SELECT _raw_data, _stg_file_name, _stg_load_time
    FROM ECOMMERCE_BRONZE_DB.OLIST.PRODUCTS_RAW
)

SELECT
    _raw_data:product_id::TEXT                      AS product_id,
    _raw_data:product_category_name::TEXT           AS product_category_name,
    TRY_TO_NUMBER(_raw_data:product_name_lenght::TEXT)        AS product_name_length,
    TRY_TO_NUMBER(_raw_data:product_description_lenght::TEXT) AS product_description_length,
    TRY_TO_NUMBER(_raw_data:product_photos_qty::TEXT)         AS product_photos_qty,
    TRY_TO_NUMBER(_raw_data:product_weight_g::TEXT, 10, 2)    AS product_weight_g,
    TRY_TO_NUMBER(_raw_data:product_length_cm::TEXT, 10, 2)   AS product_length_cm,
    TRY_TO_NUMBER(_raw_data:product_height_cm::TEXT, 10, 2)   AS product_height_cm,
    TRY_TO_NUMBER(_raw_data:product_width_cm::TEXT, 10, 2)    AS product_width_cm,
    _stg_file_name,
    _stg_load_time
FROM source