-- https://sqlzoo.net/wiki/Window_functions

-- Note that this particular page is basically down as none of the answers can
-- be submitted except for question #1. I have tried to work out the answers
-- for all questions using the answer box in question #1.

-- 1. Show the lastName, party and votes for the constituency 'S14000024' in 2017.

SELECT lastName,
       party,
       votes
FROM ge
WHERE constituency = 'E14000539'
  AND yr = 2017
ORDER BY votes DESC 

-- 2. Show the party and RANK for constituency S14000024 in 2017. List the output by party

SELECT party,
       votes,
       RANK() OVER (
                    ORDER BY votes DESC) AS posn
FROM ge
WHERE constituency = 'S14000024'
  AND yr = 2017
ORDER BY party;

-- 3. Use PARTITION to show the ranking of each party in S14000021 in each year. Include yr, party, votes and ranking (the party with the most votes is 1).

SELECT yr,
       party,
       votes,
       RANK() OVER (PARTITION BY yr
                    ORDER BY votes DESC) AS posn
FROM ge
WHERE constituency = 'S14000021'
ORDER BY yr,
         posn

-- 4. Use PARTITION BY constituency to show the ranking of each party in Edinburgh in 2017. Order your results so the winners are shown first, then ordered by constituency.

SELECT yr,
       constituency,
       party,
       votes,
       RANK() OVER (PARTITION BY constituency
                    ORDER BY votes DESC) AS posn
FROM ge
WHERE constituency BETWEEN 'S14000021' AND 'S14000026'
  AND yr = 2017
ORDER BY posn,
         constituency

-- 5. Show the parties that won for each Edinburgh constituency in 2017.

-- This is a derived table and T1 can be a name of any choosing.

SELECT constituency,
       party
FROM
  (SELECT constituency,
          party,
          RANK() OVER (PARTITION BY constituency
                       ORDER BY votes DESC) AS posn
   FROM ge
   WHERE constituency BETWEEN 'S14000021' AND 'S14000026'
     AND yr = 2017 ) AS T1
WHERE posn = 1;

-- 6. Show how many seats for each party in Scotland in 2017.

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

SELECT world.name,
       ROUND(100000*confirmed/population, 0) i_rate,
       RANK() OVER (
                    ORDER BY (confirmed/population)) AS i_rank
FROM covid
JOIN world ON covid.name=world.name
WHERE whn = '2020-04-20'
  AND population >= 10000000
ORDER BY population DESC;
