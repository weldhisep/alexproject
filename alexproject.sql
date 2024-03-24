select *
from alexproject..CovidDeaths
order by 3,4

select *
from alexproject..CovidVaccinations
--order by 3,4

Select Location, population, Max(total_cases) as highestinfectioncount, Max((total_cases/population))*100 as Percentpopulationinfected
From alexproject..CovidDeaths
Group by Location, population
order by Percentpopulationinfected desc


--Death Count
Select Location, Max(cast(total_deaths as int)) as totaldeathcount
From alexproject..CovidDeaths
Where Continent is not null
Group by Location
order by totaldeathcount desc

--data by continent(highest death count)
Select location, Max(cast(total_deaths as int)) as totaldeathcount
From alexproject..CovidDeaths
Where Continent is null
Group by location
order by totaldeathcount desc

--Global numbers
Select Location, population, Max(total_cases) as highestinfectioncount, Max((total_cases/population))*100 as Percentpopulationinfected
From alexproject..CovidDeaths
Where Continent is null
Group by Location, population
order by Percentpopulationinfected desc

--global death
Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as Totaldeath_percentage
From alexproject..CovidDeaths
Where Continent is not null
order by 1,2

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location Order by dea.location, dea.date) 
as rollingPeopleVaccinated
--, (rollingPeopleVaccinated/population*100) as vaccination_percentage 
from alexproject..CovidDeaths dea
join alexproject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date =vac.date 
where dea.continent is not null
order by 2,3

--CTE

With PopvsVac (continent, location, date, population, new_vaccinations, rollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location Order by dea.location, dea.date) 
as rollingPeopleVaccinated
--, (rollingPeopleVaccinated/population*100) as vaccination_percentage 
from alexproject..CovidDeaths dea
join alexproject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date =vac.date 
where dea.continent is not null
--order by 2,3
)
Select *, (rollingPeopleVaccinated/Population)*100 as vaccination_percentage
From PopvsVac 

--temp table

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location Order by dea.location, dea.date) 
as rollingPeopleVaccinated
--, (rollingPeopleVaccinated/population*100) as vaccination_percentage 
from alexproject..CovidDeaths dea
join alexproject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date =vac.date 
where dea.continent is not null
--order by 2,3
Select *, (rollingPeopleVaccinated/Population)*100 as vaccination_percentage
From #PercentPopulationVaccinated

--Creating view for data visualization

Create view Percentpopulationvaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location Order by dea.location, dea.date) 
as rollingPeopleVaccinated
--, (rollingPeopleVaccinated/population*100) as vaccination_percentage 
from alexproject..CovidDeaths dea
join alexproject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date =vac.date 
where dea.continent is not null
--order by 2,3

select * from Percentpopulationvaccinated
