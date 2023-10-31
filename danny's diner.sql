CREATE SCHEMA dannys_diner;


CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  show tables;
  
  select * from members;
  select * from menu;
  select * from sales;

  #1
  select customer_id, sum(price)  from sales inner join menu using (product_id)
  group by customer_id;
  
  #2
  select customer_id , count(distinct(order_date)) from sales
  group by customer_id;
  
  
  
  #3
  
  create view salesWithNames as(
  select customer_id, order_date, product_name, price from sales join menu using(product_id));
  
 create view first_ordered as(
 select customer_id, order_date, product_name, dense_rank() over ( partition by customer_id order by order_date ) as ra from salesWithnames
  );
  select * from first_ordered;
  
  select customer_id, product_name from first_ordered
  where ra = 1
  group by 1,2 ;

  
  
  
  #4
  select product_name, count(product_name) from saleswithnames
  group by product_name
  order by 2 desc limit 1;
  
  #5
  drop view customerorderranks;
  create view customerorderranks as(select customer_id, product_name, count(product_name) as coun, rank() over ( partition by customer_id order by count(product_name) desc) as ra from saleswithnames
  group by customer_id, product_name );
  
  select * from customerorderranks;
  
  select customer_id, product_name, coun from customerorderranks 
  where ra = 1;
  
  #6
  select * from members;
  select * from saleswithnames;
  
  with member_sales as( select t1.customer_id, order_date, product_name, join_date, dense_rank() over (partition by customer_id order by order_date) as ra from saleswithnames t1 right  join members using (customer_id)
  where datediff(order_date, join_date) >= 0
  order by customer_id)
  
  select customer_id, product_name, order_date from member_sales
  where ra = 1;
  
  #7
  with member_sales as( select t1.customer_id, order_date, product_name, join_date, dense_rank() over (partition by customer_id order by order_date desc) as ra from saleswithnames t1 right  join members using (customer_id)
  where datediff(order_date, join_date) < 0
  order by customer_id)
  select customer_id, product_name, order_date from member_sales
  where ra = 1;
  
  #8
  with member_sales as (select t1.customer_id, order_date, product_name,price, join_date from saleswithnames t1 right  join members using (customer_id)
  where datediff(order_date, join_date) < 0
  order by customer_id)
  select customer_id, count(distinct(product_name)), sum(price) from member_sales
  group by customer_id
  order by customer_id;
  
 #9
 with points_table as (select customer_id, product_name,price, case when product_name = 'sushi' then price*20 else price*10 end as points from saleswithnames)
 select customer_id, sum(points) from points_table
 group by customer_id
 order by customer_id;
 
 
 
 #10 
 with points_table as (  select customer_id, order_date, join_date,product_name,price,  case when product_name = 'sushi' or datediff(order_date,join_date) between 0 and 6 then price*20 else price*10 end as points from saleswithnames right join members using(customer_id)
 where order_date <= '2021-01-31' 
 order by customer_id,order_date)
 select customer_id, sum(points) from points_table
 group by customer_id
 order by customer_id;
 
 #join all things
 select customer_id, order_date, product_name, price, case when order_date >= join_date then 'Y' else 'N' end as member from saleswithnames left join members using(customer_id)
 order by customer_id, order_date, product_name;
 
 #rank all things
with summary_cte as (select customer_id, order_date, product_name, price, case when order_date >= join_date then 'Y' else 'N' end as member from saleswithnames left join members using(customer_id)
 order by customer_id, order_date, product_name)
 
 select *, case when member = 'N' then null else dense_rank() over(partition by customer_id ,member order by order_date) end as ranking from summary_cte
 
 

 
 
 
 
 
 
  
  
  
  
 
  
  
  
 
 
  
  
  