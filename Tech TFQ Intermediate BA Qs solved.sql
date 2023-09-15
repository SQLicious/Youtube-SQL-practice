CREATE DATABASE YOUTUBE_PRACTICE;
USE YOUTUBE_PRACTICE;

--- #1) Election Results ---
create table candidates
(
    id      int,
    gender  varchar(1),
    age     int,
    party   varchar(20)
);
insert into candidates values(1,'M',55,'Democratic');
insert into candidates values(2,'M',51,'Democratic');
insert into candidates values(3,'F',62,'Democratic');
insert into candidates values(4,'M',60,'Republic');
insert into candidates values(5,'F',61,'Republic');
insert into candidates values(6,'F',58,'Republic');

create table results
(
    constituency_id     int,
    candidate_id        int,
    votes               int
);
insert into results values(1,1,847529);
insert into results values(1,4,283409);
insert into results values(2,2,293841);
insert into results values(2,5,394385);
insert into results values(3,3,429084);
insert into results values(3,6,303890);
Select * from results;
select * from candidates;

-- SOLUTION 1
WITH winning_candidates AS (
    SELECT 
        r.constituency_id,
        r.candidate_id,
        c.party,
        RANK() OVER (PARTITION BY r.constituency_id ORDER BY r.votes DESC) AS rnk
    FROM results r
    JOIN candidates c ON r.candidate_id = c.id
)

SELECT 
      CONCAT(w.party, ' ', count(distinct w.constituency_id)) as party_seats_won
FROM winning_candidates w
WHERE w.rnk = 1
GROUP BY w.party;


--- #2) Advertising System Deviations report ---

-- DATASET
drop table if exists customers;
create table customers
(
    id          int,
    first_name  varchar(50),
    last_name   varchar(50)
);
insert into customers values(1, 'Carolyn', 'O''Lunny');
insert into customers values(2, 'Matteo', 'Husthwaite');
insert into customers values(3, 'Melessa', 'Rowesby');

drop table if exists campaigns;
create table campaigns
(
    id          int,
    customer_id int,
    name        varchar(50)
);
insert into campaigns values(2, 1, 'Overcoming Challenges');
insert into campaigns values(4, 1, 'Business Rules');
insert into campaigns values(3, 2, 'YUI');
insert into campaigns values(1, 3, 'Quantitative Finance');
insert into campaigns values(5, 3, 'MMC');

drop table if exists events;
create table events
(
    campaign_id int,
    status      varchar(50)
);
insert into events values(1, 'success');
insert into events values(1, 'success');
insert into events values(2, 'success');
insert into events values(2, 'success');
insert into events values(2, 'success');
insert into events values(2, 'success');
insert into events values(2, 'success');
insert into events values(3, 'success');
insert into events values(3, 'success');
insert into events values(3, 'success');
insert into events values(4, 'success');
insert into events values(4, 'success');
insert into events values(4, 'failure');
insert into events values(4, 'failure');
insert into events values(5, 'failure');
insert into events values(5, 'failure');
insert into events values(5, 'failure');
insert into events values(5, 'failure');
insert into events values(5, 'failure');
insert into events values(5, 'failure');

insert into events values(4, 'success');
insert into events values(5, 'success');
insert into events values(5, 'success');
insert into events values(1, 'failure');
insert into events values(1, 'failure');
insert into events values(1, 'failure');
insert into events values(2, 'failure');
insert into events values(3, 'failure');

-- SOLUTION#2
WITH cte AS (
    SELECT
        CONCAT(cst.first_name,' ',cst.last_name) AS customer,
        ev.status AS event_type,
        GROUP_CONCAT(DISTINCT cmp.name, ', ') AS campaign,
        COUNT(1) AS total,
        RANK() OVER (PARTITION BY ev.status ORDER BY COUNT(1) DESC) AS rnk
    FROM
        customers cst
    JOIN
        campaigns cmp ON cmp.customer_id = cst.id
    JOIN
        events ev ON ev.campaign_id = cmp.id
    GROUP BY
        customer, event_type
)
SELECT
    event_type,
    customer,
    campaign,
    total
FROM
    cte
WHERE
    rnk = 1
ORDER BY event_type DESC;


--- #3) Election Exit Poll by state report ---

-- DATASET
drop table if exists candidates_tab;
create table candidates_tab
(
    id          int,
    first_name  varchar(50),
    last_name   varchar(50)
);
insert into candidates_tab values(1, 'Davide', 'Kentish');
insert into candidates_tab values(2, 'Thorstein', 'Bridge');

drop table if exists results_tab;
create table results_tab
(
    candidate_id    int,
    state           varchar(50)
);
insert into results_tab values(1, 'Alabama');
insert into results_tab values(1, 'Alabama');
insert into results_tab values(1, 'California');
insert into results_tab values(1, 'California');
insert into results_tab values(1, 'California');
insert into results_tab values(1, 'California');
insert into results_tab values(1, 'California');
insert into results_tab values(2, 'California');
insert into results_tab values(2, 'California');
insert into results_tab values(2, 'New York');
insert into results_tab values(2, 'New York');
insert into results_tab values(2, 'Texas');
insert into results_tab values(2, 'Texas');
insert into results_tab values(2, 'Texas');

insert into results_tab values(1, 'New York');
insert into results_tab values(1, 'Texas');
insert into results_tab values(1, 'Texas');
insert into results_tab values(1, 'Texas');
insert into results_tab values(2, 'California');
insert into results_tab values(2, 'Alabama');

select * from candidates_tab;
select * from results_tab;

-- solution#3
WITH cte AS (
    SELECT 
        CONCAT(first_name, ' ', last_name) AS candidate_name,
        state,
        COUNT(*) AS total,
        DENSE_RANK() OVER (PARTITION BY CONCAT(first_name, ' ', last_name) ORDER BY COUNT(*) DESC) AS rnk
    FROM candidates_tab c
    JOIN results_tab r ON r.candidate_id = c.id
    GROUP BY candidate_name, state
)
SELECT 
    candidate_name,
    GROUP_CONCAT(CASE WHEN rnk = 1 THEN CONCAT(state, ' (', total, ')') END ORDER BY state SEPARATOR ', ') AS "1st_place",
    GROUP_CONCAT(CASE WHEN rnk = 2 THEN CONCAT(state, ' (', total, ')') END ORDER BY state SEPARATOR ', ') AS "2nd_place",
    GROUP_CONCAT(CASE WHEN rnk = 3 THEN CONCAT(state, ' (', total, ')') END ORDER BY state SEPARATOR ', ') AS "3rd_place"
FROM cte
WHERE rnk <= 3
GROUP BY candidate_name;


