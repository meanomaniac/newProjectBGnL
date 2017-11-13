use pocu3;

describe cTicker;
describe openOrders;
describe orderHistory;

CREATE TABLE cTicker15MinAvg (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	askPriceUSD FLOAT NULL,
	recordTime DATETIME NULL
);

CREATE TABLE cTicker15MinAvgBTCPrice (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	askPriceUSD FLOAT NULL,
    askPriceBTC FLOAT NULL,
	recordTime DATETIME NULL
);

select * from cTicker15MinAvgBTCPrice where tradePair = 'BTC-BCY' and exchangeName = 'bittrex';

-- took 208 secs
INSERT INTO cTicker15MinAvg
SELECT exchangeName, tradePair, avg(askPriceUSD) as avgPriceUSD, 
FROM_UNIXTIME((UNIX_TIMESTAMP(recordTime)) div 900*900 + 900) as timeRecorded
from cTicker
GROUP BY tradePair, exchangeName, timeRecorded ORDER BY timeRecorded, tradePair;
-- took 17 secs
ALTER TABLE cTicker15MinAvg ADD INDEX exchangePair (exchangeName, tradePair);

 -- 
 INSERT INTO cTicker15MinAvgBTCPrice
SELECT exchangeName, tradePair, avg(askPriceUSD) as avgPriceUSD, avg(askPriceBTC) as avgPriceBTC,
FROM_UNIXTIME((UNIX_TIMESTAMP(recordTime)) div 900*900 + 900) as timeRecorded
from cTicker
GROUP BY tradePair, exchangeName, timeRecorded ORDER BY timeRecorded, tradePair;
ALTER TABLE cTicker15MinAvgBTCPrice ADD INDEX exchangePair (exchangeName, tradePair);
    
select count(*) from cTicker15MinAvg;
select * from cTicker15MinAvg where recordTime < '2017-10-01 03:00:00' ;

-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE openOrders15MinAvg (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	recordTime DATETIME NULL,
	totalBuyAmount FLOAT NULL,
	totalSellAmount FLOAT NULL
);

-- took 171 secs
INSERT INTO openOrders15MinAvg
SELECT exchangeName, tradePair, FROM_UNIXTIME((UNIX_TIMESTAMP(recordTime)) div 900*900 + 900) as timeRecorded,
avg(totalBuyAmount) as avgTotalBuyAmount, avg(totalSellAmount) as avgTotalSellAmount
from openOrders
GROUP BY tradePair, exchangeName, timeRecorded ORDER BY timeRecorded, tradePair;
 
-- took 10 secs
ALTER TABLE openOrders15MinAvg ADD INDEX exchangePair (exchangeName, tradePair);

select count(*) from openOrders15MinAvg;
select * from openOrders15MinAvg where recordTime < '2017-10-01 03:00:00' ;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE orderHistory15MinAvg (
	exchangeName VARCHAR(15) NULL,
	exchangeName VARCHAR(20) NULL,
	recordTime DATETIME NULL,
	totalBuyAmount FLOAT NULL,
	totalSellAmount FLOAT NULL
);

-- took 185 secs
INSERT INTO orderHistory15MinAvg
SELECT exchangeName, tradePair, FROM_UNIXTIME((UNIX_TIMESTAMP(recordTime)) div 900*900 + 900) as timeRecorded,
avg(totalBuyAmount) as avgTotalBuyAmount, avg(totalSellAmount) as avgTotalSellAmount
from orderHistory
GROUP BY tradePair, exchangeName, timeRecorded ORDER BY timeRecorded, tradePair;
 
-- took 9.5 secs
ALTER TABLE orderHistory15MinAvg ADD INDEX exchangePair (exchangeName, tradePair);

select count(*) from orderHistory15MinAvg;
select * from orderHistory15MinAvg where recordTime < '2017-10-01 03:00:00' ;

select recordTime, askPriceUSD from cTicker15MinAvg where exchangeName ="bittrex" AND tradePair = "BTC-GRS";

select * from orderHistory where exchangeName ="livecoin" AND tradePair = "CVC/BTC" AND recordTime > "2017-10-16 13:45:00" AND recordTime < "2017-10-16 20:00:00";

select * from orderHistory15MinAvg where exchangeName ="livecoin" AND tradePair = "CVC/BTC";

-- del
select exchangeName, tradePair, @a := @a + askPriceUSD as newCol1, 
(case 1<3 
WHEN true then @b := @a*2
WHEN false then @b := 0 END) as newCol2
from cTicker15MinAvgBTCPrice
JOIN (select @a := 0,  @b := 0) t
where tradePair = 'BTC-BCY' and exchangeName = 'bittrex';