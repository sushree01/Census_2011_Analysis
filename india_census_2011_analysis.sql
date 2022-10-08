drop database if exists india_census;

create database india_census;

use india_census;

describe dataset_1;

describe dataset_2;

select * from dataset_2;

# count number of rows in our dataset

select count(*) from dataset_1;
select count(*) from dataset_2;

#describe data for jharkhand and bihar
select * from dataset_2;
select * from dataset_1 where state in ('jharkhand','bihar');
select* from dataset_2 where state in ('jharkhand','bihar');

#we have used inner join to provide an overall data for the two states

select d1.state,d1.district,d2.area_km2,d2.population,d1.growth,d1.sex_ratio,d1.literacy 
from dataset_1 d1
inner join dataset_2 d2
on d1.state=d2.state
where d1.state in ('jharkhand','bihar');

#Analysis based on Population
#calculate total population of India

select sum(population) as 'total population of India' from dataset_2;

#calculate state wise total population

select state,sum(population) as 'state_wise_population' from dataset_2
group by state
order by state_wise_population desc;

#calculate avg.population growth of India

select round(avg(growth),2) as 'average growth' from dataset_1;

#calculate state wise avg.population growth 

select state,round(avg(growth),2) as 'statewise_average_growth' from dataset_1
group by state
order by statewise_average_growth desc;

#find top 5 states as per average growth ratio

select state,round(avg(growth),2) as 'statewise_average_growth' from dataset_1
group by state
order by statewise_average_growth desc
limit 5;

#find bottom 5 states as per average growth ratio

select state,round(avg(growth),2) as 'statewise_average_growth' from dataset_1
group by state
order by statewise_average_growth desc
limit 30,5;

#population in previous census

select sum(s.previous_census_population) as'previous_census_population',
sum(s.current_census_population) as 'current_census_population' from
(select a.state,round(sum(a.previous_census_population),2) as'previous_census_population',
sum(a.current_census_population) as 'current_census_population' from
(select b.district,b.state,round((b.population/(1+b.growth)),2) as previous_census_population,
b.population as current_census_population from
(select d1.district,d1.state,d1.growth as 'growth',d2.population from dataset_1 d1
inner join dataset_2 d2
on d1.district=d2.district)b)a
group by a.state)s;

#since the population growth is projected at 0.97% in 2020,we can predict the total population
#of India in 2020.

select sum(population) as 'total population of India',
round(sum(population)+((sum(population)*0.97)/100),2) as 'total predicted population of India in 2020' from dataset_2;

#find out top 5 densely populated states of India

select state, round((population/area_km2),2) as 'population_density'
from dataset_2
where state not like '#%'
group by state
order by population_density desc
limit 5;

#find out bottom 5 densely populated states of India

select state, round((population/area_km2),2) as 'population_density'
from dataset_2
group by state
order by population_density desc
limit 30,5;

#find top 3 districts from each state based on population density

#find out top 5 densely populated states of India

select a. * from
(select state,district, round((population/area_km2),2) as 'population_density',rank()
over(partition by state order by (round((population/area_km2),2)) desc) as ranks from dataset_2)a
where a.ranks in (1,2,3) and state not like'#%'
order by state;

#Analysis based on sex ratio

#average sex ratio of India
select round(avg(sex_ratio),2) as 'Average_Sex_Ratio' from dataset_1;

#state wise average sex ratio
select state,round(avg(sex_ratio),2) as 'state_wise_avg_sex_ratio' from dataset_1
group by state
order by state_wise_avg_sex_ratio desc;

# top 5 states with highest avg.sex ratio

select state,round(avg(sex_ratio),2) as 'state_wise_avg_sex_ratio' from dataset_1
group by state
order by state_wise_avg_sex_ratio desc
limit 5;

#bottom 5 states with lowest avg sex ratio

select state,round(avg(sex_ratio),2) as 'state_wise_avg_sex_ratio' from dataset_1
group by state
order by state_wise_avg_sex_ratio desc
limit 30,5;

#total number of males and females and their difference (state-wise)

select a.state,sum(a.males) as 'total_males',sum(a.females) as 'total_females',
(sum(a.males)-sum(a.females)) as'difference_between_males_and_females'from
(select b.district,b.state,round(b.population/(b.sex_ratio+1),2) as males,
 round((b.sex_ratio*(b.population/(b.sex_ratio+1))),2) as females from
(select d1.district,d1.state,(d1.sex_ratio)/1000 as 'sex_ratio',d2.population from dataset_1 d1
inner join dataset_2 d2
on d1.district=d2.district)b)a
group by a.state;


#analysis based on literacy rate

#average literacy rate of India

select round(avg(literacy),2) as 'average_literacy' from dataset_1;

#statewise average literacy rate

select state, round(avg(literacy),2) as 'statewise_average_literacy' from dataset_1
group by state
order by statewise_average_literacy desc;

#top 5 states based on literacy rate

select state, round(avg(literacy),2) as 'statewise_average_literacy' from dataset_1
group by state
order by statewise_average_literacy desc
limit 5;

#bottom 5 states based on literacy rate

select state, round(avg(literacy),2) as 'statewise_average_literacy' from dataset_1
group by state
order by statewise_average_literacy desc
limit 30,5;

#calculate literate and illiterate of India(state-wise)

select a.state,round(sum(Literate_People),2) as 'Total_Literates',
round(sum(Illiterate_People),2) as 'Total_Illiterates' from
(select b.district,b.state,round((b.literacy_rate*b.population),2) as Literate_People,
round(((1-b.literacy_rate)*b.population),2) as Illiterate_People from
(select d1.district,d1.state,(d1.literacy/100) as'literacy_rate',d2.population from dataset_1 d1
inner join dataset_2 d2
on d1.district=d2.district)b)a
group by a.state;
#order by Total_Illiterates desc;

#to calculate top 3 districts from each state based on literacy rate

select a.* from
(select state,district,literacy,rank() over(partition by state order by literacy desc) as ranks
from dataset_1)a
where a.ranks in (1,2,3)
order by state;

