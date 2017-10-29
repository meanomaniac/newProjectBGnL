use pocu3;
    
    SELECT exchangeName, tradePair, (max(askPriceUSD) - min(askPriceUSD))/min(askPriceUSD)*100 as maxPriceChangePerc, 
    FROM_UNIXTIME((UNIX_TIMESTAMP(recordTime)) div 900*900 + 900) as timeRecorded
    from cTicker
    where ( recordTime > '2017-10-21 19:00:00' and recordTime < '2017-10-21 20:30:00'  and exchangeName != 'coinMarketCap') 
    GROUP BY tradePair, timeRecorded div 1500 ORDER BY timeRecorded, tradePair;