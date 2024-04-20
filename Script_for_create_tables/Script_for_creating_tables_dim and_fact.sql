-- creating new schema
CREATE SCHEMA data_warehouse

-- creating dimension user table
CREATE TABLE data_warehouse.dim_user (
    id_user INT,
    Name VARCHAR(30),
    Surname VARCHAR(50),
    Number_user_card INT,
    City VARCHAR(50),
    Street VARCHAR(50),
    Number_house VARCHAR(7),
    Number_local VARCHAR(7),
    Postal_code VARCHAR(6),
    valid_from_date DATE,
    valid_to_date DATE,
    current_flag CHAR(1)
);

-- creating dimension product table
CREATE TABLE data_warehouse.dim_product (
      id_product INT,
      name_product VARCHAR(30),
      Size VARCHAR(30),
      brand VARCHAR(30),
      category VARCHAR(30),
      vat numeric(4,2),
      valid_from_date DATE,
      valid_to_date DATE,
      current_flag CHAR(1)
);

-- creating dimension payment method
CREATE TABLE data_warehouse.dim_payment_method (
      id_payment_method INT,
      payment_method VARCHAR(50),
      valid_from_date DATE,
      valid_to_date DATE,
      current_flag CHAR(1)
);

-- creating fact sales tables using INTO statement
SELECT 
    oss.id_order,
    od.id_product,
    oss.number_customer_card, 
    oss.Date,
    od.Quantity,
    p.Price,
    oss.id_payment_method
INTO
    data_warehouse.fact_sales
FROM
    sales.orders_stationary_shops AS oss
LEFT JOIN
    sales.orders_details AS od ON oss.id_order = od.id_order
LEFT JOIN 
    sales.products AS p ON p.id_product = od.id_product;


-- inserting rows to dim_user
INSERT INTO data_warehouse.dim_user (id_user, Name, Surname, Number_user_card, City, Street, Number_house, Number_local, Postal_code, valid_from_date, valid_to_date, current_flag)
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
    GETDATE() AS valid_from_date,
    '9999-12-31' AS valid_to_date,
    'Y' AS current_flag
FROM 
    sales.users AS u
LEFT  JOIN sales.adresses As a ON u.id_address = a.id_address
LEFT JOIN sales.user_card AS uc ON u.id_user = uc.id_user;

-- inserting rows to dim_payment_method
INSERT INTO data_warehouse.dim_payment_method (id_payment_method, payment_method, valid_from_date, valid_to_date, current_flag)
SELECT
    id_payment_method,
    payment_method,
    GETDATE() AS valid_from_date,
    '9999-12-31' AS valid_to_date,
    'Y' AS current_flag
FROM
    sales.payment_methods;

-- inserting rows to dim_product
INSERT INTO data_warehouse.dim_product (id_product, name_product, Size, brand, category, vat, valid_from_date, valid_to_date, current_flag)
SELECT 
    p.id_product,
    p.name_product,
    p.Size,
    b.brand,
    c.category,
    t.vat,
    GETDATE() AS valid_from_date,
    '9999-12-31' AS valid_to_date,
    'Y' AS current_flag
FROM 
    sales.products AS p
LEFT JOIN 
    sales.brands AS b ON p.id_brand = b.id_brand
LEFT JOIN 
    sales.categories AS c ON p.id_category = c.id_category
LEFT JOIN
    sales.taxes AS t ON c.id_vat = t.id_vat;
