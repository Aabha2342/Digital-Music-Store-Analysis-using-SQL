
'''SELECT * FROM employee
ORDER BY levels desc
limit 1'''



'''select COUNT(*) as c, billing_country
from invoice
group by billing_country
order by c desc'''

'''What arebthe top 3 values of total invoice?
SELECT total FROM invoice
order by total desc
limit 3'''

'''Q4.Which city has the best customers and returns the highest total based on billing city? 
select SUM(total) as invoice_total, billing_city
from invoice
group by billing_city
order by invoice_total desc'''
'''Who is the best customer?Customer who has spend most money will be regarded as best customer?
SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
select customer.customer_id, customer.first_name, customer.last_name, SUM(invoice.total) as total
from customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id 
ORDER BY total DESC
limit 1'''


 '''Q: WRITE A QUERY TO RETURN THE EMAIL,FIRST NAME.LAST NAME AND GENRE OF ALL ROCK MUSIC LISTENERS.RETURN YOUR LIST ORDERED ALPHABETICALLY BY EMAIL STARTING WITH A
SELECT DISTINCT email, first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id                     JOINING CUSTOMER TABLE TO INVOICE TABLE USING CUSTOMER ID     
JOIN  invoice_line ON invoice.invoice_id = invoice_line.invoice_id             JOINING INVOICE TABLE TO INVOICE_LINE TABLE USING INVOICE ID     
WHERE track_id IN(                                                              FINDING TRACK ID HAVING GENRE AS ROCK  
    SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
    WHERE genre.name LIKE 'ROCK'
)
ORDER BY email;                                                         SORTING ALPHABETICALLY THE EMAIL   
                              OR
SELECT DISTINCT email AS Email,first_name AS FirstName, Last_name AS LastName, genre.name AS Name
FROM customer
JOIN invoice ON invoice.customer_id = customer.customer_id
JOIN invoice_line ON invoice_line.invoice_id = invoice.invoice_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY email;'''

'''SELECT artist.artist_id, artist.name, COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album2 ON album2.album_id = track.album_id                  WE HAVE JOINED FOUR TABLES HERE FROM TRACK TABLE
JOIN artist ON artist.artist_id = album2.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'RocK'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;'''

'''Q3: RETURN ALL THETRACK NAMES THAT HAVE A SONG LENGTH LONGER THAN THE AVERAGE SONG LENGTH.RETURN THE NAME AND MILLISECINDS FOR EACH TRACK.ORDER BY THE SONG LENGTH SONGS LISTED FIRST.
STEP 1:FINDING AVERAGE SONG LENGTH
SELECT name, milliseconds
FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) as avg_track_length
    FROM track)
ORDER BY milliseconds DESC;'''


                                            '''ADVANVCE LEVEL PROBLEMS'''
'''WITH best_selling_artist AS (
    SELECT artist.artist_id AS artist_id, artist.name AS artist_name,
	SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales
    FROM invoice_line
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN album ON album.album_id = track.album_id
    JOIN artist ON artist.artist_id = album.artist_id
    GROUP BY 1
	ORDER BY 3 DESC
    LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, 
SUM(il.unit_price.il*il.quantity) AS amount_spent
FROM invoice
JOIN customer c ON c.customer+id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;'''

                            '''ADVANCE PROBLEMS'''



'''WITH popular_genre AS
(
    SELECT 
        COUNT(invoice_line.quantity) AS purchases, 
        customer.country, 
        genre.name, 
        genre.genre_id,
        ROW_NUMBER() OVER (PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo
    FROM invoice_line
    JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
    JOIN customer ON customer.customer_id = invoice.customer_id
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN genre ON genre.genre_id = track.genre_id
    GROUP BY customer.country, genre.name, genre.genre_id
    ORDER BY customer.country ASC, purchases DESC
)
SELECT * FROM popular_genre WHERE RowNo = 1'''

'''Q3: WRITE A QUERY THAT DETERMINES THE CUSTOMER THAT HAS SPENT THE MOST ON MUSIC FOR EACH COUNTRY.
	WRITE A QUERY THAT RETURNS THE COUNTRY ALONG WITH THE TOP CUSTOMERS AND HOW MUCH THEY SPENT.
    FOR COUNTRIES WHERE THE TOP AMOUNT SPENT IS SHARED PROVIDE ALL THE CUSTOMERS WHO SPENT THIS AMOUNT.
WITH RECURSIVE
      customer_with_country AS (
          SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending
          FROM invoice
          JOIN customer ON customer.customer_id = invoice.customer_id     JOINING CUSTOMER TABLE AND INVOICE TABLE
          GROUP BY 1,2,3,4                                                 GROUPING ON BASIS OF COLUMN 1(CUSTOMER ID),2(FIRST NAME),3(LAST NAME),4(COUNTRY)
          ORDER BY 1,5 DESC),                                               FURTHER GROUPING ON BASIS OF 1 AND 5
		
	 country_max_spending AS(
         SELECT billing_country,MAX(total_spending) AS max_spending                 FINDING MAXIMUM SPENDING OF ONE COUNTRY FROM THE ABOVE QUERY 
         FROM customer_with_country 
         GROUP BY billing_country)

SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
FROM customer_with_country cc
JOIN country_max_spending ms
ON cc.billing_country = ms.billing_country                                     JOINING CC AND MS ON BASIS OF BILLING COUNTRY
WHERE cc.total_spending - ms.max_spending
ORDER BY 1;'''

WITH Customer_with_country AS (
        SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
        ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo
        FROM invoice
        JOIN customer ON customer.customer_id = invoice.customer_id
        GROUP BY 1,2,3,4
        ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customer_with_country WHERE RowNo <= 1        
         
          
          