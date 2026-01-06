#### Goal:  
To take a raw dataset and bring it through all design phases into a working, queryable database.

---

#### Data:
I found a dataset about used car sales in the U.S. between 2014 and 2015. The data gives information about the vehicle, and where and when it was sold.

| Column | Description | Example Value |
|-----------|----------|---------|
| year      | Model year of the vehicle sold | 2014 |
| make       | Manufacturer of the vehicle      | Kia      |
| model       | Model of the vehicle      | Rio     |
| trim       | Identifies included features      | LX     |
| body       | Type of vehicle      | Sedan     |
| transmission       | Transmission style of vehicle      | automatic     |
| vin       | Vehicle Identification Number      | knadm4a35e6327128     |
| state       | U.S. State car was sold in      | tx     |
| condition       | Rating of vehicle condition      | 39     |
| odometer       | Odometer reading at time of sale      | 27187     |
| color       | Exterior paint color      | silver     |
| interior       | Interior finish color      | black     |
| seller       | The entity that sold the vehicle      | tdaf remarketing     |
| mmr       | Manheim Market Report, an estimated market value      | 10650     |
| sellingprice       | Price vehicle sold for      | 10200     |
| saledate       | Date of sale      | Wed Feb 11 2015 02:15:00 GMT-0800 (PST)     |

This dataset was authored by [Syed Anwar](https://www.kaggle.com/syedanwarafridi) and [published to Kaggle](https://www.kaggle.com/datasets/syedanwarafridi/vehicle-sales-data/data).

---

#### Approach:
I used the standard layered approach, consisting of:
- **Conceptual Design** (High Level ER Diagram)
- **Logical Design** (Define tables, columns and keys)
- **Physical Model** (DDL)
- **Deployment** (Loading and transforming data)


Conceptual diagram describing preliminary structure and cardinality:
![Conceptual-Model](/diagrams/01_Conceptual_Diagram.png)

Physical model diagram created using reverse-engineer method:
![Physical_Diagram](/diagrams/03_Physical_Diagram.png)

SQL excerpt defining tables, primary keys and foreign keys:
```
CREATE TABLE MAKE
(Make_ID INT AUTO_INCREMENT,
Make VARCHAR(50),
Created_Date DATETIME DEFAULT NOW(),
Modified_Date DATETIME DEFAULT NOW(),
CONSTRAINT PK_MAKE PRIMARY KEY (Make_ID));

ALTER TABLE CAR_SALE
ADD CONSTRAINT FK_CAR_SALE_Make_ID FOREIGN KEY (Make_ID)
REFERENCES MAKE(Make_ID);
```

---

#### Results:

After data input and configuration, I'm able to define queries:
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

Output:
![Query_Output](/img/Query_Output.png)


This table is a short guide to high-volume sellers who regularly price below Manheim Market Report value, sorted by greatest savings.  

---

**What I’d do next:**  
- Dive deeper into integrity
- Improve efficiency with indexes
- Anticipate team usage (roles, backups, deployment)

---
