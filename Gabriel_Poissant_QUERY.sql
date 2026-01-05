-- Shows the most popular makes of cars in the dataset
SELECT make, COUNT(make) AS make_count
FROM vw_ALL
GROUP BY make
ORDER BY make_count DESC;

-- This shows average selling price of each body type
SELECT body, AVG(sellingprice) AS average_selling_price
FROM vw_CARS
GROUP BY body
ORDER BY average_selling_price DESC;

-- Shows the average selling price, average condition and average mileage by seller. 
-- Good for choosing a seller to buy from.
SELECT seller, AVG(sellingprice) AS average_selling_price, AVG(car_condition) AS average_condition, AVG(odometer) AS average_odometer
FROM vw_ALL 
GROUP BY seller
ORDER BY average_selling_price;

-- This shows the most popular color of car per year - using the year of the car, not the sale. If there's a tie, all are listed.
SELECT c.year, c.color, COUNT(*) AS color_count
FROM vw_CARS AS c
GROUP BY c.year, c.color
HAVING color_count = (SELECT MAX(cnt) FROM 
    (SELECT COUNT(*) AS cnt 
    FROM vw_CARS c2 
    WHERE c2.year = c.year 
    GROUP BY c2.color) AS max);
    
-- This shows the most popular make per year - using the year of the car, not the sale. If there's a tie, all are listed.
SELECT c.year, c.make, COUNT(*) AS make_count
FROM vw_CARS AS c
GROUP BY c.year, c.make
HAVING make_count = (SELECT MAX(cnt) FROM 
    (SELECT COUNT(*) AS cnt 
    FROM vw_CARS c2 
    WHERE c2.year = c.year 
    GROUP BY c2.make) AS max);