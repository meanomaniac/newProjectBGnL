/*
This is the 2nd script. Its goal is to generate a table called 'mthDiffMinMaxWithTradingInfo' with the following:
For about 36 days of data gathered at the time of the development of this script, for every trade pair in each exchange, get the:

1) minimum price over the entire duration and at what time it happened
2) maximum price over the entire duration and at what time it happened
3) the price every 15 mins for 60 mins before and after the max occured 
4) the buys and sells that are present as openOrders at the time of max
5) the buys and sells history at the time of max 


The above table is achieved stepwise with a new table generated for each of:

1) first getting the max of each trade pair in each exchange
2) then getting the time of that max value
3) then joining the above 2 tables to have the max value and the max time in the same table
4) then creating a table for getting the price of the tradepair every 15 mins for 60 mins before and after the time of max
5) repeat the steps 1), 2) and 3) from above but this time for getting the min value and the time of min
6) then the table from step 4) and step 6) are combined to form the cTicker1MthHrMinMaxPlus60Minus60 table (note that you may find 
2 additional tables just above this table - cTicker1MthHrMinMax and cTicker1MthHrMinMaxPlus60 but these may not be needed)
7) finally the table mthDiffMinMaxWithTradingInfo is created which combines the table from the above step and the tables for the 15 mins avg
of openOrders and ordeHistory from the previous script to add the the buys and sells history at the time of max 

*/
use pocu3;
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- creating the max table
CREATE TABLE cTicker1MthHrMax (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	maxPriceUSD FLOAT NULL
);

INSERT INTO cTicker1MthHrMax
    SELECT  exchangeName, tradePair, max(askPriceUSD) as maxPrice from cTicker15MinAvg
	GROUP BY tradePair, exchangeName ORDER BY tradePair;

select count(*) from cTicker1MthHrMax;
    
ALTER TABLE cTicker1MthHrMax ADD INDEX exchangePair (exchangeName, tradePair);

CREATE TABLE cTicker1MthHrMaxTIme0 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	timeOfMax DATETIME NULL
);

INSERT INTO cTicker1MthHrMaxTIme0
SELECT cTicker1MthHrMaxTemp.exchangeName, cTicker1MthHrMaxTemp.tradePair, cTicker15MinAvgTemp.recordTime
from cTicker1MthHrMax AS cTicker1MthHrMaxTemp
LEFT JOIN cTicker15MinAvg cTicker15MinAvgTemp ON ( cTicker15MinAvgTemp.exchangeName = cTicker1MthHrMaxTemp.exchangeName
																							AND cTicker15MinAvgTemp.tradePair = cTicker1MthHrMaxTemp.tradePair
                                                                                            AND cTicker15MinAvgTemp.askPriceUSD = cTicker1MthHrMaxTemp.maxPriceUSD)
GROUP BY cTicker15MinAvgTemp.tradePair, cTicker15MinAvgTemp.exchangeName ORDER BY cTicker15MinAvgTemp.tradePair;                                                                                             

ALTER TABLE cTicker1MthHrMaxTIme0 ADD INDEX exchangePair (exchangeName, tradePair);

CREATE TABLE cTicker1MthHrMaxFInal (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	maxPriceUSD FLOAT NULL,
    timeOfMax DATETIME NULL
);

INSERT INTO cTicker1MthHrMaxFInal 
SELECT cTicker1MthHrMaxTemp.exchangeName, cTicker1MthHrMaxTemp.tradePair,
cTicker1MthHrMaxTemp.maxPriceUSD, cTicker1MthHrMaxTIme0Temp.timeOfMax
from cTicker1MthHrMax AS cTicker1MthHrMaxTemp
LEFT JOIN cTicker1MthHrMaxTIme0 cTicker1MthHrMaxTIme0Temp ON ( cTicker1MthHrMaxTIme0Temp.exchangeName = cTicker1MthHrMaxTemp.exchangeName
																							AND cTicker1MthHrMaxTIme0Temp.tradePair = cTicker1MthHrMaxTemp.tradePair);

ALTER TABLE cTicker1MthHrMaxFInal ADD INDEX exchangePair (exchangeName, tradePair);

CREATE TABLE cTicker1MthHrMaxFinalPlus15 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	maxPriceUSD FLOAT NULL,
    timeOfMax DATETIME NULL,
	priceUSDPlus15 FLOAT NULL
);

INSERT into cTicker1MthHrMaxFinalPlus15
SELECT cTicker1MthHrMaxFinalTemp.exchangeName, cTicker1MthHrMaxFinalTemp.tradePair, 
cTicker1MthHrMaxFinalTemp.maxPriceUSD, cTicker1MthHrMaxFinalTemp.timeOfMax, cTicker15MinAvgTemp.askPriceUSD
from cTicker1MthHrMaxFInal AS cTicker1MthHrMaxFinalTemp
LEFT JOIN cTicker15MinAvg cTicker15MinAvgTemp ON ( cTicker15MinAvgTemp.exchangeName = cTicker1MthHrMaxFinalTemp.exchangeName
																							AND cTicker15MinAvgTemp.tradePair = cTicker1MthHrMaxFinalTemp.tradePair
																							AND FROM_UNIXTIME((UNIX_TIMESTAMP(recordTime)) - 900) = cTicker1MthHrMaxFinalTemp.timeOfMax);                                                                                           

ALTER TABLE cTicker1MthHrMaxFinalPlus15 ADD INDEX exchangePair (exchangeName, tradePair);

CREATE TABLE cTicker1MthHrMaxFinalPlus30 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	maxPriceUSD FLOAT NULL,
    timeOfMax DATETIME NULL,
	priceUSDPlus15 FLOAT NULL,
    priceUSDPlus30 FLOAT NULL
);

INSERT into cTicker1MthHrMaxFinalPlus30
SELECT cTicker1MthHrMaxFinalTemp.exchangeName, cTicker1MthHrMaxFinalTemp.tradePair, 
cTicker1MthHrMaxFinalTemp.maxPriceUSD, cTicker1MthHrMaxFinalTemp.timeOfMax, cTicker1MthHrMaxFinalTemp.priceUSDPlus15,
cTicker15MinAvgTemp.askPriceUSD
from cTicker1MthHrMaxFinalPlus15 AS cTicker1MthHrMaxFinalTemp
LEFT JOIN cTicker15MinAvg cTicker15MinAvgTemp ON ( cTicker15MinAvgTemp.exchangeName = cTicker1MthHrMaxFinalTemp.exchangeName
																							AND cTicker15MinAvgTemp.tradePair = cTicker1MthHrMaxFinalTemp.tradePair
																							AND FROM_UNIXTIME((UNIX_TIMESTAMP(recordTime)) - 1800) = cTicker1MthHrMaxFinalTemp.timeOfMax);                                                                                           

ALTER TABLE cTicker1MthHrMaxFinalPlus30 ADD INDEX exchangePair (exchangeName, tradePair);

CREATE TABLE cTicker1MthHrMaxFinalPlus45 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	maxPriceUSD FLOAT NULL,
    timeOfMax DATETIME NULL,
	priceUSDPlus15 FLOAT NULL,
    priceUSDPlus30 FLOAT NULL,
    priceUSDPlus45 FLOAT NULL
);

INSERT into cTicker1MthHrMaxFinalPlus45
SELECT cTicker1MthHrMaxFinalTemp.exchangeName, cTicker1MthHrMaxFinalTemp.tradePair, 
cTicker1MthHrMaxFinalTemp.maxPriceUSD, cTicker1MthHrMaxFinalTemp.timeOfMax, cTicker1MthHrMaxFinalTemp.priceUSDPlus15,
cTicker1MthHrMaxFinalTemp.priceUSDPlus30, cTicker15MinAvgTemp.askPriceUSD
from cTicker1MthHrMaxFinalPlus30 AS cTicker1MthHrMaxFinalTemp
LEFT JOIN cTicker15MinAvg cTicker15MinAvgTemp ON ( cTicker15MinAvgTemp.exchangeName = cTicker1MthHrMaxFinalTemp.exchangeName
																							AND cTicker15MinAvgTemp.tradePair = cTicker1MthHrMaxFinalTemp.tradePair
																							AND FROM_UNIXTIME((UNIX_TIMESTAMP(recordTime)) - 2700) = cTicker1MthHrMaxFinalTemp.timeOfMax);                                                                                           

ALTER TABLE cTicker1MthHrMaxFinalPlus45 ADD INDEX exchangePair (exchangeName, tradePair);

CREATE TABLE cTicker1MthHrMaxFinalPlus60 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	maxPriceUSD FLOAT NULL,
    timeOfMax DATETIME NULL,
	priceUSDPlus15 FLOAT NULL,
    priceUSDPlus30 FLOAT NULL,
    priceUSDPlus45 FLOAT NULL,
	priceUSDPlus60 FLOAT NULL
);

INSERT into cTicker1MthHrMaxFinalPlus60
SELECT cTicker1MthHrMaxFinalTemp.exchangeName, cTicker1MthHrMaxFinalTemp.tradePair,
cTicker1MthHrMaxFinalTemp.maxPriceUSD, cTicker1MthHrMaxFinalTemp.timeOfMax, cTicker1MthHrMaxFinalTemp.priceUSDPlus15,
cTicker1MthHrMaxFinalTemp.priceUSDPlus30, cTicker1MthHrMaxFinalTemp.priceUSDPlus45, cTicker15MinAvgTemp.askPriceUSD
from cTicker1MthHrMaxFinalPlus45 AS cTicker1MthHrMaxFinalTemp
LEFT JOIN cTicker15MinAvg cTicker15MinAvgTemp ON ( cTicker15MinAvgTemp.exchangeName = cTicker1MthHrMaxFinalTemp.exchangeName
																							AND cTicker15MinAvgTemp.tradePair = cTicker1MthHrMaxFinalTemp.tradePair
																							AND FROM_UNIXTIME((UNIX_TIMESTAMP(recordTime)) - 3600) = cTicker1MthHrMaxFinalTemp.timeOfMax);                                                                                           

ALTER TABLE cTicker1MthHrMaxFinalPlus60 ADD INDEX exchangePair (exchangeName, tradePair);


CREATE TABLE cTicker1MthHrMaxFinalPlus60Minus15 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	maxPriceUSD FLOAT NULL,
    timeOfMax DATETIME NULL,
    priceUSDMinus15 FLOAT NULL,
	priceUSDPlus15 FLOAT NULL,
    priceUSDPlus30 FLOAT NULL,
    priceUSDPlus45 FLOAT NULL,
	priceUSDPlus60 FLOAT NULL
);

INSERT into cTicker1MthHrMaxFinalPlus60Minus15
SELECT cTicker1MthHrMaxFinalTemp.exchangeName, cTicker1MthHrMaxFinalTemp.tradePair, 
cTicker1MthHrMaxFinalTemp.maxPriceUSD, cTicker1MthHrMaxFinalTemp.timeOfMax, cTicker15MinAvgTemp.askPriceUSD,
cTicker1MthHrMaxFinalTemp.priceUSDPlus15, cTicker1MthHrMaxFinalTemp.priceUSDPlus30, cTicker1MthHrMaxFinalTemp.priceUSDPlus45,
cTicker1MthHrMaxFinalTemp.priceUSDPlus60
from cTicker1MthHrMaxFinalPlus60 AS cTicker1MthHrMaxFinalTemp
LEFT JOIN cTicker15MinAvg cTicker15MinAvgTemp ON ( cTicker15MinAvgTemp.exchangeName = cTicker1MthHrMaxFinalTemp.exchangeName
																							AND cTicker15MinAvgTemp.tradePair = cTicker1MthHrMaxFinalTemp.tradePair
																							AND FROM_UNIXTIME((UNIX_TIMESTAMP(recordTime)) +900) = cTicker1MthHrMaxFinalTemp.timeOfMax);                                                                                           

ALTER TABLE cTicker1MthHrMaxFinalPlus60Minus15 ADD INDEX exchangePair (exchangeName, tradePair);


CREATE TABLE cTicker1MthHrMaxFinalPlus60Minus30 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	maxPriceUSD FLOAT NULL,
    timeOfMax DATETIME NULL,
	priceUSDMinus30 FLOAT NULL,
    priceUSDMinus15 FLOAT NULL,
	priceUSDPlus15 FLOAT NULL,
    priceUSDPlus30 FLOAT NULL,
    priceUSDPlus45 FLOAT NULL,
	priceUSDPlus60 FLOAT NULL
);

INSERT into cTicker1MthHrMaxFinalPlus60Minus30
SELECT cTicker1MthHrMaxFinalTemp.exchangeName, cTicker1MthHrMaxFinalTemp.tradePair, 
cTicker1MthHrMaxFinalTemp.maxPriceUSD, cTicker1MthHrMaxFinalTemp.timeOfMax, cTicker15MinAvgTemp.askPriceUSD,
cTicker1MthHrMaxFinalTemp.priceUSDMinus15,
cTicker1MthHrMaxFinalTemp.priceUSDPlus15, cTicker1MthHrMaxFinalTemp.priceUSDPlus30, cTicker1MthHrMaxFinalTemp.priceUSDPlus45,
cTicker1MthHrMaxFinalTemp.priceUSDPlus60
from cTicker1MthHrMaxFinalPlus60Minus15 AS cTicker1MthHrMaxFinalTemp
LEFT JOIN cTicker15MinAvg cTicker15MinAvgTemp ON ( cTicker15MinAvgTemp.exchangeName = cTicker1MthHrMaxFinalTemp.exchangeName
																							AND cTicker15MinAvgTemp.tradePair = cTicker1MthHrMaxFinalTemp.tradePair
																							AND FROM_UNIXTIME((UNIX_TIMESTAMP(recordTime)) +1800) = cTicker1MthHrMaxFinalTemp.timeOfMax);                                                                                           

ALTER TABLE cTicker1MthHrMaxFinalPlus60Minus30 ADD INDEX exchangePair (exchangeName, tradePair);



CREATE TABLE cTicker1MthHrMaxFinalPlus60Minus45 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
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

INSERT into cTicker1MthHrMaxFinalPlus60Minus45
SELECT cTicker1MthHrMaxFinalTemp.exchangeName, cTicker1MthHrMaxFinalTemp.tradePair, 
cTicker1MthHrMaxFinalTemp.maxPriceUSD, cTicker1MthHrMaxFinalTemp.timeOfMax, cTicker15MinAvgTemp.askPriceUSD,
cTicker1MthHrMaxFinalTemp.priceUSDMinus30, cTicker1MthHrMaxFinalTemp.priceUSDMinus15,
cTicker1MthHrMaxFinalTemp.priceUSDPlus15, cTicker1MthHrMaxFinalTemp.priceUSDPlus30, cTicker1MthHrMaxFinalTemp.priceUSDPlus45,
cTicker1MthHrMaxFinalTemp.priceUSDPlus60
from cTicker1MthHrMaxFinalPlus60Minus30 AS cTicker1MthHrMaxFinalTemp
LEFT JOIN cTicker15MinAvg cTicker15MinAvgTemp ON ( cTicker15MinAvgTemp.exchangeName = cTicker1MthHrMaxFinalTemp.exchangeName
																							AND cTicker15MinAvgTemp.tradePair = cTicker1MthHrMaxFinalTemp.tradePair
																							AND FROM_UNIXTIME((UNIX_TIMESTAMP(recordTime)) +2700) = cTicker1MthHrMaxFinalTemp.timeOfMax);                                                                                           

ALTER TABLE cTicker1MthHrMaxFinalPlus60Minus45 ADD INDEX exchangePair (exchangeName, tradePair);


CREATE TABLE cTicker1MthHrMaxFinalPlus60Minus60 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
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

INSERT into cTicker1MthHrMaxFinalPlus60Minus60
SELECT cTicker1MthHrMaxFinalTemp.exchangeName, cTicker1MthHrMaxFinalTemp.tradePair, 
cTicker1MthHrMaxFinalTemp.maxPriceUSD, cTicker1MthHrMaxFinalTemp.timeOfMax, cTicker15MinAvgTemp.askPriceUSD,
cTicker1MthHrMaxFinalTemp.priceUSDMinus45, cTicker1MthHrMaxFinalTemp.priceUSDMinus30, cTicker1MthHrMaxFinalTemp.priceUSDMinus15,
cTicker1MthHrMaxFinalTemp.priceUSDPlus15, cTicker1MthHrMaxFinalTemp.priceUSDPlus30, cTicker1MthHrMaxFinalTemp.priceUSDPlus45,
cTicker1MthHrMaxFinalTemp.priceUSDPlus60
from cTicker1MthHrMaxFinalPlus60Minus45 AS cTicker1MthHrMaxFinalTemp
LEFT JOIN cTicker15MinAvg cTicker15MinAvgTemp ON ( cTicker15MinAvgTemp.exchangeName = cTicker1MthHrMaxFinalTemp.exchangeName
																							AND cTicker15MinAvgTemp.tradePair = cTicker1MthHrMaxFinalTemp.tradePair
																							AND FROM_UNIXTIME((UNIX_TIMESTAMP(recordTime)) +3600) = cTicker1MthHrMaxFinalTemp.timeOfMax);                                                                                           

ALTER TABLE cTicker1MthHrMaxFinalPlus60Minus60 ADD INDEX exchangePair (exchangeName, tradePair);

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- creating the min table

CREATE TABLE cTicker1MthHrMin (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	minPriceUSD FLOAT NULL
);
    
INSERT INTO cTicker1MthHrMin 
    SELECT  exchangeName, tradePair, min(askPriceUSD) as minPrice from cTicker15MinAvg
	GROUP BY tradePair, exchangeName ORDER BY tradePair;
    
select count(*) from cTicker1MthHrMin;

ALTER TABLE cTicker1MthHrMin ADD INDEX exchangePair (exchangeName, tradePair);

CREATE TABLE cTicker1MthHrMinTIme0 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	timeOfMin DATETIME NULL
);

INSERT INTO cTicker1MthHrMinTIme0
SELECT cTicker1MthHrMinTemp.exchangeName, cTicker1MthHrMinTemp.tradePair, cTicker15MinAvgTemp.recordTime
from cTicker1MthHrMin AS cTicker1MthHrMinTemp
LEFT JOIN cTicker15MinAvg cTicker15MinAvgTemp ON ( cTicker15MinAvgTemp.exchangeName = cTicker1MthHrMinTemp.exchangeName
																							AND cTicker15MinAvgTemp.tradePair = cTicker1MthHrMinTemp.tradePair
                                                                                            AND cTicker15MinAvgTemp.askPriceUSD = cTicker1MthHrMinTemp.minPriceUSD)
GROUP BY cTicker15MinAvgTemp.tradePair, cTicker15MinAvgTemp.exchangeName ORDER BY cTicker15MinAvgTemp.tradePair;                                                                                             

ALTER TABLE cTicker1MthHrMinTIme0 ADD INDEX exchangePair (exchangeName, tradePair);

CREATE TABLE cTicker1MthHrMinFInal (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	minPriceUSD FLOAT NULL,
    timeOfMin DATETIME NULL
);

INSERT INTO cTicker1MthHrMinFInal 
SELECT cTicker1MthHrMinTemp.exchangeName, cTicker1MthHrMinTemp.tradePair, 
cTicker1MthHrMinTemp.minPriceUSD, cTicker1MthHrMinTIme0Temp.timeOfMin
from cTicker1MthHrMin AS cTicker1MthHrMinTemp
LEFT JOIN cTicker1MthHrMinTIme0 cTicker1MthHrMinTIme0Temp ON ( cTicker1MthHrMinTIme0Temp.exchangeName = cTicker1MthHrMinTemp.exchangeName
																							AND cTicker1MthHrMinTIme0Temp.tradePair = cTicker1MthHrMinTemp.tradePair);

ALTER TABLE cTicker1MthHrMinFInal ADD INDEX exchangePair (exchangeName, tradePair);

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
-- creating the combined min, max table

 -- the below 2 tables may not be needed

CREATE TABLE cTicker1MthHrMinMax (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	minPriceUSD FLOAT NULL,
    timeOfMin DATETIME NULL,
	maxPriceUSD FLOAT NULL,
    timeOfMax DATETIME NULL
);

INSERT INTO cTicker1MthHrMinMax
select cTicker1MthHrMaxFinalTemp.exchangeName, cTicker1MthHrMaxFinalTemp.tradePair, 
cTicker1MthHrMinFinalTemp.minPriceUSD, cTicker1MthHrMinFinalTemp.timeOfMin, cTicker1MthHrMaxFinalTemp.maxPriceUSD, 
cTicker1MthHrMaxFinalTemp.timeOfMax 
from  cTicker1MthHrMaxFInal AS cTicker1MthHrMaxFinalTemp 
LEFT JOIN
cTicker1MthHrMinFInal cTicker1MthHrMinFinalTemp ON (cTicker1MthHrMinFinalTemp.exchangeName = cTicker1MthHrMaxFinalTemp.exchangeName
																	AND cTicker1MthHrMinFinalTemp.tradePair = cTicker1MthHrMaxFinalTemp.tradePair);                                                                     
                                                                        

ALTER TABLE cTicker1MthHrMinMax ADD INDEX exchangePair (exchangeName, tradePair);

CREATE TABLE cTicker1MthHrMinMaxPlus60 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	minPriceUSD FLOAT NULL,
    timeOfMin DATETIME NULL,
	maxPriceUSD FLOAT NULL,
    timeOfMax DATETIME NULL,
	priceUSDMaxPlus15 FLOAT NULL,
    priceUSDMaxPlus30 FLOAT NULL,
    priceUSDMaxPlus45 FLOAT NULL,
	priceUSDMaxPlus60 FLOAT NULL
);

INSERT INTO cTicker1MthHrMinMaxPlus60
select cTicker1MthHrMaxFinalTemp.exchangeName, cTicker1MthHrMaxFinalTemp.tradePair, 
cTicker1MthHrMaxFinalTemp.minPriceUSD, cTicker1MthHrMaxFinalTemp.timeOfMin, cTicker1MthHrMaxFinalTemp.maxPriceUSD, 
cTicker1MthHrMaxFinalTemp.timeOfMax , cTicker1MthHrFinalTemp.priceUSDPlus15, cTicker1MthHrFinalTemp.priceUSDPlus30, 
cTicker1MthHrFinalTemp.priceUSDPlus45, cTicker1MthHrFinalTemp.priceUSDPlus60
from  cTicker1MthHrMinMax AS cTicker1MthHrMaxFinalTemp 
LEFT JOIN
cTicker1MthHrMaxFinalPlus60 cTicker1MthHrFinalTemp ON (cTicker1MthHrFinalTemp.exchangeName = cTicker1MthHrMaxFinalTemp.exchangeName
																	AND cTicker1MthHrFinalTemp.tradePair = cTicker1MthHrMaxFinalTemp.tradePair);      
                                                 
ALTER TABLE cTicker1MthHrMinMaxPlus60 ADD INDEX exchangePair (exchangeName, tradePair);

CREATE TABLE cTicker1MthHrMinMaxPlus60NoNull LIKE cTicker1MthHrMinMaxPlus60; 
INSERT cTicker1MthHrMinMaxPlus60NoNull SELECT * FROM cTicker1MthHrMinMaxPlus60;

UPDATE cTicker1MthHrMinMaxPlus60NoNull SET priceUSDMaxPlus15 = maxPriceUSD where priceUSDMaxPlus15 IS NULL;
UPDATE cTicker1MthHrMinMaxPlus60NoNull SET priceUSDMaxPlus30 = priceUSDMaxPlus15 where priceUSDMaxPlus30 IS NULL;
UPDATE cTicker1MthHrMinMaxPlus60NoNull SET priceUSDMaxPlus45 = priceUSDMaxPlus30 where priceUSDMaxPlus45 IS NULL;
UPDATE cTicker1MthHrMinMaxPlus60NoNull SET priceUSDMaxPlus60 = priceUSDMaxPlus45 where priceUSDMaxPlus60 IS NULL;
use pocu3;

 -- the above may not be needed

CREATE TABLE cTicker1MthHrMinMaxPlus60Minus60 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
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

INSERT INTO cTicker1MthHrMinMaxPlus60Minus60
select cTicker1MthHrMaxFinalTemp.exchangeName, cTicker1MthHrMaxFinalTemp.tradePair, 
cTicker1MthHrMaxFinalTemp.minPriceUSD, cTicker1MthHrMaxFinalTemp.timeOfMin, cTicker1MthHrMaxFinalTemp.maxPriceUSD, 
cTicker1MthHrMaxFinalTemp.timeOfMax , 
cTicker1MthHrFinalTemp.priceUSDMinus60, cTicker1MthHrFinalTemp.priceUSDMinus45, cTicker1MthHrFinalTemp.priceUSDMinus30, 
cTicker1MthHrFinalTemp.priceUSDMinus15, 
cTicker1MthHrMaxFinalTemp.priceUSDMaxPlus15, cTicker1MthHrMaxFinalTemp.priceUSDMaxPlus30, 
cTicker1MthHrMaxFinalTemp.priceUSDMaxPlus45, cTicker1MthHrMaxFinalTemp.priceUSDMaxPlus60
from  cTicker1MthHrMinMaxPlus60NoNull AS cTicker1MthHrMaxFinalTemp 
LEFT JOIN
cTicker1MthHrMaxFinalPlus60Minus60 cTicker1MthHrFinalTemp ON (cTicker1MthHrFinalTemp.exchangeName = cTicker1MthHrMaxFinalTemp.exchangeName
																	AND cTicker1MthHrFinalTemp.tradePair = cTicker1MthHrMaxFinalTemp.tradePair);      
                                                 
ALTER TABLE cTicker1MthHrMinMaxPlus60Minus60 ADD INDEX exchangePair (exchangeName, tradePair);

CREATE TABLE cTicker1MthHrMinMaxPlus60Minus60NoNull LIKE cTicker1MthHrMinMaxPlus60Minus60; 
INSERT cTicker1MthHrMinMaxPlus60Minus60NoNull SELECT * FROM cTicker1MthHrMinMaxPlus60Minus60;

describe cTicker1MthHrMinMaxPlus60Minus60NoNull;
UPDATE cTicker1MthHrMinMaxPlus60Minus60NoNull SET atMaxMinus45 = atMaxMinus60 where atMaxMinus45 IS NULL;
UPDATE cTicker1MthHrMinMaxPlus60Minus60NoNull SET atMaxMinus30 = atMaxPlus15 where atMaxMinus30 IS NULL;
UPDATE cTicker1MthHrMinMaxPlus60Minus60NoNull SET atMaxMinus15 = atMaxPlus30 where atMaxMinus15 IS NULL;


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- combining the minMax table with openOrders and OrderHistory


CREATE TABLE mthDiffMinMaxWithTradingInfo (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
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

INSERT INTO mthDiffMinMaxWithTradingInfo 
SELECT cTicker1MthHrMinMaxPlus60Minus60NoNullTemp.exchangeName, cTicker1MthHrMinMaxPlus60Minus60NoNullTemp.tradePair, 
cTicker1MthHrMinMaxPlus60Minus60NoNullTemp.minPriceUSD, 
cTicker1MthHrMinMaxPlus60Minus60NoNullTemp.timeOfMin, cTicker1MthHrMinMaxPlus60Minus60NoNullTemp.maxPriceUSD, 
cTicker1MthHrMinMaxPlus60Minus60NoNullTemp.timeOfMax, cTicker1MthHrMinMaxPlus60Minus60NoNullTemp.atMaxMinus60, 
cTicker1MthHrMinMaxPlus60Minus60NoNullTemp.atMaxMinus45, cTicker1MthHrMinMaxPlus60Minus60NoNullTemp.atMaxMinus30, 
cTicker1MthHrMinMaxPlus60Minus60NoNullTemp.atMaxMinus15, cTicker1MthHrMinMaxPlus60Minus60NoNullTemp.atMaxPlus15, 
cTicker1MthHrMinMaxPlus60Minus60NoNullTemp.atMaxPlus30, cTicker1MthHrMinMaxPlus60Minus60NoNullTemp.atMaxPlus45, 
cTicker1MthHrMinMaxPlus60Minus60NoNullTemp.atMaxPlus60,
openOrders15MinAvgTemp.totalBuyAmount, openOrders15MinAvgTemp.totalSellAmount,
orderHistory15MinAvgTemp.totalBuyAmount, orderHistory15MinAvgTemp.totalSellAmount
FROM cTicker1MthHrMinMaxPlus60Minus60NoNull AS cTicker1MthHrMinMaxPlus60Minus60NoNullTemp
LEFT JOIN 
openOrders15MinAvg openOrders15MinAvgTemp ON ( openOrders15MinAvgTemp.exchangeName = cTicker1MthHrMinMaxPlus60Minus60NoNullTemp.exchangeName
																							AND openOrders15MinAvgTemp.tradePair = cTicker1MthHrMinMaxPlus60Minus60NoNullTemp.tradePair
																							AND openOrders15MinAvgTemp.recordTime = cTicker1MthHrMinMaxPlus60Minus60NoNullTemp.timeOfMax)
LEFT JOIN 
orderHistory15MinAvg orderHistory15MinAvgTemp ON ( orderHistory15MinAvgTemp.exchangeName = cTicker1MthHrMinMaxPlus60Minus60NoNullTemp.exchangeName
																							AND orderHistory15MinAvgTemp.tradePair = cTicker1MthHrMinMaxPlus60Minus60NoNullTemp.tradePair
																							AND orderHistory15MinAvgTemp.recordTime = cTicker1MthHrMinMaxPlus60Minus60NoNullTemp.timeOfMax);

ALTER TABLE mthDiffMinMaxWithTradingInfo ADD INDEX exchangePair (exchangeName, tradePair);
select count(*) from mthDiffMinMaxWithTradingInfo;

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- TEST 
use pocu3;

SELECT * FROM mthDiffMinMaxWithTradingInfo where recordDay < '2017-10-02 03:00:00';	

SELECT CONCAT(exchangeName, tradePair) AS exchTP
from mthDiffMinMaxWithTradingInfo 
where timeOfMax > timeOfMin AND (maxPriceUSD-minPriceUSD)/minPriceUSD > 1
AND exchangeName != 'coinMarketCap' AND exchangeName != 'coinExchange' ;

SELECT exchangeName, tradePair, timeOfMax AS exchPairDate, ROUND((maxPriceUSD-minPriceUSD)/minPriceUSD*100,2) as priceChangePerc
from mthDiffMinMaxWithTradingInfo 
where timeOfMax > timeOfMin AND (maxPriceUSD-minPriceUSD)/minPriceUSD > 1
AND exchangeName != 'coinMarketCap' AND exchangeName != 'coinExchange' 
ORDER BY priceChangePerc DESC;

SELECT exchangeName, tradePair, timeOfMax AS exchPairDate, ROUND((maxPriceUSD-minPriceUSD)/minPriceUSD*100,2) as priceChangePerc
from mthDiffMinMaxWithTradingInfo 
where timeOfMax > timeOfMin AND (maxPriceUSD-minPriceUSD)/minPriceUSD > 1
AND ((atMaxPlus15+atMaxPlus30+atMaxPlus45+atMaxPlus60)/4 > 1.5*minPriceUSD OR
(atMaxMinus15+atMaxMinus30+atMaxMinus45+atMaxMinus60)/4 > 1.5*minPriceUSD OR
(atMaxPlus15+atMaxPlus30+atMaxMinus15+atMaxMinus30)/4 > 1.5*minPriceUSD)
AND exchangeName != 'coinMarketCap' AND exchangeName != 'coinExchange' 
AND UPPER(tradePair) REGEXP 
"BCH|ETH|XRP|USDT|LTC|EOS|DASH|ETC|QTUM|NEO|ZEC|XMR|OMG|VTC|BCC|XLM|HSR|GRS|WAVES|ZEN|MIOTA|WTC|STRAT|SYS|LSK|BTG|ETP|STORJ|MCO|GNT|FCT|BAT|POWR|SNT|VRC|XEM|KMD|BTS|NXT|SYNX|ARK|XVG|XDN|SALT|MTL|BCN|NAS|ADA|PAY|ADX|ARDR|DOGE|MONA|LINK|BQX|BNB|KNC|RISE|DGB|XST|MOD|TRST|OK|CVC|EVX|ZRX|AST|VIA|DNT|SC|GXS|SNGLS|ATB|MAID|TRX|PIVX|KCS|BNT|RPX|NAV|CTR|XZC|GAS|TX|REP|STEEM|MCAP|FTC|GNO|RBY|GAME|ICN"
ORDER BY priceChangePerc DESC;

SELECT exchangeName, tradePair, timeOfMax AS exchPairDate, ROUND((maxPriceUSD-minPriceUSD)/minPriceUSD*100,2) as priceChangePerc
from mthDiffMinMaxWithTradingInfo 
where timeOfMax > timeOfMin AND (maxPriceUSD-minPriceUSD)/minPriceUSD > 1
AND ((atMaxPlus15+atMaxPlus30+atMaxPlus45+atMaxPlus60)/4 > 1.5*minPriceUSD OR
(atMaxMinus15+atMaxMinus30+atMaxMinus45+atMaxMinus60)/4 > 1.5*minPriceUSD OR
(atMaxPlus15+atMaxPlus30+atMaxMinus15+atMaxMinus30)/4 > 1.5*minPriceUSD)
AND exchangeName != 'coinMarketCap' AND exchangeName != 'coinExchange' 
AND UPPER(tradePair) REGEXP 
"BCH|ETH|XRP|USDT|LTC|EOS|DASH|ETC|QTUM|NEO|ZEC|XMR|OMG|VTC|BCC|XLM|HSR|GRS|WAVES|ZEN|MIOTA|WTC|STRAT|SYS|LSK|BTG|ETP|STORJ|MCO|GNT|FCT|BAT|POWR|SNT|VRC|XEM|KMD|BTS|NXT|SYNX|ARK|XVG|XDN|SALT|MTL|BCN|NAS|ADA|PAY|ADX|ARDR|DOGE|MONA|LINK|BQX|BNB|KNC|RISE|DGB|XST|MOD|TRST|OK|CVC|EVX|ZRX|AST|VIA|DNT|SC|GXS|SNGLS|ATB|MAID|TRX|PIVX|KCS|BNT|RPX|NAV|CTR|XZC|GAS|TX|REP|STEEM|MCAP|FTC|GNO|RBY|GAME|ICN"
ORDER BY priceChangePerc DESC;

SELECT * from cTicker where CONCAT(exchangeName, tradePair, DATE(recordTime)) IN 
(SELECT CONCAT(exchangeName, tradePair, DATE(timeOfMax)) AS exchPairDate from mthDiffMinMaxWithTradingInfo 
where timeOfMax > timeOfMin AND (maxPriceUSD-minPriceUSD)/minPriceUSD > 1
AND ((atMaxPlus15+atMaxPlus30+atMaxPlus45+atMaxPlus60)/4 > 2*minPriceUSD OR
(atMaxMinus15+atMaxMinus30+atMaxMinus45+atMaxMinus60)/4 > 2*minPriceUSD OR
(atMaxPlus15+atMaxPlus30+atMaxMinus15+atMaxMinus30)/4 > 2*minPriceUSD)
AND exchangeName != 'coinMarketCap' AND exchangeName != 'coinExchange' 
AND UPPER(tradePair) REGEXP 
"BCH|ETH|XRP|USDT|LTC|EOS|DASH|ETC|QTUM|NEO|ZEC|XMR|OMG|VTC|BCC|XLM|HSR|GRS|WAVES|ZEN|MIOTA|WTC|STRAT|SYS|LSK|BTG|ETP|STORJ|MCO|GNT|FCT|BAT|POWR|SNT|VRC|XEM|KMD|BTS|NXT|SYNX|ARK|XVG|XDN|SALT|MTL|BCN|NAS|ADA|PAY|ADX|ARDR|DOGE|MONA|LINK|BQX|BNB|KNC|RISE|DGB|XST|MOD|TRST|OK|CVC|EVX|ZRX|AST|VIA|DNT|SC|GXS|SNGLS|ATB|MAID|TRX|PIVX|KCS|BNT|RPX|NAV|CTR|XZC|GAS|TX|REP|STEEM|MCAP|FTC|GNO|RBY|GAME|ICN");

SELECT * FROM mthDiffMinMaxWithTradingInfo where recordDay < '2017-10-02 03:00:00';	
SELECT count(*) from mthDiffMinMaxWithTradingInfo where timeOfMax > timeOfMin AND (maxPriceUSD-minPriceUSD)/minPriceUSD > 1
AND ((atMaxPlus15+atMaxPlus30+atMaxPlus45+atMaxPlus60)/4 > 1.5*minPriceUSD OR
(atMaxMinus15+atMaxMinus30+atMaxMinus45+atMaxMinus60)/4 > 1.5*minPriceUSD OR
(atMaxPlus15+atMaxPlus30+atMaxMinus15+atMaxMinus30)/4 > 1.5*minPriceUSD)
AND exchangeName != 'coinMarketCap' AND exchangeName != 'coinExchange' 
AND (buyHistoryAmount > 10 OR sellHistoryAmount > 10);

SELECT count(*) from mthDiffMinMaxWithTradingInfo where (buyHistoryAmount > 10 OR sellHistoryAmount > 10) 
AND exchangeName != 'coinMarketCap' AND exchangeName != 'coinExchange' ;

SELECT count(*) FROM mthDiffMinMaxWithTradingInfo;	

select * from mthDiffMinMaxWithTradingInfo where tradePair = 'BTC-BCY' and exchangeName = 'bittrex';

SELECT * FROM mthDiffMinMaxWithTradingInfo where tradePair = 'BTC-MONA';

-- del 

SELECT * FROM cTicker1MthHrMinMaxPlus60Minus60NoNull where recordDay < '2017-10-02 03:00:00';			

SELECT count(*) from cTicker1MthHrMinMaxPlus60Minus60NoNull where timeOfMax > timeOfMin AND (maxPriceUSD-minPriceUSD)/minPriceUSD > 1
AND ((atMaxPlus15+atMaxPlus30+atMaxPlus45+atMaxPlus60)/4 > 2*minPriceUSD ||
(atMaxMinus15+atMaxMinus30+atMaxMinus45+atMaxMinus60)/4 > 2*minPriceUSD ||
(atMaxPlus15+atMaxPlus30+atMaxMinus15+atMaxMinus30)/4 > 2*minPriceUSD)
AND exchangeName != 'coinMarketCap' AND exchangeName != 'coinExchange' ;

SELECT * FROM cTicker1MthHrMinMaxPlus60Minus60NoNull where recordDay < '2017-10-02 03:00:00';			
SELECT count(*) from cTicker1MthHrMinMaxPlus60Minus60NoNull where timeOfMax > timeOfMin AND (maxPriceUSD-minPriceUSD)/minPriceUSD > 1
AND (atMaxPlus15+atMaxPlus30+atMaxPlus45+atMaxPlus60)/4 > 0.5*maxPriceUSD 
AND exchangeName != 'coinMarketCap' ;

SELECT count(*) from cTicker1MthHrMinMaxPlus60Minus60NoNull where timeOfMax > timeOfMin AND (maxPriceUSD-minPriceUSD)/minPriceUSD > 1
AND (atMaxPlus15+atMaxPlus30+atMaxPlus45+atMaxPlus60)/4 > 2*minPriceUSD 
AND exchangeName != 'coinMarketCap' ;


SELECT * FROM cTicker1MthHrMinMaxPlus60NoNull where recordDay < '2017-10-02 03:00:00';														
SELECT count(*) from cTicker1MthHrMinMaxPlus60NoNull ;
SELECT count(*) from cTicker1MthHrMinMaxPlus60NoNull where priceUSDMaxPlus30 IS NULL;
SELECT count(*) from cTicker1MthHrMinMaxPlus60NoNull where timeOfMax > timeOfMin AND (maxPriceUSD-minPriceUSD)/minPriceUSD > 1
AND (priceUSDMaxPlus15+priceUSDMaxPlus30+priceUSDMaxPlus45+priceUSDMaxPlus60)/4 > 0.5*maxPriceUSD 
AND exchangeName != 'coinMarketCap';

SELECT count(*) from cTicker1MthHrMinMaxPlus60Minus60 where atMaxMinus45 IS NULL;

SELECT * FROM cTicker1MthHrMinMaxPlus60 where recordDay < '2017-10-02 03:00:00';														
SELECT count(*) from cTicker1MthHrMinMaxPlus60 ;
SELECT count(*) from cTicker1MthHrMinMaxPlus60 where priceUSDMaxPlus45 IS NULL;

SELECT count(*) from cTicker1MthHrMinMaxPlus60 where timeOfMax > timeOfMin and (maxPriceUSD-minPriceUSD)/minPriceUSD > 1;

SELECT count(*) from cTicker1MthHrMinMaxPlus60 where ((timeOfMax > timeOfMin) AND ((maxPriceUSD-minPriceUSD)/minPriceUSD > 1)
AND (((priceUSDMaxPlus15+priceUSDMaxPlus30+priceUSDMaxPlus45+priceUSDMaxPlus60)/4) > 0.5*maxPriceUSD));

SELECT count(*) from cTicker1MthHrMinMaxPlus60 where ((timeOfMax > timeOfMin) AND ((maxPriceUSD-minPriceUSD)/minPriceUSD > 1)
AND (((priceUSDMaxPlus15+priceUSDMaxPlus30+priceUSDMaxPlus45)/3) > 0.5*maxPriceUSD));

SELECT count(*) from cTicker1MthHrMinMaxPlus60 where ((timeOfMax > timeOfMin) AND ((maxPriceUSD-minPriceUSD)/minPriceUSD > 1)
AND (((priceUSDMaxPlus15+priceUSDMaxPlus30)/2) > 0.5*maxPriceUSD));
select * from cTicker1MthHrMinMax where recordDay < '2017-10-02 03:00:00';
select * from cTicker1MthHrMaxFinalPlus15 where recordDay < '2017-10-02 03:00:00';
select * from cTicker1MthHrMin where recordDay < '2017-10-02 03:00:00';
select * from cTicker1MthHrMax where recordDay < '2017-10-02 03:00:00';
select * from cTicker1MthHrMaxTIme0 where recordDay < '2017-10-02 03:00:00';
select count(*) from cTicker1MthHrMax;
select count(*) from cTicker1MthHrMaxFInal ;

drop table cTicker1MthHrMin;
drop table cTicker1MthHrMax;

 SELECT  exchangeName, tradePair, DATE(recordTime) as recordDay, min(askPriceUSD) as minPrice, recordTime from cTicker15MinAvg
 where recordTime < '2017-10-02 01:00:00' and tradePair = '$$$/BTC';
	  SELECT  exchangeName, tradePair, DATE(recordTime) as recordDay, max(askPriceUSD) as minPrice, recordTime from cTicker15MinAvg
 where recordTime < '2017-10-02 01:00:00' and tradePair = '$$$/BTC';
	SELECT  *  from cTicker15MinAvg
 where recordTime < '2017-10-02 01:00:00' and tradePair = '$$$/BTC';
 
 	SELECT  *  from cTicker1MthHrMaxFInal
 where recordDay < '2017-10-02' ;
 	SELECT  *  from cTicker1MthHrMaxTIme0
 where recordDay < '2017-10-02' and tradePair = '$$$/BTC';
 


