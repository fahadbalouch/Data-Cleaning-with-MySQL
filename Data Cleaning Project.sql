select *
from layoffs;

# 1.remove duplicates
-- 2. standardize the data
--  3. null values and blank values
--   4. remove any columns
select *
from layoff_staging;

create table layoff_staging
like layoffs;


insert layoff_staging
select *
from layoffs;
-- ---------------------------------------------------------------

select *,
row_number() over(
partition by company, location, industry, total_laid_off,percentage_laid_off,
 `date`, stage,country,funds_raised_millions) as row_num
 from layoff_staging;
 
 with duplicate_cte as
 (
select *,
row_number() over(
partition by company, location, industry, total_laid_off,percentage_laid_off,
 `date`, stage,country,funds_raised_millions) as row_num
 from layoff_staging
 )

select *
from duplicate_cte
where row_num > 1;

CREATE TABLE `layoff_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


select *
from layoff_staging2
where row_num > 1;

insert into layoff_staging2
select *,
row_number() over(
partition by company, location, industry, total_laid_off,percentage_laid_off,
 `date`, stage,country,funds_raised_millions) as row_num
 from layoff_staging;

delete
from layoff_staging2
where row_num > 1;


select *
from layoff_staging2;

-- ------------------------------------------------------------------
-- standardizing the data

select company,(trim(company))
from layoff_staging2;

update layoff_staging2
set company = trim(company);


select *
from layoff_staging2
where industry like '%rypto%';

update layoff_staging2
set industry = 'Crypto'
where industry like 'Crypto%';

select distinct country
from layoff_staging2;

select distinct country, trim( trailing '.' from country)
from layoff_staging2;

update layoff_staging2
set country = trim( trailing '.' from country)
where country like 'United States%';

select `date`
from layoff_staging2;

update layoff_staging2
set date = str_to_date(`date`, '%m/%d/%Y')
;

alter table layoff_staging2
modify column `date` date;

update layoff_staging2
set industry = null
where industry like '';

select t1.industry, t2.industry
from layoff_staging2 t1
join layoff_staging2 t2
	on t1.company = t2.company
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

update layoff_staging2 t1
join layoff_staging2 t2
	on t1.company = t2.company
set t1.industry= t2.industry
where t1.industry is null
and t2.industry is not null;

select *
from layoff_staging2
where total_laid_off is null
and percentage_laid_off is null;

select *
from layoff_staging2;

delete
from layoff_staging2
where total_laid_off is null
and percentage_laid_off is null;

alter table layoff_staging2
drop column row_num;

-- ------------------------------------------------------------------------------------------------------

select max(total_laid_off), max(percentage_laid_off)
from layoff_staging2;

select *
from layoff_staging2
where percentage_laid_off = 1
order by funds_raised_millions desc
;

select company, sum(total_laid_off)
from layoff_staging2
group by company
order by 2 desc;

select min(`date`), max(`date`)
from layoff_staging2;

select country, sum(total_laid_off)
from layoff_staging2
group by country
order by 2 desc;

select year(`date`), sum(total_laid_off)
from layoff_staging2
group by year(`date`)
order by 1 desc;


select stage, sum(total_laid_off)
from layoff_staging2
group by stage
order by 2 desc;

select substring(`date`,1,7) as `month`	, sum(total_laid_off)
from layoff_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1;

with rolling_total as
(
select substring(`date`,1,7) as `month`	, sum(total_laid_off) as total_off
from layoff_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1
)
select `month`,total_off, sum(total_off) over(order by `month`) as rolling_total
from rolling_total;


















































































































































































































































































































































