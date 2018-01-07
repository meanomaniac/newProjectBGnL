use pocu4;
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


CREATE TABLE cTicker24HrMaxFinalPlus60Minus15 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	recordDay DATE NULL,
	maxPriceUSD FLOAT NULL,
    timeOfMax DATETIME NULL,
    priceUSDMinus15 FLOAT NULL,
	priceUSDPlus15 FLOAT NULL,
    priceUSDPlus30 FLOAT NULL,
    priceUSDPlus45 FLOAT NULL,
	priceUSDPlus60 FLOAT NULL
);

INSERT into cTicker24HrMaxFinalPlus60Minus15
SELECT cTicker24HrMaxFinalTemp.exchangeName, cTicker24HrMaxFinalTemp.tradePair, cTicker24HrMaxFinalTemp.recordDay, 
cTicker24HrMaxFinalTemp.maxPriceUSD, cTicker24HrMaxFinalTemp.timeOfMax, cTicker15MinAvgTemp.askPriceUSD,
cTicker24HrMaxFinalTemp.priceUSDPlus15, cTicker24HrMaxFinalTemp.priceUSDPlus30, cTicker24HrMaxFinalTemp.priceUSDPlus45,
cTicker24HrMaxFinalTemp.priceUSDPlus60
from cTicker24HrMaxFinalPlus60 AS cTicker24HrMaxFinalTemp
LEFT JOIN cTicker15MinAvg cTicker15MinAvgTemp ON ( cTicker15MinAvgTemp.exchangeName = cTicker24HrMaxFinalTemp.exchangeName
																							AND cTicker15MinAvgTemp.tradePair = cTicker24HrMaxFinalTemp.tradePair
																							AND FROM_UNIXTIME((UNIX_TIMESTAMP(recordTime)) +900) = cTicker24HrMaxFinalTemp.timeOfMax);                                                                                           

ALTER TABLE cTicker24HrMaxFinalPlus60Minus15 ADD INDEX exchangePair (exchangeName, tradePair, recordDay);


CREATE TABLE cTicker24HrMaxFinalPlus60Minus30 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	recordDay DATE NULL,
	maxPriceUSD FLOAT NULL,
    timeOfMax DATETIME NULL,
	priceUSDMinus30 FLOAT NULL,
    priceUSDMinus15 FLOAT NULL,
	priceUSDPlus15 FLOAT NULL,
    priceUSDPlus30 FLOAT NULL,
    priceUSDPlus45 FLOAT NULL,
	priceUSDPlus60 FLOAT NULL
);

INSERT into cTicker24HrMaxFinalPlus60Minus30
SELECT cTicker24HrMaxFinalTemp.exchangeName, cTicker24HrMaxFinalTemp.tradePair, cTicker24HrMaxFinalTemp.recordDay, 
cTicker24HrMaxFinalTemp.maxPriceUSD, cTicker24HrMaxFinalTemp.timeOfMax, cTicker15MinAvgTemp.askPriceUSD,
cTicker24HrMaxFinalTemp.priceUSDMinus15,
cTicker24HrMaxFinalTemp.priceUSDPlus15, cTicker24HrMaxFinalTemp.priceUSDPlus30, cTicker24HrMaxFinalTemp.priceUSDPlus45,
cTicker24HrMaxFinalTemp.priceUSDPlus60
from cTicker24HrMaxFinalPlus60Minus15 AS cTicker24HrMaxFinalTemp
LEFT JOIN cTicker15MinAvg cTicker15MinAvgTemp ON ( cTicker15MinAvgTemp.exchangeName = cTicker24HrMaxFinalTemp.exchangeName
																							AND cTicker15MinAvgTemp.tradePair = cTicker24HrMaxFinalTemp.tradePair
																							AND FROM_UNIXTIME((UNIX_TIMESTAMP(recordTime)) +1800) = cTicker24HrMaxFinalTemp.timeOfMax);                                                                                           

ALTER TABLE cTicker24HrMaxFinalPlus60Minus30 ADD INDEX exchangePair (exchangeName, tradePair, recordDay);



CREATE TABLE cTicker24HrMaxFinalPlus60Minus45 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	recordDay DATE NULL,
	maxPriceUSD FLOAT NULL,
    timeOfMax DATETIME NULL,
	priceUSDMinus45 FLOAT NULL,
	priceUSDMinus30 FLOAT NULL,
    priceUSDMinus15 FLOAT NULL,
	priceUSDPlus15 FLOAT NULL,
    priceUSDPlus30 FLOAT NULL,
    priceUSDPlus45 FLOAT NULL,
	priceUSDPlus60 FLOAT NULL
);

INSERT into cTicker24HrMaxFinalPlus60Minus45
SELECT cTicker24HrMaxFinalTemp.exchangeName, cTicker24HrMaxFinalTemp.tradePair, cTicker24HrMaxFinalTemp.recordDay, 
cTicker24HrMaxFinalTemp.maxPriceUSD, cTicker24HrMaxFinalTemp.timeOfMax, cTicker15MinAvgTemp.askPriceUSD,
cTicker24HrMaxFinalTemp.priceUSDMinus30, cTicker24HrMaxFinalTemp.priceUSDMinus15,
cTicker24HrMaxFinalTemp.priceUSDPlus15, cTicker24HrMaxFinalTemp.priceUSDPlus30, cTicker24HrMaxFinalTemp.priceUSDPlus45,
cTicker24HrMaxFinalTemp.priceUSDPlus60
from cTicker24HrMaxFinalPlus60Minus30 AS cTicker24HrMaxFinalTemp
LEFT JOIN cTicker15MinAvg cTicker15MinAvgTemp ON ( cTicker15MinAvgTemp.exchangeName = cTicker24HrMaxFinalTemp.exchangeName
																							AND cTicker15MinAvgTemp.tradePair = cTicker24HrMaxFinalTemp.tradePair
																							AND FROM_UNIXTIME((UNIX_TIMESTAMP(recordTime)) +2700) = cTicker24HrMaxFinalTemp.timeOfMax);                                                                                           

ALTER TABLE cTicker24HrMaxFinalPlus60Minus45 ADD INDEX exchangePair (exchangeName, tradePair, recordDay);

CREATE TABLE cTicker24HrMaxFinalPlus60Minus60 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	recordDay DATE NULL,
	maxPriceUSD FLOAT NULL,
    timeOfMax DATETIME NULL,
	priceUSDMinus60 FLOAT NULL,
	priceUSDMinus45 FLOAT NULL,
	priceUSDMinus30 FLOAT NULL,
    priceUSDMinus15 FLOAT NULL,
	priceUSDPlus15 FLOAT NULL,
    priceUSDPlus30 FLOAT NULL,
    priceUSDPlus45 FLOAT NULL,
	priceUSDPlus60 FLOAT NULL
);

INSERT into cTicker24HrMaxFinalPlus60Minus60
SELECT cTicker24HrMaxFinalTemp.exchangeName, cTicker24HrMaxFinalTemp.tradePair, cTicker24HrMaxFinalTemp.recordDay, 
cTicker24HrMaxFinalTemp.maxPriceUSD, cTicker24HrMaxFinalTemp.timeOfMax, cTicker15MinAvgTemp.askPriceUSD,
cTicker24HrMaxFinalTemp.priceUSDMinus45, cTicker24HrMaxFinalTemp.priceUSDMinus30, cTicker24HrMaxFinalTemp.priceUSDMinus15,
cTicker24HrMaxFinalTemp.priceUSDPlus15, cTicker24HrMaxFinalTemp.priceUSDPlus30, cTicker24HrMaxFinalTemp.priceUSDPlus45,
cTicker24HrMaxFinalTemp.priceUSDPlus60
from cTicker24HrMaxFinalPlus60Minus45 AS cTicker24HrMaxFinalTemp
LEFT JOIN cTicker15MinAvg cTicker15MinAvgTemp ON ( cTicker15MinAvgTemp.exchangeName = cTicker24HrMaxFinalTemp.exchangeName
																							AND cTicker15MinAvgTemp.tradePair = cTicker24HrMaxFinalTemp.tradePair
																							AND FROM_UNIXTIME((UNIX_TIMESTAMP(recordTime)) +3600) = cTicker24HrMaxFinalTemp.timeOfMax);                                                                                           

ALTER TABLE cTicker24HrMaxFinalPlus60Minus60 ADD INDEX exchangePair (exchangeName, tradePair, recordDay);

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

CREATE TABLE cTicker24HrMinMaxPlus60NoNull LIKE cTicker24HrMinMaxPlus60; 
INSERT cTicker24HrMinMaxPlus60NoNull SELECT * FROM cTicker24HrMinMaxPlus60;

UPDATE cTicker24HrMinMaxPlus60NoNull SET priceUSDMaxPlus15 = maxPriceUSD where priceUSDMaxPlus15 IS NULL;
UPDATE cTicker24HrMinMaxPlus60NoNull SET priceUSDMaxPlus30 = priceUSDMaxPlus15 where priceUSDMaxPlus30 IS NULL;
UPDATE cTicker24HrMinMaxPlus60NoNull SET priceUSDMaxPlus45 = priceUSDMaxPlus30 where priceUSDMaxPlus45 IS NULL;
UPDATE cTicker24HrMinMaxPlus60NoNull SET priceUSDMaxPlus60 = priceUSDMaxPlus45 where priceUSDMaxPlus60 IS NULL;
use pocu4;


CREATE TABLE cTicker24HrMinMaxPlus60Minus60 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	recordDay DATETIME NULL,
	minPriceUSD FLOAT NULL,
    timeOfMin DATETIME NULL,
	maxPriceUSD FLOAT NULL,
    timeOfMax DATETIME NULL,
	atMaxMinus60 FLOAT NULL,
	atMaxMinus45 FLOAT NULL,
	atMaxMinus30 FLOAT NULL,
    atMaxMinus15 FLOAT NULL,
	atMaxPlus15 FLOAT NULL,
    atMaxPlus30 FLOAT NULL,
    atMaxPlus45 FLOAT NULL,
	atMaxPlus60 FLOAT NULL
);

INSERT INTO cTicker24HrMinMaxPlus60Minus60
select cTicker24HrMaxFinalTemp.exchangeName, cTicker24HrMaxFinalTemp.tradePair, cTicker24HrMaxFinalTemp.recordDay, 
cTicker24HrMaxFinalTemp.minPriceUSD, cTicker24HrMaxFinalTemp.timeOfMin, cTicker24HrMaxFinalTemp.maxPriceUSD, 
cTicker24HrMaxFinalTemp.timeOfMax , 
cTicker24HrFinalTemp.priceUSDMinus60, cTicker24HrFinalTemp.priceUSDMinus45, cTicker24HrFinalTemp.priceUSDMinus30, 
cTicker24HrFinalTemp.priceUSDMinus15, 
cTicker24HrMaxFinalTemp.priceUSDMaxPlus15, cTicker24HrMaxFinalTemp.priceUSDMaxPlus30, 
cTicker24HrMaxFinalTemp.priceUSDMaxPlus45, cTicker24HrMaxFinalTemp.priceUSDMaxPlus60
from  cTicker24HrMinMaxPlus60NoNull AS cTicker24HrMaxFinalTemp 
LEFT JOIN
cTicker24HrMaxFinalPlus60Minus60 cTicker24HrFinalTemp ON (cTicker24HrFinalTemp.exchangeName = cTicker24HrMaxFinalTemp.exchangeName
																	AND cTicker24HrFinalTemp.tradePair = cTicker24HrMaxFinalTemp.tradePair
																	AND cTicker24HrFinalTemp.recordDay = cTicker24HrMaxFinalTemp.recordDay);      
                                                 
ALTER TABLE cTicker24HrMinMaxPlus60Minus60 ADD INDEX exchangePair (exchangeName, tradePair, recordDay);

CREATE TABLE cTicker24HrMinMaxPlus60Minus60NoNull LIKE cTicker24HrMinMaxPlus60Minus60; 
INSERT cTicker24HrMinMaxPlus60Minus60NoNull SELECT * FROM cTicker24HrMinMaxPlus60Minus60;


UPDATE cTicker24HrMinMaxPlus60Minus60NoNull SET atMaxMinus45 = atMaxMinus60 where atMaxMinus45 IS NULL;
UPDATE cTicker24HrMinMaxPlus60Minus60NoNull SET atMaxMinus30 = priceUSDMaxPlus15 where atMaxMinus30 IS NULL;
UPDATE cTicker24HrMinMaxPlus60Minus60NoNull SET atMaxMinus15 = priceUSDMaxPlus30 where atMaxMinus15 IS NULL;

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- combining the minMax table with openOrders and OrderHistory

CREATE TABLE dayDiffMinMaxWithTradingInfo (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	recordDay DATETIME NULL,
	minPriceUSD FLOAT NULL,
    timeOfMin DATETIME NULL,
	maxPriceUSD FLOAT NULL,
    timeOfMax DATETIME NULL,
	atMaxMinus60 FLOAT NULL,
	atMaxMinus45 FLOAT NULL,
	atMaxMinus30 FLOAT NULL,
    atMaxMinus15 FLOAT NULL,
	atMaxPlus15 FLOAT NULL,
    atMaxPlus30 FLOAT NULL,
    atMaxPlus45 FLOAT NULL,
	atMaxPlus60 FLOAT NULL,
    openBuyAmount FLOAT NULL,
    openSellAmount FLOAT NULL,
    buyHistoryAmount FLOAT NULL,
    sellHistoryAmount FLOAT NULL
);

INSERT INTO dayDiffMinMaxWithTradingInfo 
SELECT cTicker24HrMinMaxPlus60Minus60NoNullTemp.exchangeName, cTicker24HrMinMaxPlus60Minus60NoNullTemp.tradePair, 
cTicker24HrMinMaxPlus60Minus60NoNullTemp.recordDay, cTicker24HrMinMaxPlus60Minus60NoNullTemp.minPriceUSD, 
cTicker24HrMinMaxPlus60Minus60NoNullTemp.timeOfMin, cTicker24HrMinMaxPlus60Minus60NoNullTemp.maxPriceUSD, 
cTicker24HrMinMaxPlus60Minus60NoNullTemp.timeOfMax, cTicker24HrMinMaxPlus60Minus60NoNullTemp.atMaxMinus60, 
cTicker24HrMinMaxPlus60Minus60NoNullTemp.atMaxMinus45, cTicker24HrMinMaxPlus60Minus60NoNullTemp.atMaxMinus30, 
cTicker24HrMinMaxPlus60Minus60NoNullTemp.atMaxMinus15, cTicker24HrMinMaxPlus60Minus60NoNullTemp.atMaxPlus15, 
cTicker24HrMinMaxPlus60Minus60NoNullTemp.atMaxPlus30, cTicker24HrMinMaxPlus60Minus60NoNullTemp.atMaxPlus45, 
cTicker24HrMinMaxPlus60Minus60NoNullTemp.atMaxPlus60,
openOrders15MinAvgTemp.totalBuyAmount, openOrders15MinAvgTemp.totalSellAmount,
orderHistory15MinAvgTemp.totalBuyAmount, orderHistory15MinAvgTemp.totalSellAmount
FROM cTicker24HrMinMaxPlus60Minus60NoNull AS cTicker24HrMinMaxPlus60Minus60NoNullTemp
LEFT JOIN 
openOrders15MinAvg openOrders15MinAvgTemp ON ( openOrders15MinAvgTemp.exchangeName = cTicker24HrMinMaxPlus60Minus60NoNullTemp.exchangeName
																							AND openOrders15MinAvgTemp.tradePair = cTicker24HrMinMaxPlus60Minus60NoNullTemp.tradePair
																							AND openOrders15MinAvgTemp.recordTime = cTicker24HrMinMaxPlus60Minus60NoNullTemp.timeOfMax)
LEFT JOIN 
orderHistory15MinAvg orderHistory15MinAvgTemp ON ( orderHistory15MinAvgTemp.exchangeName = cTicker24HrMinMaxPlus60Minus60NoNullTemp.exchangeName
																							AND orderHistory15MinAvgTemp.tradePair = cTicker24HrMinMaxPlus60Minus60NoNullTemp.tradePair
																							AND orderHistory15MinAvgTemp.recordTime = cTicker24HrMinMaxPlus60Minus60NoNullTemp.timeOfMax);

ALTER TABLE dayDiffMinMaxWithTradingInfo ADD INDEX exchangePair (exchangeName, tradePair, recordDay);


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- TEST 
use pocu4;

SELECT DISTINCT(tradePair) from dayDiffMinMaxWithTradingInfo where UPPER(tradePair) REGEXP "AV|888|BUCKS";



SELECT * FROM dayDiffMinMaxWithTradingInfo where recordDay < '2017-10-02 03:00:00';	

Select distinct(CONCAT(exchangeName, tradePair)) from 
(SELECT exchangeName, tradePair, timeOfMax AS exchPairDate from dayDiffMinMaxWithTradingInfo 
where timeOfMax > timeOfMin AND (maxPriceUSD-minPriceUSD)/minPriceUSD > 1
AND ((atMaxPlus15+atMaxPlus30+atMaxPlus45+atMaxPlus60)/4 > 2*minPriceUSD OR
(atMaxMinus15+atMaxMinus30+atMaxMinus45+atMaxMinus60)/4 > 2*minPriceUSD OR
(atMaxPlus15+atMaxPlus30+atMaxMinus15+atMaxMinus30)/4 > 2*minPriceUSD)
AND exchangeName != 'coinMarketCap' AND exchangeName != 'coinExchange' 
AND UPPER(tradePair) REGEXP 
"BCH|ETH|XRP|USDT|LTC|EOS|DASH|ETC|QTUM|NEO|ZEC|XMR|OMG|VTC|BCC|XLM|HSR|GRS|WAVES|ZEN|MIOTA|WTC|STRAT|SYS|LSK|BTG|ETP|STORJ|MCO|GNT|FCT|BAT|POWR|SNT|VRC|XEM|KMD|BTS|NXT|SYNX|ARK|XVG|XDN|SALT|MTL|BCN|NAS|ADA|PAY|ADX|ARDR|DOGE|MONA|LINK|BQX|BNB|KNC|RISE|DGB|XST|MOD|TRST|OK|CVC|EVX|ZRX|AST|VIA|DNT|SC|GXS|SNGLS|ATB|MAID|TRX|PIVX|KCS|BNT|RPX|NAV|CTR|XZC|GAS|TX|REP|STEEM|MCAP|FTC|GNO|RBY|GAME|ICN") as test;


SELECT exchangeName, tradePair, timeOfMax AS exchPairDate, ROUND((maxPriceUSD-minPriceUSD)/minPriceUSD*100,2) as priceChangePerc
from dayDiffMinMaxWithTradingInfo 
where timeOfMax > timeOfMin AND (maxPriceUSD-minPriceUSD)/minPriceUSD > 1
AND ((atMaxPlus15+atMaxPlus30+atMaxPlus45+atMaxPlus60)/4 > 2*minPriceUSD OR
(atMaxMinus15+atMaxMinus30+atMaxMinus45+atMaxMinus60)/4 > 2*minPriceUSD OR
(atMaxPlus15+atMaxPlus30+atMaxMinus15+atMaxMinus30)/4 > 2*minPriceUSD)
AND exchangeName != 'coinMarketCap' AND exchangeName != 'coinExchange' 
AND UPPER(tradePair) REGEXP 
"BCH|ETH|XRP|USDT|LTC|EOS|DASH|ETC|QTUM|NEO|ZEC|XMR|OMG|VTC|BCC|XLM|HSR|GRS|WAVES|ZEN|MIOTA|WTC|STRAT|SYS|LSK|BTG|ETP|STORJ|MCO|GNT|FCT|BAT|POWR|SNT|VRC|XEM|KMD|BTS|NXT|SYNX|ARK|XVG|XDN|SALT|MTL|BCN|NAS|ADA|PAY|ADX|ARDR|DOGE|MONA|LINK|BQX|BNB|KNC|RISE|DGB|XST|MOD|TRST|OK|CVC|EVX|ZRX|AST|VIA|DNT|SC|GXS|SNGLS|ATB|MAID|TRX|PIVX|KCS|BNT|RPX|NAV|CTR|XZC|GAS|TX|REP|STEEM|MCAP|FTC|GNO|RBY|GAME|ICN";

SELECT * from cTicker where CONCAT(exchangeName, tradePair, DATE(recordTime)) IN 
(SELECT CONCAT(exchangeName, tradePair, DATE(timeOfMax)) AS exchPairDate from dayDiffMinMaxWithTradingInfo 
where timeOfMax > timeOfMin AND (maxPriceUSD-minPriceUSD)/minPriceUSD > 1
AND ((atMaxPlus15+atMaxPlus30+atMaxPlus45+atMaxPlus60)/4 > 2*minPriceUSD OR
(atMaxMinus15+atMaxMinus30+atMaxMinus45+atMaxMinus60)/4 > 2*minPriceUSD OR
(atMaxPlus15+atMaxPlus30+atMaxMinus15+atMaxMinus30)/4 > 2*minPriceUSD)
AND exchangeName != 'coinMarketCap' AND exchangeName != 'coinExchange' 
AND UPPER(tradePair) REGEXP 
"BCH|ETH|XRP|USDT|LTC|EOS|DASH|ETC|QTUM|NEO|ZEC|XMR|OMG|VTC|BCC|XLM|HSR|GRS|WAVES|ZEN|MIOTA|WTC|STRAT|SYS|LSK|BTG|ETP|STORJ|MCO|GNT|FCT|BAT|POWR|SNT|VRC|XEM|KMD|BTS|NXT|SYNX|ARK|XVG|XDN|SALT|MTL|BCN|NAS|ADA|PAY|ADX|ARDR|DOGE|MONA|LINK|BQX|BNB|KNC|RISE|DGB|XST|MOD|TRST|OK|CVC|EVX|ZRX|AST|VIA|DNT|SC|GXS|SNGLS|ATB|MAID|TRX|PIVX|KCS|BNT|RPX|NAV|CTR|XZC|GAS|TX|REP|STEEM|MCAP|FTC|GNO|RBY|GAME|ICN");

SELECT * FROM dayDiffMinMaxWithTradingInfo where recordDay < '2017-10-02 03:00:00';	
SELECT count(*) from dayDiffMinMaxWithTradingInfo where timeOfMax > timeOfMin AND (maxPriceUSD-minPriceUSD)/minPriceUSD > 1
AND ((atMaxPlus15+atMaxPlus30+atMaxPlus45+atMaxPlus60)/4 > 1.5*minPriceUSD OR
(atMaxMinus15+atMaxMinus30+atMaxMinus45+atMaxMinus60)/4 > 1.5*minPriceUSD OR
(atMaxPlus15+atMaxPlus30+atMaxMinus15+atMaxMinus30)/4 > 1.5*minPriceUSD)
AND exchangeName != 'coinMarketCap' AND exchangeName != 'coinExchange' 
AND (buyHistoryAmount > 10 OR sellHistoryAmount > 10);

SELECT count(*) from dayDiffMinMaxWithTradingInfo where (buyHistoryAmount > 10 OR sellHistoryAmount > 10) 
AND exchangeName != 'coinMarketCap' AND exchangeName != 'coinExchange' ;

SELECT count(*) FROM dayDiffMinMaxWithTradingInfo;	


-- del 

SELECT * FROM cTicker24HrMinMaxPlus60Minus60NoNull where recordDay < '2017-10-02 03:00:00';			

SELECT count(*) from cTicker24HrMinMaxPlus60Minus60NoNull where timeOfMax > timeOfMin AND (maxPriceUSD-minPriceUSD)/minPriceUSD > 1
AND ((atMaxPlus15+atMaxPlus30+atMaxPlus45+atMaxPlus60)/4 > 2*minPriceUSD ||
(atMaxMinus15+atMaxMinus30+atMaxMinus45+atMaxMinus60)/4 > 2*minPriceUSD ||
(atMaxPlus15+atMaxPlus30+atMaxMinus15+atMaxMinus30)/4 > 2*minPriceUSD)
AND exchangeName != 'coinMarketCap' AND exchangeName != 'coinExchange' ;

SELECT * FROM cTicker24HrMinMaxPlus60Minus60NoNull where recordDay < '2017-10-02 03:00:00';			
SELECT count(*) from cTicker24HrMinMaxPlus60Minus60NoNull where timeOfMax > timeOfMin AND (maxPriceUSD-minPriceUSD)/minPriceUSD > 1
AND (atMaxPlus15+atMaxPlus30+atMaxPlus45+atMaxPlus60)/4 > 0.5*maxPriceUSD 
AND exchangeName != 'coinMarketCap' ;

SELECT count(*) from cTicker24HrMinMaxPlus60Minus60NoNull where timeOfMax > timeOfMin AND (maxPriceUSD-minPriceUSD)/minPriceUSD > 1
AND (atMaxPlus15+atMaxPlus30+atMaxPlus45+atMaxPlus60)/4 > 2*minPriceUSD 
AND exchangeName != 'coinMarketCap' ;


SELECT * FROM cTicker24HrMinMaxPlus60NoNull where recordDay < '2017-10-02 03:00:00';														
SELECT count(*) from cTicker24HrMinMaxPlus60NoNull ;
SELECT count(*) from cTicker24HrMinMaxPlus60NoNull where priceUSDMaxPlus30 IS NULL;
SELECT count(*) from cTicker24HrMinMaxPlus60NoNull where timeOfMax > timeOfMin AND (maxPriceUSD-minPriceUSD)/minPriceUSD > 1
AND (priceUSDMaxPlus15+priceUSDMaxPlus30+priceUSDMaxPlus45+priceUSDMaxPlus60)/4 > 0.5*maxPriceUSD 
AND exchangeName != 'coinMarketCap';

SELECT count(*) from cTicker24HrMinMaxPlus60Minus60 where atMaxMinus45 IS NULL;

SELECT * FROM cTicker24HrMinMaxPlus60 where recordDay < '2017-10-02 03:00:00';														
SELECT count(*) from cTicker24HrMinMaxPlus60 ;
SELECT count(*) from cTicker24HrMinMaxPlus60 where priceUSDMaxPlus45 IS NULL;

SELECT count(*) from cTicker24HrMinMaxPlus60 where timeOfMax > timeOfMin and (maxPriceUSD-minPriceUSD)/minPriceUSD > 1;

SELECT count(*) from cTicker24HrMinMaxPlus60 where ((timeOfMax > timeOfMin) AND ((maxPriceUSD-minPriceUSD)/minPriceUSD > 1)
AND (((priceUSDMaxPlus15+priceUSDMaxPlus30+priceUSDMaxPlus45+priceUSDMaxPlus60)/4) > 0.5*maxPriceUSD));

SELECT count(*) from cTicker24HrMinMaxPlus60 where ((timeOfMax > timeOfMin) AND ((maxPriceUSD-minPriceUSD)/minPriceUSD > 1)
AND (((priceUSDMaxPlus15+priceUSDMaxPlus30+priceUSDMaxPlus45)/3) > 0.5*maxPriceUSD));

SELECT count(*) from cTicker24HrMinMaxPlus60 where ((timeOfMax > timeOfMin) AND ((maxPriceUSD-minPriceUSD)/minPriceUSD > 1)
AND (((priceUSDMaxPlus15+priceUSDMaxPlus30)/2) > 0.5*maxPriceUSD));
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
 


