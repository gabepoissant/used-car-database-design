## Analysis

---

Shows the most popular makes of cars in the dataset.
```
SELECT make, COUNT(make) AS make_count
FROM vw_ALL
GROUP BY make
ORDER BY make_count DESC;
```

<img src="/img/Query_Output_1.png" width="200" alt="Query_Output" />

---

Shows the average selling price, average condition and average mileage by seller. Good for choosing a seller to buy from.
```
SELECT seller, AVG(sellingprice) AS average_selling_price,
	AVG(car_condition) AS average_condition, AVG(odometer) AS average_odometer
FROM vw_ALL 
GROUP BY seller
ORDER BY average_selling_price;
```

<img src="/img/Query_Output_2.png" width="650" alt="Query_Output" />

---

This table is a short guide to high-volume sellers who regularly price below Manheim Market Report value, sorted by the greatest savings.
```
SELECT
   seller,
   COUNT(*) AS cars_sold,
   ROUND(AVG(mmr - sellingprice),2) AS avg_discount_vs_mmr,
   ROUND(AVG(car_condition),2) AS average_condition,
   ROUND(AVG(odometer),2) AS average_odometer
FROM vw_ALL
GROUP BY seller
HAVING COUNT(*) > 100
ORDER BY avg_discount_vs_mmr DESC
LIMIT 10;
```

<img src="/img/Query_Output_3.png" alt="Query_Output" />

---

Shows the most popular car color by model year.
```
SELECT c.model_year, c.color, c.color_count
FROM (
    SELECT model_year, color, COUNT(*) AS color_count
    FROM vw_CARS
    GROUP BY model_year, color) c
JOIN (
    SELECT model_year, MAX(color_count) AS max_count
    FROM (
        SELECT model_year, color, COUNT(*) AS color_count
        FROM vw_CARS
        GROUP BY model_year, color) x
    GROUP BY model_year) m
ON c.model_year = m.model_year
AND c.color_count = m.max_count
ORDER BY c.model_year;
```

<img src="/img/Query_Output_4.png" width="300" alt="Query_Output" />

---

Shows the percentage of makes in the dataset vs. in the subset that were sold with odometer > 250,000.
```
SELECT
    m.make,
	ROUND(m.total_count * 100.0 / t.total_rows, 2) AS overall_percentage,
    ROUND(m.high_mileage_count * 100.0 / h.high_mileage_rows, 2) AS high_mileage_percentage,
    ROUND((m.high_mileage_count * 100.0 / h.high_mileage_rows) - (m.total_count * 100.0 / t.total_rows),2) AS percentage_difference
FROM (SELECT
        make,
        COUNT(*) AS total_count,
        SUM(CASE WHEN odometer > 250000 THEN 1 ELSE 0 END) AS high_mileage_count
    FROM vw_ALL
    GROUP BY make) m
CROSS JOIN (SELECT COUNT(*) AS total_rows
    FROM vw_ALL) t
CROSS JOIN (SELECT COUNT(*) AS high_mileage_rows
    FROM vw_ALL
    WHERE odometer > 250000) h
WHERE m.high_mileage_count > 0
ORDER BY percentage_difference DESC, m.high_mileage_count DESC;
```

<img src="/img/Query_Output_5.png" width="450" alt="Query_Output" />
