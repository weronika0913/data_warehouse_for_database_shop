CREATE TRIGGER AIU_payment_method_SCD_type2
ON sales.payment_methods
AFTER INSERT, UPDATE
AS
BEGIN
    -- Update previous versions of records in the dimension table
    UPDATE data_warehouse.dim_payment_method
    SET 
        valid_to_date = GETDATE(),
        current_flag = 'N'
    FROM 
        data_warehouse.dim_payment_method AS pm
    JOIN 
        inserted AS i ON pm.id_payment_method = i.id_payment_method;
    
    -- Insert new rows into the dimension table with the new data
    INSERT INTO data_warehouse.dim_payment_method (
      id_payment_method,
      payment_method,
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
    inserted;
END;
