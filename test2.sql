	use pocu3;
    
    SELECT exchangeName, tradePair, avg(askPriceUSD) as avgPriceUSD, (recordTime div 1500) as timeRecorded  from cTicker
    where ( recordTime > '2017-10-21 20:00:00' and recordTime < '2017-10-21 20:30:00'  and exchangeName != 'coinMarketCap') 
    GROUP BY tradePair, recordTime div 1500 ORDER BY timeRecorded, tradePair;
    
    SELECT distinct(recordTime div 1500) from cTicker where recordTime > '2017-10-01 20:19:10' and recordTime < '2017-10-01 20:34:10';
    
    
    	
    SELECT exchangeName, tradePair, avg(askPriceUSD) as avgPriceUSD from cTicker 
    where ( recordTime > (SELECT (CURRENT_TIMESTAMP -1500)) and recordTime < (SELECT (CURRENT_TIMESTAMP)) 
    and exchangeName != 'coinMarketCap') 
    GROUP BY tradePair ORDER BY avgPriceUSD;

select * from cTicker where tradePair='ACOIN/BTC' and (recordTime div 1500) = '13447347467';