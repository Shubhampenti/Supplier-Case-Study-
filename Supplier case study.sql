use master
go

/***************************************************************************
Name	:  CODE FOR SUPPLIER DATA BASE 
Author  :  Shubham Penti
Date	:  sept 19,2023

purpose : This script will create db and few table in it to store info about
SupplierDB
***************************************************************************/
create database Supplier 
go

use Supplier
go

create table SUPPLIERMASTER 
( 
    SID		int				Primary Key,
	NAME	Varchar(40)		NOT NULL ,
	CITY	Char(6)			NOT NULL,
	GRADE	Tinyint			NOT NULL
)
go

-- get the schema of the table
sp_help SUPPLIERMASTER 
go

Select * from SUPPLIERMASTER 
go


-- insert data
insert into SUPPLIERMASTER  values (11, 'Nagesh Kassa',		'Delhi', 1)
insert into SUPPLIERMASTER  values (22, 'Nagesh Kalburgi',  'Mumbai', 2)
insert into SUPPLIERMASTER  values (34, 'Revan Mali',		'Nagpur', 3)
insert into SUPPLIERMASTER  values (43, 'Akshay Shilwant',	'Dule', 4)
insert into SUPPLIERMASTER  values (52, 'Anish Shah',		'Delhi', 5)
insert into SUPPLIERMASTER  values (61, 'Aditya Gayakwad',	'Pune', 6)
go


--Part Master

create table PARTMASTER 
(	
	PID		TinyInt			Primary Key,
	NAME	Varchar(40)		NULL,
	PRICE	Money			NOT NULL,
	CATEGORY Tinyint		NOT NULL,
	QTYONHAND Integer		NULL
)
go

select * from PARTMASTER 
go

insert into PARTMASTER  values (1, 'john', 398, 2, 1)
insert into PARTMASTER  values (2, 'rohan', 3548, 3, 15)
insert into PARTMASTER  values (011, 'sohamn', 898, 26, 8)
insert into PARTMASTER  values (5, 'anynahn', 78, 7, 188)
insert into PARTMASTER values (6, 'sima', 348, 26, 16)
insert into PARTMASTER  values (7, 'tima', 358, 4, 14)
go

create table SUPPLYDETAILS  
(
	PID		TinyInt		     Not NULL	Foreign Key references PARTMASTER(PID),
	SID		Integer			 Not NULL   Foreign Key references SupplierMaster(SID),
	DATEOFSUPPLY DateTime	 NOT NULL,
	CITY		Varchar(40)	 NOT NULL,
	QTYSUPPLIED Integer		 NOT NULL
)
go

select * from SUPPLYDETAILS 
go

insert into SUPPLYDETAILS values ( 2, 1, '2021/03/01','pune',2)
insert into SUPPLYDETAILS values ( 3, 1, '2921/04/01','pune',4)
insert into SUPPLYDETAILS values ( 4, 2, '2025/03/01','NAGPUR',5)
insert into SUPPLYDETAILS values ( 5, 3, '2024/33/01','MUMBAI',2)
GO

--1. List the month- wise average supply of parts supplied for all parts.
--   provide the  information only if the average is higher than 20. 


		SELECT 
			MONTH(DOS) as Month ,
			YEAR(DOS)as Year,
			AVG(QTYSUPP) as AverageSupply
		FROM 
			SUPPLYDETAILS
		GROUP BY 
			YEAR(DOS),
			MONTH(DOS)
		HAVING 
			AVG(QTYSUPP) > 20


--2. List the names of the Suppliers who do not supply part with PID ‘1 ’ .

		SELECT DISTINCT S.NAME
		FROM SUPPLIERMASTER as S
		LEFT JOIN SUPPLYDETAILS As SD On S.SID = SD.SID  AND SD.PID = '1'
		WHERE SD.SID IS NULL


--3. List the part id , name , price and difference between price and average price of all parts.

		SELECT 	PID,NAME,PRICE,
			Price - (SELECT AVG(PRICE) FROM PARTMASTER) AS PriceDifference
		FROM 
		PARTMASTER


--4. List the names of the suppliers who have supplied at least one part where the quantity supplied is lower than 10.

			SELECT DISTINCT S.NAME
			FROM SUPPLIERMASTER AS S
			JOIN SUPPLYDETAILS AS PS ON S.SID = PS.SID
			WHERE PS.QTYSUPP < 10


--5. List the names of the suppliers who live in a city where no suply has been made.

			SELECT DISTINCT S.NAME
			FROM SUPPLIERMASTER AS S
			WHERE S.CITY NOT IN (
			SELECT DISTINCT SD.CITY
			FROM SUPPLYDETAILS AS SD
			JOIN SUPPLIERMASTER AS S ON  SD.SID = S.SID
			)


--6. List the Names of the parts which have not been supplied in the month of May 2007.

			SELECT NAME
			FROM PARTMASTER
			WHERE PID NOT IN (
			SELECT PID
			FROM SUPPLYDETAILS
			WHERE MONTH (DOS) = 5	AND YEAR (DOS) = 2007
			)


--7. List name and Price category for all parts. Price category has to be displayed as “Cheap” if price is less than 100,
--"Medium" if the price is grater than or equal to 100 and less than 500,and "Costly"if the price  is grater than or 
--equal to 500.

				SELECT NAME,
				CASE
				WHEN PRICE < 100 THEN 'CHEAP'
				WHEN PRICE >= 100 AND PRICE < 500 THEN 'MEDIUM'
				END AS  PRICECATEGORY
				FROM PARTMASTER



--8. List the most recent supply details with information on Product name, price and 
--no.of days elapsed since the latest supply.


			SELECT P.NAME AS ProductName , P.PRICE ,
			DATEDIFF(DAY , PS.DOS , GETDATE()) AS DaysElapsedSinceLatestSupply
			FROM SUPPLYDETAILS AS PS
			JOIN PARTMASTER AS P ON PS.PID = P.PID
			WHERE PS.DOS =(
			SELECT MAX (DOS)
			FROM SUPPLYDETAILS )



--9. List the names of the suppliers who have supplied exactly 100 units of part P1.

			SELECT DISTINCT S.NAME
			FROM SUPPLIERMASTER AS S
			JOIN SUPPLYDETAILS AS SD ON S.SID = SD.SID
			JOIN PARTMASTER AS P ON SD.PID = P.PID 
			WHERE P.PID = '1'
			AND SD.QTYSUPP = 100


--10. List the names of the parts supplied by more than one supplier.
	
			SELECT P.NAME AS PartName
			FROM PARTMASTER AS P
			JOIN SUPPLYDETAILS AS SM ON P.PID = SM.PID 
			GROUP BY P.PID ,P.NAME 
			HAVING COUNT (DISTINCT SM.SID) > 1


--11. List the names of the parts whose price is less than the average price of parts. 

			SELECT NAME 
			FROM PARTMASTER 
			WHERE PRICE < (SELECT AVG (PRICE) FROM PARTMASTER)


--12 List the Category - wise number of parts ; exclude those where the sum is > 100
--and less than 500. List in the decending order of sum .

			SELECT CATEGORY ,COUNT (*) AS NumOfParts
			FROM PARTMASTER 
			GROUP BY CATEGORY
			HAVING SUM (PRICE) > 100 AND SUM (PRICE) < 500 
			ORDER BY SUM (PRICE) DESC 

-- 13. List the supplier name , part name and supplied quantity for all supplies made
--between 1st ad 15th of june 2007 .

			SELECT SM.NAME ,P.NAME AS PartName , SD.QTYSUPP
			FROM SUPPLIERMASTER AS SM
			JOIN SUPPLYDETAILS AS SD ON SM.SID = SD.SID 
			JOIN PARTMASTER AS P ON SD.PID = P.PID
			WHERE SD.DOS >= '2007-06-01' AND SD.DOS <= '2007-06-15'



--14. For all products supplied by supplier S1,list the part name and total quantity. 

			SELECT P.NAME AS PartName ,SUM(SD.QTYSUPP) AS TotalQTY
			FROM SUPPLIERMASTER AS SM
			JOIN SUPPLYDETAILS SD ON  SM.SID = SD.SID 
			JOIN PARTMASTER AS P ON SD .PID = P.PID 
			WHERE SM.NAME = 'SRUJANA SUPPLIERS'
			GROUP BY P.NAME 


--15. For the part with the minimum price ,List the latest supply details (Supplier Name,
--part id,Date of supply , Quantity Supplied).

			SELECT SM.NAME,SD.PID,SD.DOS,SD.QTYSUPP
			FROM SUPPLIERMASTER AS SM
			JOIN SUPPLYDETAILS SD ON SM.SID = SD.SID 
			JOIN(
				SELECT TOP 1 PID 
				FROM PARTMASTER
				WHERE PRICE =(SELECT MIN (PRICE) FROM PARTMASTER)
				ORDER BY PID )
				AS MinPricePart ON SD.PID = MinPricePart.PID
				ORDER BY SD.DOS DESC
