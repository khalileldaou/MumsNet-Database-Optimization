# MumsNet-Database-Optimization
Implemented improvements and transaction processing on the database  using Microsoft SQL Server speeding up the process by 25% and introduced a new business intelligence platform to  benefit the business using SSAS.

The database is normalized to 3NF. The new database’s design is an OLTP (Online Transactional Processing), so that the tables will be normalized to remove redundancies and enhance data consistency for better use and more efficient memory. This will help in data processing in real time.

The original MumsNet database is placed in the new 3NF database. The new database called “MUMSNETDB” will have the three old databases at first (CustomerCity, OrderItem, and Product) to store the old data, but then will be removed after migration. 

Below is a figure of the new database “MUMSNETDB” (figure 1): 

![MUMSNET OLTP](https://user-images.githubusercontent.com/55437013/217838293-368fdebb-869a-45b2-b44b-d112cd2254ee.png)

Moreover, in the database script, triggers were added to update the database every time a new record is inserted, modified, or deleted in “OrderItem” table. Two new columns were added to the table which are “TotalLineItems” and “SavedTotal,” where “TotalLineItems” will show the total number of items added and “SavedTotal” will show the total order value. The triggers will update the two new columns whenever a new order is added to the database. 

In addition, two stored procedures were added to create “OrderGroup” and “OrderItem” and contain error handling and transactional support to ensure data consistency in the database. Furthermore, some indices were added in “OrderItem,” “OrderGroup,” and “ProductVariant” to improve query and processing performance. 

Before creating the data source, data source view, cube and dimensions, a set of dimension tables and fact tables were created following the star schema. Using the normalized OLTP database “MUMSNETDB,” an OLAP database was created to develop business intelligence. 

The below figure shows the OLAP database (star schema) for “MUMSNETDB” (figure 2):

![image](https://user-images.githubusercontent.com/55437013/217838850-74dce816-394c-46f1-8aca-8d4c37086433.png)


