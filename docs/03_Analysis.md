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
