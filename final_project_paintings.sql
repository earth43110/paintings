--What museums have the highest proportion of cubist paintings? What other styles of art do these museums typically display? 
select * from
(
select a.name museum_name
	,round(avg(case when style='Cubism' then 1 else 0 end),2) proportion_of_cubist_paintings
from museum a
inner join work b on a.museum_id=b.museum_id
group by 1
order by 2 desc
)
where proportion_of_cubist_paintings > 0;

select * 
from
(
select distinct b.style
from museum a
inner join work b on a.museum_id=b.museum_id
where a.museum_id in (61,30,62,34,56,68,67,50,35,60)
) 
where style is not null;


--Which artists have their work displayed in museums in many different countries? 
select c.full_name
	,count(distinct(a.country)) country_count
	,count(b.work_id) work_count
from museum a
inner join work b on a.museum_id=b.museum_id
inner join artist c on b.artist_id=c.artist_id
group by 1
having count(distinct(a.country)) > 4
order by 2 desc;


/*
Create a table that shows the most frequently painted subject for each style of painting, 
how many paintings there were for the most frequently painted subject in that style, 
how many paintings there are in that style overall, and the percent of paintings in that 
style with the most frequent subject. Exclude cases where there is no 
information on the subject of the painting. Format the table and copy it into the google doc. 
*/
create table a as
(
select 
	work.style,
	subject.subject,
	count(work.work_id) as no_paintings_subject,
	rank() over(partition by work.style order by count(subject.subject) desc) as rank
from subject
join work on subject.work_id = work.work_id
group by 1,2
);

create table b as (
select *
from
(
select 
	style,
	count(work_id) as no_paintings_style,
from work
where style is not null
group by 1
)
);

select 
	a.style,
	a.subject,
	a.no_paintings_subject,
	b.no_paintings_style,
	round(a.no_paintings_subject::numeric / b.no_paintings_style, 2) as percent_paintings
from a 
join b on a.style = b.style
where rank = 1 and a.style is not null and a.subject is not null;

