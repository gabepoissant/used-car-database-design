-- Make lookup tables functional

-- YEAR
-- Populate lookup tables with each distinct value from BULK_CAR_SALES
INSERT INTO YEAR
(`Year`)
SELECT DISTINCT `year` FROM BULK_CAR_SALES ORDER BY year;

-- Add foreign key column in BULK_CAR_SALES
ALTER TABLE BULK_CAR_SALES
ADD Year_ID INT;

-- Create index to avoid long loading times
CREATE INDEX idx_BULK_CAR_SALES_year ON BULK_CAR_SALES (year);

-- Populate foreign key column in BULK_CAR_SALES with the corresponding foreign key value
UPDATE BULK_CAR_SALES b, `YEAR` y
SET b.Year_ID = y.Year_ID
WHERE b.year = y.Year;
-- The above structure is repeated for each lookup table

-- MAKE
INSERT INTO MAKE
(Make)
SELECT DISTINCT make FROM BULK_CAR_SALES;

ALTER TABLE BULK_CAR_SALES
ADD Make_ID INT;

CREATE INDEX idx_BULK_CAR_SALES_make ON BULK_CAR_SALES (make);

UPDATE BULK_CAR_SALES b, MAKE m
SET b.Make_ID = m.Make_ID
WHERE b.make = m.Make;

-- MODEL
INSERT INTO MODEL
(Model)
SELECT DISTINCT model FROM BULK_CAR_SALES;

ALTER TABLE BULK_CAR_SALES
ADD Model_ID INT;

CREATE INDEX idx_BULK_CAR_SALES_model ON BULK_CAR_SALES (model);

UPDATE BULK_CAR_SALES b, MODEL m
SET b.Model_ID = m.Model_ID
WHERE b.model = m.Model;

-- TRIM_TYPE
INSERT INTO TRIM_TYPE
(Trim_Type)
SELECT DISTINCT trim FROM BULK_CAR_SALES;

ALTER TABLE BULK_CAR_SALES
ADD Trim_Type_ID INT;

CREATE INDEX idx_BULK_CAR_SALES_trim ON BULK_CAR_SALES (trim);

UPDATE BULK_CAR_SALES b, TRIM_TYPE t
SET b.Trim_Type_ID = t.Trim_Type_ID
WHERE b.trim = t.Trim_Type;

-- BODY
INSERT INTO BODY
(Body)
SELECT DISTINCT body FROM BULK_CAR_SALES;

ALTER TABLE BULK_CAR_SALES
ADD Body_ID INT;

CREATE INDEX idx_BULK_CAR_SALES_body ON BULK_CAR_SALES (body);

UPDATE BULK_CAR_SALES b, BODY bo
SET b.Body_ID = bo.Body_ID
WHERE b.body = bo.Body;

-- TRANSMISSION
INSERT INTO TRANSMISSION
(Transmission)
SELECT DISTINCT transmission FROM BULK_CAR_SALES;

ALTER TABLE BULK_CAR_SALES
ADD Transmission_ID INT;

CREATE INDEX idx_BULK_CAR_SALES_transmission ON BULK_CAR_SALES (transmission);

UPDATE BULK_CAR_SALES b, TRANSMISSION t
SET b.Transmission_ID = t.Transmission_ID
WHERE b.transmission = t.Transmission;

-- STATE
INSERT INTO STATE
(State)
SELECT DISTINCT state FROM BULK_CAR_SALES ORDER BY state;

ALTER TABLE BULK_CAR_SALES
ADD State_ID INT;

CREATE INDEX idx_BULK_CAR_SALES_state ON BULK_CAR_SALES (state);

UPDATE BULK_CAR_SALES b, STATE s
SET b.State_ID = s.State_ID
WHERE b.state = s.State;

-- SELLER
INSERT INTO SELLER
(Seller)
SELECT DISTINCT seller FROM BULK_CAR_SALES;

ALTER TABLE BULK_CAR_SALES
ADD Seller_ID INT;

CREATE INDEX idx_BULK_CAR_SALES_seller ON BULK_CAR_SALES (seller);

UPDATE BULK_CAR_SALES b, SELLER s
SET b.Seller_ID = s.Seller_ID
WHERE b.seller = s.Seller;

-- COLOR
-- Color is a special case in which two columns will reference the same table
-- Thus we must combine all distinct values from `color` and `interior` to create our table
INSERT INTO COLOR
(Color)
SELECT DISTINCT color FROM BULK_CAR_SALES
UNION 
SELECT DISTINCT interior FROM BULK_CAR_SALES;

ALTER TABLE BULK_CAR_SALES
ADD Color_ID INT;

ALTER TABLE BULK_CAR_SALES
ADD Interior_Color_ID INT; 

CREATE INDEX idx_BULK_CAR_SALES_color ON BULK_CAR_SALES (color);
CREATE INDEX idx_BULK_CAR_SALES_interior ON BULK_CAR_SALES (interior);

UPDATE BULK_CAR_SALES b, COLOR c
SET b.Color_ID = c.Color_ID
WHERE b.color = c.Color;

UPDATE BULK_CAR_SALES b, COLOR c
SET b.Interior_Color_ID = c.Color_ID
WHERE b.interior = c.Color;

-- Populate core entity with appropriate values from BULK_CAR_SALES 
-- CAR_SALE
INSERT INTO CAR_SALE
(VIN,Year_ID,Make_ID,Model_ID,Trim_Type_ID,Body_ID,Transmission_ID,Color_ID,
Interior_Color_ID,Car_Condition,Odometer,MMR,Selling_Price,State_ID,Seller_ID,Sale_Date)
SELECT vin,Year_ID,Make_ID,Model_ID,Trim_Type_ID,Body_ID,Transmission_ID,Color_ID,
Interior_Color_ID,`condition`,Odometer,mmr,sellingprice,State_ID,Seller_ID,saledate
FROM BULK_CAR_SALES;

-- Create view to unite all data similar to original data structure
-- vw_ALL
CREATE VIEW vw_ALL
as 
SELECT 
y.Year as `year`,
m.Make as make,
mo.Model as model,
t.Trim_Type as trim,
b.Body as body,
tr.Transmission as transmission,
cs.VIN as vin,
s.State as state,
cs.Car_Condition as `condition`,
cs.Odometer as odometer,
c.Color as color,
ic.Color as interior,
se.Seller as seller,
cs.MMR as mmr,
cs.Selling_Price as sellingprice,
cs.Sale_Date as saledate
FROM CAR_SALE cs
INNER JOIN `YEAR` y ON cs.Year_ID = y.Year_ID 
INNER JOIN MAKE m on cs.Make_ID = m.Make_ID
INNER JOIN MODEL mo ON cs.Model_ID = mo.Model_ID
INNER JOIN TRIM_TYPE t ON cs.Trim_Type_ID = t.Trim_Type_ID
INNER JOIN BODY b on cs.Body_ID = b.Body_ID
INNER JOIN TRANSMISSION tr ON cs.Transmission_ID = tr.Transmission_ID
INNER JOIN STATE s ON cs.State_ID = s.State_ID
INNER JOIN COLOR c ON cs.Color_ID = c.Color_ID
INNER JOIN COLOR ic ON cs.Interior_Color_ID = ic.Color_ID
INNER JOIN SELLER se ON cs.Seller_ID = se.Seller_ID;

-- Additional view giving only details on the cars sold, without details about their sale
-- vw_CARS
CREATE VIEW vw_CARS
as 
SELECT 
y.Year as `year`,
m.Make as make,
mo.Model as model,
t.Trim_Type as trim,
b.Body as body,
tr.Transmission as transmission,
cs.VIN as vin,
cs.Car_Condition as `condition`,
cs.Odometer as odometer,
c.Color as color,
ic.Color as interior,
cs.MMR as mmr,
cs.Selling_Price as sellingprice
FROM CAR_SALE cs
INNER JOIN `YEAR` y ON cs.Year_ID = y.Year_ID 
INNER JOIN MAKE m on cs.Make_ID = m.Make_ID
INNER JOIN MODEL mo ON cs.Model_ID = mo.Model_ID
INNER JOIN TRIM_TYPE t ON cs.Trim_Type_ID = t.Trim_Type_ID
INNER JOIN BODY b on cs.Body_ID = b.Body_ID
INNER JOIN TRANSMISSION tr ON cs.Transmission_ID = tr.Transmission_ID
INNER JOIN COLOR c ON cs.Color_ID = c.Color_ID
INNER JOIN COLOR ic ON cs.Interior_Color_ID = ic.Color_ID;

-- Additional view describing only location, date and seller of each sale
-- vw_SELLER
CREATE VIEW vw_SELLER
as 
SELECT 
s.State as state,
se.Seller as seller,
cs.Sale_Date as saledate
FROM CAR_SALE cs
INNER JOIN STATE s ON cs.State_ID = s.State_ID
INNER JOIN SELLER se ON cs.Seller_ID = se.Seller_ID;