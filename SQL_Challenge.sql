-- QUESTION 1
-- This query counts the number of Wave users

SELECT COUNT(u_id) FROM users;


-- QUESTION 2
-- The number of transfers sent in currency CFA

SELECT COUNT(*) FROM transfers
	WHERE send_amount_currency = 'CFA';


-- QUESTION 3
-- Number of CFA transfers made by different users

SELECT DISTINCT COUNT(u_id) FROM transfers
	WHERE send_amount_currency = 'CFA';


-- QUESTION 4
-- Number of agent_transaction in 2018 grouped by Months
SELECT COUNT(atx_id) FROM agent_transactions
	WHERE EXTRACT(YEAR FROM when_created) = '2018'
	GROUP BY EXTRACT(MONTH FROM when_created);


-- QUESTION 5
-- Number of net depositors and net with-drawers over the past week

WITH net_depositors(depositors_id) AS
	(SELECT agent_id FROM agent_transactions
	WHERE amount < 0),

	net_withdrawers(withdrawers_id) AS
	(SELECT agent_id FROM agent_transactions
	WHERE amount > 0 )

	SELECT COUNT(depositors_id) AS net_depositors,
	    COUNT(withdrawers_id) AS net_withdrawers
	FROM net_depositors, net_withdrawers, agent_transactions
	WHERE when_created > CURRENT_DATE - interval '1 week';


-- QUESTION 6
-- Create a table('atx_volume_city_summary') that summarizes the
-- volume of agent transactions over the past week grouped by city

SELECT city, COUNT(atx_id)  AS volume
	INTO atx_volume_city_summary
	FROM agent_transactions INNER JOIN agents
	ON agent_transactions.agent_id = agents.agent_id
	WHERE agents.when_created > CURRENT_DATE - interval '1 week'
	GROUP BY city;


-- QUESTION 7
-- Create a table('atx_volume_country_city_summary') that summarizies the
-- volume of agent transactions over the past week grouped by country and city

SELECT country, city, COUNT(atx_id)  AS volume
	INTO atx_volume_country_city_summary
	FROM agent_transactions INNER JOIN agents
	ON agent_transactions.agent_id = agents.agent_id
	WHERE agents.when_created > CURRENT_DATE - interval '1 week'
	GROUP BY country, city;


-- QUESITON 8
-- Create a table('send_volume_by_country_and_kind') that summarizies the
-- volume of transfers over the past week grouped by country and transfer kind

SELECT ledger_location AS country,  transfers.kind,
	SUM(transfers.send_amount_scalar)  AS volume
	INTO send_volume_by_country_and_kind
	FROM transfers INNER JOIN wallets
	ON transfers.source_wallet_id = wallets.wallet_id
	WHERE transfers.when_created > current_date - interval '1 week'
	GROUP BY country, transfers.kind;


-- QUESTION 9
-- Add transaction count and unique senders columns to the
-- send_volume_by_country_and_kind table

SELECT wallets.ledger_location AS country,
	transfers.kind AS transfer_kind,
	sum(transfers.send_amount_scalar) AS Volume,
	COUNT(transfers.source_wallet_id) AS Unique_Senders,
	COUNT(transfer_id) AS Transaction_count FROM transfers
	INNER JOIN wallets ON transfers.source_wallet_id = wallets.wallet_id
	WHERE transfers.when_created > current_date - interval '1 week'
	GROUP BY country, transfers.kind;


-- QUESTION 10
-- Wallets which sent more that 10,000,000 CFA in transfers in the last 
-- Month and how much they sent

SELECT source_wallet_id, send_amount_scalar
	FROM transfers
	WHERE send_amount_currency = 'CFA' AND send_amount_scalar > 10000000
	AND  transfers.when_created > current_date - interval '1 month'
