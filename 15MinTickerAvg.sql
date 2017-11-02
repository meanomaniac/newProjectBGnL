use pocu3;

CREATE TABLE cTicker15MinAvg (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	askPriceUSD FLOAT NULL,
	recordTime DATETIME NULL
);

-- took 208 secs
INSERT INTO cTicker15MinAvg
SELECT exchangeName, tradePair, avg(askPriceUSD) as avgPriceUSD, 
FROM_UNIXTIME((UNIX_TIMESTAMP(recordTime)) div 900*900 + 900) as timeRecorded
from cTicker
GROUP BY tradePair, exchangeName, timeRecorded ORDER BY timeRecorded, tradePair;
 
-- took 17 secs
ALTER TABLE cTicker15MinAvg ADD INDEX exchangePair (exchangeName, tradePair);
    
select count(*) from cTicker15MinAvg;
select * from cTicker15MinAvg where recordTime < '2017-10-01 03:00:00' ;

show tables;
