

select * from dbo.food;
select * from dbo.menu;
select * from dbo.users;
select * from dbo.restaurants;
select * from dbo.orders;
select * from dbo.order_details;

----Find customers who have never ordered--
select name from users where user_id NOT IN (select user_id from orders)

select name from users where user_id = 6 or user_id = 7;

select users.name from users left join orders on users.user_id = orders.user_id 
where users.user_id NOT IN (select orders.user_id from orders where orders.user_id is not NULL);



------average price of food in the menu----
select food.f_name, AVG(menu.price) as avg_Price from food join menu on food.f_id = menu.f_id 
group by food.f_name;

------ Find the top restaurant in terms numbers of orders in a given month
select *, DATENAME(MONTH, date) as Month from orders where Month(date) = 6;

select TOP 1 r_id, count(*) as orders_count  from orders where Month(date) = 6 group by r_id order by orders_count desc;

select TOP 1 r.r_id, r.r_name, count(*) as orders_count  from orders o
join restaurants r
on o.r_id = r.r_id
where Month(date) = 6 
group by r.r_id, r.r_name
order by orders_count desc;

------ restaurants with monthly sales> x, x = 1000'
select r.r_id, r.r_name, sum(o.amount) as sum_price from restaurants r 
join orders o on r.r_id = o.r_id where Month(o.date) = 6 
group by r.r_id, r.r_name order by sum_price desc;

select r.r_id, r.r_name, sum(o.amount) as revenue from restaurants r 
join orders o on r.r_id = o.r_id where Month(o.date) = 6 
group by r.r_id, r.r_name 
having sum(o.amount)> 500
order by revenue desc;

-----show all orders with order details for a particular customer in a particular date range
select * from orders where user_id = (select user_id from users where name like 'Ankit');

select o.order_id, r.r_name, o.amount from orders o join restaurants r on r.r_id = o.r_id  
where user_id = (select user_id from users where name like 'Ankit')
AND date > '2022-06-10' AND date< '2022-7-10';

select o.order_id, r.r_name, f.f_name, o.amount from orders o 
join restaurants r on r.r_id = o.r_id 
join order_details od on o.order_id = od.order_id
join food f on od.f_id = f.f_id 
where user_id = (select user_id from users where name like 'Nitish')
AND date > '2022-06-10' AND date< '2022-7-10';


-------Find restaurants with max repeated customers.---

select  user_id, r_id, count(*) as visits from orders where user_id is NOT NULL 
group by user_id,r_id 
having count(*) > 1 
order by r_id;

select top 1 r.r_id, r.r_name, count(*) as loyal_customers FROM (select  user_id, r_id, count(*) as visits from orders where user_id is NOT NULL 
group by user_id,r_id 
having count(*) > 1 ) t join restaurants r on r.r_id = t.r_id group by r.r_id,  r.r_name order by loyal_customers desc; 

------- Month over month revenue growth of swiggy

with sales as
(
select MONTH(date) as Month, sum(amount) as revenue from orders  
group by MONTH(date) 
having sum(amount) is not null
) 
select t.Month, ((t.revenue-t.prev_revenue)/t.prev_revenue)*100 as monthly_Growth 
from (select s.Month, s.revenue, lag(s.revenue, 1) over(order by s.Month) as prev_revenue from sales s
) t

-------- Find most loyal customers for all restaurant---
select user_id, r_id, count(*) as visits from orders 
where user_id is not null 
group by user_id, r_id 
having count(*)>1 
order by user_id;

select t.r_id,u.name as loyal_customer from (select user_id, r_id, count(*) as visits from orders 
where user_id is not null 
group by user_id, r_id 
having count(*)>1 
) t join users u on u.user_id = t.user_id
group by t.r_id, u.name order by t.r_id;

-------Month over Month revenue growth of a restaurant---
select * from dbo.orders;
select * from dbo.restaurants;

with sales as (
select r_id, sum(amount) as revenue , Month(date) as month from orders 
group by r_id, Month(date)
having r_id is not null 
)
select r.r_name, t.Month, ((t.revenue-t.prev_revenue)/t.prev_revenue)*100 as month_growth 
from (select s.r_id, s.month, s.revenue, lag(s.revenue) over(order by s.month) as prev_revenue from sales s) t join restaurants r 
on t.r_id = r.r_id;

----- customer -> favourite food -----
--- we define favourite food as food which is ordered more then once ---
select * from dbo.orders;
select * from dbo.order_details;
select * from dbo.food;

select * from orders o join order_details od on o.order_id = od.order_id;

select o.user_id, od.f_id, count(*) as food_orders from orders o join order_details od on o.order_id = od.order_id 
group by o.user_id, od.f_id 
having count(*)>1
order by food_orders desc;



select o.user_id, od.f_id, count(*) as food_orders from orders o join order_details od 
on o.order_id = od.order_id
group by o.user_id, od.f_id 
having count(*)>1
order by food_orders desc;

select u.name, f.f_name, t.food_orders from (select o.user_id, od.f_id, count(*) as food_orders from orders o join order_details od 
on o.order_id = od.order_id
group by o.user_id, od.f_id 
having count(*)>1
) t join food f on f.f_id = t.f_id
join users u on t.user_id = u.user_id
order by food_orders desc;

----- Most Paired products --- 
select * from dbo.orders;
select * from dbo.food;
select * from dbo.order_details;

select od.order_id, f.f_name from food f join order_details od on f.f_id = od.f_id;

select TOP 1 f1.f_name as food1, f2.f_name as food2 , count(*) as most_paired_food from order_details od1 
join order_details od2 on od1.order_id = od2.order_id and od1.f_id <od2.f_id
join food f1 on f1.f_id = od1.f_id
join food f2 on f2.f_id = od2.f_id
 group by f1.f_name, f2.f_name
 order by most_paired_food desc;


