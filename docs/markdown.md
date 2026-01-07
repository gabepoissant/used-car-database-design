
SECTION 1: 
Explain Conceptual Diagram
  == Talk about Cardinalities ==
Explain Logical Diagram
  color joining tables
Explain Data Loading
  Talk about cleaning logic
Explain DDL (Data Definition Language)
  color joining tables
Explain Physical Diagram

Explain DML (Data Manipulation Language)
Show Example Queries



## Conceptual Diagram

I decided to begin the database design process by creating a conceptual diagram using [draw.io](draw.io) to map out the entities I needed to create. I understood that the purpose of creating entities outside of a primary entity is to reduce redundancy in the data, as well as making a robust system using normalization. So, I identified all columns in the dataset that contained repetitive information, mapped them out as their own entities, and replaced their column names in the primary entity with foreign key ID columns. 

<img src="/diagrams/01_Conceptual_Diagram.png" alt="Conceptual-Model" />

Though not strictly necessary at this stage, I also decided to include cardinality as part of the logic for this diagram. 

Each entity relates to the primary entity `car_sale` with a optional-many to manditory-one cardinality structure. 

---

## Logical Diagram

Next, I refined my structure, creating a new diagram with [draw.io](draw.io). This logical diagram is very similar in structure to the previous with the following exceptions:

- Each entity has been assigned its primary key
- Each foreign key in `CAR_SALE` is established and assigned to its corresponding entity
- Formatting norms have been established (capitalization)
- Cardinality has been redefined as manditory-many to manditory-one
- Each entity is given a `Created_Date` and `Modified_Date` column to keep track of edits to each row
- `color` and `interior` have been combined, as they share many values

<img src="/diagrams/02_Logical_Diagram.png" alt="Logical-Model" />

---

## Data Loading and Cleaning

Now that I had considered the critical details of the database, it was time to being creating the database.

To do this, I used MySQL Workbench. 

First, I created a table which would receive the bulk data, defining the datatypes for each column.

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
Though there are no NULLs in the dataset, there are many empty strings and some fields only containing `—` across the various columns. Handling missing data is outside of the scope of this project, so I elected to delete ALL rows that had ANY column with a non-valid value. 

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

Having established my entity structure and loaded my data, I was able to then define the entities in my database, using `CREATE TABLE`. For example:

```
CREATE TABLE MODEL
(Model_ID INT AUTO_INCREMENT,
Model VARCHAR(50),
Created_Date DATETIME DEFAULT NOW(),
Modified_Date DATETIME DEFAULT NOW(),
CONSTRAINT PK_MODEL PRIMARY KEY (Model_ID));
```

This query establishes a surrogate key called Model_ID as the primary key of the table, as well as the data types for Model, and the `Created_Date` and `Modified_Date` fields. 

Here is the primary entity creation statement: 

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

Using the reverse-engineer method within MySQL Workbench, I was able to produce a physical diagram based off of my DDL document:
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

Because `COLOR` was serving both the Color_ID and Interior_ID columns, it's insert statement looked slightly different:
```
INSERT INTO COLOR
(Color)
SELECT DISTINCT color FROM BULK_CAR_SALES
UNION 
SELECT DISTINCT interior FROM BULK_CAR_SALES;
```
But otherwise the same steps were followed. 

Next, I populated the CAR_SALE entity with appropriate values from BULK_CAR_SALES 
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
<img src="/img/Query_Output_3.png" alt="Query_Output" />





