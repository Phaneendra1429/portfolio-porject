
select * from portfolio..['covid deaths$']
order by 3, 4


select * from portfolio..['covid vaccinations$']
order by 3, 4

select location,date,total_cases,new_cases,total_deaths,population
from portfolio..['covid deaths$']
order by 1,2

--total cases and total deaths
--it shows the  chances of dying in india
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from portfolio..['covid deaths$']
where location like 'india'
order by 1,2

select location,date,total_cases,population,(population/total_cases)*100 as infectedpercentage
from portfolio..['covid deaths$']
where location like 'india'
order by 1,2




select location,date,population,total_cases,(total_cases/population)*100 as infectedpercentage
from portfolio..['covid deaths$']
where location like 'india'
order by 1,2

---higest infect countries compare to population4
select location,population,max(total_cases) as maximum, max((total_cases/population))*100  as infectedpercentagebycountry
from portfolio..['covid deaths$'] 
group by location,population
order by infectedpercentagebycountry desc

select location,population,max(total_cases) as maximum, max((total_cases/population))*100  as infectedpercentagebycountry
from portfolio..['covid deaths$'] 
where location like 'india'
group by location,population

--SHOWING COUNTIRES WITH HIGHEST DEATH COUNT PER POPULATION
select location,date,max(total_deaths) as totaldeathcount
from portfolio..['covid deaths$'] 
group by location,date
order by totaldeathcount desc  


--HERE THE TYPE OF TOTAL DEATHS IS VARCHAR WE  HAVR TO CHANGE IT INT
select location, max(CAST(total_deaths as INT )) as totaldeathcount
from portfolio..['covid deaths$'] 
where continent is not null
group by location
order by totaldeathcount desc  

--BY CONTINENT 

select location, max(CAST(total_deaths as INT )) as totaldeathcount
from portfolio..['covid deaths$'] 
where continent is   null
group by location
order by totaldeathcount desc  

--GLOBAL NUMBERS
select date,SUM(new_cases) as total_newcases,sum(cast(new_deaths as int)) as totaldeaths ,sum(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage--total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from portfolio..['covid deaths$']
where continent IS NOT NULL
group by date
order by 1,2

select SUM(new_cases) as total_newcases,sum(cast(new_deaths as int)) as totaldeaths ,sum(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage--total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from portfolio..['covid deaths$']
where continent IS NOT NULL
--group by date
order by 1,2

--joining tables
select * 
from portfolio..['covid deaths$'] dea
join portfolio..['covid vaccinations$']  vac
    on dea.location=vac.location
	and dea.date=vac.date

-- looking at total population vs vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from portfolio..['covid deaths$'] dea
join portfolio..['covid vaccinations$']  vac
    on dea.location=vac.location
	and dea.date=vac.date
	where dea.continent is not null
	order by 2,3


select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from portfolio..['covid deaths$'] dea
join portfolio..['covid vaccinations$']  vac
    on dea.location=vac.location
	and dea.date=vac.date
	where dea.continent is not null 
	and vac.new_vaccinations is not null
	order by 2,3

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as total
from portfolio..['covid deaths$'] dea
join portfolio..['covid vaccinations$']  vac
    on dea.location=vac.location
	and dea.date=vac.date
	where dea.continent is not null
	order by 2,3


--USING CTE

With popvsvac( continent,location,date,population,new_vaccinations,total)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as total
from portfolio..['covid deaths$'] dea
join portfolio..['covid vaccinations$']  vac
    on dea.location=vac.location
	and dea.date=vac.date
	where dea.continent is not null
	--order by 2,3
)
select * ,(total/population)*100  AS PERCENTAGE
from popvsvac
where location like 'india'

--  using temp table 
drop table if exists #percentagevaccinations
create table #percentagevaccinations
(
continent nvarchar(333),
location nvarchar(333),
date datetime,
population numeric,
new_vaccinations numeric,
total numeric
)
insert into #percentagevaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as total
from portfolio..['covid deaths$'] dea
join portfolio..['covid vaccinations$']  vac
    on dea.location=vac.location
	and dea.date=vac.date
	where dea.continent is not null
	--order by 2,3
select * ,(total/population)*100  AS PERCENTAGE
from #percentagevaccinations
where location like 'india'


create view  totalpercentagevaccinations as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as total
from portfolio..['covid deaths$'] dea
join portfolio..['covid vaccinations$']  vac
    on dea.location=vac.location
	and dea.date=vac.date
	where dea.continent is not null
	--order by 2,3


select * from totalpercentagevaccinations

