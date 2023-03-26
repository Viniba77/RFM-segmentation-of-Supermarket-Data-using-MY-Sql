use rfm;
select * from supermart
select distinct Category from supermart
select distinct Sub_Catgory from supermart
select distinct city from supermart
/*calculate the profit from each category*/

with profit AS
(select category,profit,ROUND((profit/sales) * 100,4) as pp,
rank() over(partition by category order by profit  desc) as pro1
from supermart  s)

select distinct category,
ROUND(sum(profit) over(partition by category),0) as Total_Profit, 
CAST(sum(pp) over(partition by category) AS DECIMAL(18,2)) as percent 
from profit
order by Total_Profit 
/*From Category snacks we got more profit followed by Category Eggs,Meat&Fish*/
select city,sum(Sales)
 from supermart
group by city
order by 2 desc


/* calculating the RFM */
with rfm as
(select customer_Name,sum(sales) Monetary_Value,
count(ï»¿Order_ID) Frequency,
max(Order_Date) last_order_Date,
(select Max(order_Date) from supermart) as max_order_Date,
DATEDIFF((select Max(order_Date) from supermart),max(Order_Date)) Recency
from supermart
group by customer_Name)
,
rfm_calc as
(select r.*, 
     NTILE(4) over(order by Recency desc)rfm_recency,
     NTILE(4) over(order by Frequency ) rfm_Frequency,
     NTILE(4) over(order by Monetary_Value ) rfm_Monetary
from rfm r)
,
f as
(select 
	c.*, 
    rfm_recency+ rfm_frequency+ rfm_monetary as rfm_cell,
    CONCAT(rfm_recency,rfm_frequency,rfm_Monetary) as rfm_cell_string
from rfm_calc c),
seg as 
(select customer_Name,rfm_recency,rfm_frequency,rfm_monetary,
case 
		when rfm_cell_string in (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141) then 'lost_customers' 
		when rfm_cell_string in (133, 134, 143, 244, 334, 343, 344, 142,144) then 'slipping away, cannot lose'
		when rfm_cell_string in (311, 411,412, 331,413) then 'new customers'
		when rfm_cell_string in (222, 223, 233,232,234, 322) then 'potential churners'
		when rfm_cell_string in (323, 333,321, 422,421, 332, 432) then 'active'
		when rfm_cell_string in (433, 434, 443, 444) then 'loyal'
end rfm_segment
    from f)
    
   SELECT 
    COUNT(DISTINCT customer_Name) AS TotaluniqueCustomers,
    COUNT(DISTINCT IF(rfm_segment = 'new customers',
            customer_Name,
            NULL)) AS New,
    COUNT(DISTINCT IF(rfm_segment = 'lost_customers',
            customer_Name,
            NULL)) AS lost,
    COUNT(DISTINCT IF(rfm_segment = 'active',
            customer_Name,
            NULL)) AS Activee,
    COUNT(DISTINCT IF(rfm_segment = 'slipping away, cannot lose',
            customer_Name,
            NULL)) AS slip,
	COUNT(DISTINCT IF(rfm_segment = 'Potential churners',
            customer_Name,
            NULL)) AS PC,
	COUNT(DISTINCT IF(rfm_segment = 'Loyal',
            customer_Name,
            NULL)) AS loyal
FROM seg


     
     













