#SQL Queries Homework 3
#Chris Della Donna

#1.	Get	the	cities	of	agents	booking	an	order	for	customer	c002.	Use	a	
subquery.	(Yes,	this	is	the	same	question	as	on	homework	#2).

Select agents.city
From agents
Where agents.aid in
(Select orders.aid
From orders
Where orders.cid = 'c002');


#2 2.	Get	the	cities	of	agents	booking	an	order	for	customer	c002.	This	time	
# use	joins;	no	subqueries.

Select distinct agents.city
From agents
Join orders
ON agents.aid = orders.aid
AND orders.cid = 'c002';


#3 3.	Get	the	pids	of	products	ordered	through	any	agent	who	makes	at	least	
#one	order	for	a	customer	in	Kyoto.	Use	subqueries.	(Yes,	this	is	also	the	
#same	question	as	on	homework	#2.)


SELECT distinct orders.pid
FROM orders
Where orders.aid in
(	  SELECT orders.aid
    FROM orders
    WHERE orders.cid in
    (	   Select customers.cid
         FROM customers
         WHERE customers.city = 'Kyoto'));
         
#4 4.	Get	the	pids	of	products	ordered	through	any	agent	who	makes	at	least	
#one	order	for	a	customer	in	Kyoto.	Use	joins	thus	time;	no	subqueries.
         
         
#5   5.	Get	the	names	of	customers	who	have	never	placed	an	order.	Use	a	
subquery.
    
         select customers.name
         From customers
         WHERE customers.cid not in (
         select orders.cid
         from orders);
         
#6 6.	Get	the	names	of	customers	who	have	never	placed	an	order.	Use	an	
outer	join.

  select distinct customers.name
  from customers
  FULL OUTER JOIN orders
  on customers.cid= orders.cid
  Where orders.cid is null
  
  #7 7.	Get	the	names	of	customers	who	placed	at	least	one	order	through	an	
agent	in	their	city,	along	with	those	agent(s)	names.

select customers.name, agents.name
from customers full outer join 
         
  select distinct customers.name, agents.name
from customers, orders, agents
Where customers.cid = orders.cid
And orders.aid = agents.aid
And customers.city = agents.city   


#8     Get	the	names	of	customers	and	agents	in	the	same	city,	along	with	the	
#name	of	the	city,	regardless	of	whether	or	not	the	customer	has	ever	
#placed	an	order	with	that	agent.

select distinct customers.name, agents.name , customers.city
from customers, orders, agents
Where customers.city = agents.city

#9 9.	Get	the	name	and	city	of	customers	who	live	in	the	city	where	the	least	
number	of	products	are	made

Drop VIEW if exists minP;
CREATE VIEW minP As 
select( count(city) )
from products
group by products.city;

select customers.name, customers.city
from customers
Where customers.city in (
select products.city
from products
group by products.city
having count(city) in(Select MIN(count)From minP));


10.	Get	the	name	and	city	of	customers	who	live	in	a	city	where	the	most	
number	of	products	are	made.

Drop VIEW if exists MaxP;
CREATE VIEW MaxP As 
select( count(city) )
from products
group by products.city;

select customers.name, customers.city
from customers
Where customers.city in (
select products.city
from products
group by products.city
having count(city) in(Select MAX(count)From minP));

11.	Get	the	name	and	city	of	customers	who	live	in	any	city	where	the	
most	number	of	products	are	made.

Drop VIEW if exists MaxP;
CREATE VIEW MaxP As 
select( count(city) )
from products
group by products.city;

select customers.name, customers.city
from customers
Where customers.city in (
select products.city
from products
group by products.city
having count(city) in(Select MAX(count)From minP) limit 1);

#12.	List	the	products	whose	priceUSD	is	above	the	average	priceUSD.
Select products.name
from products
Where products.priceUSD > (
Select AVG(products.priceUSD)
From products)


#13.	Show	the	customer	name,	pid	ordered,	and	the	dollars	for	all	customer	
orders,	sorted	by	dollars	from	high	to	low.

select customers.name, orders.pid, orders.dollars
from customers join orders
on customers.cid = orders.cid
order by orders.dollars DESC;

14.	Show	all	customer	names	(in	order)	and	their	total	ordered,	and	
nothing	more.	Use	coalesce	to	avoid	showing	NULLs


Select customers.name, coalesce (SUM(dollars), 0)
From orders
FULL OUTER JOIN customers
On customers.cid = orders.cid
group by customers.cid

15.	Show	the	names	of	all	customers	who	bought	products	from	agents	
based	in	New	York	along	with	the	names	of	the	products	they	ordered,	
and	the	names	of	the	agents	who	sold	it	to	them.

select c.name, p.name, a.name
from orders o , customers c , products p , agents a 
where o.cid = c.cid
And o.aid = a.aid
And o.pid = p.pid
And a.city = 'New York'


16.	Write	a	query	to	check	the	accuracy	of	the	dollars	column	in	the	
Orders	table.	This	means	calculating	Orders.dollars	from	other	data	in	
other	tables	and	then	comparing	those	values	to	the	values	in	
Orders.dollars.

Drop VIEW if exists recalc;
CREATE VIEW recalc As 
select orders.ordno,(products.priceUSD * orders.qty ) * (1-(customers.discount / 100)) as checked
from agents, customers, orders, products
Where customers.cid = orders.cid
and orders.aid = agents.aid
And orders.pid = products.pid
group by orders.ordno, (products.priceUSD * orders.qty ) * (1-(customers.discount / 100));

select orders.ordno, recalc.checked, orders.dollars
from recalc, orders
Where recalc.ordno = orders.ordno
order by ordno;

17.	Create	an	error	in	the	dollars	column	of	the	Orders	table	so	that	you	
can	verify	your	accuracy	checking	query.

Drop VIEW if exists recalc;
CREATE VIEW recalc As 
select orders.ordno,(products.priceUSD * orders.qty ) * (1-(customers.discount / 100)) as checked
from agents, customers, orders, products
Where customers.cid = orders.cid
and orders.aid = agents.aid
And orders.pid = products.pid
group by orders.ordno, (products.priceUSD * orders.qty ) * (1-(customers.discount / 100));

select orders.ordno, recalc.checked, orders.dollars
from recalc, orders
Where recalc.ordno = orders.ordno
And orders.dollars != recalc.checked
order by ordno;






         