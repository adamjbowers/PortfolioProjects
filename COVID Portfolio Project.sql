-- All Covid death data for USA
SELECT	*
FROM	portfolioproject001..coviddeaths
WHERE	location LIKE '%united states%'
ORDER	BY 3, 4 

-- All Covid vaccination data
SELECT *
FROM portfolioproject001..covidvaccinations
ORDER BY 3, 4 

-- Select statement for the data that will be used
SELECT location,
       date,
       total_cases,
       new_cases,
       total_deaths,
       population
FROM   portfolioproject001..coviddeaths
ORDER  BY 1, 2 

-- Looking at total cases vs total deaths
-- Shows the liklihood of dying if you contract covid in the USA by date
SELECT location,
       date,
       total_cases,
       total_deaths,
       ( total_deaths / total_cases ) * 100 AS DeathPercentage
FROM   portfolioproject001..coviddeaths
WHERE  location LIKE '%states%'
ORDER  BY 1, 2 

-- TOTAL CASES VS POPULATION
-- Shows covid cases as percent of population by date in the USA
SELECT location,
       date,
       population,
       total_cases,
       ( total_cases / population ) * 100 AS PercentPopulationInfected
FROM   portfolioproject001..coviddeaths
WHERE  location LIKE '%states%'
ORDER  BY 1, 2 

-- Looking at countries with highest infection rate compared to population
SELECT location,
       population,
       Max(total_cases)                        AS HighestInfectionCount,
       Max(( total_cases / population )) * 100 AS PercentPopulationInfected
FROM   portfolioproject001..coviddeaths
WHERE  continent IS NOT NULL
GROUP  BY population,
          location
ORDER  BY 4 DESC 

-- Showing the countries with the higest death count per population
SELECT location,
       Max(Cast(total_deaths AS INT)) AS TotalDeathCount
FROM   portfolioproject001..coviddeaths
WHERE  continent IS NOT NULL
GROUP  BY location
ORDER  BY totaldeathcount DESC 


-- BREAKING THINGS DOWN BY CONTINENT
-- Showing the countries with the higest death count per population
SELECT location,
       Max(Cast(total_deaths AS INT)) AS TotalDeathCount
FROM   portfolioproject001..coviddeaths
WHERE  continent IS NULL
       AND location NOT LIKE '%income%'
       AND location NOT IN ( 'world' )
GROUP  BY location
ORDER  BY totaldeathcount DESC 

-- Global numbers
SELECT Sum(new_cases)                                      AS Total_Cases,
       Sum(Cast(new_deaths AS INT))                        AS Total_Deaths,
       Sum(Cast(new_deaths AS INT)) / Sum(new_cases) * 100 AS DeathPercentage
FROM   portfolioproject001..coviddeaths
WHERE  continent IS NOT NULL
ORDER  BY 1, 2 

-- Looking at total population vs vaccinations
-- CTE
WITH popvsvac (continent, location, date, population, new_vaccinations,
     Rolling_Total_Vaccinated)
     AS (SELECT dea.continent,
                dea.location,
                dea.date,
                dea.population,
                vac.new_vaccinations,
                Sum(CONVERT(INT, vac.new_vaccinations))
                  OVER (
                    PARTITION BY dea.location
                    ORDER BY dea.location, dea.date) AS
                Rolling_Total_Vaccinated
         FROM   portfolioproject001..coviddeaths dea
                JOIN portfolioproject001..covidvaccinations vac
                  ON dea.location = vac.location
                     AND dea.date = vac.date
         WHERE  dea.continent LIKE '%north amer%')
SELECT *,
       ( Rolling_Total_Vaccinated / population ) * 100	AS Rolling_Total_Percent
FROM   popvsvac
WHERE  location LIKE '%united s%'
ORDER  BY 2, 3 

-- TEMP TABLE
DROP TABLE IF EXISTS #percentpopulationvaccinated
CREATE TABLE #percentpopulationvaccinated
  (
     continent                NVARCHAR(255),
     location                 NVARCHAR(255),
     date                     DATETIME,
     population               NUMERIC,
     new_vaccinations         NUMERIC,
     rolling_total_vaccinated NUMERIC
  ) 
INSERT INTO #percentpopulationvaccinated
SELECT   dea.continent,
         dea.location,
         dea.date,
         dea.population,
         vac.new_vaccinations ,
         Sum(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_Total_Vaccinated
FROM     portfolioproject001..coviddeaths dea
		 JOIN portfolioproject001..covidvaccinations vac
			ON dea.location = vac.location
			AND	 dea.date = vac.date
WHERE    dea.continent LIKE '%north amer%'

SELECT   *,
         (rolling_total_vaccinated/population)*100 as Rolling_Total_Percent
FROM     #percentpopulationvaccinated
ORDER BY 1, 2, 3

-- CREATING VIEW to store for later visualizations
-- CREATE VIEW PercentPopulationVaccinated AS
ALTER VIEW percentpopulationvaccinated
AS
  SELECT dea.continent,
         dea.location,
         dea.date,
         dea.population,
         vac.new_vaccinations,
         Sum(CONVERT(INT, vac.new_vaccinations))
           OVER (
             PARTITION BY dea.location
             ORDER BY dea.location, dea.date) AS Rolling_Total_Vaccinated
  FROM   portfolioproject001..coviddeaths dea
         JOIN portfolioproject001..covidvaccinations vac
           ON dea.location = vac.location
              AND dea.date = vac.date
  WHERE  dea.continent IS NOT NULL

SELECT *,
       (rolling_total_vaccinated/population)*100 as Rolling_Total_Percent
FROM PercentPopulationVaccinated
WHERE location like '%united s%' 
