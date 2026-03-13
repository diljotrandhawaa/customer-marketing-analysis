
SELECT * FROM player_info_and_transactions

-- Combining First and Last names into Player Name
ALTER TABLE player_info_and_transactions
ADD player_name VARCHAR(150)

UPDATE player_info_and_transactions
SET player_name = CONCAT(Name,' ',Surname)

ALTER TABLE player_info_and_transactions
DROP COLUMN Name

ALTER TABLE player_info_and_transactions
DROP COLUMN Surname

-- Fixing Gender Null values
SELECT COUNT(*), Gender FROM player_info_and_transactions
GROUP BY Gender;

UPDATE player_info_and_transactions
SET Gender = 'Non-Binary'
where Gender IS NULL;


-- Looking up PlayerIds
SELECT count(DISTINCT Customer_ID) from player_info_and_transactions

SELECT MIN(Customer_ID), MAX(Customer_ID) FROM player_info_and_transactions


SELECT TOP 200
    player_name,
    Gender,
    Birthdate,
    SUM(Transaction_Amount) AS total_spent
FROM player_info_and_transactions
GROUP BY
    player_name,
    Gender,
    Birthdate
ORDER BY total_spent DESC;


ALTER TABLE customer_segmentation_data
ADD player_name VARCHAR(150),
gender varchar(50),
birthdate Date

select * from customer_segmentation_data

-- Separating Player data from transactions
UPDATE c
SET 
    c.player_name = t.player_name,
    c.Gender = t.Gender,
    c.Birthdate = t.Birthdate
FROM customer_segmentation_data c
JOIN
(
    SELECT TOP 200
        player_name,
        Gender,
        Birthdate,
        ROW_NUMBER() OVER (ORDER BY SUM(Transaction_Amount) DESC) AS rn
    FROM player_info_and_transactions
    GROUP BY player_name, Gender, Birthdate
) t
ON c.id = t.rn;

ALTER TABLE player_info_and_transactions
DROP COLUMN birthDate

select * from player_info_and_transactions
select * from customer_segmentation_data

-- Connecting Transactions to Players data

ALTER TABLE player_info_and_transactions
add player_id INT

UPDATE player_info_and_transactions
SET player_id = ABS(CHECKSUM(NEWID())) % 200 + 1;



-- Deleting some records with low transaction amount

WITH rows_to_delete AS
(
    SELECT TOP 20000 *
    FROM player_info_and_transactions
    ORDER BY Transaction_Amount ASC
)
DELETE FROM rows_to_delete;

ALTER TABLE customer_segmentation_data
drop column preferred_category

ALTER TABLE customer_segmentation_data
drop column spending_score

ALTER TABLE customer_segmentation_data
drop column purchase_frequency

ALTER TABLE customer_segmentation_data
drop column birthdate


-- Adjusting Dates
select MIN(Date), MAX(date) from player_info_and_transactions

UPDATE player_info_and_transactions
SET [Date] = DATEADD(
    DAY,
    ABS(CHECKSUM(NEWID())) % (DATEDIFF(DAY, '2020-01-01', '2025-12-31') + 1),
    '2020-01-01'
);

ALTER TABLE player_info_and_transactions
drop column Merchant_Name

ALTER TABLE player_info_and_transactions
drop column Merchant_Name


select * from player_info_and_transactions
select * from customer_segmentation_data

-- Getting tables ready for reporting
exec sp_rename 'player_info_and_transactions.Customer_ID', 'transaction_id', 'COLUMN'
exec sp_rename 'player_info_and_transactions.Transaction_Amount', 'amount', 'COLUMN'
exec sp_rename 'player_info_and_transactions.Category', 'game_played', 'COLUMN'

SELECT game_played, SUM(amount), COUNT(amount)
FROM player_info_and_transactions
GROUP BY game_played

UPDATE player_info_and_transactions
set game_played = 'Baccarat'
where game_played = 'Cosmetic'

-- Join query for the reports
SELECT
p.id AS Player_ID,
p.player_name,
p.age,
p.gender,
p.income,
p.membership_years,
p.last_purchase_amount,
t.amount,
t.Date,
t.game_played,
t.transaction_id
FROM customer_segmentation_data p
JOIN player_info_and_transactions t
ON p.id = t.player_id