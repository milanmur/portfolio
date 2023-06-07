
-- Showing total cases versus total deaths in Serbia

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 death_percentage
FROM covid_deaths
WHERE location = 'Serbia';

-- Showing what percentage of population got covid in Serbia

SELECT location, date, population, total_cases, (total_cases/population)*100 death_percentage
FROM covid_deaths
WHERE location = 'Serbia';

-- Countries with highest infection rate compared to population

SELECT location, population, max(total_cases) as total_infection_count, MAX((total_cases/population))*100 percent_of_infected_population
FROM covid_deaths
GROUP BY location, population
ORDER BY percent_of_infected_population DESC;

-- Countries with highest death count 

SELECT location, max(total_deaths) as total_death_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;

-- Continents ordered by the highest death count

SELECT location, max(total_deaths) as total_death_count
FROM covid_deaths
WHERE continent IS NULL AND location NOT LIKE '%income%'
GROUP BY location
ORDER BY total_death_count DESC;

-- Continents ordered by the highest death rate per population

SELECT location, max(total_deaths) as total_death_count, max(total_deaths)/population*100 death_rate_per_population
FROM covid_deaths
WHERE continent IS NULL AND location NOT LIKE '%income%'
GROUP BY location
ORDER BY death_rate_per_population DESC;

-- Global death rate by the time

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, ROUND(SUM(new_deaths)/SUM(new_cases)*100, 2) as DeathRate
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

-- Total global death rate as of today

SELECT  SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, ROUND(SUM(new_deaths)/SUM(new_cases)*100, 2) as DeathRate
FROM covid_deaths
WHERE continent IS NOT NULL;

-- Showing total population versus vaccinations by the time in Serbia

CREATE TEMP TABLE Pop_vs_Vacc AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER(ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM covid_deaths AS dea
JOIN covid_vaccinations AS vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL AND dea.location = 'Serbia'
ORDER BY dea.location, dea.date;

SELECT *, ROUND((rolling_people_vaccinated/population)*100,2)
FROM Pop_vs_Vacc;

-- Showing new cases by country

SELECT location, new_cases
FROM covid_deaths
WHERE date = '14.02.2023' AND continent IS NOT NULL AND location NOT LIKE '%income%'
ORDER BY new_cases desc;

-- Total new cases

SELECT sum(new_cases)
FROM covid_deaths
WHERE date = '14.02.2023' AND continent IS NOT NULL AND location NOT LIKE '%income%'
ORDER BY new_cases desc;
