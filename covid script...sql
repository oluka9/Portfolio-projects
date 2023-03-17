
-- looking at total deaths vs total cases
-- shows the likelihood dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_rate
FROM covid.`covid deaths`
WHERE location = "Kenya"
ORDER BY 1,2;

-- looking at total case vs population
-- shows what percentage of population got covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS Percent_of_population_infected
FROM covid.`covid deaths`
WHERE location = "kenya"
ORDER BY 1,2;

-- looking at countries with highest covid infection rate compared to there population
SELECT location, MAX(total_cases) AS Highest_infection_count, 
       population, MAX((total_cases/population))*100 AS Percent_of_population_infected
FROM covid.`covid deaths`
GROUP BY population,location
ORDER BY percent_of_population_infected desc;

-- showing the continents with highest death count per population
SELECT continent, MAX(total_deaths) AS Highest_death_count
FROM covid.`covid deaths`
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Highest_death_count DESC;

-- Global numbers
SELECT date, SUM(new_cases), SUM(new_deaths), 
	SUM(new_deaths)/SUM(new_cases) * 100 AS DeathPercentage
FROM covid.`covid deaths`
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- Lookin at total population vs vaccinations
SELECT  ccv.date, ccv.continent, ccv.location, ccd.population, ccv.new_vaccinations,
       SUM(ccv.new_vaccinations) over (partition by ccv.location order by ccv.date)as Cummulative_vaccinated 
       -- (cummulative_vaccinated/population)*100
FROM covid.covidvaccinations ccv
JOIN covid.`covid deaths` ccd
    ON ccv.date= ccd.date AND ccv.location=ccd.location
WHERE ccd.continent IS NOT NULL
GROUP BY continent,location,date,population,new_vaccinations
order BY ccv.location; 

-- USE CTE
WITH popvsvac (date, continent, location,population,new_vaccination, cummulative_vaccinated)
as 
(
SELECT  ccv.date, ccv.continent, ccv.location, ccd.population, ccv.new_vaccinations,
       SUM(ccv.new_vaccinations) over (partition by ccv.location order by ccv.date)as Cummulative_vaccinated
       -- , (cummulative_vaccinated/population)*100
FROM covid.covidvaccinations ccv
JOIN covid.`covid deaths` ccd
    ON ccv.date= ccd.date AND ccv.location=ccd.location
WHERE ccd.continent IS NOT NULL
GROUP BY continent,location,date,population,new_vaccinations
order BY ccv.location
)

select*, (cummulative_vaccinated/population)*100 as "% of population vaccinated"
from popvsvac;

-- TABLE

create view ofpopulationvaccinated as
SELECT  ccv.date, ccv.continent, ccv.location, ccd.population, ccv.new_vaccinations,
       SUM(ccv.new_vaccinations) over (partition by ccv.location order by ccv.date)as Cummulative_vaccinated
       -- , (cummulative_vaccinated/population)*100
FROM covid.covidvaccinations ccv
JOIN covid.`covid deaths` ccd
    ON ccv.date= ccd.date AND ccv.location=ccd.location
WHERE ccd.continent IS NOT NULL
GROUP BY continent,location,date,population,new_vaccinations
order BY ccv.location

