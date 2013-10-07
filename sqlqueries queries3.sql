--#SQL Queries Homework 3
--#Chris Della Donna

--#1.	Get	the	cities	of	agents	booking	an	order	for	customer	c002.	Use	a	
--subquery.	(Yes,	this	is	the	same	question	as	on	homework	#2).

SELECT agents.city
FROM agents
WHERE agents.aid IN
  (Select orders.aid
  FROM orders
  WHERE orders.cid = 'c002');


--2.	Get	the	cities	of	agents	booking	an	order	for	customer	c002.	This	time	
 --use	joins;	no	subqueries.

SELECT DISTINCT agents.city
FROM agents
JOIN orders
ON agents.aid = orders.aid
AND orders.cid = 'c002';


--3.	Get	the	pids	of	products	ordered	through	any	agent	who	makes	at	least	
--one	order	for	a	customer	in	Kyoto.	Use	subqueries.	(Yes,	this	is	also	the	
--same	question	as	on	homework	#2.)


SELECT DISTINCT orders.pid
FROM orders
WHERE orders.aid IN
(	  SELECT orders.aid
    FROM orders
    WHERE orders.cid IN
    (	   SELECT customers.cid
         FROM customers
         WHERE customers.city = 'Kyoto'));
         
--4.	Get	the	pids	of	products	ordered	through	any	agent	who	makes	at	least	
--one	order	for	a	customer	in	Kyoto.	Use	joins	thus	time;	no	subqueries.


SELECT DISTINCT o2.pid
FROM orders o FULL OUTER JOIN orders o2 
ON o.aid=o2.aid, customers c
where c.cid = o.cid
AND c.city = 'Kyoto'
ORDER BY o2.pid;
         
         
--5.	Get	the	names	of	customers	who	have	never	placed	an	order.	Use	a	
--subquery.
    
select customers.name
From customers
WHERE customers.cid NOT IN (
  SELECT orders.cid
  FROM orders);
         
--6.	Get	the	names	of	customers	who	have	never	placed	an	order.	Use	an	
--outer	join.

SELECT DISTINCT customers.name
FROM customers
FULL OUTER JOIN orders
ON customers.cid= orders.cid
WHERE orders.cid IS NULL;
  
--7.	Get	the	names	of	customers	who	placed	at	least	one	order	through	an	
--agent	in	their	city,	along	with	those	agent(s)	names.

SELECT customers.name, agents.name
FROM customers FULL OUTER JOIN; 
         
SELECT DISTINCT customers.name, agents.name
FROM customers, orders, agents
WHERE customers.cid = orders.cid
AND orders.aid = agents.aid
AND customers.city = agents.city;   


--8     Get	the	names	of	customers	and	agents	in	the	same	city,	along	with	the	
name	of	the	city,	regardless	of	whether	or	not	the	customer	has	ever	
placed	an	order	with	that	agent.

SELECT DISTINCT customers.name, agents.name , customers.city
FROM customers, orders, agents
WHERE customers.city = agents.city;

--9.	Get	the	name	and	city	of	customers	who	live	in	the	city	where	the	least	
--number	of	products	are	made

DROP VIEW IF EXISTS minP;
CREATE VIEW minP AS 
  SELECT( count(city) )
  FROM products
  GROUP BY products.city;

SELECT customers.name, customers.city
FROM customers
WHERE customers.city IN (
  SELECT products.city
  FROM products
  GROUP BY products.city
  HAVING count(city) IN (
    SELECT MIN(count)FROM minP));


--10.	Get	the	name	and	city	of	customers	who	live	in	a	city	where	the	most	
--number	of	products	are	made.

Drop VIEW IF EXISTS MaxP;
CREATE VIEW MaxP AS 
  SELECT( count(city) )
  FROM products
  GROUP BY products.city;

SELECT customers.name, customers.city
FROM customers
WHERE customers.city in (
  SELECT products.city
  FROM products
  GROUP BY products.city
  HAVING count(city) IN (
    SELECT MAX(count)From minP));

--11.	Get	the	name	and	city	of	customers	who	live	in	any	city	where	the	
--most	number	of	products	are	made.

DROP VIEW IF EXISTS MaxP;
CREATE VIEW MaxP AS 
SELECT( count(city) )
FROM products
GROUP BY products.city;

SELECT customers.name, customers.city
FROM customers
WHERE customers.city IN (
  SELECT products.city
  FROM products
  GROUP BY products.city
  HAVING count(city) IN (
    Select MAX(count)From minP) limit 1);

--12.	List	the	products	whose	priceUSD	is	above	the	average	priceUSD.

SELECT products.name
FROM products
WHERE products.priceUSD > (
  SELECT AVG(products.priceUSD)
  FROM products);


--13.	Show	the	customer	name,	pid	ordered,	and	the	dollars	for	all	customer	
--orders,	sorted	by	dollars	from	high	to	low.

SELECT customers.name, orders.pid, orders.dollars
FROM customers join orders
ON customers.cid = orders.cid
ORDER BY orders.dollars DESC;

--14.	Show all	customer	names	(in	order)	and	their	total	ordered,	and	
--nothing	more.	Use	coalesce	to	avoid	showing	NULLs


SELECT customers.name, coalesce (SUM(dollars), 0)
FROM orders
FULL OUTER JOIN customers
ON customers.cid = orders.cid
GROUP BY customers.cid;

--15.	Show	the	names	of	all	customers	who	bought	products	from	agents	
--based	in	New	York	along	with	the	names	of	the	products	they	ordered,	
--and	the	names	of	the	agents	who	sold	it	to	them.

SELECT c.name, p.name, a.name
FROM orders o , customers c , products p , agents a 
WHERE o.cid = c.cid
AND o.aid = a.aid
AND o.pid = p.pid
AND a.city = 'New York';


--16.	Write	a	query	to	check	the	accuracy	of	the	dollars	column	in	the	
--Orders	table.	This	means	calculating	Orders.dollars	from	other	data	in	
--other	tables	and	then	comparing	those	values	to	the	values	in	
--Orders.dollars.

DROP VIEW IF EXISTS recalc;
CREATE VIEW recalc AS 
SELECT orders.ordno,(products.priceUSD * orders.qty ) * (1-(customers.discount / 100)) as checked
FROM agents, customers, orders, products
WHERE customers.cid = orders.cid
AND orders.aid = agents.aid
AND orders.pid = products.pid
GROUP BY orders.ordno, (products.priceUSD * orders.qty ) * (1-(customers.discount / 100));

SELECT orders.ordno, recalc.checked, orders.dollars
FROM recalc, orders
WHERE recalc.ordno = orders.ordno
ORDER BY ordno;

--17.	Create	an	error	in	the	dollars	column	of	the	Orders	table	so	that	you	
--can	verify	your	accuracy	checking	query.

UPDATE orders
SET dollars = '600'
WHERE ordno = '1013';


DROP VIEW IF EXISTS recalc;
CREATE VIEW recalc AS 
SELECT orders.ordno,(products.priceUSD * orders.qty ) * (1-(customers.discount / 100)) as checked
FROM agents, customers, orders, products
WHERE customers.cid = orders.cid
AND orders.aid = agents.aid
AND orders.pid = products.pid
GROUP BY orders.ordno, (products.priceUSD * orders.qty ) * (1-(customers.discount / 100));

SELECT orders.ordno, recalc.checked, orders.dollars
FROM recalc, orders
WHERE recalc.ordno = orders.ordno
AND orders.dollars != recalc.checked
ORDER BY ordno;






         