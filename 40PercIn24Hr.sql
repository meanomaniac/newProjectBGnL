use pocu3;
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- creating the max table
CREATE TABLE cTicker24HrMax (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	recordDay DATE NULL,
	maxPriceUSD FLOAT NULL
);
    
INSERT INTO cTicker24HrMax (exchangeName, tradePair, recordDay, maxPriceUSD)
    SELECT  exchangeName, tradePair, DATE(recordTime) as recordDay, max(askPriceUSD) as maxPrice from cTicker15MinAvg
	GROUP BY tradePair, exchangeName, recordDay ORDER BY recordDay, tradePair;

select count(*) from cTicker24HrMax;
    
ALTER TABLE cTicker24HrMax ADD INDEX exchangePair (exchangeName, tradePair, recordDay);

CREATE TABLE cTicker24HrMaxTIme0 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	recordDay DATE NULL,
	timeOfMax DATETIME NULL
);

INSERT INTO cTicker24HrMaxTIme0
SELECT cTicker24HrMaxTemp.exchangeName, cTicker24HrMaxTemp.tradePair, cTicker24HrMaxTemp.recordDay, cTicker15MinAvgTemp.recordTime
from cTicker24HrMax AS cTicker24HrMaxTemp
LEFT JOIN cTicker15MinAvg cTicker15MinAvgTemp ON ( cTicker15MinAvgTemp.exchangeName = cTicker24HrMaxTemp.exchangeName
																							AND cTicker15MinAvgTemp.tradePair = cTicker24HrMaxTemp.tradePair
																							AND DATE(cTicker15MinAvgTemp.recordTime) = cTicker24HrMaxTemp.recordDay
                                                                                            AND cTicker15MinAvgTemp.askPriceUSD = cTicker24HrMaxTemp.maxPriceUSD)
GROUP BY cTicker15MinAvgTemp.tradePair, cTicker15MinAvgTemp.exchangeName, cTicker24HrMaxTemp.recordDay ORDER BY cTicker24HrMaxTemp.recordDay, cTicker15MinAvgTemp.tradePair;                                                                                             

ALTER TABLE cTicker24HrMaxTIme0 ADD INDEX exchangePair (exchangeName, tradePair, recordDay);

CREATE TABLE cTicker24HrMaxFInal (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	recordDay DATE NULL,
	maxPriceUSD FLOAT NULL,
    timeOfMax DATETIME NULL
);

INSERT INTO cTicker24HrMaxFInal 
SELECT cTicker24HrMaxTemp.exchangeName, cTicker24HrMaxTemp.tradePair, cTicker24HrMaxTemp.recordDay, 
cTicker24HrMaxTemp.maxPriceUSD, cTicker24HrMaxTIme0Temp.timeOfMax
from cTicker24HrMax AS cTicker24HrMaxTemp
LEFT JOIN cTicker24HrMaxTIme0 cTicker24HrMaxTIme0Temp ON ( cTicker24HrMaxTIme0Temp.exchangeName = cTicker24HrMaxTemp.exchangeName
																							AND cTicker24HrMaxTIme0Temp.tradePair = cTicker24HrMaxTemp.tradePair
																							AND cTicker24HrMaxTIme0Temp.recordDay = cTicker24HrMaxTemp.recordDay);

ALTER TABLE cTicker24HrMaxFInal ADD INDEX exchangePair (exchangeName, tradePair, recordDay);

CREATE TABLE cTicker24HrMaxFinalPlus15 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	recordDay DATE NULL,
	maxPriceUSD FLOAT NULL,
    timeOfMax DATETIME NULL,
	priceUSDPlus15 FLOAT NULL
);

INSERT into cTicker24HrMaxFinalPlus15
SELECT cTicker24HrMaxFinalTemp.exchangeName, cTicker24HrMaxFinalTemp.tradePair, cTicker24HrMaxFinalTemp.recordDay, 
cTicker24HrMaxFinalTemp.maxPriceUSD, cTicker24HrMaxFinalTemp.timeOfMax, cTicker15MinAvgTemp.askPriceUSD
from cTicker24HrMaxFInal AS cTicker24HrMaxFinalTemp
LEFT JOIN cTicker15MinAvg cTicker15MinAvgTemp ON ( cTicker15MinAvgTemp.exchangeName = cTicker24HrMaxFinalTemp.exchangeName
																							AND cTicker15MinAvgTemp.tradePair = cTicker24HrMaxFinalTemp.tradePair
																							AND FROM_UNIXTIME((UNIX_TIMESTAMP(recordTime)) - 900) = cTicker24HrMaxFinalTemp.timeOfMax);                                                                                           

ALTER TABLE cTicker24HrMaxFinalPlus15 ADD INDEX exchangePair (exchangeName, tradePair, recordDay);

CREATE TABLE cTicker24HrMaxFinalPlus30 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	recordDay DATE NULL,
	maxPriceUSD FLOAT NULL,
    timeOfMax DATETIME NULL,
	priceUSDPlus15 FLOAT NULL,
    priceUSDPlus30 FLOAT NULL
);

INSERT into cTicker24HrMaxFinalPlus30
SELECT cTicker24HrMaxFinalTemp.exchangeName, cTicker24HrMaxFinalTemp.tradePair, cTicker24HrMaxFinalTemp.recordDay, 
cTicker24HrMaxFinalTemp.maxPriceUSD, cTicker24HrMaxFinalTemp.timeOfMax, cTicker24HrMaxFinalTemp.priceUSDPlus15,
cTicker15MinAvgTemp.askPriceUSD
from cTicker24HrMaxFinalPlus15 AS cTicker24HrMaxFinalTemp
LEFT JOIN cTicker15MinAvg cTicker15MinAvgTemp ON ( cTicker15MinAvgTemp.exchangeName = cTicker24HrMaxFinalTemp.exchangeName
																							AND cTicker15MinAvgTemp.tradePair = cTicker24HrMaxFinalTemp.tradePair
																							AND FROM_UNIXTIME((UNIX_TIMESTAMP(recordTime)) - 1800) = cTicker24HrMaxFinalTemp.timeOfMax);                                                                                           

ALTER TABLE cTicker24HrMaxFinalPlus30 ADD INDEX exchangePair (exchangeName, tradePair, recordDay);

CREATE TABLE cTicker24HrMaxFinalPlus45 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	recordDay DATE NULL,
	maxPriceUSD FLOAT NULL,
    timeOfMax DATETIME NULL,
	priceUSDPlus15 FLOAT NULL,
    priceUSDPlus30 FLOAT NULL,
    priceUSDPlus45 FLOAT NULL
);

INSERT into cTicker24HrMaxFinalPlus45
SELECT cTicker24HrMaxFinalTemp.exchangeName, cTicker24HrMaxFinalTemp.tradePair, cTicker24HrMaxFinalTemp.recordDay, 
cTicker24HrMaxFinalTemp.maxPriceUSD, cTicker24HrMaxFinalTemp.timeOfMax, cTicker24HrMaxFinalTemp.priceUSDPlus15,
cTicker24HrMaxFinalTemp.priceUSDPlus30, cTicker15MinAvgTemp.askPriceUSD
from cTicker24HrMaxFinalPlus30 AS cTicker24HrMaxFinalTemp
LEFT JOIN cTicker15MinAvg cTicker15MinAvgTemp ON ( cTicker15MinAvgTemp.exchangeName = cTicker24HrMaxFinalTemp.exchangeName
																							AND cTicker15MinAvgTemp.tradePair = cTicker24HrMaxFinalTemp.tradePair
																							AND FROM_UNIXTIME((UNIX_TIMESTAMP(recordTime)) - 2700) = cTicker24HrMaxFinalTemp.timeOfMax);                                                                                           

ALTER TABLE cTicker24HrMaxFinalPlus45 ADD INDEX exchangePair (exchangeName, tradePair, recordDay);

CREATE TABLE cTicker24HrMaxFinalPlus60 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	recordDay DATE NULL,
	maxPriceUSD FLOAT NULL,
    timeOfMax DATETIME NULL,
	priceUSDPlus15 FLOAT NULL,
    priceUSDPlus30 FLOAT NULL,
    priceUSDPlus45 FLOAT NULL,
	priceUSDPlus60 FLOAT NULL
);

INSERT into cTicker24HrMaxFinalPlus60
SELECT cTicker24HrMaxFinalTemp.exchangeName, cTicker24HrMaxFinalTemp.tradePair, cTicker24HrMaxFinalTemp.recordDay, 
cTicker24HrMaxFinalTemp.maxPriceUSD, cTicker24HrMaxFinalTemp.timeOfMax, cTicker24HrMaxFinalTemp.priceUSDPlus15,
cTicker24HrMaxFinalTemp.priceUSDPlus30, cTicker24HrMaxFinalTemp.priceUSDPlus45, cTicker15MinAvgTemp.askPriceUSD
from cTicker24HrMaxFinalPlus45 AS cTicker24HrMaxFinalTemp
LEFT JOIN cTicker15MinAvg cTicker15MinAvgTemp ON ( cTicker15MinAvgTemp.exchangeName = cTicker24HrMaxFinalTemp.exchangeName
																							AND cTicker15MinAvgTemp.tradePair = cTicker24HrMaxFinalTemp.tradePair
																							AND FROM_UNIXTIME((UNIX_TIMESTAMP(recordTime)) - 3600) = cTicker24HrMaxFinalTemp.timeOfMax);                                                                                           

ALTER TABLE cTicker24HrMaxFinalPlus60 ADD INDEX exchangePair (exchangeName, tradePair, recordDay);


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- creating the min table
CREATE TABLE cTicker24HrMin (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	recordDay DATE NULL,
	minPriceUSD FLOAT NULL,
    timeOfMin DATETIME NULL
);
    
INSERT INTO cTicker24HrMin (exchangeName, tradePair, recordDay, minPriceUSD)
    SELECT  exchangeName, tradePair, DATE(recordTime) as recordDay, min(askPriceUSD) as minPrice from cTicker15MinAvg
	GROUP BY tradePair, exchangeName, recordDay ORDER BY recordDay, tradePair;
    
select count(*) from cTicker24HrMin;

ALTER TABLE cTicker24HrMin ADD INDEX exchangePair (exchangeName, tradePair, recordDay);

CREATE TABLE cTicker24HrMinTIme0 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	recordDay DATE NULL,
	timeOfMin DATETIME NULL
);

INSERT INTO cTicker24HrMinTIme0
SELECT cTicker24HrMinTemp.exchangeName, cTicker24HrMinTemp.tradePair, cTicker24HrMinTemp.recordDay, cTicker15MinAvgTemp.recordTime
from cTicker24HrMin AS cTicker24HrMinTemp
LEFT JOIN cTicker15MinAvg cTicker15MinAvgTemp ON ( cTicker15MinAvgTemp.exchangeName = cTicker24HrMinTemp.exchangeName
																							AND cTicker15MinAvgTemp.tradePair = cTicker24HrMinTemp.tradePair
																							AND DATE(cTicker15MinAvgTemp.recordTime) = cTicker24HrMinTemp.recordDay
                                                                                            AND cTicker15MinAvgTemp.askPriceUSD = cTicker24HrMinTemp.minPriceUSD)
GROUP BY cTicker15MinAvgTemp.tradePair, cTicker15MinAvgTemp.exchangeName, cTicker24HrMinTemp.recordDay ORDER BY cTicker24HrMinTemp.recordDay, cTicker15MinAvgTemp.tradePair;                                                                                             

ALTER TABLE cTicker24HrMinTIme0 ADD INDEX exchangePair (exchangeName, tradePair, recordDay);

CREATE TABLE cTicker24HrMinFInal (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	recordDay DATE NULL,
	minPriceUSD FLOAT NULL,
    timeOfMin DATETIME NULL
);

INSERT INTO cTicker24HrMinFInal 
SELECT cTicker24HrMinTemp.exchangeName, cTicker24HrMinTemp.tradePair, cTicker24HrMinTemp.recordDay, 
cTicker24HrMinTemp.minPriceUSD, cTicker24HrMinTIme0Temp.timeOfMin
from cTicker24HrMin AS cTicker24HrMinTemp
LEFT JOIN cTicker24HrMinTIme0 cTicker24HrMinTIme0Temp ON ( cTicker24HrMinTIme0Temp.exchangeName = cTicker24HrMinTemp.exchangeName
																							AND cTicker24HrMinTIme0Temp.tradePair = cTicker24HrMinTemp.tradePair
																							AND cTicker24HrMinTIme0Temp.recordDay = cTicker24HrMinTemp.recordDay);

ALTER TABLE cTicker24HrMinFInal ADD INDEX exchangePair (exchangeName, tradePair, recordDay);

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
-- creating the combined min, max table
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
select cTicker24HrMaxFinalTemp.exchangeName, cTicker24HrMaxFinalTemp.tradePair, cTicker24HrMaxFinalTemp.recordDay, 
cTicker24HrMinFinalTemp.minPriceUSD, cTicker24HrMinFinalTemp.timeOfMin, cTicker24HrMaxFinalTemp.maxPriceUSD, 
cTicker24HrMaxFinalTemp.timeOfMax 
from  cTicker24HrMaxFInal AS cTicker24HrMaxFinalTemp 
LEFT JOIN
cTicker24HrMinFInal cTicker24HrMinFinalTemp ON (cTicker24HrMinFinalTemp.exchangeName = cTicker24HrMaxFinalTemp.exchangeName
																	AND cTicker24HrMinFinalTemp.tradePair = cTicker24HrMaxFinalTemp.tradePair
																	AND cTicker24HrMinFinalTemp.recordDay = cTicker24HrMaxFinalTemp.recordDay);                                                                     
                                                                        

ALTER TABLE cTicker24HrMinMax ADD INDEX exchangePair (exchangeName, tradePair, recordDay);

CREATE TABLE cTicker24HrMinMaxPlus60 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	recordDay DATETIME NULL,
	minPriceUSD FLOAT NULL,
    timeOfMin DATETIME NULL,
	maxPriceUSD FLOAT NULL,
    timeOfMax DATETIME NULL,
	priceUSDMaxPlus15 FLOAT NULL,
    priceUSDMaxPlus30 FLOAT NULL,
    priceUSDMaxPlus45 FLOAT NULL,
	priceUSDMaxPlus60 FLOAT NULL
);

INSERT INTO cTicker24HrMinMaxPlus60
select cTicker24HrMaxFinalTemp.exchangeName, cTicker24HrMaxFinalTemp.tradePair, cTicker24HrMaxFinalTemp.recordDay, 
cTicker24HrMaxFinalTemp.minPriceUSD, cTicker24HrMaxFinalTemp.timeOfMin, cTicker24HrMaxFinalTemp.maxPriceUSD, 
cTicker24HrMaxFinalTemp.timeOfMax , cTicker24HrFinalTemp.priceUSDPlus15, cTicker24HrFinalTemp.priceUSDPlus30, 
cTicker24HrFinalTemp.priceUSDPlus45, cTicker24HrFinalTemp.priceUSDPlus60
from  cTicker24HrMinMax AS cTicker24HrMaxFinalTemp 
LEFT JOIN
cTicker24HrMaxFinalPlus60 cTicker24HrFinalTemp ON (cTicker24HrFinalTemp.exchangeName = cTicker24HrMaxFinalTemp.exchangeName
																	AND cTicker24HrFinalTemp.tradePair = cTicker24HrMaxFinalTemp.tradePair
																	AND cTicker24HrFinalTemp.recordDay = cTicker24HrMaxFinalTemp.recordDay);      
                                                 
ALTER TABLE cTicker24HrMinMaxPlus60 ADD INDEX exchangePair (exchangeName, tradePair, recordDay);
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- TEST 														
SELECT count(*) from cTicker24HrMinMaxPlus60 ;
SELECT count(*) from cTicker24HrMinMaxPlus60 where timeOfMax > timeOfMin and (maxPriceUSD-minPriceUSD)/minPriceUSD > 1;

SELECT count(*) from cTicker24HrMinMaxPlus60 where ((timeOfMax > timeOfMin) AND ((maxPriceUSD-minPriceUSD)/minPriceUSD > 1)
AND (((priceUSDMaxPlus15+priceUSDMaxPlus30+priceUSDMaxPlus45+priceUSDMaxPlus60)/4) > 0.5*maxPriceUSD));

SELECT count(*) from cTicker24HrMinMaxPlus60 where ((timeOfMax > timeOfMin) AND ((maxPriceUSD-minPriceUSD)/minPriceUSD > 1)
AND (((priceUSDMaxPlus15+priceUSDMaxPlus30+priceUSDMaxPlus45)/3) > 0.5*maxPriceUSD));

SELECT count(*) from cTicker24HrMinMaxPlus60 where ((timeOfMax > timeOfMin) AND ((maxPriceUSD-minPriceUSD)/minPriceUSD > 1)
AND (((priceUSDMaxPlus15+priceUSDMaxPlus30)/2) > 0.5*maxPriceUSD));


-- del 
select * from cTicker24HrMinMax where recordDay < '2017-10-02 03:00:00';
select * from cTicker24HrMaxFinalPlus15 where recordDay < '2017-10-02 03:00:00';
select * from cTicker24HrMin where recordDay < '2017-10-02 03:00:00';
select * from cTicker24HrMax where recordDay < '2017-10-02 03:00:00';
select * from cTicker24HrMaxTIme0 where recordDay < '2017-10-02 03:00:00';
select count(*) from cTicker24HrMax;
select count(*) from cTicker24HrMaxFInal ;

drop table cTicker24HrMin;
drop table cTicker24HrMax;

 SELECT  exchangeName, tradePair, DATE(recordTime) as recordDay, min(askPriceUSD) as minPrice, recordTime from cTicker15MinAvg
 where recordTime < '2017-10-02 01:00:00' and tradePair = '$$$/BTC';
	  SELECT  exchangeName, tradePair, DATE(recordTime) as recordDay, max(askPriceUSD) as minPrice, recordTime from cTicker15MinAvg
 where recordTime < '2017-10-02 01:00:00' and tradePair = '$$$/BTC';
	SELECT  *  from cTicker15MinAvg
 where recordTime < '2017-10-02 01:00:00' and tradePair = '$$$/BTC';
 
 	SELECT  *  from cTicker24HrMaxFInal
 where recordDay < '2017-10-02' ;
 	SELECT  *  from cTicker24HrMaxTIme0
 where recordDay < '2017-10-02' and tradePair = '$$$/BTC';
 


