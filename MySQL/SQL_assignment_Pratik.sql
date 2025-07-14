use classicmodels;
#Fetch the employee number, first name and last name of those employees who 
#are working as Sales Rep reporting to employee with employeenumber 1102 (Refer employee table)

select * from employees;
select employeeNumber, firstName, lastName from employees where jobTitle = 'Sales rep' and reportsTo = 1102;


#Show the unique productline values containing the word cars at the end from the products table.
select * from productlines;
select distinct productline from productlines where productline like '%cars';
 
#Using a CASE statement, segment customers into three categories based on their country:(Refer Customers table)
select * from customers;
select customerNumber,customerName,
case
when country in ( 'USA' , ' CANADA') THEN 'North America'
when country in ( 'UK' , 'FRANCE' , 'GERMANY' ) THEN 'Europe'
else 'Other' 
End as customer_segment
from customers;

#Using the OrderDetails table, identify the top 10 products (by productCode) with the highest total order quantity across all orders.
select * from orderdetails;
Select 
    productCode,
    SUM(quantityOrdered) as totalQuantity
from
    OrderDetails
group by
    productCode
order by 
    totalQuantity DESC
limit  10;

#Company wants to analyse payment frequency by month. 
#Extract the month name from the payment date to count the total number of payments for each month and 
#include only those months with a payment count exceeding 20. 
#Sort the results by total number of payments in descending order.  (Refer Payments table). 
select * from payments;
select Monthname (paymentDate) as Monthname ,
count(paymentdate) as total_payments from payments
group by 
Monthname
having 
total_payments > 20
order by 
total_payments DESC;

#Create a new database named and Customers_Orders and add the following tables as per the description
create database customers_orders;
use customers_orders;
create table customers ( customers_id  int auto_increment PRIMARY KEY , 
first_name varchar(50) not null ,
last_name varchar(50) not null ,
email varchar(225) unique,
phone_number varchar(20));


#Create a table named Orders to store information about customer orders. Include the following columns:
create table orders ( order_id int auto_increment primary key,
customer_id int ,
order_date date ,
total_amount decimal (10,2) ,
check (total_amount > 0) );


#List the top 5 countries (by order count) that Classic Models ships to. (Use the Customers and Orders tables
select * from customers;
select * from orders;

SELECT c.Country, COUNT(o.OrderNumber) AS OrderCount
FROM Customers c
JOIN Orders o ON c.CustomerNumber = o.CustomerNumber
GROUP BY c.Country
ORDER BY OrderCount DESC
LIMIT 5;


#Create a table project with below fields.
#EmployeeID : integer set as the PRIMARY KEY and AUTO_INCREMENT.
#FullName: varchar(50) with no null values
#Gender : Values should be only ‘Male’  or ‘Female’
#ManagerID: integer 
create table project (employeeID int auto_increment primary key,
fullName varchar(50) not null,
gender enum ( 'male' , 'female' ) not null,
ManagerID int );
insert into project ( employeeID, fullName, gender, ManagerID)
values ( '1' , 'Pranaya','Male', '3');
insert into project ( employeeID, fullName, gender, ManagerID)
values ( '2' , 'Priyanka','FeMale', '1');
insert into project ( employeeID, fullName, gender, ManagerID)
values ( '3' , 'Preety','FeMale','0');
insert into project ( employeeID, fullName, gender, ManagerID)
values ( '4' , 'Anurag','Male', '1');
insert into project ( employeeID, fullName, gender, ManagerID)
values ( '5' , 'Sambit','Male', '1');
insert into project ( employeeID, fullName, gender, ManagerID)
values ( '6' , 'Rajesh','Male', '3');
insert into project ( employeeID, fullName, gender, ManagerID)
values ( '7' , 'Heena','FeMale', '3');

#Find out the names of employees and their related managers.
select
    e.FullName AS EmployeeName,
    m.FullName AS ManagerName
from 
    project e
left join
    project m ON e.ManagerID = m.EmployeeID;
    
#Create table facility. Add the below fields into it.
#Facility_ID
#Name
#State
#Country
create table facility(
facilityID int primary key, Name varchar(100),State varchar(100), Country varchar(100));

#Alter the table by adding the primary key and auto increment to Facility_ID column.
alter table facility 
modify column facilityID int auto_increment;

#Add a new column city after name with data type as varchar which should not accept any null values.
alter table facility
add column city varchar(100) not null after Name;
select * from facility;


# Create a view named product_category_sales
#that provides insights into sales performance by product category.
# This view should include the following information:
select * from products;
select * from orderdetails;
select * from orders;
select * from productlines;
create view product_category_sales as
select 
    pl.productLine, 
    sum(od.quantityOrdered * od.priceEach) as total_sales,
    count(DISTINCT o.orderNumber) as number_of_orders
from 
    ProductLines pl
join 
    Products p ON pl.productLine = p.productLine
join 
    OrderDetails od ON p.productCode = od.productCode
join 
    Orders o ON od.orderNumber = o.orderNumber
group by 
    pl.productLine;
    
#Create a stored procedure Get_country_payments which takes in year and
#country as inputs and gives year wise, country wise total amount as an output. 
#Format the total amount to nearest thousand unit (K)
select * from customers;
select * from payments;
DELIMITER $$

CREATE PROCEDURE Get_country_payments (
    IN input_year INT,
    IN input_country VARCHAR(100)
)
BEGIN
    SELECT
        YEAR(p.paymentDate) AS year,
        c.country AS country,
        CONCAT(ROUND(SUM(p.amount) / 1000, 0), 'K') AS total_amount
    FROM
        Customers c
    JOIN
        Payments p ON c.customerNumber = p.customerNumber
    WHERE
        YEAR(p.paymentDate) = input_year
        AND c.country = input_country
    GROUP BY
        YEAR(p.paymentDate), c.country;
END $$

DELIMITER ;

#Using customers and orders tables, rank the customers based on their order frequency
SELECT 
    c.customerNumber,
    c.contactFirstName,
    c.contactLastName,
    COUNT(o.orderNumber) AS total_orders,
    RANK() OVER (ORDER BY COUNT(o.orderNumber) DESC) AS order_rank
FROM 
    Customers c
LEFT JOIN 
    Orders o ON c.customerNumber = o.customerNumber
GROUP BY 
    c.customerNumber
ORDER BY 
    order_rank;
  
#) Calculate year wise, month name wise count of orders and year over year (YoY) percentage change. 
#Format the YoY values in no decimals and show in % sign.
SELECT 
    YEAR(orderDate) AS order_year,
    MONTHNAME(orderDate) AS order_month,
    COUNT(orderNumber) AS order_count,
    CONCAT(
        ROUND(
            ((COUNT(orderNumber) - LAG(COUNT(orderNumber)) OVER (PARTITION BY MONTH(orderDate) ORDER BY YEAR(orderDate))) * 100.0) /
            NULLIF(LAG(COUNT(orderNumber)) OVER (PARTITION BY MONTH(orderDate) ORDER BY YEAR(orderDate)), 0), 
            0
        ),
	'%'
    ) AS yoy_percentage_change
FROM 
    Orders o
GROUP BY 
    YEAR(orderDate), MONTH(orderDate)
ORDER BY 
    order_year DESC, 
    FIELD(MONTHNAME(orderDate), 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December');
    

#Find out how many product lines are there for which the buy price value is greater than the average of buy price value. 
#Show the output as product line and its count.
WITH avg_buy_price AS (
    SELECT AVG(buyprice) AS avgprice
    FROM products
)
SELECT product_line, COUNT(products) AS products
FROM products, avg_buy_price
WHERE buy_price > avg_price
GROUP BY product_line;


#Create the table Emp_EH
CREATE TABLE Emp_EH (
    EmpID INT PRIMARY KEY,           
    EmpName VARCHAR(100),            
    EmailAddress VARCHAR(100)        
);
#Create a procedure to accept the values for the columns in Emp_EH. 
#Handle the error using exception handling concept. Show the message as “Error occurred” in case of anything wrong.
CREATE PROCEDURE Insert_Emp_EH (
    p_EmpID INT,
    p_EmpName VARCHAR(100),
    p_EmailAddress VARCHAR(100)
)
    INSERT INTO Emp_EH (EmpID, EmpName, EmailAddress)
    VALUES (p_EmpID, p_EmpName, p_EmailAddress);

    COMMIT;
    -- WHEN OTHERS THEN('Error occurred');
    ROLLBACK; 


#Create the table Emp_BIT. Add below fields in it.
--	Name
--	Occupation
#Working_date
CREATE TABLE Emp_BIT (
    Name VARCHAR(100),            
    Occupation VARCHAR(100),      
    Working_date DATE             
);
DROP TABLE Emp_BIT;
CREATE TABLE Emp_BIT (
    Name VARCHAR(100),          
    Occupation VARCHAR(100),    
    Working_date DATE,          
    Working_hours DECIMAL(5,2)  
);
DELIMITER //
CREATE TRIGGER before_insert_emp_bit
BEFORE INSERT ON Emp_BIT
FOR EACH ROW
BEGIN
IF NEW.Working_hours < 0 THEN
SET NEW.Working_hours = ABS(NEW.Working_hours);
END IF;
end//
DELIMITER ;
INSERT INTO Emp_BIT  VALUES
('Robin', 'Scientist', '2020-10-04', 12),  
('Warner', 'Engineer', '2020-10-04', 10),  
('Peter', 'Actor', '2020-10-04', 13),  
('Marco', 'Doctor', '2020-10-04', 14),  
('Brayden', 'Teacher', '2020-10-04', 12),  
('Antonio', 'Business', '2020-10-04', 11);
desc emp_bit;
select* from emp_bit;