## Conceptual Diagram

I decided to begin the database design process by creating a conceptual diagram using [draw.io](draw.io) to map out the entities I needed to create. I understood that the purpose of creating entities outside of a primary entity is to reduce redundancy in the data, as well as making a robust system using normalization. 

So, I identified all columns in the dataset that contained repetitive information and mapped them out as their own entities.

<img src="/diagrams/01_Conceptual_Diagram.png" alt="Conceptual-Model" />

Though not strictly necessary at this stage, I also decided to include cardinality as part of the logic for this diagram. 

Each entity relates to the primary entity `car_sale` with an optional-many to mandatory-one cardinality structure. 

---

## Logical Diagram

Next, I refined my structure, creating a new diagram with [draw.io](draw.io). This logical diagram is very similar in structure to the previous with the following exceptions:

- Each entity has been assigned its primary key
- Each foreign key in `CAR_SALE` is established and assigned to its corresponding entity
- Formatting norms have been established (capitalization)
- Cardinality has been redefined as mandatory-many to mandatory-one
- Each entity is given a `Created_Date` and `Modified_Date` column to keep track of edits to each row
- `color` and `interior` have been combined, as they share many values

<img src="/diagrams/02_Logical_Diagram.png" alt="Logical-Model" />

---

## Data Loading and Cleaning

Now that I had considered the critical details of the database, it was time to begin creating the database.

I used a staging-to-warehouse pattern for this application. 

First, I created a staging table which would receive the bulk data, defining the datatypes for each column.

```
CREATE TABLE BULK_CAR_SALES (
    year INT NOT NULL,
    make VARCHAR(50),
    model VARCHAR(100),
    trim VARCHAR(100),
    body VARCHAR(50),
    transmission VARCHAR(20),
    vin CHAR(17),
    state CHAR(2),
    `condition` INT,
    odometer INT,
    color VARCHAR(30),
    interior VARCHAR(30),
    seller VARCHAR(255),
    mmr INT,
    sellingprice INT,
    saledate VARCHAR(100)
);
```

Using `LOAD DATA LOCAL INFILE`, I was able to load in the data from a `.csv` file on my machine.

#### Data Cleaning
Though there are no NULLs in the dataset, there are many empty strings and some fields only containing `—` across the various columns. 

Handling missing data is outside of the scope of this project, so I elected to delete ALL rows that had ANY column with an invalid value. In production, I would attempt to keep as many as possible using missing data strategies like imputation.

Using `DELETE`, I deleted all rows with any empty strings or `—` values. 

This brought the row count from 558,837 rows to 440,393 rows (118,444 removed).

I also needed to reformat the `saledate` column, as it was not recognizable as a TIMESTAMP.
```
-- BEFORE: 'Tue Dec 16 2014 12:30:00 GMT-0800 (PST)'
UPDATE BULK_CAR_SALES
SET saledate = CONVERT_TZ(STR_TO_DATE(SUBSTRING_INDEX(saledate, ' GMT', 1), '%a %b %d %Y %H:%i:%s'), '-08:00', '+00:00');
-- AFTER: '2014-12-16 20:30:00'
```
With this, I also changed the datatype of `saledate` from VARCHAR to TIMESTAMP 

---

## Data Definition (DDL)

Having established my entity structure and loaded my data, I was able to define the entities in my database, using `CREATE TABLE`. For example:

```
CREATE TABLE MODEL
(Model_ID INT AUTO_INCREMENT,
Model VARCHAR(50),
Created_Date DATETIME DEFAULT NOW(),
Modified_Date DATETIME DEFAULT NOW(),
CONSTRAINT PK_MODEL PRIMARY KEY (Model_ID));
```

This query establishes a surrogate key called Model_ID as the primary key of the table, as well as the data types for Model, and the `Created_Date` and `Modified_Date` fields. 

Here is the fact table creation statement: 

```
CREATE TABLE CAR_SALE
(Sale_ID INT AUTO_INCREMENT,
VIN VARCHAR(50) NOT NULL,
Car_Condition VARCHAR(50),
Odometer INT,
MMR INT,
Selling_Price INT,
Sale_Date TIMESTAMP,
Year_ID INT,
Make_ID INT, 
Model_ID INT, 
Trim_Type_ID INT,
Body_ID INT,
Transmission_ID INT,
State_ID INT,
Color_ID INT, 
Interior_Color_ID INT,
Seller_ID INT NOT NULL,
Created_Date DATETIME DEFAULT NOW(),
Modified_Date DATETIME DEFAULT NOW(),
CONSTRAINT PK_SALE PRIMARY KEY (Sale_ID));
```

To finish this stage, I needed to establish primary keys of all entities as foreign keys for CAR_SALE, which looked like this for each entity:

```
ALTER TABLE CAR_SALE
ADD CONSTRAINT FK_CAR_SALE_Model_ID FOREIGN KEY (Model_ID)
REFERENCES MODEL(Model_ID);
```

The only deviation from my logical model at this stage is renaming TRIM to TRIM_TYPE to avoid conflicts with the SQL command `trim`.

---

## Physical Diagram

Using the reverse-engineer method within MySQL Workbench, I was able to produce a physical diagram based on my DDL document:
<img src="/diagrams/03_Physical_Diagram.png" alt="Physical-Model" />

I am happy to see the physical diagram matching my logical diagram. 

---

## Data Manipulation (DML)

Now that each lookup table and their constraints were successfully created, I needed to do the following for each entity:
1. Populate lookup tables with each distinct value from BULK_CAR_SALES
```
INSERT INTO YEAR
(`Year`)
SELECT DISTINCT `year` FROM BULK_CAR_SALES ORDER BY year;
```
2. Add foreign key column in BULK_CAR_SALES
```
ALTER TABLE BULK_CAR_SALES
ADD Year_ID INT;
```
3. Create index to avoid long loading times
```
CREATE INDEX idx_BULK_CAR_SALES_year ON BULK_CAR_SALES (year);
```
4. Populate foreign key column in BULK_CAR_SALES with the corresponding foreign key value
```
UPDATE BULK_CAR_SALES b, `YEAR` y
SET b.Year_ID = y.Year_ID
WHERE b.year = y.Year;
```

Because `COLOR` was serving both the Color_ID and Interior_ID columns, its insert statement looked slightly different:
```
INSERT INTO COLOR
(Color)
SELECT DISTINCT color FROM BULK_CAR_SALES
UNION 
SELECT DISTINCT interior FROM BULK_CAR_SALES;
```
But otherwise the same steps were followed. 

Next, I populated the CAR_SALE entity with appropriate values from BULK_CAR_SALES: 
```
INSERT INTO CAR_SALE
(VIN,Year_ID,Make_ID,Model_ID,Trim_Type_ID,Body_ID,Transmission_ID,Color_ID,
Interior_Color_ID,Car_Condition,Odometer,MMR,Selling_Price,State_ID,Seller_ID,Sale_Date)
SELECT vin,Year_ID,Make_ID,Model_ID,Trim_Type_ID,Body_ID,Transmission_ID,Color_ID,
Interior_Color_ID,`condition`,Odometer,mmr,sellingprice,State_ID,Seller_ID,saledate
FROM BULK_CAR_SALES;
```
Finally, I had completed the database design. Querying `CAR_SALE` gives an output like this:

<img src="/img/Query_Output_2.png" alt="Query_Output" />

Querying `MAKE` gives an output like this:

<img src="/img/Query_Output_3.png" width="400" alt="Query_Output" />

Lastly, I created a view for convenience.
```
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
```

Querying it returns something like this:

<img src="/img/Query_Output_4.png" alt="Query_Output" />

I also created vw_CARS and vw_SELLER.

---

## Example Queries

Shows the most popular makes of cars in the dataset:
```
SELECT make, COUNT(make) AS make_count
FROM vw_ALL
GROUP BY make
ORDER BY make_count DESC;
```
<img src="/img/Query_Output_5.png" width="200" alt="Query_Output" />

This table is a short guide to high-volume sellers who regularly price below Manheim Market Report value, sorted by the greatest savings
```
SELECT
   seller,
   COUNT(*) AS cars_sold,
   ROUND(AVG(mmr - sellingprice),2) AS avg_discount_vs_mmr,
   ROUND(AVG(car_condition),2) AS average_condition,
   ROUND(AVG(odometer),2) AS average_odometer
FROM vw_CARS
GROUP BY seller
HAVING COUNT(*) > 100
ORDER BY avg_discount_vs_mmr DESC
LIMIT 10;
```
<img src="/img/Query_Output.png" alt="Query_Output" />

This shows the most popular color of car per year - using the year of the car, not the sale. If there's a tie, all are listed.
```
SELECT c.year, c.color, COUNT(*) AS color_count
FROM vw_CARS AS c
GROUP BY c.year, c.color
HAVING color_count = (SELECT MAX(cnt) FROM 
    (SELECT COUNT(*) AS cnt 
    FROM vw_CARS c2 
    WHERE c2.year = c.year 
    GROUP BY c2.color) AS max);
```
<img src="/img/Query_Output_6.png" width="200" alt="Query_Output" />

This shows the most popular make per year - using the year of the car, not the sale. If there's a tie, all are listed.
```
SELECT c.year, c.make, COUNT(*) AS make_count
FROM vw_CARS AS c
GROUP BY c.year, c.make
HAVING make_count = (SELECT MAX(cnt) FROM 
    (SELECT COUNT(*) AS cnt 
    FROM vw_CARS c2 
    WHERE c2.year = c.year 
    GROUP BY c2.make) AS max);
```
<img src="/img/Query_Output_7.png" width="200" alt="Query_Output" />
