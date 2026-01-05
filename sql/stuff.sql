SET GLOBAL local_infile = 1;

DROP TABLE BULK_CAR_SALES;

CREATE TABLE BULK_CAR_SALES (
    year INT NOT NULL,
    make VARCHAR(50),
    model VARCHAR(100),
    trim VARCHAR(100),
    body VARCHAR(50),
    transmission VARCHAR(20),
    vin CHAR(17),
    state CHAR(2),
    `condition` SMALLINT,
    odometer INT,
    color VARCHAR(30),
    interior VARCHAR(30),
    seller VARCHAR(255),
    mmr INT,
    sellingprice INT,
    saledate VARCHAR(100)
) ENGINE=InnoDB;


SET autocommit=0;
SET unique_checks=0;
SET foreign_key_checks=0;

SET GLOBAL local_infile = 1;


LOAD DATA LOCAL INFILE 'C:\Users\gabri\Documents\PittSCI\Courses\CMPINF_2110\Conceptual Design Project\car_prices_cleaned.csv'
INTO TABLE BULK_CAR_SALES
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
