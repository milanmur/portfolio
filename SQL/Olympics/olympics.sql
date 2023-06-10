--1. How many Olympics games have been held?

SELECT COUNT(DISTINCT Games) as total_olympic_games
FROM athlete_events;

--Answer: 51 Olympics games were held so far.

--2. List all Olympics games held so far.

SELECT DISTINCT Games
FROM athlete_events
ORDER BY Games; 

--3. Total number of nations who participated in each olympic games?

SELECT DISTINCT Games, COUNT(DISTINCT NOC)
FROM athlete_events
GROUP BY Games
ORDER BY Games;

--4. Which year saw the highest and lowest no of countries participating in olympics?

WITH least_no_countries AS (SELECT DISTINCT Games, COUNT(DISTINCT NOC) as least
FROM athlete_events
GROUP BY Games
ORDER BY least
LIMIT 1),

most_no_countries AS (SELECT DISTINCT Games, COUNT(DISTINCT NOC) as most
FROM athlete_events
GROUP BY Games
ORDER BY most DESC
LIMIT 1)

SELECT least_no_countries.Games || " - " || least as Olympic_with_least_countries, most_no_countries.Games || " - " || most as Olympic_with_most_countries
FROM least_no_countries, most_no_countries;

--Answer: Olympics with the highest number of countries was in 2016, when 204 countries participated, and in 1896 only 12 countries participated. 

--5. Which nation has participated in all of the Olympic games?

WITH nocs AS (SELECT NOC, COUNT(DISTINCT Games) as no_of_participation
FROM athlete_events
GROUP BY NOC
ORDER BY no_of_participation DESC)

SELECT region, no_of_participation
FROM nocs
JOIN noc_regions
ON nocs.NOC=noc_regions.NOC
WHERE no_of_participation = (
	SELECT COUNT(DISTINCT Games) FROM athlete_events)
ORDER BY no_of_participation DESC;

--Answer: Switzerland, Italy, UK and France participated in all Olympics.

--6. Identify the sport which was played in all summer olympics.

WITH cte1 AS (SELECT Sport, COUNT(DISTINCT Games) no_of_times
FROM athlete_events
GROUP BY Sport
ORDER BY COUNT(DISTINCT Games) DESC)

SELECT *
FROM cte1
WHERE no_of_times = 
	(SELECT COUNT(DISTINCT Games) as total_olympic_games
	FROM athlete_events
	WHERE Games LIKE '%Summer%');
	
--Answer: Swimming, Gymnastics, Fencing, Cycling and Athletics are sports, that were played in all summer olympics.

--7. Which Sports were just played only once in the olympics?

WITH cte1 AS (SELECT Sport, COUNT(DISTINCT Games) no_of_times, Games
FROM athlete_events
GROUP BY Sport
ORDER BY COUNT(DISTINCT Games))

SELECT *
FROM cte1
WHERE no_of_times = 1;

--Answer: 10 sports in total, names of each sport are shown once query is run.

--8. Fetch the total no of sports played in each olympic games.

SELECT Games, COUNT( DISTINCT Sport) as no_of_sports
FROM athlete_events
GROUP BY Games
ORDER BY no_of_sports DESC;

--9. Fetch oldest athletes to win a gold Medal

WITH oldest_rank AS (SELECT *,
DENSE_RANK() OVER(ORDER BY Age DESC) as rankings
FROM athlete_events
WHERE Medal='Gold' AND Age <> 'NA'
ORDER BY Age DESC)

SELECT *
FROM oldest_rank
WHERE rankings = 1;

--Answer: Charles Jacobus and Oscar Gomer Swahn where the oldest athletes to win gold medal (64 years old)

--10. Find the Ratio of male and female athletes participated in all olympic games.

WITH total_athletes AS (SELECT COUNT(DISTINCT Name)
FROM athlete_events),
male_athletes AS (SELECT CAST(COUNT(DISTINCT Name) AS REAL) as male
FROM athlete_events
WHERE Sex = 'M'),
female_athletes AS (SELECT CAST(COUNT(DISTINCT Name) AS REAL) as female
FROM athlete_events
WHERE Sex = 'F')

SELECT 1 || " : " || ROUND(male/female,2) as ratio
FROM male_athletes, female_athletes

--Answer: Ratio is 1:2.99

--11. Fetch the top 5 athletes who have won the most gold medals.

WITH cte1 AS (SELECT Name, COUNT(Medal) as total_medals,
DENSE_RANK() OVER(ORDER BY COUNT(Medal) DESC) as dense_ranking
FROM athlete_events
WHERE Medal = 'Gold'
GROUP BY Name
ORDER BY COUNT(Medal) DESC)

SELECT Name, total_medals
FROM cte1
WHERE dense_ranking <6;

--Answer: List can be seen once query is run

--12.  Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

WITH cte1 AS (SELECT Name, COUNT(Medal) as total_medals,
DENSE_RANK() OVER(ORDER BY COUNT(Medal) DESC) as dense_ranking
FROM athlete_events
WHERE Medal <> 'NA'
GROUP BY Name
ORDER BY COUNT(Medal) DESC)

SELECT Name, total_medals
FROM cte1
WHERE dense_ranking <6;

--Answer: List can be seen once query is run

--13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

WITH cte1 AS (SELECT NOC, COUNT(Medal) as total_medals,
DENSE_RANK() OVER(ORDER BY COUNT(Medal) DESC) as dense_ranking
FROM athlete_events
WHERE Medal <> 'NA'
GROUP BY NOC
ORDER BY COUNT(Medal) DESC)

SELECT region, SUM(total_medals)
FROM cte1
JOIN noc_regions
ON cte1.NOC=noc_regions.NOC
GROUP BY region
ORDER BY SUM(total_medals) DESC
LIMIT 5;

--Answer: 1. USA 2. Russia 3. Germany 4. UK 5. France

--14. List down total gold, silver and bronze medals won by each country.

WITH gold as (SELECT NOC, COUNT(Medal) as gold
FROM athlete_events
WHERE Medal <> 'NA' AND Medal = 'Gold'
GROUP BY NOC),

silver AS (SELECT NOC, COUNT(Medal) as silver
FROM athlete_events
WHERE Medal <> 'NA' AND Medal = 'Silver'
GROUP BY NOC),

bronze AS (SELECT NOC, COUNT(Medal) as bronze
FROM athlete_events
WHERE Medal <> 'NA' AND Medal = 'Bronze'
GROUP BY NOC),

all_medals AS (SELECT g.NOC, gold, silver, bronze
FROM gold g
JOIN silver s
ON g.NOC=s.NOC
JOIN bronze b
ON b.NOC=g.NOC
ORDER BY gold DESC)

SELECT region, SUM(gold), SUM(silver), SUM(bronze)
FROM all_medals
JOIN noc_regions
ON all_medals.NOC=noc_regions.NOC
GROUP BY region
ORDER BY SUM(gold) DESC;

--15. List down total gold, silver and bronze medals won by each country corresponding to each olympic games.

WITH gold as (SELECT Games, NOC, COUNT(Medal) as gold
FROM athlete_events
WHERE Medal <> 'NA' AND Medal = 'Gold'
GROUP BY NOC, Games
ORDER BY Games, NOC),

silver AS (SELECT Games, NOC, COUNT(Medal) as silver
FROM athlete_events
WHERE Medal <> 'NA' AND Medal = 'Silver'
GROUP BY NOC, Games),

bronze AS (SELECT Games, NOC, COUNT(Medal) as bronze
FROM athlete_events
WHERE Medal <> 'NA' AND Medal = 'Bronze'
GROUP BY NOC, Games),

all_medals AS (SELECT g.Games, g.NOC, gold, silver, bronze
FROM gold g
LEFT JOIN silver s
ON g.NOC=s.NOC AND g.Games=s.Games
LEFT JOIN bronze b
ON b.NOC=g.NOC AND b.Games=g.Games
ORDER BY gold DESC)

SELECT Games, region, SUM(gold), SUM(silver), SUM(bronze)
FROM all_medals
JOIN noc_regions
ON all_medals.NOC=noc_regions.NOC
GROUP BY Games, region
ORDER BY Games, region;

--16. Identify which country won the most gold medals in each olympic games.

WITH gold as (SELECT Games, NOC, COUNT(Medal) as gold
FROM athlete_events
WHERE Medal <> 'NA' AND Medal = 'Gold'
GROUP BY NOC, Games
ORDER BY Games, NOC),

silver AS (SELECT Games, NOC, COUNT(Medal) as silver
FROM athlete_events
WHERE Medal <> 'NA' AND Medal = 'Silver'
GROUP BY NOC, Games),

bronze AS (SELECT Games, NOC, COUNT(Medal) as bronze
FROM athlete_events
WHERE Medal <> 'NA' AND Medal = 'Bronze'
GROUP BY NOC, Games),

all_medals AS (SELECT g.Games, g.NOC, gold, silver, bronze
FROM gold g
LEFT JOIN silver s
ON g.NOC=s.NOC AND g.Games=s.Games
LEFT JOIN bronze b
ON b.NOC=g.NOC AND b.Games=g.Games
ORDER BY gold DESC),

cte1 AS (SELECT Games, region, SUM(gold) as total_gold, SUM(silver) as total_silver, SUM(bronze) as total_bronze
FROM all_medals
JOIN noc_regions
ON all_medals.NOC=noc_regions.NOC
GROUP BY Games, region
ORDER BY Games, region),

gold_max AS (SELECT Games, region, total_gold, total_silver, total_bronze,
MAX(total_gold) OVER(PARTITION BY Games) as max_gold_olympic
FROM cte1
GROUP BY Games, region),

cte2 AS (SELECT *, max_gold_olympic-total_gold as gold_difference
FROM gold_max)

SELECT Games, region || " - " || total_gold
FROM cte2
WHERE gold_difference = 0;

--18. Which countries have never won gold medal but have won silver/bronze medals?

WITH cte1 AS (SELECT NOC,
SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) as gold_medals,
SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) as silver_medals,
SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) as bronze_medals
FROM athlete_events
GROUP BY NOC)

SELECT region, gold_medals, silver_medals, bronze_medals
FROM cte1
JOIN noc_regions
ON cte1.NOC=noc_regions.NOC
WHERE gold_medals = 0 AND (silver_medals <> 0 OR bronze_medals <> 0)
GROUP BY region
ORDER BY bronze_medals DESC;

--19. In which Sport/event, Serbia has won highest medals.

WITH cte1 AS (SELECT Sport,
SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) as gold_medals,
SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) as silver_medals,
SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) as bronze_medals
FROM athlete_events
WHERE (NOC = "SCG" OR NOC = "SRB") AND Medal <> 'NA'
GROUP BY Sport)

SELECT Sport, gold_medals+silver_medals+bronze_medals as total_medals
FROM cte1
ORDER BY total_medals DESC
LIMIT 1;

--Answer: In waterpolo (64).

--20.  Break down all olympic games where Serbia won medal in Water Polo and how many medals in each olympic games

WITH cte1 AS (SELECT Games, Sport,
SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) as gold_medals,
SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) as silver_medals,
SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) as bronze_medals
FROM athlete_events
WHERE (NOC = "SCG" OR NOC = "SRB") AND Medal <> 'NA' AND Sport = 'Water Polo'
GROUP BY Games, Sport)
