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

-- took only 3 minutes to execute the below query with 3 Million records in the inserted table and when there were 12 million in cTicker
	INSERT INTO cTicker15MinAvg
    SELECT exchangeName, tradePair, avg(askPriceUSD) as avgPriceUSD, 
    FROM_UNIXTIME((UNIX_TIMESTAMP(recordTime)) div 900*900 + 900) as timeRecorded
    from cTicker
    GROUP BY tradePair, exchangeName, timeRecorded ORDER BY timeRecorded, tradePair;
 
    
describe cTicker15MinAvg;
select count(*) from cTicker15MinAvg;

select * from cTicker15MinAvg where recordTime < '2017-10-01 03:00:00' ;

CREATE TABLE cTicker15MinMinMax24Hr (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	minMaxUSDDiff FLOAT NULL,
	timeRecorded DATETIME NULL
);

	INSERT INTO cTicker15MinMinMax24Hr
	SELECT exchangeName, tradePair, (max(askPriceUSD) - min(askPriceUSD))/min(askPriceUSD)*100 as maxPriceChangePerc, 
	FROM_UNIXTIME((UNIX_TIMESTAMP(recordTime)) div 86400*86400) as timeRecorded from cTicker
	GROUP BY tradePair, exchangeName, timeRecorded ORDER BY timeRecorded, tradePair;
    
    select count(*) from cTicker15MinMinMax24Hr;
    
    ALTER TABLE cTicker15MinMinMax24Hr ADD INDEX exchangePair (exchangeName, tradePair);
    
    
    CREATE TABLE cTicker15MinMax24Hr (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	maxPrice FLOAT NULL,
    recordTime DATETIME NULL,
	timeRecorded DATETIME NULL
);

INSERT INTO cTicker15MinMax24Hr 
	SELECT exchangeName, tradePair, max(askPriceUSD) as maxPrice, recordTime,
	FROM_UNIXTIME((UNIX_TIMESTAMP(recordTime)) div 86400*86400) as timeRecorded from cTicker
	GROUP BY tradePair, exchangeName, timeRecorded ORDER BY timeRecorded, tradePair;
    
        select count(*) from cTicker15MinMax24Hr;
    
    ALTER TABLE cTicker15MinMax24Hr ADD INDEX exchangePair (exchangeName, tradePair);
    
    
   CREATE TABLE cTicker15MinMin24Hr (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	maxPrice FLOAT NULL,
    recordTime DATETIME NULL,
	timeRecorded DATETIME NULL
);

INSERT INTO cTicker15MinMin24Hr 
	SELECT exchangeName, tradePair, max(askPriceUSD) as maxPrice, recordTime,
	FROM_UNIXTIME((UNIX_TIMESTAMP(recordTime)) div 86400*86400) as timeRecorded from cTicker
	GROUP BY tradePair, exchangeName, timeRecorded ORDER BY timeRecorded, tradePair;
    
        select count(*) from cTicker15MinMin24Hr;
    
    ALTER TABLE cTicker15MinMin24Hr ADD INDEX exchangePair (exchangeName, tradePair);
    
