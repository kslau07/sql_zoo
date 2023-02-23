-- https://sqlzoo.net/wiki/Window_LAG

-- 1. Modify the query to show data from Spain

SELECT name, DAY(whn),
 confirmed, deaths, recovered
 FROM covid
WHERE name = 'Spain'
AND MONTH(whn) = 3 AND YEAR(whn) = 2020
ORDER BY whn

-- 2. Modify the query to show confirmed for the day before.

SELECT name, 
       DAY(whn),
       confirmed,
       LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn) AS lag
FROM covid
WHERE name = 'Italy'
AND MONTH(whn) = 3 AND YEAR(whn) = 2020
ORDER BY whn

-- 3. Show the number of new cases for each day, for Italy, for March.

SELECT name,
       DAY(whn),
       confirmed - LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn) as new       
FROM covid
WHERE name = 'Italy'
AND MONTH(whn) = 3
AND YEAR(whn) = 2020
ORDER BY whn;

-- 4. Show the number of new cases in Italy for each week in 2020 - show Monday only.

SELECT name,
       DATE_FORMAT(whn,'%Y-%m-%d'),
       confirmed - LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn) as new       
FROM covid
WHERE name = 'Italy'
AND WEEKDAY(whn) = 0 
AND YEAR(whn) = 2020
ORDER BY whn

-- 5. Show the number of new cases in Italy for each week - show Monday only.

-- Note that this is a self-join.

SELECT tw.name,
       DATE_FORMAT(tw.whn,'%Y-%m-%d'), 
       tw.confirmed,
       lw.confirmed
FROM covid tw LEFT JOIN covid lw ON 
DATE_ADD(lw.whn, INTERVAL 1 WEEK) = tw.whn
AND tw.name=lw.name
WHERE tw.name = 'Italy'
ORDER BY tw.whn;

-- 6. Include the ranking for the number of deaths in the table.

SELECT 
      name,
      confirmed,
      RANK() OVER (ORDER BY confirmed DESC) rc,
      deaths,
      RANK() OVER (ORDER BY deaths DESC) rd
FROM covid
WHERE whn = '2020-04-20'
ORDER BY confirmed DESC

-- 7. Show the infect rate ranking for each country. Only include countries with a population of at least 10 million.

-- Rank infection rate per country
-- Countries with pop > 10MM
SELECT
   world.name,
   ROUND(100000*confirmed/population,0) AS i_rate,
   RANK() OVER (ORDER BY (confirmed/population*100000) DESC) AS ir_rank
  FROM covid JOIN world ON covid.name=world.name
WHERE 
-- whn = '2020-04-20'
population > 10000000
ORDER BY ir_rank

SELECT 
   world.name,
   ROUND(100000*confirmed/population,0) AS i_rate,
   RANK() OVER (ORDER BY (confirmed/population*100000) DESC) AS i_rank
   
  FROM covid JOIN world ON covid.name=world.name
-- WHERE whn = '2020-04-20' AND population > 10000000
WHERE population > 10000000
ORDER BY population DESC

-- 8. For each country that has had at last 1000 new cases in a single day, show the date of the peak number of new cases.

-- First, get a list of countries that have had at least 1000 cases in a single day
-- For this, we'll use ('Luxembourg', 'Italy')
-- Only Italy should be returned, Luxembourg does not have enough cases
-- Try to get the date in which the 1000 cases happened

-- WHERE name IN ('Luxembourg', 'Italy')

-- Perhaps try selecting the date in one FROM statement
-- And selecting the MAX from another FROM statement

-- Below code works, but is not what we really want.
SELECT
      name,
      DATE_FORMAT(whn, '%Y-%m-%d') AS date,
      confirmed
FROM covid y
WHERE name IN ('Luxembourg')
AND MONTH(whn) = 3
AND YEAR(whn) = 2020
AND confirmed >= ALL ( SELECT confirmed
                         FROM covid x
                         WHERE name = 'Luxembourg'
                         AND MONTH(whn) = 3
                         AND YEAR(whn) = 2020
                        )


SELECT name,
       new_cases

FROM (
      SELECT name,
            DATE_FORMAT(whn, '%Y-%m-%d') AS date,
            confirmed - LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn) AS new_cases
      FROM covid
  
      WHERE name IN ('Luxembourg')
      AND MONTH(whn) = 3
  
      ORDER BY date
      ) AS t1

WHERE new_cases >= (SELECT new_cases
                    FROM t1
                  )


---

SELECT name,
       new_cases

FROM 
      (
      SELECT name,
             DATE_FORMAT(whn, '%Y-%m-%d') AS date,
             confirmed - LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn) AS new_cases
      FROM covid x
      WHERE name IN ('Luxembourg')
--      AND MONTH(whn) = 3
--      AND YEAR(whn) = 2020
      ORDER BY date
      ) AS t1

WHERE new_cases >= ALL
      (
      SELECT 
            CASE
                  WHEN confirmed - LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn) IS NULL THEN 0
                  ELSE confirmed - LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn)
            END
      FROM covid y
      WHERE name IN ('Luxembourg')
--      AND MONTH(whn) = 3
--      AND YEAR(whn) = 2020
      )

---

-- Now find the date of the max new_cases we found
-- We may be able to use CASE to test the new_case number.
-- We need dates next to new_cases now.

SELECT name,
       date,
       new_cases

FROM 
      (
      SELECT name,
             DATE_FORMAT(whn, '%Y-%m-%d') AS date,
             confirmed - LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn) AS new_cases
      FROM covid x
      WHERE name IN ('Luxembourg')
      AND YEAR(whn) = 2020
      ORDER BY date
      ) AS t1

WHERE new_cases >= ALL
      (
      SELECT 
            CASE
                  WHEN confirmed - LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn) IS NULL THEN 0
                  ELSE confirmed - LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn)
            END
      FROM covid y
      WHERE name IN ('Luxembourg')
      AND YEAR(whn) = 2020
      )


---

SELECT name,
       date,
       new_cases

FROM 
      (
      SELECT name,
             DATE_FORMAT(whn, '%Y-%m-%d') AS date,

            CASE
                  WHEN confirmed - LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn) IS NULL THEN 0
                  ELSE confirmed - LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn)
            END AS new_cases



      FROM covid x
      WHERE name IN ('Luxembourg')
      AND YEAR(whn) = 2020
      ORDER BY date
      ) AS t1

WHERE date = (SELECT DATE_FORMAT(whn, '%Y-%m-%d')
              FROM covid
              WHERE new_cases >= ALL
                    (
                    SELECT 
                          CASE
                                WHEN confirmed - LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn) IS NULL THEN 0
                                ELSE confirmed - LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn)
                          END
                    FROM covid y
                    WHERE name IN ('Luxembourg')
                    AND YEAR(whn) = 2020
                    )
              )

---

SELECT name,
       DATE_FORMAT(whn, '%Y-%m-%d') AS date,

FROM covid
WHERE name = 'Luxembourg'
AND YEAR(whn) = 2020

AND date = (SELECT DATE_FORMAT(whn, '%Y-%m-%d')
              FROM covid
              WHERE new_cases >= ALL
                    (
                    SELECT 
                          CASE
                                WHEN confirmed - LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn) IS NULL THEN 0
                                ELSE confirmed - LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn)
                          END
                    FROM covid
                    WHERE name IN ('Luxembourg')
                    AND YEAR(whn) = 2020
                    )
              )

---

SELECT name,
       date
FROM 
      (
      SELECT name,
             DATE_FORMAT(whn, '%Y-%m-%d') AS date,

            CASE
                  WHEN confirmed - LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn) IS NULL THEN 0
                  ELSE confirmed - LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn)
            END AS new_cases


      FROM covid x
      WHERE name IN ('Luxembourg')
      AND YEAR(whn) = 2020
      ORDER BY date
      ) AS t1

WHERE date = (SELECT DATE_FORMAT(whn, '%Y-%m-%d')
              FROM covid
              WHERE new_cases >= ALL
                    (
                    SELECT 
                          CASE
                                WHEN confirmed - LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn) IS NULL THEN 0
                                ELSE confirmed - LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn)
                          END
                    FROM covid
                    WHERE name IN ('Luxembourg')
                    AND YEAR(whn) = 2020
                    )
              )

---
-- This piece of code works, we just need the date!!

SELECT name,
       date,
       new_cases
       
FROM 
      (
      SELECT name,
             DATE_FORMAT(whn, '%Y-%m-%d') AS date,

            CASE
                  WHEN confirmed - LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn) IS NULL THEN 0
                  ELSE confirmed - LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn)
            END AS new_cases


      FROM covid x
      WHERE name IN ('Luxembourg')
      AND YEAR(whn) = 2020
      ORDER BY date
      ) AS t1


WHERE date = '2020-04-04'

--

SELECT name,
       date,
       new_cases
       
FROM 
      (
      SELECT name,
             DATE_FORMAT(whn, '%Y-%m-%d') AS date,

            CASE
                  WHEN confirmed - LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn) IS NULL THEN 0
                  ELSE confirmed - LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn)
            END AS new_cases


      FROM covid x
      WHERE name = 'Luxembourg'
      AND YEAR(whn) = 2020
      ORDER BY date
      ) AS t1

WHERE name = 'Luxembourg'
AND date LIKE '2020%'
-- GROUP BY name, date
-- HAVING date = MAX(new_cases)
-- Follow this thread, we just need HAVING date = [code that finds date for max new_cases]