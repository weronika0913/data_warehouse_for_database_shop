CREATE TRIGGER AIU_users_SCD_type2
ON sales.users
AFTER INSERT, UPDATE
AS
BEGIN
    -- Update previous versions of records in the dimension table
    UPDATE data_warehouse.dim_user
    SET 
        valid_to_date = GETDATE(),
        current_flag = 'N'
    FROM 
        data_warehouse.dim_user AS du
    JOIN 
        inserted AS i ON du.id_user = i.id_user;
    
    -- Insert new rows into the dimension table with the new data
    INSERT INTO data_warehouse.dim_user (
        id_user,
        Name,
        Surname,
        Number_user_card,
        City,
        Street,
        Number_house,
        Number_local,
        Postal_code,
        valid_from_date,
        valid_to_date,
        current_flag
    )
    SELECT 
        u.id_user,
        u.Name,
        u.Surname,
        uc.Number_user_card,
        a.City,
        a.Street,
        a.Number_house,
        a.Number_local,
        a.Postal_code,
        GETDATE() AS Uploaded_date,
        '9999-12-31' AS valid_to_date,
        'Y' AS current_flag
    FROM 
        inserted AS u
    LEFT JOIN 
        sales.adresses AS a ON u.id_address = a.id_address
    LEFT JOIN 
        sales.user_card AS uc ON u.id_user = uc.id_user;
END;
