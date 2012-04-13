-- The full GO set was loaded

select * from db where name = "GO";

--+-------+------+-------------+-----------+------+
--| db_id | name | description | urlprefix | url  |
--+-------+------+-------------+-----------+------+
--|    66 | GO   | NULL        | NULL      | NULL |
--+-------+------+-------------+-----------+------+
--1 row in set (0.00 sec)


-- The db_id for go terms is 66
-- therefore to select go terms from dbxref we us db_id = 66
-- for example, given GO:0009987

select dbxref_id from dbxref where accession = 0009987 and db_id = 66;

--+-----------+-------+-----------+---------+-------------+
--| dbxref_id | db_id | accession | version | description |
--+-----------+-------+-----------+---------+-------------+
--|     18566 |    66 | 0009987   |         | NULL        |
--+-----------+-------+-----------+---------+-------------+
--1 row in set (0.68 sec)

-- This is substantailly slower than those cases where we can ignore db_id
select dbxref_id from dbxref where accession = 0009987;
--+-----------+
--| dbxref_id |
--+-----------+
--|     18566 |
--+-----------+
--1 row in set (0.04 sec)


-- now we want to turn this value into a cvterm id
select cvterm_id from cvterm where dbxref_id = 18566;


--
-- Joining these together
--
select cvterm_id from cvterm where dbxref_id = 
( select dbxref_id from dbxref where accession = 0009987 and db_id = 
( select db_id from db where name = "GO") );
-- +-----------+
-- | cvterm_id |
-- +-----------+
-- |      8094 |
-- +-----------+
-- 1 row in set (0.58 sec)

-- using quotation marks
select cvterm_id from cvterm where dbxref_id = 
( select dbxref_id from dbxref where accession = "0009987" and db_id = 
( select db_id from db where name = "GO") );

-- +-----------+
-- | cvterm_id |
-- +-----------+
-- |      8094 |
-- +-----------+
-- 1 row in set (0.00 sec)



-- This command can be used with $accessoin variable used at accession value
-- This is slow because the accession column is not an integer

-- As JOINS to select all
SELECT cvterm.cvterm_id 
FROM cvterm
LEFT JOIN dbxref
ON cvterm.dbxref_id=dbxref.dbxref_id
LEFT JOIN db
ON db.db_id=dbxref.db_id;

-- add GO as DB
SELECT cvterm.cvterm_id 
FROM cvterm
LEFT JOIN dbxref
ON cvterm.dbxref_id=dbxref.dbxref_id
LEFT JOIN db
ON db.db_id=dbxref.db_id
WHERE db.name = "GO";

-- add ACCESSION
SELECT cvterm.cvterm_id 
FROM cvterm
LEFT JOIN dbxref
ON cvterm.dbxref_id=dbxref.dbxref_id
LEFT JOIN db
ON db.db_id=dbxref.db_id
WHERE db.name = "GO"
AND dbxref.accession = "0009987";

-- use term name to fetch
-- the term id
-- this is useful to get term inds
-- possibly could do this query without the db name
-- but adding db name makes sure we are fetching
-- the correct id from the correct namespace
SELECT cvterm.cvterm_id 
FROM cvterm
LEFT JOIN dbxref
ON cvterm.dbxref_id=dbxref.dbxref_id
LEFT JOIN db
ON db.db_id=dbxref.db_id
WHERE db.name = "GO"
AND cvterm.name = "reproduction";

-- TRON terms
SELECT cvterm.cvterm_id 
FROM cvterm
LEFT JOIN dbxref
ON cvterm.dbxref_id=dbxref.dbxref_id
LEFT JOIN db
ON db.db_id=dbxref.db_id
WHERE db.name = "TRON";

SELECT cvterm.name
FROM cvterm
LEFT JOIN dbxref
ON cvterm.dbxref_id=dbxref.dbxref_id
LEFT JOIN db
ON db.db_id=dbxref.db_id
WHERE db.name = "TRON";

SELECT cvterm.name, cvterm.cvterm_id
FROM cvterm
LEFT JOIN dbxref
ON cvterm.dbxref_id=dbxref.dbxref_id
LEFT JOIN db
ON db.db_id=dbxref.db_id
WHERE db.name = "TRON";


-- example including term from ontology
SELECT cvterm.cvterm_id
FROM cvterm
LEFT JOIN dbxref
ON cvterm.dbxref_id=dbxref.dbxref_id
LEFT JOIN db
ON db.db_id=dbxref.db_id
WHERE db.name = "TRON"
AND
cvterm.name = "tandem_duplication";

-- To get the term for software used
SELECT cvterm.cvterm_id
FROM cvterm
LEFT JOIN dbxref
ON cvterm.dbxref_id=dbxref.dbxref_id
LEFT JOIN db
ON db.db_id=dbxref.db_id
WHERE db.name = "TRON"
AND
cvterm.name = "tandem_duplication";

SELECT cvterm.cvterm_id
FROM cvterm
LEFT JOIN dbxref
ON cvterm.dbxref_id=dbxref.dbxref_id
LEFT JOIN db
ON db.db_id=dbxref.db_id
WHERE db.name = "TRON"
AND
cvterm.name = "reconciled_tree";