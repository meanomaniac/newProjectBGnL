use pocu3;
    
SELECT FortyPercIn24Hr.exchangeName, FortyPercIn24Hr.tradePair, FortyPercIn24Hr.maxPriceChangePerc, FortyPercIn24Hr.timeRecorded 
	from 
	(SELECT exchangeName, tradePair, (max(askPriceUSD) - min(askPriceUSD))/min(askPriceUSD)*100 as maxPriceChangePerc, 
	FROM_UNIXTIME((UNIX_TIMESTAMP(recordTime)) div 86400*86400) as timeRecorded from cTicker
	GROUP BY tradePair, exchangeName, timeRecorded ORDER BY timeRecorded, tradePair) FortyPercIn24Hr
LEFT JOIN (
	SELECT exchangeName, tradePair, max(askPriceUSD) as maxPrice, recordTime,
	FROM_UNIXTIME((UNIX_TIMESTAMP(recordTime)) div 86400*86400) as timeRecorded from cTicker
	GROUP BY tradePair, exchangeName, timeRecorded ORDER BY timeRecorded, tradePair) cTickerMax 
    ON (cTickerMax.exchangeName = FortyPercIn24Hr.exchangeName
			AND cTickerMax.tradePair = FortyPercIn24Hr.tradePair
            AND cTickerMax.timeRecorded = FortyPercIn24Hr.timeRecorded)
LEFT JOIN (
	SELECT exchangeName, tradePair, min(askPriceUSD) as minPrice, recordTime,
	FROM_UNIXTIME((UNIX_TIMESTAMP(recordTime)) div 86400*86400) as timeRecorded from cTicker
	GROUP BY tradePair, exchangeName, timeRecorded ORDER BY timeRecorded, tradePair) cTickerMin 
    ON (cTickerMax.exchangeName = FortyPercIn24Hr.exchangeName
			AND cTickerMax.tradePair = FortyPercIn24Hr.tradePair
            AND cTickerMax.timeRecorded = FortyPercIn24Hr.timeRecorded)
where maxPriceChangePerc > 40 AND cTickerMin.recordTime < cTickerMax.recordTime;

	SELECT FortyPercIn24Hr.exchangeName, FortyPercIn24Hr.tradePair, FortyPercIn24Hr.minMaxUSDDiff, FortyPercIn24Hr.timeRecorded 
	from cTicker15MinMinMax24Hr AS FortyPercIn24Hr
LEFT JOIN cTicker15MinMax24Hr AS cTickerMax 
    ON (cTickerMax.exchangeName = FortyPercIn24Hr.exchangeName
			AND cTickerMax.tradePair = FortyPercIn24Hr.tradePair
            AND cTickerMax.timeRecorded = FortyPercIn24Hr.timeRecorded)
LEFT JOIN cTicker15MinMin24Hr AS cTickerMin 
    ON (cTickerMax.exchangeName = FortyPercIn24Hr.exchangeName
			AND cTickerMax.tradePair = FortyPercIn24Hr.tradePair
            AND cTickerMax.timeRecorded = FortyPercIn24Hr.timeRecorded)
where FortyPercIn24Hr.minMaxUSDDiff > 40 AND cTickerMin.recordTime < cTickerMax.recordTime;


SELECT cTicker15MinAvgMinDay.exchangeName, cTicker15MinAvgMinDay.tradePair, DATE(cTicker15MinAvgMinDay.recordTime) as recordDay, 
	min(cTicker15MinAvgMinDay.askPriceUSD) as minPrice,  cTicker15MinAvgMinDay.recordTime as minTime,  
    max(cTicker15MinAvgMinDay.askPriceUSD) as maxPrice 
    from (select * from cTicker15MinAvg where recordTime < '2017-10-01 03:00:00') cTicker15MinAvgMinDay
    LEFT JOIN cTicker15MinAvg cTicker15MinAvgMin ON 
    (cTicker15MinAvgMin.exchangeName = cTicker15MinAvgMinDay.exchangeName
    AND cTicker15MinAvgMin.tradePair = cTicker15MinAvgMinDay.tradePair
    AND cTicker15MinAvgMin.recordTime = cTicker15MinAvgMinDay.recordTime
    AND cTicker15MinAvgMin.askPriceUSD = cTicker15MinAvgMinDay.askPriceUSD
    AND cTicker15MinAvgMin.recordTime < '2017-10-01 03:00:00')
    GROUP BY tradePair, exchangeName, recordDay ORDER BY recordDay, tradePair;
    
CREATE TABLE cTicker24HrMinMax (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	recordDay DATETIME NULL,
    minPriceUSD FLOAT NULL,
    minTime DATETIME NULL,
	maxPriceUSD FLOAT NULL,
    maxTime DATETIME NULL
);

SELECT  exchangeName, tradePair, max(askPriceUSD) as maxPrice, 
	DATE(recordTime) as recordDay, recordTime from cTicker15MinAvg
	GROUP BY tradePair, exchangeName, recordDay ORDER BY recordDay, tradePair;
    
INSERT INTO cTicker24HrMinMax (exchangeName, tradePair, maxPriceUSD, recordDay, maxTime)
    SELECT  exchangeName, tradePair, max(askPriceUSD) as maxPrice, 
	DATE(recordTime) as recordDay, recordTime from cTicker15MinAvg
	GROUP BY tradePair, exchangeName, recordDay ORDER BY recordDay, tradePair;
    
    select count(*) from cTicker24HrMinMax;
    
	select * from cTicker24HrMinMax where recordDay < '2017-10-02 03:00:00';
        
	ALTER TABLE cTicker15MinAvg ADD INDEX exchangePair (exchangeName, tradePair);
    
    	ALTER TABLE cTicker24HrMinMax ADD INDEX exchangePair (exchangeName, tradePair);
        
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------        

CREATE TABLE cTicker24HrMax (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	recordDay DATETIME NULL,
	maxPriceUSD FLOAT NULL,
    timeOfMax DATETIME NULL
);
    
INSERT INTO cTicker24HrMax
    SELECT  exchangeName, tradePair, DATE(recordTime) as recordDay, max(askPriceUSD) as maxPrice, recordTime from cTicker15MinAvg
	GROUP BY tradePair, exchangeName, recordDay ORDER BY recordDay, tradePair;

    select count(*) from cTicker24HrMax;
    
ALTER TABLE cTicker24HrMax ADD INDEX exchangePair (exchangeName, tradePair, recordDay);


CREATE TABLE cTicker24HrMin (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	recordDay DATETIME NULL,
	minPriceUSD FLOAT NULL,
    timeOfMin DATETIME NULL
);
    
INSERT INTO cTicker24HrMin
    SELECT  exchangeName, tradePair, DATE(recordTime) as recordDay, min(askPriceUSD) as minPrice, recordTime from cTicker15MinAvg
	GROUP BY tradePair, exchangeName, recordDay ORDER BY recordDay, tradePair;

    select count(*) from cTicker24HrMin;
    
     ALTER TABLE cTicker24HrMin ADD INDEX exchangePair (exchangeName, tradePair, recordDay);
        
    select cTicker24HrMinJoin.exchangeName, cTicker24HrMinJoin.tradePair, cTicker24HrMinJoin.recordDay, cTicker24HrMinJoin.minPriceUSD, 
    cTicker24HrMinJoin.timeOfMin, cTicker24HrMaxJoin.maxPriceUSD, cTicker24HrMaxJoin.timeOfMax from 
    cTicker24HrMin AS cTicker24HrMinJoin
    LEFT JOIN
    cTicker24HrMax cTicker24HrMaxJoin ON (cTicker24HrMinJoin.exchangeName = cTicker24HrMaxJoin.exchangeName
																		AND cTicker24HrMinJoin.tradePair = cTicker24HrMaxJoin.tradePair
																		AND cTicker24HrMinJoin.recordDay = cTicker24HrMaxJoin.recordDay);
                                                                        
                                                                        
	CREATE TABLE cTicker24HrMinMax (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	recordDay DATETIME NULL,
	minPriceUSD FLOAT NULL,
    timeOfMin DATETIME NULL,
	maxPriceUSD FLOAT NULL,
    timeOfMax DATETIME NULL
);


INSERT INTO cTicker24HrMinMax
   select cTicker24HrMinJoin.exchangeName, cTicker24HrMinJoin.tradePair, cTicker24HrMinJoin.recordDay, cTicker24HrMinJoin.minPriceUSD, 
    cTicker24HrMinJoin.timeOfMin, cTicker24HrMaxJoin.maxPriceUSD, cTicker24HrMaxJoin.timeOfMax from 
    cTicker24HrMin AS cTicker24HrMinJoin
    LEFT JOIN
    cTicker24HrMax cTicker24HrMaxJoin ON (cTicker24HrMinJoin.exchangeName = cTicker24HrMaxJoin.exchangeName
																		AND cTicker24HrMinJoin.tradePair = cTicker24HrMaxJoin.tradePair
																		AND cTicker24HrMinJoin.recordDay = cTicker24HrMaxJoin.recordDay);
														
	SELECT count(*) from cTicker24HrMinMax ;
    select * from cTicker24HrMinMax where recordDay < '2017-10-02 03:00:00';
	select * from cTicker24HrMin where recordDay < '2017-10-02 03:00:00';
	select * from cTicker24HrMax where recordDay < '2017-10-02 03:00:00';
    
    drop table cTicker24HrMin;
    drop table cTicker24HrMax;
    
     SELECT  exchangeName, tradePair, DATE(recordTime) as recordDay, min(askPriceUSD) as minPrice, recordTime from cTicker15MinAvg
     where recordTime < '2017-10-02 01:00:00' and tradePair = '$$$/BTC';
          SELECT  exchangeName, tradePair, DATE(recordTime) as recordDay, max(askPriceUSD) as minPrice, recordTime from cTicker15MinAvg
     where recordTime < '2017-10-02 01:00:00' and tradePair = '$$$/BTC';
        SELECT  *  from cTicker15MinAvg
     where recordTime < '2017-10-02 01:00:00' and tradePair = '$$$/BTC';