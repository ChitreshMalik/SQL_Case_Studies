create database coffee;
use coffee;
 desc coffee_chain_sales;
 -- Changing Date column to Datetime format
drop table if exists cfe;
create table cfe as (
select *,str_to_date(Date,"%m/%d/%Y") as New_Date from coffee_chain_sales);
select *from cfe;
-- sales-()
-- drop the existing date column in text format
alter table cfe drop column date;

-- drop duplicates in date
delete from cfe 
where new_date="2012-10-01" and `Inventory Margin`=405;


-- have same length as the dataset used for visulaization
select count(*) from cfe;

 
 -- KPI's
 select sum(profit) as Total_Profit,sum(Sales) as Total_Sales,
 sum(Total_expenses) as Total_Expenses,sum(Marketing) As Marketing_Expenses,sum(Margin) as Total_Margin
 from cfe;


-- Prorfit insights

 
-- Top N product by Profit and there profit contributions where n can be dynamic using stored procedure
drop procedure if exists TOP_N_Product;
delimiter //
create procedure TOP_N_Product(in N int)
begin
select product,sum(profit) as Total_profit ,round(((sum(profit)/64285) *100),2) as `Contribution_%` from cfe
group by product
order by Total_profit desc
limit N
;
end //
delimiter ;
call TOP_N_Product(6);

-- percentage of contribution of product in total profit
select product ,((sum(profit)/64285) *100) as `Contribution_%`
from cfe
group by product
order by `Contribution_%` desc;


-- case when if tpr >pr then 0 else 1 end as pr_bigger_thn_tpr 
-- count of which target profit is met 
select yr,mon,pr,tpr,
case when pr <tpr then 0 else 1 end as pr_bigger_thn_tpr from 
(select year(new_date)as yr, MONTH(new_date) as mon, sum(profit) as pr,sum(target_profit) as tpr
from cfe
group by yr,mon) t;

drop procedure if exists Target_met;
delimiter //
create procedure target_met(in yr1 int )
begin
select yr, mon,pr_bigger_thn_tpr from (select yr,mon,pr,tpr,
case when pr <tpr then 0 else 1 end as pr_bigger_thn_tpr from 
(select year(new_date)as yr, MONTH(new_date) as mon, sum(profit) as pr,sum(target_profit) as tpr
from cfe
group by yr,mon) t) dt
where dt.yr=yr1 and pr_bigger_thn_tpr=1
;
end //
delimiter ;
call Target_met(2013);

-- MOM% change in profit
-- round((pr-prev_pr)/pr,2)
select yr, mon ,pr,prev_pr,(((pr-prev_pr)/pr)*100)as `MOM_%_in_pr`
from
(select yr, mon ,pr,
lag(pr,1,0) over (order by yr,mon) as prev_pr
 from (select year(new_date)as yr, MONTH(new_date) as mon, sum(profit) as pr,sum(target_profit) as tpr
from cfe
group by yr,mon) t) dt
order by yr,mon;
;


--  MOM %change in target profit
select yr, mon ,tpr,prev_tpr,(((tpr-prev_tpr)/tpr)*100)as `MOM_%_in_tpr`
from
(select yr, mon ,tpr,
lag(tpr,1,0) over (order by yr,mon) as prev_tpr
 from (select year(new_date)as yr, MONTH(new_date) as mon, sum(profit) as pr,sum(target_profit) as tpr
from cfe
group by yr,mon) t) dt
order by yr,mon;
;



-- state wise profit contributuion and their total prorfit

drop procedure if exists TOP_N_state;
delimiter //
create procedure TOP_N_State(in N int)
begin
select state,sum(profit) as Total_profit ,round(((sum(profit)/64285) *100),2) as `Contribution_%` from cfe
group by state
order by Total_profit desc
limit N
;
end //
delimiter ;
call TOP_N_state(6);


--  market wise profit contributuion and their total prorfit
drop procedure if exists market_contri;
delimiter //
create procedure market_contri(in N int)
begin
select market,sum(profit) as Total_profit ,round(((sum(profit)/64285) *100),2) as `Contribution_%` from cfe
group by market
order by Total_profit desc
limit N
;
end //
delimiter ;
call market_contri(6);



-- SALES insights

-- market wise sales contribution


drop procedure if exists market_sales;
delimiter //
create procedure market_sales(in N int)
begin
select market,sum(sales) as Total_sales ,round(((sum(sales)/202772) *100),2) as `Contribution_%` from cfe
group by market
order by Total_sales desc
limit N
;
end //
delimiter ;
call market_sales(4);


-- product wise sales contribution
delimiter //
create procedure product_sales(in N int)
begin
select product,sum(sales) as Total_sales ,round(((sum(sales)/202772) *100),2) as `Contribution_%` from cfe
group by product
order by Total_sales desc
limit N
;
end //
delimiter ;
call product_sales(6);



-- state wise sales contribution and total sales
drop procedure if exists state_sales;
delimiter //
create procedure state_sales(in N int)
begin
select state,sum(sales) as Total_sales ,round(((sum(sales)/202772) *100),2) as `Contribution_%` from cfe
group by state
order by Total_sales desc
limit N
;
end //
delimiter ;
call state_sales(4);



-- target sales is met or not

drop procedure if exists Target_met_sales;
delimiter //
create procedure Target_met_sales(in yr1 int )
begin
select yr, mon,sal_bigger_thn_tsal from (select yr,mon,sal,tsal,
case when sal <tsal then 0 else 1 end as sal_bigger_thn_tsal from 
(select year(new_date)as yr, MONTH(new_date) as mon, sum(sales) as sal,sum(target_sales) as tsal
from cfe
group by yr,mon) t) dt
where dt.yr=yr1 and sal_bigger_thn_tsal=1
;
end //
delimiter ;
call Target_met_sales(2015);

select year(new_date) as yr, sum(target_sales),sum(sales) from cfe
group by yr;



-- mom % change in sales 
select yr, mon ,sal,prev_sal,(((sal-prev_sal)/sal)*100)as `MOM_%_in_sal`
from
(select yr, mon ,sal,
lag(sal,1,0) over (order by yr,mon) as prev_sal
 from (select year(new_date)as yr, MONTH(new_date) as mon, sum(sales) as sal
from cfe
group by yr,mon) t) dt
order by yr,mon;
;




--  Marketing


-- state wise marketing 

drop procedure if exists Marketing_sales;
delimiter //
create procedure Marketing_sales(in N int)
begin
select state,sum(Marketing) as Total_Marketing ,round(((sum(marketing)/32303) *100),2) as `Contribution_%` from cfe
group by state
order by Total_Marketing desc
limit N
;
end //
delimiter ;
call Marketing_sales(4);




-- product wise total marketing expenses and their contributions

drop procedure if exists product_Marketing_sales;
delimiter //
create procedure product_Marketing_sales(in N int)
begin
select product,sum(Marketing) as Total_Marketing ,round(((sum(marketing)/32303) *100),2) as `Contribution_%` from cfe
group by product
order by Total_Marketing desc
limit N
;
end //
delimiter ;
call product_Marketing_sales(4);



-- MArket wise MArketing expenses and their contribution 

drop procedure if exists Market_Marketing_sales;
delimiter //
create procedure Market_Marketing_sales(in N int)
begin
select market,sum(Marketing) as Total_Marketing_expenses ,round(((sum(marketing)/32303) *100),2) as `Contribution_%` from cfe
group by market
order by Total_Marketing_expenses desc
limit N
;
end //
delimiter ;
call Market_Marketing_sales(4);


-- Expenses
-- trend of expenses over date
SELECT new_Date, SUM(Total_expenses) AS Total_Expenses
FROM cfe
GROUP BY new_Date
ORDER BY new_Date;

-- Market wise expenses
drop procedure if exists Market_Expenses;
delimiter //
create procedure Market_Expenses(in N int)
begin
select market,sum(Total_expenses) as Total_MArket_Expenses ,round(((sum(Total_expenses)/57129) *100),2) as `Contribution_%` from cfe
group by market
order by Total_MArket_Expenses desc
limit N
;
end //
delimiter ;
call Market_Expenses(4);


-- product wise expenses

drop procedure if exists Product_Expenses;
delimiter //
create procedure Product_Expenses(in N int)
begin
select product,sum(Total_expenses) as Total_Expenses ,round(((sum(Total_expenses)/57129) *100),2) as `Contribution_%` from cfe
group by product
order by Total_Expenses desc
limit N
;
end //
delimiter ;
call Product_Expenses(4);


-- state wise expenses

drop procedure if exists State_Expenses;
delimiter //
create procedure State_Expenses(in N int)
begin
select state,sum(Total_expenses) as Total_Expenses ,round(((sum(Total_expenses)/57129) *100),2) as `Contribution_%` from cfe
group by state
order by Total_Expenses desc
limit N
;
end //
delimiter ;
call State_Expenses(4);

-- 


-- margin by product type and its contributions

select sum(margin) from cfe;
drop procedure if exists product_margin;
delimiter //
create procedure product_margin(in N int)
begin
select product,sum(margin) as Total_Margin ,round(((sum(margin)/108703) *100),2) as `Contribution_%` from cfe
group by product
order by Total_Margin desc
limit N
;
end //
delimiter ;
call product_margin(4);




-- MArgin w.r.t product_type 

drop procedure if exists product_type__margin;
delimiter //
create procedure product_type__margin(in N int)
begin
select product_type,sum(margin) as Total_Margin ,round(((sum(margin)/108703) *100),2) as `Contribution_%` from cfe
group by product_type
order by Total_Margin desc
limit N
;
end //
delimiter ;

call product_type__margin(4);