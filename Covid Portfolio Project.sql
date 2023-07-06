use portfolioproject;

select * from coviddeaths 
where continent is not null
order by 3,4;

select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
order by 1,2;

#looking at total cases vs total deaths
#shows the likelihood of dying if you contract COVID in Ghana

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from coviddeaths
where location like 'Ghana'
order by 1,2;

#Look at total cases vs population
#Shows percentage of population who caught covid
select location, date, population, total_cases, total_deaths, (total_cases/population)*100 as PopulationInfectedPercentage
from coviddeaths
order by 1,2;

#Countries with highest infection rate compared to total population
select location, population, max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PopulationInfectedPercentage
from coviddeaths
Group by location, population
order by PopulationInfectedPercentage desc;

#Showing countries with highest death count per population
select location, max(total_deaths) as TotalDeathCount
from coviddeaths
where continent is not null
Group by location
order by TotalDeathCount desc;

#Showing continents with highest death count per population
select continent, max(total_deaths) as TotalDeathCount
from coviddeaths
where continent is not null
Group by continent
order by TotalDeathCount desc;

#Showing continents with highest death count per population
select location, max(total_deaths) as TotalDeathCount
from coviddeaths
where continent is not null
Group by location
order by TotalDeathCount desc;

#Global Numbers

select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from coviddeaths
where continent is not null
group by date
order by 1,2;


#Looking at Total Popultion vs Vaccinations

SELECT 
    dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM
    coviddeaths dea
        JOIN
    covidvaccinations vac ON dea.date = vac.date and dea.location = vac.location
    where dea.continent is not null
    Order by 2,3;
    

    
#USE CTE (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
    
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as
	(
    SELECT 
    dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM
    coviddeaths dea
        JOIN
    covidvaccinations vac ON dea.date = vac.date and dea.location = vac.location
    where dea.continent is not null
    )
    select *, (rollingpeoplevaccinated/population)*100
    from PopvsVac;
    
    
    #Temp Table

drop table if exists  PercentPopulationVaccinated;
Create temporary table PercentPopulationVaccinated
    (
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime, 
    Population bigint,
    new_vaccinations bigint,
    rollingpeoplevaccinated bigint);
    
Insert into PercentPopulationVaccinated
SELECT 
    dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM
    coviddeaths dea
        JOIN
    covidvaccinations vac ON dea.date = vac.date and dea.location = vac.location
    #where dea.continent is not null
    ;
    
select *, (rollingpeoplevaccinated/population)*100 as RollingPeopleVaccinatedPercentage
    from PercentPopulationVaccinated;
    
    
#Creating View to store data for visualisations

create view PercentPopulationVaccinated as
SELECT 
    dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM
    coviddeaths dea
        JOIN
    covidvaccinations vac ON dea.date = vac.date and dea.location = vac.location
    where dea.continent is not null;
    
select * from percentpopulationvaccinated;