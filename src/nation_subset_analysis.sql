-- 1. Show the possible values of the year column in the country_stats table sorted by most recent year first.
SELECT distinct year FROM country_stats ORDER BY year DESC;
-- 2. Show the names of the first 5 countries in the database when sorted in alphabetical order by name.
SELECT name FROM countries ORDER BY name LIMIT 5;
-- 3. Adjust the previous query to show both the country name and the gdp from 2018, but this time show the top 5 countries by gdp.
SELECT c.name, cs.gdp
FROM countries AS c
INNER JOIN country_stats AS cs
ON c.country_id = cs.country_id
WHERE cs.year = 2018
ORDER BY cs.gdp DESC
LIMIT 5;
-- 4. How many countries are associated with each region id?
SELECT r.region_id, count(*) AS country_count
FROM regions AS r
INNER JOIN countries AS c
ON r.region_id = c.region_id
GROUP BY r.region_id
ORDER BY country_count DESC;
-- 5. What is the average area of countries in each region id?
SELECT region_id, ROUND(AVG(area)) AS avg_area
FROM countries
GROUP BY region_id
ORDER BY avg_area;
-- 6. Use the same query as above, but only show the groups with an average country area less than 1000.
SELECT region_id, ROUND(AVG(area)) AS avg_area
FROM countries
GROUP BY region_id
HAVING ROUND(AVG(area)) < 1000
ORDER BY avg_area;
-- 7. Create a report displaying the name and population of every continent in the database from the year 2018 in millions.
SELECT c.name, ROUND(SUM(cs.population)/1000000.0,2) AS tot_pop
FROM continents AS c
INNER JOIN regions AS r
ON c.continent_id = r.continent_id 
INNER JOIN countries AS ct
ON r.region_id = ct.region_id
INNER JOIN country_stats as cs
ON ct.country_id = cs.country_id
WHERE cs.year = 2018
GROUP BY c.name
ORDER BY tot_pop DESC;
-- 8. List the names of all of the countries that do not have a language.
SELECT c.name
FROM countries AS c
LEFT JOIN country_languages AS cl
On c.country_id = cl.country_id
LEFT JOIN languages AS l
ON cl.language_id = l.language_id
WHERE l.language is NULL;
-- 9. Show the country name and number of associated languages of the top 10 countries with most languages.
SELECT c.name, COUNT(*) AS lang_count
FROM countries AS c
INNER JOIN country_languages AS cl
ON c.country_id = cl.country_id
GROUP BY c.name
ORDER BY lang_count DESC
LIMIT 10;
-- 10. Repeat your previous query, but display a comma separated list of spoken languages rather than a count.
SELECT c.name, STRING_AGG(l.language, ',') AS string_agg
FROM countries AS c
INNER JOIN country_languages AS cl
ON c.country_id = cl.country_id
INNER JOIN languages AS l
ON cl.language_id = l.language_id
GROUP BY c.name
ORDER BY COUNT(*) DESC
LIMIT 10;
-- 11. What's the average number of languages in every country in a region in the dataset?
WITH country_lang_count(c_name, l_count, region_id) AS
(
    SELECT c.name, COUNT(*), MAX(c.region_id)
    FROM countries AS c
    LEFT JOIN country_languages AS cl
    ON c.country_id = cl.country_id
    GROUP BY c.name
)
SELECT r.name, ROUND(AVG(calc.l_count),1) AS avg_lang_count_per_country
FROM country_lang_count AS calc
LEFT JOIN regions AS r
ON r.region_id = calc.region_id
GROUP BY r.name
ORDER BY ROUND(AVG(calc.l_count),1) DESC; 
-- 12. Show the country name and its "national day" for the country with the most recent national day 
-- and the country with the oldest national day. Do this with a single query.
SELECT name, national_day 
FROM countries 
WHERE national_day = (
    SELECT MIN(national_day) FROM countries
) 
UNION ALL 
SELECT name, national_day 
FROM countries 
WHERE national_day = (
    SELECT MAX(national_day) FROM countries
)
ORDER BY national_day DESC;
