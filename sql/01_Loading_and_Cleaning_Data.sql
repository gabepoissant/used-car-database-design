-- Create empty table to receive data
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

-- Enable local file loading
SET GLOBAL local_infile = 1;

-- Load csv data
LOAD DATA LOCAL INFILE 'C:/Users/car_prices.csv'
INTO TABLE BULK_CAR_SALES
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS; -- Ignore column header row

-- Clean Data
-- Number of rows before cleaning
SELECT count(*) FROM BULK_CAR_SALES; -- 558,837 rows

-- Delete all rows containing any empty string
DELETE FROM BULK_CAR_SALES 
WHERE year = '' 
OR make = ''
OR model = ''
OR trim = ''
OR body = ''
OR transmission = ''
OR vin = ''
OR state = ''
OR `condition` = ''
OR odometer = ''
OR color = ''
OR interior = ''
OR seller = ''
OR mmr = ''
OR sellingprice = ''
OR saledate = '';

-- Delete rows with any cell that only contains '—'
DELETE FROM BULK_CAR_SALES 
WHERE color = '—'
OR interior = '—';

-- Number of rows after cleaning
SELECT count(*) FROM BULK_CAR_SALES; -- 440393 rows