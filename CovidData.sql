
-- Select Data we are going to be using 
select * 
from CovidDeaths
order by 1,2 

--- Looking at Total Cases vs Total Deaths 
--- Shows the likelihood of dying if you got infected with COVID in your country

select Location, Date, total_cases, total_deaths, (total_deaths/total_cases) * 100  as death_percentage
from CovidDeaths
where Location like '%states%'
order by 1,2 


-- Looking at Total Cases vs Population
-- to show what percentage of the population got COVID

select Location, Date, population, total_cases, (total_cases/population) * 100  as infection_percentage
from CovidDeaths
--where Location like '%states%'
order by 1,2 

-- Looking at countries with the highest infection rate compared to population 
select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100  as infection_percentage
from CovidDeaths
--where Location like '%states%'
group by Location, Population
order by infection_percentage asc 

-- Showing the countries with the highest Death count per population

select Location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
from CovidDeaths
group by Location
order by TotalDeathCount desc 

select * 
from CovidDeaths
where continent is not null
order by 3,4 
----
select Location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by Location
order by TotalDeathCount desc

--- BREAK NUMBERS DOWN BY CONTINENT

select Location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is null
group by location 
order by TotalDeathCount desc


----
select continent, MAX(cast(Total_Deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent 
order by TotalDeathCount desc

-- Showing the continents with the highest death count

select Location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is null
group by location 
order by TotalDeathCount desc



-- Calculate global numbers 

select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as global
from CovidDeaths
--where Location like '%states%'
where continent is not null
group by Date 
order by 1,2


select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as global
from CovidDeaths
--where Location like '%states%'
where continent is not null
--group by Date 
order by 1,2

--- Looking for Total Popuation v. accinations 

select * from CovidDeaths CD
join CovidVaccinations CC
	on CD.location = CC.location and CD.date = CC.date

select CD.continent, CD.location, CD.date, CD.population, CC.new_vaccinations
, sum(cast(cc.new_vaccinations as int)) over (partition by CD.location order by CD.location, CD.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
from CovidDeaths CD
join CovidVaccinations CC
	on CD.location = CC.location 
	and CD.date = CC.date
where CD.continent is not null
order by 2, 3 

-- USE CTE

with PopvsVac (continent,location,date,population,new_vaccinations, RollingPeopleVaccinated)
as 
(
select CD.continent, CD.location, CD.date, CD.population, CC.new_vaccinations
, sum(cast(cc.new_vaccinations as int)) over (partition by CD.location order by CD.location, CD.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
from CovidDeaths CD
join CovidVaccinations CC
	on CD.location = CC.location 
	and CD.date = CC.date
where CD.continent is not null
--order by 2, 3 
)
select *, (RollingPeopleVaccinated/population) * 100
from PopvsVac

-- TEMP table

drop table if exists #PercentPopVaccinated
create table #PercentPopVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopVaccinated
select CD.continent, CD.location, CD.date, CD.population, CC.new_vaccinations
, sum(cast(cc.new_vaccinations as int)) over (partition by CD.location order by CD.location, CD.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
from CovidDeaths CD
join CovidVaccinations CC
	on CD.location = CC.location 
	and CD.date = CC.date
--where CD.continent is not null
--order by 2, 3 
select *, (RollingPeopleVaccinated/population) * 100
from #PercentPopVaccinated



-- How to create a view to store data for later visualization

create view PercentPopVaccinated as
select CD.continent, CD.location, CD.date, CD.population, CC.new_vaccinations
, sum(cast(cc.new_vaccinations as int)) over (partition by CD.location order by CD.location, CD.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
from CovidDeaths CD
join CovidVaccinations CC
	on CD.location = CC.location 
	and CD.date = CC.date
where CD.continent is not null
--order by 2, 3 
--select *, (RollingPeopleVaccinated/population) * 100
--from #PercentPopVaccinated
--where continent is null
--group by location 
--order by TotalDeathCount desc

select * from PercentPopVaccinated
