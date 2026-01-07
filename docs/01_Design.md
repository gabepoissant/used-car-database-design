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
