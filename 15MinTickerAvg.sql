	use pocu3;
    
    SELECT exchangeName, tradePair, avg(askPriceUSD) as avgPriceUSD, 
    FROM_UNIXTIME((UNIX_TIMESTAMP(recordTime)) div 900*900 + 900) as timeRecorded
    from cTicker
    where ( recordTime > '2017-10-21 19:00:00' and recordTime < '2017-10-21 20:30:00'  and exchangeName != 'coinMarketCap') 
    GROUP BY tradePair, exchangeName, timeRecorded ORDER BY timeRecorded, tradePair;

CREATE TABLE cTicker15MinAvg (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	askPriceUSD FLOAT NULL,
	recordTime DATETIME NULL
);

select * from cTicker where tradePair='BTC-EGC' and  ( recordTime > '2017-10-21 19:00:00' and recordTime < '2017-10-21 20:30:00'  and exchangeName != 'coinMarketCap') ;

	INSERT INTO cTicker15MinAvg
    SELECT exchangeName, tradePair, avg(askPriceUSD) as avgPriceUSD, 
    FROM_UNIXTIME((UNIX_TIMESTAMP(recordTime)) div 900*900 + 900) as timeRecorded
    from cTicker
    GROUP BY tradePair, exchangeName, timeRecorded ORDER BY timeRecorded, tradePair;


select count(*) from cTicker15MinAvg;

select * from cTicker15MinAvg where recordTime < '2017-10-01 03:00:00' ;