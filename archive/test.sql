use pocu3;
select exchangeName, tradePair, min(recordTime), max(recordTime) from cTicker where ( recordTime > '2017-09-24 22:00:02' and recordTime < '2017-09-24 22:05:02'   and exchangeName != 'coinMarketCap') GROUP BY tradePair;

select exchangeName, tradePair, askPriceUSD, recordTime from cTicker where (recordTime > '2017-09-24 02:50:02' and recordTime < '2017-09-24 02:55:02'  and exchangeName != 'coinMarketCap') GROUP BY tradePair;

SELECT m1.exchangeName, m1.tradePair, m1.askPriceUSD, m1.recordTime
FROM cTicker m1 LEFT JOIN cTicker m2
 ON (m1.tradePair = m2.tradePair AND m1.recordTime < m2.recordTime)
WHERE (m2.recordTime IS NULL and m1.recordTime > '2017-09-24 02:50:02' and m1.recordTime < '2017-09-24 02:55:02'  and m1.exchangeName != 'coinMarketCap');


select exchangeName, tradePair, askPriceUSD, recordTime from cTicker where (recordTime > '2017-09-24 02:50:02' and recordTime < '2017-09-24 02:55:02'  and exchangeName = 'yoBit') GROUP BY tradePair;

SELECT m1.exchangeName, m1.tradePair, m1.askPriceUSD, m1.recordTime
FROM cTicker m1 LEFT JOIN cTicker m2
 ON (m1.tradePair = m2.tradePair AND m1.recordTime < m2.recordTime)
WHERE (m2.recordTime IS NULL and m1.recordTime > '2017-09-24 02:50:02' and m1.recordTime < '2017-09-24 02:55:02'  and m1.exchangeName = 'yoBit');



SELECT vMinMaxTime.exchangeName, vMinMaxTime.tradePair, vMinMaxTime.endTime, 
ROUND(((cTickerEndPrice.askPriceUSD - cTickerStartPrice.askPriceUSD)/ cTickerStartPrice.askPriceUSD*100), 2) as priceChangePercent
FROM (
	SELECT exchangeName, tradePair, min(recordTime) as startTime, max(recordTime) as endTime from cTicker 
    where ( recordTime > '2017-10-01 19:34:10' and recordTime < '2017-10-01 20:34:10'  and exchangeName != 'coinMarketCap') 
    GROUP BY tradePair

) vMinMaxTime
LEFT JOIN cTicker cTickerStartPrice ON (cTickerStartPrice.recordTime = vMinMaxTime.startTime 
																	AND cTickerStartPrice.exchangeName = vMinMaxTime.exchangeName
                                                                    AND cTickerStartPrice.tradePair = vMinMaxTime.tradePair)
LEFT JOIN cTicker cTickerEndPrice ON (cTickerEndPrice.recordTime = vMinMaxTime.endTime 
																	AND cTickerEndPrice.exchangeName = vMinMaxTime.exchangeName
                                                                    AND cTickerEndPrice.tradePair = vMinMaxTime.tradePair)
WHERE cTickerStartPrice.askPriceUSD > 0 AND cTickerStartPrice.askPriceUSD IS NOT NULL AND cTickerEndPrice.askPriceUSD IS NOT NULL AND
((cTickerEndPrice.askPriceUSD - cTickerStartPrice.askPriceUSD)/ cTickerStartPrice.askPriceUSD*100 > 10
OR (cTickerEndPrice.askPriceUSD - cTickerStartPrice.askPriceUSD)/ cTickerStartPrice.askPriceUSD*100 < -10)
-- AND (cTickerEndPrice.askPriceUSD - cTickerStartPrice.askPriceUSD)/ cTickerStartPrice.askPriceUSD*100 < 12000000000000
-- GROUP BY cTickerStartPrice.tradePair
ORDER BY priceChangePercent DESC;

select * from cTicker where tradePair='BTC-EGC' and  ( recordTime > '2017-10-21 19:00:00' and recordTime < '2017-10-21 20:30:00'  and exchangeName != 'coinMarketCap') ;