use campusx

select * from sharktank1
truncate sharktank1

desc sharktank1

-- in file statement
LOAD DATA INFILE "E:/a/sharktank1.csv"
INTO TABLE sharktank1
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;



select * from sharktank1
-- 478 rows fetched afte using infile

-- Shark Tank India.
-- 1.	You Team must promote shark Tank India season 4, 
-- The senior come up with the idea to show highest funding domain wise so that new startups can be attracted,
-- and you were assigned the task to show the same.


-- more efficient than the window func
select industry,max(total_deal_amount_in_lakhs) as "Highest_funding" 
from sharktank1
group by industry
order by Highest_funding desc
 
-- using row_number to find out top highest funding domain wise
 
select * from
(
select   industry ,total_deal_amount_in_lakhs,row_number() over(partition by industry order by  total_deal_amount_in_lakhs desc) as rnk from sharktank1
)t where rnk=1





-- 2.	You have been assigned the role of finding the domain 
-- where female as pitchers have female to male pitcher ratio >70%
select * from sharktank1



-- Find out the given industry where female ratio is more than 70 percent

select * ,round(((female/male)*100),2) as "ratio"
from(
select industry,sum(Male_Presenters) as "male",sum(Female_Presenters) as "Female"
from sharktank1
group by industry
having male>0 and female>0 )t
where (female/male)*100 >70




-- 3.	You are working at marketing firm of Shark Tank India,
 -- you have got the task to determine volume of per season sale pitch made,
 -- pitches who received offer and pitches that were converted.
 -- Also show the percentage of pitches converted and percentage of pitches entertained.
 
 
 select * from sharktank1
 
select a.season_number, Total_pitches, Received,round(((Received/Total_pitches)*100),2) as "Entertained %",Accepted,
round(((Accepted/Total_pitches)*100),2) as "Converted %"
from( 

(select season_number,count(Pitch_number) as "Total_pitches"
from sharktank1 
group by season_number)a
inner join 
(select season_number,count(Received_Offer) as "Received"
from sharktank1
where Received_Offer="Yes"
group by season_number)b
on a.season_number=b.season_number -- here joined first 2 tables 
inner join
(select season_number,count(Accepted_Offer) as "Accepted"
from sharktank1
where Accepted_Offer="Yes"
group by season_number)c
on b.season_number=c.season_number)  -- here joined the third table to the joined tables
 
 
 
 
 
-- 4.	As a venture capital firm specializing in investing in startups featured on a renowned entrepreneurship TV show,
-- you are determining the season with the highest average monthly sales and identify the top 5 industries with
-- the highest average monthly sales during that season to optimize investment decisions?
select * from sharktank1


set @season=(
select season_number from(
select season_number,avg(Monthly_Sales_in_lakhs) as av
from sharktank1
group by season_number
order by av Desc
limit 1)t)

select @season

select industry,round(avg(Monthly_Sales_in_lakhs),2) as "Average"
from sharktank1
where season_number=@season
group by industry
order by Average desc
limit 5





-- 5.	As a data scientist at our firm, your role involves solving real-world challenges like identifying industries with consistent increases in funds raised over multiple seasons.
-- This requires focusing on industries where data is available across all three seasons. Once these industries are pinpointed,
-- your task is to delve into the specifics, analyzing the number of pitches made, offers received, and offers converted per season within each industry.


select * from sharktank1

select Industry,Season_Number,sum(Total_Deal_Amount_in_lakhs) as "sum"
from sharktank1
group by Industry,Season_Number
order by industry


-- here checked getting the same output after groupping and pivoting which we were getting in the above statement



with desired_industry as(
select industry,
max(case when season_number=1 then (Total_Deal_Amount_in_lakhs)  end) as season1,
max(case when season_number=2 then (Total_Deal_Amount_in_lakhs)  end) as season2,
max(case when season_number=3 then (Total_Deal_Amount_in_lakhs)  end) as season3
from sharktank1
group by industry-- Season1!=0 in below statement is used because at that season there were no such industries who pitched
having season2>season1 and season3>season2 and season1!=0) -- from this query we get the desired industry which have funding increases consistently
select a.industry,b.season_number,count(Pitch_number) as "Total_pitches",-- now we have got the industry we inner joined it to sharktank to get other columns which required
count(case when received_offer="Yes" then Received_Offer end) as "Offer_Received",-- use count outside the case when otherwise it will be treated as a non-aggregated column and it will throw error
count(case when accepted_offer="Yes" then Accepted_Offer end) as "Offer_Accepted"
 from desired_industry as a
inner join sharktank1 as b
on a.industry=b.industry
group by a.industry,b.season_number



-- 6.	Every shark wants to know in how much year their investment will be returned, so you must create a system for them,
-- where shark will enter the name of the startup’s and the based on the total deal and equity given in how many years their 
-- principal amount will be returned and make their investment decisions.

-- 
select * from sharktank1

delimiter //
create procedure TOT( in startup varchar(100))
begin
   case 
      when (select Accepted_offer ='No' from sharktank1 where startup_name = startup)
	        then  select "Cannot calculate because the given startup doesn't accepted the offer";
	 when (select Accepted_offer ='Yes' and Yearly_Revenue_in_lakhs = 'Not Mentioned' from sharktank1 where startup_name= startup)
           then select 'Previous data is not available';
	 else
         select `startup_name`,`Yearly_Revenue_in_lakhs`,`Total_Deal_Amount_in_lakhs`,`Total_Deal_Equity_%`, 
         `Total_Deal_Amount_in_lakhs`/((`Total_Deal_Equity_%`/100)*`Total_Deal_Amount_in_lakhs`) as 'years'
		 from sharktank1 where Startup_Name= startup;
	
    end case;
end
//
DELIMITER ;


call tot('BluePineFoods')








-- 7.	In the world of startup investing, we're curious to know which big-name investor, often referred to as "sharks," 
-- tends to put the most money into each deal on average. This comparison helps us see who's the most generous with their 
-- investments and how they measure up against their fellow investors.

select * from sharktank1

select sharkname, round(avg(investment),2)  as 'average' from
(
SELECT `Namita_Investment_Amount_in lakhs` AS investment, 'Namita' AS sharkname FROM sharktank1 WHERE `Namita_Investment_Amount_in lakhs` > 0
union all
SELECT `Vineeta_Investment_Amount_in_lakhs` AS investment, 'Vineeta' AS sharkname FROM sharktank1 WHERE `Vineeta_Investment_Amount_in_lakhs` > 0
union all
SELECT `Anupam_Investment_Amount_in_lakhs` AS investment, 'Anupam' AS sharkname FROM sharktank1 WHERE `Anupam_Investment_Amount_in_lakhs` > 0
union all
SELECT `Aman_Investment_Amount_in_lakhs` AS investment, 'Aman' AS sharkname FROM sharktank1 WHERE `Aman_Investment_Amount_in_lakhs` > 0
union all
SELECT `Peyush_Investment_Amount__in_lakhs` AS investment, 'peyush' AS sharkname FROM sharktank1 WHERE `Peyush_Investment_Amount__in_lakhs` > 0
union all
SELECT `Amit_Investment_Amount_in_lakhs` AS investment, 'Amit' AS sharkname FROM sharktank1 WHERE `Amit_Investment_Amount_in_lakhs` > 0
union all
SELECT `Ashneer_Investment_Amount` AS investment, 'Ashneer' AS sharkname FROM sharktank1 WHERE `Ashneer_Investment_Amount` > 0
)k group by sharkname





-- 8.	Develop a stored procedure that accepts inputs for the season number and the name of a shark. 
-- The procedure will then provide detailed insights into the total investment made by that specific shark
-- across different industries during the specified season. Additionally, it will calculate the percentage 
-- of their investment in each sector relative to the total investment in that year, giving a comprehensive 
-- understanding of the shark's investment distribution and impact.
select * from sharktank1

DELIMITER //
create PROCEDURE getseasoninvestment(IN season INT, IN sharkname VARCHAR(100))
BEGIN
      
    CASE 

        WHEN sharkname = 'namita' THEN
            set @total = (select  sum(`Namita_Investment_Amount_in lakhs`) from sharktank1 where Season_Number= season );
            SELECT Industry, sum(`Namita_Investment_Amount_in lakhs`) as 'sum' ,(sum(`Namita_Investment_Amount_in lakhs`)/@total)*100 as 'Percent' FROM sharktank1 WHERE season_Number = season AND `Namita_Investment_Amount_in lakhs` > 0
            group by industry;
        WHEN sharkname = 'Vineeta' THEN
            set @total = (select  sum(`Vineeta_Investment_Amount_in_lakhs`) from sharktank1 where Season_Number= season );
            SELECT industry,sum(`Vineeta_Investment_Amounti_n_lakhs`) as 'sum',(sum(`Vineeta_Investment_Amount_in_lakhs`)/@total)*100 as 'Percent' FROM sharktank1 WHERE season_Number = season AND `Vineeta_Investment_Amount_in_lakhs` > 0
            group by industry;
        WHEN sharkname = 'Anupam' THEN
            set @total = (select  sum(`Anupam_Investment_Amount_in_lakhs`) from sharktank1 where Season_Number= season );
            SELECT industry,sum(`Anupam_Investment_Amount_in_lakhs`) as 'sum',(sum(`Anupam_Investment_Amount_in_lakhs`)/@total)*100 as 'Percent' FROM sharktank1 WHERE season_Number = season AND `Anupam_Investment_Amount_in_lakhs` > 0
            group by Industry;
        WHEN sharkname = 'Aman' THEN
            set @total = (select  sum(`Aman_Investment_Amount_in_lakhs`) from sharktank1 where Season_Number= season );
            SELECT industry,sum(`Aman_Investment_Amount_in_lakhs`) as 'sum',(sum(`Aman_Investment_Amount_in_lakhs`)/@total)*100 as 'Percent'  FROM sharktank1 WHERE season_Number = season AND `Aman_Investment_Amount_in_lakhs` > 0
             group by Industry;
        WHEN sharkname = 'Peyush' THEN
             set @total = (select  sum(`Peyush_Investment_Amount__in_lakhs`) from sharktank1 where Season_Number= season );
             SELECT industry,sum(`Peyush_Investment_Amount__in_lakhs`) as 'sum',(sum(`Peyush_Investment_Amount__in_lakhs`)/@total)*100 as 'Percent'  FROM sharktank1 WHERE season_Number = season AND `Peyush_Investment_Amount__in_lakhs` > 0
             group by Industry;
        WHEN sharkname = 'Amit' THEN
              set @total = (select  sum(`Amit_Investment_Amount_in_lakhs`) from sharktank1 where Season_Number= season );
              SELECT industry,sum(`Amit_Investment_Amount_in_lakhs`) as 'sum',(sum(`Amit_Investment_Amount_in_lakhs`)/@total)*100 as 'Percent' FROM sharktank1  WHERE season_Number = season AND `Amit_Investment_Amount_in_lakhs` > 0
             group by Industry;
        WHEN sharkname = 'Ashneer' THEN
            set @total = (select  sum(`Ashneer_Investment_Amount`) from sharktank1 where Season_Number= season );
            SELECT industry,sum(`Ashneer_Investment_Amount`),(sum(`Ashneer_Investment_Amount`)/@total)*100 as 'Percent'  FROM sharktank1 WHERE season_Number = season AND `Ashneer_Investment_Amount` > 0
             group by Industry;
        ELSE
            SELECT 'Invalid shark name';
    END CASE;
    
END //
DELIMITER ;

-- drop procedure getseasoninvestment
-- select @total
call getseasoninvestment(3,"Namita")



-- 9.	In the realm of venture capital, we're exploring which shark possesses the most diversified
-- investment portfolio across various industries. By examining their investment patterns and preferences,
-- we aim to uncover any discernible trends or strategies that may shed light on their decision-making processes and investment philosophies.


select * from sharktank1

select sharkname, 
count(distinct industry) as 'unique industy',
count(distinct concat(pitchers_city,' ,', pitchers_state)) as 'unique locations' from 
(
		SELECT Industry, Pitchers_City, Pitchers_State, 'Namita'  as sharkname from sharktank1 where  `Namita_Investment_Amount_in lakhs` > 0
		union all
		SELECT Industry, Pitchers_City, Pitchers_State, 'Vineeta'  as sharkname from sharktank1 where `Vineeta_Investment_Amount_in_lakhs` > 0
		union all
		SELECT Industry, Pitchers_City, Pitchers_State, 'Anupam'  as sharkname from sharktank1 where  `Anupam_Investment_Amount_in_lakhs` > 0 
		union all
		SELECT Industry, Pitchers_City, Pitchers_State, 'Aman'  as sharkname from sharktank1 where `Aman_Investment_Amount_in_lakhs` > 0
		union all
		SELECT Industry, Pitchers_City, Pitchers_State, 'Peyush'  as sharkname from sharktank1 where   `Peyush_Investment_Amount__in_lakhs` > 0
		union all
		SELECT Industry, Pitchers_City, Pitchers_State, 'Amit'  as sharkname from sharktank1 where `Amit_Investment_Amount_in_lakhs` > 0
		union all
		SELECT Industry, Pitchers_City, Pitchers_State, 'Ashneer'  as sharkname from sharktank1 where `Ashneer_Investment_Amount` > 0
)t  
group by sharkname 
order by  'unique industry' desc ,'unique location' desc