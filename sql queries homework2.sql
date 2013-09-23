Chris Della Donna
22 September 2013
SQL Queries2




Get the cities of agents booking an order for customer c002

SELECT distinct agents.city
FROM agents
Where agents.aid in
(   SELECT orders.aid
    FROM orders
    WHERE orders.cid = 'c002');


Get	the	pids	of	products	ordered	through	any	agent	who	makes	at	least	
one	order	for	a	customer	in	Kyoto.		(This	is	not	the	same	as	asking	for	pids	
of	products	ordered	by	a	customer	in	Kyoto.)

SELECT distinct orders.pid
FROM orders
Where orders.aid in
(	 	SELECT orders.aid
		FROM orders
		WHERE orders.cid in
    (	   	Select customers.cid
			FROM customers
			WHERE customers.city = 'Kyoto'));
		
Find	the	cids	and	names	of	customers	who	never	placed	an	order	through	
agent	a03.

SELECT customers.cid, customers.name
FROM customers
WHERE customers.cid not in
(	  	SELECT orders.cid
		FROM orders
		WHERE orders.aid = 'a03');
	
Get	the	cids	and	names	of	customers	who	ordered	both	product	p01	and	
p07.

SELECT customers.cid, customers.name
FROM customers
WHERE customers.cid in
(	 	SELECT orders.cid
		FROM orders
		WHERE orders.pid = 'p07'
		AND customers.cid in
    (	  	SELECT orders.cid
			FROM orders
			WHERE orders.pid = 'p01'));
        
Get	the	pids	of	products	ordered	by	any	customers	who	ever	placed	an	
order	through	agent	a03.

SELECT distinct orders.pid
FROM orders
WHERE orders.cid in
(	  	SELECT orders.cid
		FROM orders
		WHERE orders.aid = 'a03');
    
Get	the	names	and	discounts	of	all	customers	who	place	orders	through	
agents	in	Dallas	or	Duluth.

SELECT customers.name, customers.discount
FROM customers
WHERE customers.cid in
(	  	SELECT distinct orders.cid
		FROM orders
		WHERE orders.aid in
		(	  	SELECT agents.aid
				FROM agents
				WHERE agents.city = 'Dallas'
				OR agents.city = 'Duluth'));

Find	all	customers	who	have	the	same	discount	as	that	of	any	customers	
in	Dallas	or	Kyoto

SELECT distinct customers.*
FROM customers
WHERE customers.discount in
(	  	SELECT distinct customers.discount
		FROM customers
		WHERE customers.city = 'Dallas'
		OR customers.city = 'Kyoto');
