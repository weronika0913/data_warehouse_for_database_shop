CREATE TRIGGER AIU_product_SCD_type2
ON sales.products
AFTER INSERT, UPDATE
AS
BEGIN
    -- Update previous versions of records in the dimension table
    UPDATE data_warehouse.dim_product
    SET 
        valid_to_date = GETDATE(),
        current_flag = 'N'
    FROM 
        data_warehouse.dim_product AS dp
    JOIN 
        inserted AS i ON dp.id_product = i.id_product;
    
    -- Insert new rows into the dimension table with the new data
    INSERT INTO data_warehouse.dim_product (
      id_product,
      name_product,
      Size,
      brand,
      category,
      vat,
      valid_from_date,
      valid_to_date,
      current_flag
    )
SELECT 
    id_payment_method,
    payment_method,
    GETDATE() AS valid_from_date,
    '9999-12-31' AS valid_to_date,
    'Y' AS current_flag
FROM 
    inserted AS p
LEFT JOIN 
    sales.brands AS b ON p.id_brand = b.id_brand
LEFT JOIN 
    sales.categories AS c ON p.id_category = c.id_category
LEFT JOIN
    sales.taxes AS t ON c.id_vat = t.id_vat;
END;
