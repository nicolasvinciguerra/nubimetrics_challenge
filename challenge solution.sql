CREATE TABLE TEMP_TABLE AS
SELECT PL.id
FROM phone_sales.phones_listing PL
LEFT JOIN phone_sales.phones_brands PB ON upper(PL.title) LIKE concat('% ',upper(PB.name),' %') #la marca esta 'suelta' en el texto
									   OR SUBSTRING_INDEX(upper(PL.title),' ',1) LIKE upper(PB.name) #cuando empieza con la marca
									   OR upper(PL.title) LIKE concat('% ',upper(PB.synonym),' %') #cuando el sinonimo esta 'suelto' en el texto
                                       OR SUBSTRING_INDEX(upper(PL.title),' ',1) LIKE upper(PB.synonym) #cuando empieza con el sinonimo
GROUP BY PL.id
HAVING COUNT(PL.id) > 1
;

CREATE TABLE listing_brand AS
SELECT DISTINCT PL.*,
				CASE
					WHEN PB.NAME IS NULL THEN 'OTROS'
					WHEN PL.ID IN (SELECT id FROM TEMP_TABLE) THEN 'MULTIMARCA'
					ELSE PB.name
				END BRAND
FROM phone_sales.phones_listing PL
LEFT JOIN phone_sales.phones_brands PB ON upper(PL.title) LIKE concat('% ',upper(PB.name),' %') #la marca esta 'suelta' en el texto
									   OR SUBSTRING_INDEX(upper(PL.title),' ',1) LIKE upper(PB.name) #cuando empieza con la marca
									   OR upper(PL.title) LIKE concat('% ',upper(PB.synonym),' %') #cuando el sinonimo esta 'suelto' en el texto
                                       OR SUBSTRING_INDEX(upper(PL.title),' ',1) LIKE upper(PB.synonym) #cuando empieza con el sinonimo
;

SELECT 	A.BRAND,                                      
		SUM(A.sales) TOTAL_SALES,
		SUM(A.unit_sales) TOTAL_UNIT_SALES,
		COUNT(1) TOTAL_LISTINGS
FROM listing_brand A
GROUP BY A.BRAND
;