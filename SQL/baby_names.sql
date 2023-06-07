
--TOP 10 f names in US

SELECT Name, Sum(Count)
FROM StateNames
WHERE Gender='F' 
GROUP BY Name
ORDER BY Sum(Count) DESC
LIMIT 10;

--TOP 10 f names in 19th century

SELECT Name, Sum(Count)
FROM NationalNames
WHERE Gender='F' and Year <= 1900
GROUP BY Name
ORDER BY Sum(Count) DESC
LIMIT 10;

-- TOP female names by the year with cumulative quantity and rank

SELECT *,
RANK() OVER(PARTITION BY name ORDER BY year) as Count_by_year
FROM (
SELECT year, name, sum(count) AS cnt,
 row_number() OVER (PARTITION BY year ORDER BY sum(count) DESC) AS seqnum
     FROM NationalNames
     WHERE gender = 'F'
     GROUP BY year)
 WHERE seqnum=1
 ORDER BY year;
 
-- TOP male names by the year

SELECT year, name
FROM (
SELECT year, name, sum(count) AS cnt,
 row_number() OVER (PARTITION BY year ORDER BY sum(count) DESC) AS seqnum
     FROM NationalNames
     WHERE gender = 'M' --'F' for female
     GROUP BY year)
 WHERE seqnum=1;
 
-- Male name that was the most times first per year

WITH top_names AS (
SELECT year, name
FROM (
SELECT year, name, sum(count) AS cnt,
 row_number() OVER (PARTITION BY year ORDER BY sum(count) DESC) AS seqnum
     FROM NationalNames
     WHERE gender = 'M' --changing letter
     GROUP BY year)
 WHERE seqnum=1)
 
SELECT name, count(name)
FROM top_names
GROUP BY name
ORDER BY count(name) DESC;

-- Female names that were the most times first per year in terms of popularity

WITH top_names AS (
SELECT year, name
FROM (
SELECT year, name, sum(count) AS cnt,
 row_number() OVER (PARTITION BY year ORDER BY sum(count) DESC) AS seqnum
     FROM NationalNames
     WHERE gender = 'F' --changing letter
     GROUP BY year)
 WHERE seqnum=1)
 
SELECT name, count(name)
FROM top_names
GROUP BY name
ORDER BY count(name) DESC;

-- Showing in which state is Jennifer the most given girl name.

SELECT name, state, sum(count)
FROM StateNames
WHERE name = 'Jennifer'
GROUP BY state
ORDER BY sum(count) DESC
LIMIT 1;

--Showing the most popular boy name per state in 2014 to compare with image from the internet

SELECT name, state
FROM(
SELECT name, state, sum(count),
ROW_NUMBER() OVER (PARTITION BY state ORDER BY sum(count) DESC) AS seqnum
FROM StateNames
WHERE gender = 'M' AND year= '2014' --in 2014
GROUP BY name, state) 
WHERE seqnum =1;

--The most popular m name by the year in Montana state

SELECT year, name
FROM (
SELECT year, name, sum(count) AS cnt,
ROW_NUMBER () OVER (PARTITION BY year ORDER BY sum(count) DESC) AS seqnum
     FROM StateNames
     WHERE gender = 'M' and state = 'MT'--changing letter
     GROUP BY year)
WHERE seqnum=1;
 
--Do trends in Montana follow trends in country?

CREATE TEMP TABLE Montana AS
SELECT year, name,
ROW_NUMBER() OVER(PARTITION BY year ORDER BY sum(count) DESC) AS seqnum
     FROM StateNames
     WHERE gender='M' and state ='MT'--changing letter
     GROUP BY year;
     
CREATE TEMP TABLE USA AS 
SELECT year, name
FROM (SELECT year, name, sum(count) AS cnt,
 row_number() OVER (PARTITION BY year ORDER BY sum(count) DESC) AS seqnum
     FROM NationalNames
     WHERE gender = 'M' --'F' for female
     GROUP BY year);
     
CREATE TEMP TABLE Montana_USA AS
SELECT m.year, m.name as Name_in_Montana, u.name as Name_in_US
FROM Montana m
LEFT JOIN USA u
ON m.year=u.year;

SELECT SUM(same_or_not)/COUNT(*) as rate_of_similarity
FROM(
SELECT *,
CASE WHEN Name_in_Montana = Name_in_US THEN 1
ELSE 0 END AS Same_or_not
FROM Montana_USA);

-- Showing most popular girl names across the years, with their cumulative count

CREATE TEMP TABLE top_female_names AS
SELECT year, name
FROM (
SELECT year, name, sum(count) AS cnt,
 row_number() OVER (PARTITION BY year ORDER BY sum(count) DESC) AS seqnum
     FROM NationalNames
     WHERE gender = 'F' 
     GROUP BY year)
 WHERE seqnum=1;

SELECT Name, Year, SUM(count),
SUM(count) OVER(partition by name order by year)  as cumulative
FROM NationalNames
WHERE name IN (
            SELECT name
            FROM top_female_names
            GROUP BY name)
GROUP BY name, year
ORDER BY name, year;
