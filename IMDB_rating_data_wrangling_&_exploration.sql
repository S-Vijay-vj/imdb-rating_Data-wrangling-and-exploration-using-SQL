-------------------------------------------------------------------------
------------------------------Data cleaning-----------------------------

-- cleaning year column consist of data like (2018-2020 ,  2022– , III 2022)
-- removing roman numbers from year column
update imdb 
SET year = regexp_replace(year,'[IVXLCDM]+','')
WHERE year not like '%-%'

-- removing non-numerical data from year
update imdb 
SET year = regexp_replace(year,'[^0-9]','')

-- extracting first 4 strings
update imdb 
SET year = substring(year,1,4)

-- replace '' in year with 0 (assume 0 ='not specified')
update imdb 
SET year = case when year = '' then '0'  else year end 

-- alter datatype of year as int
alter table imdb 
ALTER COLUMN year TYPE INT USING year::integer

------------------------------------------------------------------

-- cleaning rating column consist of null data
-- set ratings is 0 where null 
update imdb 
SET rating  = case when rating is null then 0 else rating end

---------------------------------------------------------------------

-- cleaning votes column consist of null data and comma','
-- set votes is 0 where null 
update imdb 
set votes = case when votes = '' then '0' else votes end

-- removing non numeric datas
update imdb 
SET votes  = regexp_replace(votes,'[^0-9]','')

-- altering data type int
alter table imdb 
ALTER COLUMN votes TYPE INT USING votes::integer

------------------------------------------------------------------------

-- cleaning desc column consist of null data
-- casting 'not specified' for notnull 
update imdb 
set "desc" = case when "desc" in ('','Add a Plot') then 'Not specified' 
			 else "desc" end 

-------------------------------------------------------------------------

-- CLEANING runtime column consist of min,'null'
-- replace 'null' with '0'( assume 0 = 'Not specified)
update imdb 
set runtime = case when runtime = 'null' then '0' else runtime end

-- remove non numeric data 
update imdb 
set runtime = replace(runtime,' min','')

-- convert datatype to int 
alter table imdb 
ALTER COLUMN runtime TYPE INT USING runtime::integer 

--------------------------------------------------------------------------

-- standardizing data in certificate column
update imdb 
set certificate = case when certificate in ('UA','U/A','U/A 16+','UA 13+','UA 16+','UA 7+') then 'UA'
					   when certificate in ('Unrated','Not Rated') then 'Not Rated'
					   when certificate in ('PG','PG-13') then 'PG'
					   when certificate in ('13','13+') then '13+'
					   when certificate in ('15','15+') then '15+'
					   when certificate in ('16','16+') then '16+'
					   when certificate in ('18','18+','A') then 'A'
					   when certificate in ('7','7+') then '7'
					   when certificate = 'null' then 'Not Specified'
					   else certificate 
				  end
				  
--------------------------------------------------------------------------
-- CLEANING GENRE COLUMN CONSIST 'null'
update imdb 
set genre  = case when genre = 'null' then 'Not specified' else genre  end	

--- Trimming unwanted spaces on the right side
update imdb 
set genre  = rtrim(genre) 


----------------------------------------------------------------------------
--- Creating a column - Weighted average 
select (votes / (votes + 25000.0)) * rating + (25000 / (votes + 25000.0)) * (select  AVG(rating) FROM imdb)  AS Weighted_rating 
FROM imdb
order by weighted_rating desc ;

ALTER TABLE imdb  ADD COLUMN weighted_rating FLOAT;

update imdb 
set weighted_rating = (votes / (votes + 25000.0)) * rating + (25000 / (votes + 25000.0)) * (select  AVG(rating) FROM imdb)


				  
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
------------------------------------ DATA EXPLORATION ----------------------------------------------
				  
--- GETTING TOP 10 MOVIES AND SHOWS BY RATING ALONE.
select * from imdb
order by rating desc
limit 10;

--- GETTING TOP 10 MOVIES AND SHOWS BY VOTES ALONE.
select * from imdb
order by votes desc
limit 10;

--- GETTING TOP 10 MOVIES AND SHOWS BY WEIGHTED rating 
select * from imdb 
order by weighted_rating desc
limit 10;

--- GETTING DISTINCT GENRES
select distinct genre 
from imdb

--- GETTING POPOULAR GENRES
select genre, count(genre) as movies_per_genre from imdb
group by genre
order by movies_per_genre desc 
limit 10;

--- GETTING TOP RATED DRAMA MOVIES AND SHOWS
select * from imdb  
where genre like 'Drama'
order by weighted_rating desc
limit 10;

--- GETTING TOP RATED DRAMA MOVIES AND SHOWS IN YEAR 2022
select * from imdb  
where genre like 'Drama' and year = 2022
order by weighted_rating desc
limit 10;

--- GETTING TOP RATED 'COMEDY' MOVIES AND SHOWS
select * from imdb  
where genre like 'Comedy'
order by weighted_rating desc
limit 10;

--- GETTING TOP RATED 'COMEDY' MOVIES AND SHOWS IN YEAR 2022
select * from imdb  
where genre like 'Comedy' and year = 2022
order by weighted_rating desc 
limit 10;


--- GETTING LIST OF ACTION MOVIES
select * from imdb  
where genre like 'Action%'

--- GETTING TOP 10 ACTION MOVIES AND SHOWS
select * from imdb  
where genre like 'Action%'
order by weighted_rating desc
limit 10;

--- GETTING TOP RATED TV SHOWS
select * from imdb i 
where genre like '%Reality-TV%'
order by weighted_rating desc
limit 10;

--- GETTING TOP RATED ANIMATION MOVIES AND SHOWS
select * from imdb i 
where genre like '%Animation%'
order by weighted_rating desc
limit 10; 

--- GETTING TOP RATED MOVIES AND SHOWS IN 2022
select * from imdb i 
where year = 2022
order by weighted_rating desc
limit 10;

--- GETTING TOP RATED MOVIES AND SHOWS IN 2023
select * from imdb i 
where year = 2023
order by weighted_rating desc
limit 10;

--- GETTING MOST HYPED MOVIES AND SHOWS GOING TO BE RELEASED IN 2024
select * from imdb i 
where year = 2024
order by weighted_rating desc
limit 10;

--- CHECKING FOR ANY MOVIES AND SHOWS TO BE RELEASED AFTER 2024 PRESENT IN THIS DATA
select * from imdb i 
where year > 2024;

--- GETTING NUMBER OF MOVIES OR SHOWS PER  YEAR
select year,COUNT(YEAR) as movies_per_year
from imdb
group by year
order by movies_per_year desc;

--- GETTING DISTINCT VALUES FROM CERTIFICATE COLUMN
select distinct certificate  as "Types of certificate"
from imdb

--- GETTING NUMBER NUMBER OF MOVIES OR SHOWS PER CERTIFICATE
select certificate ,COUNT(certificate) as movies_per_certificate
from imdb
group by certificate 
order by movies_per_certificate desc;

--- GETTING MOST RATED 'U' CERTIFICATE MOVIE AND SHOWS
select * 
from imdb 
where certificate = 'U'
order by weighted_rating desc
limit 10

--- GETTING MOST RATED 'U' CERTIFICATE MOVIE AND SHOWS OF 2022
select * 
from imdb 
where certificate = 'U' and "year" = 2022
order by weighted_rating desc
limit 10

--- GETTING MOST RATED 'UA' CERTIFICATE MOVIE AND SHOWS
select * 
from imdb 
where certificate = 'UA'
order by weighted_rating desc
limit 10

--- GETTING MOST RATED 'UA' CERTIFICATE MOVIE AND SHOWS OF 2022
select * 
from imdb 
where certificate = 'UA' and "year" = 2022
order by weighted_rating desc
limit 10
