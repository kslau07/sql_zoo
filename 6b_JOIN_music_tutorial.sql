-- https://sqlzoo.net/wiki/Music_Tutorial

-- 1. Find the title and artist who recorded the song 'Alison'.

SELECT title,
       artist
FROM album
JOIN track ON (album.asin=track.album)
WHERE song = 'Alison'

-- 2. Which artist recorded the song 'Exodus'?

  SELECT artist
  FROM album
  JOIN track ON (album.asin = track.album) WHERE song = 'Exodus';

-- 3. Show the song for each track on the album 'Blur'

SELECT song
FROM album
JOIN track ON (album.asin = track.album)
WHERE album.title = 'Blur';

-- 4. For each album show the title and the total number of track.

SELECT title,
       COUNT(*)
FROM album
JOIN track ON (asin=album)
GROUP BY title

-- 5. For each album show the title and the total number of tracks containing the word 'Heart' (albums with no such tracks need not be shown).

SELECT title,
       COUNT(song)
FROM album
JOIN track ON (album.asin = track.album)
WHERE song LIKE '%heart%'
GROUP BY title;

-- 6. A "title track" is where the song is the same as the title. Find the title tracks.

SELECT track.song
FROM album
JOIN track ON (album.asin = track.album)
WHERE album.title = track.song;

-- 7. An "eponymous" album is one where the title is the same as the artist (for example the album 'Blur' by the band 'Blur'). Show the eponymous albums.

SELECT title
FROM album
WHERE artist = title

-- 8. Find the songs that appear on more than 2 albums. Include a count of the number of times each shows up.

  SELECT song,
         COUNT(song)
  FROM album
  JOIN track ON (album.asin = track.album) WHERE song <> ''
GROUP BY song
HAVING COUNT(song) > 2
AND COUNT(DISTINCT title) > 2;

-- 9. A "good value" album is one where the price per track is less than 50 pence. Find the good value album - show the title, the price and the number of tracks.

SELECT title,
       price,
       COUNT(song)
FROM album
JOIN track ON (album.asin = track.album)
WHERE price IS NOT NULL
GROUP BY title,
         price
HAVING price/COUNT(song) < 0.50

-- 10. Wagner's Ring cycle has an imposing 173 tracks, Bing Crosby clocks up 101 tracks.

-- List albums so that the album with the most tracks is first. Show the title and the number of tracks

-- Where two or more albums have the same number of tracks you should order alphabetically

SELECT title,
       COUNT(song)
FROM album
JOIN track ON (album.asin = track.album)
GROUP BY title
ORDER BY COUNT(song) DESC, title ASC