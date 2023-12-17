
--                                         CASE STUDY 3

select * from continent
select * from customers
select * from transactions


--1. Display the count of customers in each region who have done the transaction in the year 2020.

select count(*) as no_of_customers, region_name from transactions as t
inner join customers as c
on t.customer_id=c.customer_id
inner join continent as co
on c.region_id=co.region_id
where year(t.txn_date)='2020'
group by region_name

--2. Display the maximum and minimum transaction amount of each transaction type.

select txn_type, max(txn_amount) as max_amount, min(txn_amount) as min_amount from transactions
group by txn_type

--3. Display the customer id, region name and transaction amount where transaction type is deposit and transaction amount > 2000.

select t.customer_id, region_name, txn_amount from transactions as t
inner join customers as c
on t.customer_id=c.customer_id
inner join continent as co
on c.region_id=co.region_id
where txn_type='deposit' and txn_amount>2000

--4. Find duplicate records in the Customer table.

select customer_id,region_id,start_date, end_date from customers
group by customer_id,region_id,start_date, end_date
having count(*)>1

--5. Display the customer id, region name, transaction type and transaction amount for the minimum transaction amount in deposit.

select 
      t.customer_id, 
	  region_name, 
	  txn_type as transaction_type, 
	  txn_amount as transaction_amount 
	  from transactions as t
inner join customers as c 
on t.customer_id = c.customer_id
inner join continent as co 
on c.region_id=co.region_id 
where txn_amount in (select min(txn_amount) from transactions where txn_type ='deposit')
group by 
       t.customer_id,
	   region_name, 
	   txn_type ,
	   txn_amount

--6. Create a stored procedure to display details of customers in the transaction table where the transaction date is greater than Jun 2020.

create procedure customer_details
as
select * from transactions
where month(txn_date)>6 and year(txn_date)>2020
go

exec customer_details

--7. Create a stored procedure to insert a record in the Continent table.

create procedure continentT
@r_region_id int,
@r_region_name varchar(30)
as
begin
 insert into continent(region_id, region_name)
 values(@r_region_id, @r_region_name)
end

exec continentT @r_region_id=6, @r_region_name='N.America'

--8. Create a stored procedure to display the details of transactions that happened on a specific day.

create procedure transactionsonday
@t_txn_date date
as
begin
select * from transactions
where convert(date, txn_date)=@t_txn_date
end

exec transactionsonday @t_txn_date='2020-01-21'

--9. Create a user defined function to add 10% of the transaction amount in a table.

CREATE FUNCTION Add10PercentToAmount (@amount FLOAT)
RETURNS FLOAT
AS
BEGIN
    DECLARE @newAmount FLOAT;
    SET @newAmount = @amount * 1.10; 
    RETURN @newAmount;
END;
GO

--10. Create a user defined function to find the total transaction amount for a given transaction type.

CREATE FUNCTION total_transaction_amount(@amount FLOAT)
RETURNS FLOAT
AS
BEGIN
    DECLARE @newAmount FLOAT;
    SET @newAmount = @amount * 1.10; 
    RETURN @newAmount;
END;
GO
select * from transactions

--11. Create a table value function which comprises the columns customer_id,
--region_id ,txn_date , txn_type , txn_amount which will retrieve data from the above table.CREATE FUNCTION TYPE_1()RETURNS TABLE AS RETURN(SELECT c.customer_id, c.region_id, t.txn_date, t.txn_type, t.txn_amount from transactions as tinner join customers as c on t.customer_id=c.customer_id)select * from TYPE_1()--12. Create a TRY...CATCH block to print a region id and region name in a single column.
begin try
  select concat(region_id,region_name) as new_column from continent
end try
begin catch
  select ERROR_MESSAGE()
end catch

--13. Create a TRY...CATCH block to insert a value in the Continent table.

begin try
  
  insert into continent values(7, 'S.America')
end try
begin catch
  select ERROR_MESSAGE()
end catch

select *from continent
--14. Create a trigger to prevent deleting a table in a database.create trigger tr1on continent instead of delete as begin     print('deleting table not allowed')	 rollback transaction;end--15. Create a trigger to audit the data in a table.create table auditvalue(region_id int, region_name varchar(30))create trigger tr4on continent for insertas begin       declare @region_id int	   select @region_id=region_id from inserted	   insert into auditvalue(region_id)	   values('new region_id = ' + cast(@region_id as varchar(30)) + ' is added  at ' + cast(getdate() as varchar(70)))  end

INSERT INTO continent (region_id, region_name) VALUES (9, 'Saloni');

--16. Create a trigger to prevent login of the same user id in multiple pages. 

CREATE TRIGGER 
 PREVENT_MULTIPLE_LOGINS ON ALL SERVER FOR 
 LOGON 
 AS
 BEGIN 
 DECLARE @SESSION_COUNT INT 
 SELECT @SESSION_COUNT = COUNT(*)FROM SYS.DM_EXEC_SESSIONS 
 WHERE is_user_process = 1 AND LOGIN_NAME = ORIGINAL_LOGIN()IF @SESSION_COUNT > 1 BEGIN PRINT 'MULTIPLE LOGINS NOT ALLOW'
   ROLLBACK
   END
 END;
 DISABLE TRIGGER PREVENT_MULTIPLE_LOGINS ON ALL SERVER;

--17. Display top n customers on the basis of transaction type.

with cte as 
( select *, row_number() over (partition by txn_type order by txn_amount desc) as t from transactions
)
 select customer_id, txn_type from cte
 where t<=n--18. Create a pivot table to display the total purchase, withdrawal and deposit for all the customers.select * from (select customer_id, txn_type, txn_amount from transactions) as resultspivot (sum([txn_amount])for [txn_type]IN([purchase], [deposit], [withdrawal])) as resultset order by customer_id