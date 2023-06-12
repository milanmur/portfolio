-- Order countries by the total reserves

SELECT Entity, SUM(Reserves)/1000000 AS "Reserves (MM barrels)"
FROM world_reserves
WHERE code IS NOT NULL
GROUP BY Entity
ORDER BY SUM(Reserves) DESC;

-- Order countries by the total production

SELECT Entity, SUM(Production)
FROM world_production
WHERE code IS NOT NULL AND entity IS NOT 'World'
GROUP BY Entity
ORDER BY SUM(Production) DESC;

-- Order countries by the consumption

SELECT Entity, SUM(Consumption)
FROM world_consumption
WHERE code IS NOT NULL AND entity IS NOT 'World' 
GROUP BY Entity
ORDER BY SUM(Consumption) DESC;

-- Total production by the years

SELECT year, SUM(Production) AS Total_production
FROM world_production
WHERE code IS NOT NULL AND entity IS NOT 'World'
GROUP BY year
ORDER BY year;

-- Total production by the USA over the years

SELECT *,
SUM(Production) OVER(order by year)
FROM world_production
WHERE entity = 'United States'
ORDER BY year;

-- Showing relationship between oil consumption and oil production

SELECT entity, year, production, consumption
FROM world_production p
JOIN world_consumption c
USING (year, entity)
WHERE p.code IS NOT NULL AND entity IS NOT 'World';

-- Showing relationship between oil reserves and oil production

SELECT entity, year, reserves/1000000 AS "Reserves (MM barrels)", production
FROM world_reserves r
JOIN world_production p
USING (year, entity)
WHERE r.code IS NOT NULL AND entity IS NOT 'World';

-- Showing TOP 10 countries which have the highest ratio of reserves versus production 
-- (countries with "underdeveloped" production, countries with big potential to produce much more)

WITH res_vs_prod AS (
SELECT entity, year, reserves/1000000 AS "Reserves (MM barrels)", production
FROM world_reserves r
JOIN world_production p
USING (year, entity)
WHERE r.code IS NOT NULL AND entity IS NOT 'World')

SELECT entity, SUM("Reserves (MM barrels)") as total_reserves, SUM(production) as total_production, 
SUM("Reserves (MM barrels)")/SUM(production) as ratio_reserves_production
FROM res_vs_prod
GROUP BY entity
ORDER BY ratio_reserves_production desc
LIMIT 10;

-- Showing countries which have the highest ratio of consumption versus production (possibly highest importers in the world) and labeling them

WITH cons_vs_prod AS (
SELECT entity, year, production, consumption
FROM world_production p
JOIN world_consumption c
USING (year, entity)
WHERE p.code IS NOT NULL AND entity IS NOT 'World')

SELECT entity, SUM(consumption), SUM(production), SUM(consumption)/SUM(production) as ratio_cons_prod,
CASE WHEN SUM(consumption)/SUM(production) > 1 THEN 'Oil importers'
WHEN SUM(consumption)/SUM(production) < 1 THEN 'Oil Exporters'
END AS label
FROM cons_vs_prod
GROUP BY entity
ORDER BY ratio_cons_prod DESC;


