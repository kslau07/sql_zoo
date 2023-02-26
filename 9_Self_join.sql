-- https://sqlzoo.net/wiki/Self_join

-- 1. How many stops are in the database.

SELECT COUNT(*)
FROM stops;

-- 2. Find the id value for the stop 'Craiglockhart'

SELECT id
FROM stops
WHERE name = 'Craiglockhart';

-- 3. Give the id and the name for the stops on the '4' 'LRT' service.

SELECT stops.id,
       stops.name
FROM stops
JOIN route ON stops.id = route.stop
WHERE route.num = 4
  AND route.company = 'LRT'
ORDER BY pos;

-- 4. The query shown gives the number of routes that visit either London Road (149) or Craiglockhart (53). Run the query and notice the two services that link these stops have a count of 2. Add a HAVING clause to restrict the output to these two routes.

SELECT company,
       num,
       COUNT(*)
FROM route
WHERE STOP=149
  OR STOP=53
GROUP BY company,
         num
HAVING COUNT(*) = 2;

-- 5. Execute the self join shown and observe that b.stop gives all the places you can get to from Craiglockhart, without changing routes. Change the query so that it shows the services from Craiglockhart to London Road.

SELECT a.company,
       a.num,
       a.stop,
       b.stop
FROM route a
JOIN route b ON (a.company=b.company
                 AND a.num=b.num)
JOIN stops astop ON a.stop = astop.id
JOIN stops bstop ON b.stop = bstop.id
WHERE astop.name = 'Craiglockhart'
  AND bstop.name = 'London Road'
  
-- 6. The query shown is similar to the previous one, however by joining two copies of the stops table we can refer to stops by name rather than by number. Change the query so that the services between 'Craiglockhart' and 'London Road' are shown. If you are tired of these places try 'Fairmilehead' against 'Tollcross'

SELECT ra.company,
		ra.num,
		sa.name,
		sb.name
FROM route ra
JOIN route rb ON ra.num=rb.num
AND ra.company=rb.company
JOIN stops sa ON ra.stop = sa.id
JOIN stops sb ON rb.stop = sb.id WHERE sa.name = 'Craiglockhart'
AND sb.name = 'London Road' 

-- 7. Give a list of all the services which connect stops 115 and 137 ('Haymarket' and 'Leith')

SELECT DISTINCT ra.company,
				ra.num
FROM route ra
JOIN route rb ON ra.num=rb.num
AND ra.company=rb.company
JOIN stops sa ON ra.stop = sa.id
JOIN stops sb ON rb.stop = sb.id WHERE sa.id=115
AND sb.id=137;

-- 8. Give a list of the services which connect the stops 'Craiglockhart' and 'Tollcross'

SELECT rb.company,
       rb.num
FROM route ra
JOIN route rb ON ra.num=rb.num
AND ra.company=rb.company
JOIN stops sa ON ra.stop = sa.id
JOIN stops sb ON rb.stop = sb.id
WHERE sa.name = 'Craiglockhart'
  AND sb.name = 'Tollcross'
  
-- 9. Give a distinct list of the stops which may be reached from 'Craiglockhart' by taking one bus, including 'Craiglockhart' itself, offered by the LRT company. Include the company and bus no. of the relevant services.

SELECT sb.name,
		ra.company,
		ra.num
FROM route ra
JOIN route rb ON ra.company=rb.company
AND ra.num=rb.num
JOIN stops sa ON ra.stop=sa.id
JOIN stops sb ON rb.stop=sb.id WHERE ra.company='LRT'
AND sa.name='Craiglockhart'
  
-- 10. Find the routes involving two buses that can go from Craiglockhart to Lochend.

SELECT DISTINCT route1_board.num,
				route1_board.company,
				stop1_exit.name,
				route2_board.num,
				route2_board.company
FROM route route1_board
JOIN route route1_exit ON route1_board.num=route1_exit.num
AND route1_board.company=route1_exit.company
JOIN stops stop1_board ON route1_board.stop=stop1_board.id
JOIN stops stop1_exit ON route1_exit.stop=stop1_exit.id
JOIN route route2_board ON route2_board.stop = route1_exit.stop
JOIN route route2_exit ON route2_board.num = route2_exit.num
AND route2_board.company = route2_exit.company
JOIN stops stop2_board ON route2_board.stop=stop2_board.id
JOIN stops stop2_exit ON route2_exit.stop=stop2_exit.id WHERE stop1_board.name = 'Craiglockhart'
AND stop2_exit.name = 'Lochend'
ORDER BY route1_board.num,
		route1_exit.stop,
		route2_board.num