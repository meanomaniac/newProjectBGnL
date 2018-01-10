use pocu4;

CREATE TABLE spikeStringTable (
	spikeString VARCHAR(100) NULL
);

INSERT into spikeStringTable
select CONCAT(exchangeName, tradePair, minOfMaxTimeForStep) from steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo;
select * from spikeStringTable;


CREATE TABLE CCIntTickerWSpikeInfo (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	askPriceUSD FLOAT NULL,
	askPriceBTC FLOAT NULL,
	recordTime DATETIME NULL,
    spikeStarts TINYINT(1) DEFAULT 0
);

INSERT INTO CCIntTickerWSpikeInfo
select exchangeName, tradePair, askPriceUSD, askPriceBTC, recordTime, 
(case CONCAT(exchangeName, tradePair, recordTime) IN (select * from spikeStringTable)
WHEN true then 1
WHEN false then 0 END) as spikeStarts
from CCIntTicker ;

ALTER TABLE CCIntTickerWSpikeInfo ADD INDEX exchangePair (exchangeName, tradePair);

select * from CCIntTickerWSpikeInfo where spikeStarts = 1;


CREATE TABLE CCIntTickerWPriceDiff (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	askPriceUSD FLOAT NULL,
	askPriceBTC FLOAT NULL,
	recordTime DATETIME NULL,
    spikeStarts TINYINT(1) DEFAULT 0,
    diff2Hr FLOAT NULL
    /* ,
    diff4Hr FLOAT NULL,
    diff8Hr FLOAT NULL,
    diff16Hr FLOAT NULL,
    diff1Day FLOAT NULL,
    diff2Day FLOAT NULL,
    diff4Day FLOAT NULL,
    diff1Wk FLOAT NULL,
    diff2Wk FLOAT NULL,
    diff4Wk FLOAT NULL
    */
);

INSERT INTO CCIntTickerWPriceDiff
select 
temp1.exchangeName, temp1.tradePair, temp1.askPriceUSD, temp1.askPriceBTC, 
temp1.recordTime, temp1.spikeStarts, (temp1.askPriceUSD - temp2.askPriceUSD)*100/temp2.askPriceUSD as diff2Hr
from CCIntTickerWSpikeInfo temp1
LEFT JOIN CCIntTicker temp2 on (temp2.exchangeName = temp1.exchangeName AND
														temp2.tradePair = temp1.tradePair AND
														FROM_UNIXTIME((UNIX_TIMESTAMP(temp2.recordTime)) +7200) = temp1.recordTime);

ALTER TABLE CCIntTickerWPriceDiff ADD INDEX exchangePair (exchangeName, tradePair);

select * from CCIntTickerWPriceDiff limit 10000;


CREATE TABLE CCIntTickerWPriceDiff2 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	askPriceUSD FLOAT NULL,
	askPriceBTC FLOAT NULL,
	recordTime DATETIME NULL,
    spikeStarts TINYINT(1) DEFAULT 0,
    diff2Hr FLOAT NULL,
    diff4Hr FLOAT NULL
);

INSERT INTO CCIntTickerWPriceDiff2
select 
temp1.exchangeName, temp1.tradePair, temp1.askPriceUSD, temp1.askPriceBTC, 
temp1.recordTime, temp1.spikeStarts, temp1.diff2Hr,
(temp1.askPriceUSD - temp2.askPriceUSD)*100/temp2.askPriceUSD as diff4Hr
from CCIntTickerWPriceDiff temp1
LEFT JOIN CCIntTicker temp2 on (temp2.exchangeName = temp1.exchangeName AND
														temp2.tradePair = temp1.tradePair AND
														FROM_UNIXTIME((UNIX_TIMESTAMP(temp2.recordTime)) +14400) = temp1.recordTime);

ALTER TABLE CCIntTickerWPriceDiff2 ADD INDEX exchangePair (exchangeName, tradePair);

select * from CCIntTickerWPriceDiff2 limit 3000;

CREATE TABLE CCIntTickerWPriceDiff3 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	askPriceUSD FLOAT NULL,
	askPriceBTC FLOAT NULL,
	recordTime DATETIME NULL,
    spikeStarts TINYINT(1) DEFAULT 0,
    diff2Hr FLOAT NULL,
    diff4Hr FLOAT NULL,
    diff8Hr FLOAT NULL
);

INSERT INTO CCIntTickerWPriceDiff3
select 
temp1.exchangeName, temp1.tradePair, temp1.askPriceUSD, temp1.askPriceBTC, 
temp1.recordTime, temp1.spikeStarts, temp1.diff2Hr, temp1.diff4Hr,
(temp1.askPriceUSD - temp2.askPriceUSD)*100/temp2.askPriceUSD as diff8Hr
from CCIntTickerWPriceDiff2 temp1
LEFT JOIN CCIntTicker temp2 on (temp2.exchangeName = temp1.exchangeName AND
														temp2.tradePair = temp1.tradePair AND
														FROM_UNIXTIME((UNIX_TIMESTAMP(temp2.recordTime)) +28800) = temp1.recordTime);

ALTER TABLE CCIntTickerWPriceDiff3 ADD INDEX exchangePair (exchangeName, tradePair);

select * from CCIntTickerWPriceDiff3 limit 6000;

CREATE TABLE CCIntTickerWPriceDiff4 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	askPriceUSD FLOAT NULL,
	askPriceBTC FLOAT NULL,
	recordTime DATETIME NULL,
    spikeStarts TINYINT(1) DEFAULT 0,
    diff2Hr FLOAT NULL,
    diff4Hr FLOAT NULL,
    diff8Hr FLOAT NULL,
    diff16Hr FLOAT NULL
);

INSERT INTO CCIntTickerWPriceDiff4
select 
temp1.exchangeName, temp1.tradePair, temp1.askPriceUSD, temp1.askPriceBTC, 
temp1.recordTime, temp1.spikeStarts, temp1.diff2Hr, temp1.diff4Hr, temp1.diff8Hr,
(temp1.askPriceUSD - temp2.askPriceUSD)*100/temp2.askPriceUSD as diff16Hr
from CCIntTickerWPriceDiff3 temp1
LEFT JOIN CCIntTicker temp2 on (temp2.exchangeName = temp1.exchangeName AND
														temp2.tradePair = temp1.tradePair AND
														FROM_UNIXTIME((UNIX_TIMESTAMP(temp2.recordTime)) +57600) = temp1.recordTime);

ALTER TABLE CCIntTickerWPriceDiff4 ADD INDEX exchangePair (exchangeName, tradePair);

select * from CCIntTickerWPriceDiff4 limit 12000;

CREATE TABLE CCIntTickerWPriceDiff5 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	askPriceUSD FLOAT NULL,
	askPriceBTC FLOAT NULL,
	recordTime DATETIME NULL,
    spikeStarts TINYINT(1) DEFAULT 0,
    diff2Hr FLOAT NULL,
    diff4Hr FLOAT NULL,
    diff8Hr FLOAT NULL,
    diff16Hr FLOAT NULL,
    diff1Day FLOAT NULL
);

INSERT INTO CCIntTickerWPriceDiff5
select 
temp1.exchangeName, temp1.tradePair, temp1.askPriceUSD, temp1.askPriceBTC, 
temp1.recordTime, temp1.spikeStarts, temp1.diff2Hr, temp1.diff4Hr, temp1.diff8Hr,
temp1.diff16Hr,
(temp1.askPriceUSD - temp2.askPriceUSD)*100/temp2.askPriceUSD as diff1Day
from CCIntTickerWPriceDiff4 temp1
LEFT JOIN CCIntTicker temp2 on (temp2.exchangeName = temp1.exchangeName AND
														temp2.tradePair = temp1.tradePair AND
														FROM_UNIXTIME((UNIX_TIMESTAMP(temp2.recordTime)) +86400) = temp1.recordTime);

ALTER TABLE CCIntTickerWPriceDiff5 ADD INDEX exchangePair (exchangeName, tradePair);

select * from CCIntTickerWPriceDiff5 limit 12000;

CREATE TABLE CCIntTickerWPriceDiff6 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	askPriceUSD FLOAT NULL,
	askPriceBTC FLOAT NULL,
	recordTime DATETIME NULL,
    spikeStarts TINYINT(1) DEFAULT 0,
    diff2Hr FLOAT NULL,
    diff4Hr FLOAT NULL,
    diff8Hr FLOAT NULL,
    diff16Hr FLOAT NULL,
    diff1Day FLOAT NULL,
    diff2Day FLOAT NULL
);

INSERT INTO CCIntTickerWPriceDiff6
select 
temp1.exchangeName, temp1.tradePair, temp1.askPriceUSD, temp1.askPriceBTC, 
temp1.recordTime, temp1.spikeStarts, temp1.diff2Hr, temp1.diff4Hr, temp1.diff8Hr,
temp1.diff16Hr, temp1.diff1Day,
(temp1.askPriceUSD - temp2.askPriceUSD)*100/temp2.askPriceUSD as diff2Day
from CCIntTickerWPriceDiff5 temp1
LEFT JOIN CCIntTicker temp2 on (temp2.exchangeName = temp1.exchangeName AND
														temp2.tradePair = temp1.tradePair AND
														FROM_UNIXTIME((UNIX_TIMESTAMP(temp2.recordTime)) +172800) = temp1.recordTime);

ALTER TABLE CCIntTickerWPriceDiff6 ADD INDEX exchangePair (exchangeName, tradePair);

select * from CCIntTickerWPriceDiff6 limit 12000;

CREATE TABLE CCIntTickerWPriceDiff7 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	askPriceUSD FLOAT NULL,
	askPriceBTC FLOAT NULL,
	recordTime DATETIME NULL,
    spikeStarts TINYINT(1) DEFAULT 0,
    diff2Hr FLOAT NULL,
    diff4Hr FLOAT NULL,
    diff8Hr FLOAT NULL,
    diff16Hr FLOAT NULL,
    diff1Day FLOAT NULL,
    diff2Day FLOAT NULL,
    diff4Day FLOAT NULL
);

INSERT INTO CCIntTickerWPriceDiff7
select 
temp1.exchangeName, temp1.tradePair, temp1.askPriceUSD, temp1.askPriceBTC, 
temp1.recordTime, temp1.spikeStarts, temp1.diff2Hr, temp1.diff4Hr, temp1.diff8Hr,
temp1.diff16Hr, temp1.diff1Day, temp1.diff2Day,
(temp1.askPriceUSD - temp2.askPriceUSD)*100/temp2.askPriceUSD as diff4Day
from CCIntTickerWPriceDiff6 temp1
LEFT JOIN CCIntTicker temp2 on (temp2.exchangeName = temp1.exchangeName AND
														temp2.tradePair = temp1.tradePair AND
														FROM_UNIXTIME((UNIX_TIMESTAMP(temp2.recordTime)) +345600) = temp1.recordTime);

ALTER TABLE CCIntTickerWPriceDiff7 ADD INDEX exchangePair (exchangeName, tradePair);

select * from CCIntTickerWPriceDiff7 limit 12000;

CREATE TABLE CCIntTickerWPriceDiff8 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	askPriceUSD FLOAT NULL,
	askPriceBTC FLOAT NULL,
	recordTime DATETIME NULL,
    spikeStarts TINYINT(1) DEFAULT 0,
    diff2Hr FLOAT NULL,
    diff4Hr FLOAT NULL,
    diff8Hr FLOAT NULL,
    diff16Hr FLOAT NULL,
    diff1Day FLOAT NULL,
    diff2Day FLOAT NULL,
    diff4Day FLOAT NULL,
    diff1Wk FLOAT NULL
);

INSERT INTO CCIntTickerWPriceDiff8
select 
temp1.exchangeName, temp1.tradePair, temp1.askPriceUSD, temp1.askPriceBTC, 
temp1.recordTime, temp1.spikeStarts, temp1.diff2Hr, temp1.diff4Hr, temp1.diff8Hr,
temp1.diff16Hr, temp1.diff1Day, temp1.diff2Day, temp1.diff4Day,
(temp1.askPriceUSD - temp2.askPriceUSD)*100/temp2.askPriceUSD as diff1Wk
from CCIntTickerWPriceDiff7 temp1
LEFT JOIN CCIntTicker temp2 on (temp2.exchangeName = temp1.exchangeName AND
														temp2.tradePair = temp1.tradePair AND
														FROM_UNIXTIME((UNIX_TIMESTAMP(temp2.recordTime)) +604800) = temp1.recordTime);

ALTER TABLE CCIntTickerWPriceDiff8 ADD INDEX exchangePair (exchangeName, tradePair);

select * from CCIntTickerWPriceDiff8 limit 12000;

CREATE TABLE CCIntTickerWPriceDiff9 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	askPriceUSD FLOAT NULL,
	askPriceBTC FLOAT NULL,
	recordTime DATETIME NULL,
    spikeStarts TINYINT(1) DEFAULT 0,
    diff2Hr FLOAT NULL,
    diff4Hr FLOAT NULL,
    diff8Hr FLOAT NULL,
    diff16Hr FLOAT NULL,
    diff1Day FLOAT NULL,
    diff2Day FLOAT NULL,
    diff4Day FLOAT NULL,
    diff1Wk FLOAT NULL,
    diff2Wk FLOAT NULL
);

INSERT INTO CCIntTickerWPriceDiff9
select 
temp1.exchangeName, temp1.tradePair, temp1.askPriceUSD, temp1.askPriceBTC, 
temp1.recordTime, temp1.spikeStarts, temp1.diff2Hr, temp1.diff4Hr, temp1.diff8Hr,
temp1.diff16Hr, temp1.diff1Day, temp1.diff2Day, temp1.diff4Day, temp1.diff1Wk,
(temp1.askPriceUSD - temp2.askPriceUSD)*100/temp2.askPriceUSD as diff2Wk
from CCIntTickerWPriceDiff8 temp1
LEFT JOIN CCIntTicker temp2 on (temp2.exchangeName = temp1.exchangeName AND
														temp2.tradePair = temp1.tradePair AND
														FROM_UNIXTIME((UNIX_TIMESTAMP(temp2.recordTime)) +1209600) = temp1.recordTime);

ALTER TABLE CCIntTickerWPriceDiff9 ADD INDEX exchangePair (exchangeName, tradePair);

select * from CCIntTickerWPriceDiff9 limit 12000;

CREATE TABLE CCIntTickerWPriceDiff10 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	askPriceUSD FLOAT NULL,
	askPriceBTC FLOAT NULL,
	recordTime DATETIME NULL,
    spikeStarts TINYINT(1) DEFAULT 0,
    diff2Hr FLOAT NULL,
    diff4Hr FLOAT NULL,
    diff8Hr FLOAT NULL,
    diff16Hr FLOAT NULL,
    diff1Day FLOAT NULL,
    diff2Day FLOAT NULL,
    diff4Day FLOAT NULL,
    diff1Wk FLOAT NULL,
    diff2Wk FLOAT NULL,
    diff4Wk FLOAT NULL
);

INSERT INTO CCIntTickerWPriceDiff10
select 
temp1.exchangeName, temp1.tradePair, temp1.askPriceUSD, temp1.askPriceBTC, 
temp1.recordTime, temp1.spikeStarts, temp1.diff2Hr, temp1.diff4Hr, temp1.diff8Hr,
temp1.diff16Hr, temp1.diff1Day, temp1.diff2Day, temp1.diff4Day, temp1.diff1Wk, temp1.diff2Wk,
(temp1.askPriceUSD - temp2.askPriceUSD)*100/temp2.askPriceUSD as diff4Wk
from CCIntTickerWPriceDiff9 temp1
LEFT JOIN CCIntTicker temp2 on (temp2.exchangeName = temp1.exchangeName AND
														temp2.tradePair = temp1.tradePair AND
														FROM_UNIXTIME((UNIX_TIMESTAMP(temp2.recordTime)) +2419200) = temp1.recordTime);

ALTER TABLE CCIntTickerWPriceDiff10 ADD INDEX exchangePair (exchangeName, tradePair);

select * from CCIntTickerWPriceDiff10 limit 12000;

select count(*) from CCIntTickerWPriceDiff10 where diff2Wk > 30;

CREATE TABLE CCIntTickerOrdered (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	askPriceUSD FLOAT NULL,
	askPriceBTC FLOAT NULL,
	recordTime DATETIME NULL,
    spikeStarts TINYINT(1) DEFAULT 0,
    diff2Hr FLOAT NULL,
    diff4Hr FLOAT NULL,
    diff8Hr FLOAT NULL,
    diff16Hr FLOAT NULL,
    diff1Day FLOAT NULL,
    diff2Day FLOAT NULL,
    diff4Day FLOAT NULL,
    diff1Wk FLOAT NULL,
    diff2Wk FLOAT NULL,
    diff4Wk FLOAT NULL
);

INSERT into CCIntTickerOrdered
select * from CCIntTickerWPriceDiff10 ORDER BY CONCAT(exchangeName, tradePair), recordTime;

CREATE TABLE CCIntTickerGSTracker (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	askPriceUSD FLOAT NULL,
	askPriceBTC FLOAT NULL,
	recordTime DATETIME NULL,
    spikeStarts TINYINT(1) DEFAULT 0,
    diff2Hr FLOAT NULL,
    diff4Hr FLOAT NULL,
    diff8Hr FLOAT NULL,
    diff16Hr FLOAT NULL,
    diff1Day FLOAT NULL,
    diff2Day FLOAT NULL,
    diff4Day FLOAT NULL,
    diff1Wk FLOAT NULL,
    diff2Wk FLOAT NULL,
    diff4Wk FLOAT NULL,
    gsMarker FLOAT NULL
);

INSERT into CCIntTickerGSTracker
select exchangeName, tradePair, askPriceUSD, askPriceBTC, recordTime, spikeStarts, 
diff2Hr, diff4Hr, diff8Hr, diff16Hr, diff1Day, diff2Day, diff4Day, diff1Wk, diff2Wk, diff4Wk, 
gsMarker from 
(select *, 
(case 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff2Hr >30) 	 then 2 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff4Hr >30) 	 then 4 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff8Hr >30) 	 then 8 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff16Hr >30) 	 then 16 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff1Day >30) 	 then 100 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff2Day >30) 	 then 200 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff4Day >30) 	 then 400 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff1Wk >30) 	 then 1000 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff2Wk >30) 	 then 2000 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff4Wk >30) 	 then 4000 
ELSE 0
END) as gsMarker,
(@previousTradePair := CONCAT(exchangeName, tradePair)) as lastTradePair
from CCIntTickerOrdered
JOIN (select @previousTradePair := "none") t) t2;

ALTER TABLE CCIntTickerGSTracker ADD INDEX exchangePair (exchangeName, tradePair);

select count(DISTINCT(CONCAT(exchangeName, tradePair))) from CCIntTickerGSTracker where gsMarker = 4;

select count(DISTINCT(CONCAT(exchangeName, tradePair))) from CCIntTickerGSTracker where CONCAT(exchangeName, tradePair, recordTime) in 
(select DISTINCT(CONCAT(exchangeName, tradePair, recordTime)) from CCIntTickerGSTracker where gsMarker = 4) 
and CONCAT(exchangeName, tradePair, recordTime) in 
(select DISTINCT(CONCAT(exchangeName, tradePair, recordTime)) from CCIntTickerGSTracker where gsMarker = 2);

select DISTINCT(CONCAT(exchangeName, tradePair, recordTime)) from CCIntTickerGSTracker where gsMarker = 2 limit 100;

select CONCAT(exchangeName, tradePair) from CCIntTickerGSTracker group by  CONCAT(exchangeName, tradePair) ;

select count(*) from 
(
select t.tradePair, ts.minSpikeTime, t1.minTime as hr2, t2.minTime as hr4, t3.minTime as hr8, t4.minTime as hr16, t5.minTime as d1,
 t6.minTime as d2, t7.minTime as d4, t8.minTime as w1,  t9.minTime as w2, t10.minTime as w4
from 
(select DISTINCT(CONCAT(exchangeName, tradePair)) as tradePair from CCIntTickerGSTracker) t
LEFT JOIN
(select CONCAT(exchangeName, tradePair) as tradePair, min(recordTime) as minSpikeTime from CCIntTickerGSTracker where spikeStarts = 1 group by CONCAT(exchangeName, tradePair)) ts 
ON (ts.tradePair = t.tradePair)
LEFT JOIN
(select CONCAT(exchangeName, tradePair) as tradePair, min(recordTime) as minTime from CCIntTickerGSTracker where gsMarker = 2 group by CONCAT(exchangeName, tradePair)) t1 
ON (t1.tradePair = t.tradePair)
LEFT JOIN
(select CONCAT(exchangeName, tradePair) as tradePair, min(recordTime) as minTime from CCIntTickerGSTracker where gsMarker = 4 group by CONCAT(exchangeName, tradePair)) t2 
ON (t2.tradePair = t.tradePair)
LEFT JOIN
(select CONCAT(exchangeName, tradePair) as tradePair, min(recordTime) as minTime from CCIntTickerGSTracker where gsMarker = 8 group by CONCAT(exchangeName, tradePair)) t3 
ON (t3.tradePair = t.tradePair)
LEFT JOIN
(select CONCAT(exchangeName, tradePair) as tradePair, min(recordTime) as minTime from CCIntTickerGSTracker where gsMarker = 16 group by CONCAT(exchangeName, tradePair)) t4 
ON (t4.tradePair = t.tradePair)
LEFT JOIN
(select CONCAT(exchangeName, tradePair) as tradePair, min(recordTime) as minTime from CCIntTickerGSTracker where gsMarker = 100 group by CONCAT(exchangeName, tradePair)) t5 
ON (t5.tradePair = t.tradePair)
LEFT JOIN
(select CONCAT(exchangeName, tradePair) as tradePair, min(recordTime) as minTime from CCIntTickerGSTracker where gsMarker = 200 group by CONCAT(exchangeName, tradePair)) t6 
ON (t6.tradePair = t.tradePair)
LEFT JOIN
(select CONCAT(exchangeName, tradePair) as tradePair, min(recordTime) as minTime from CCIntTickerGSTracker where gsMarker = 400 group by CONCAT(exchangeName, tradePair)) t7 
ON (t7.tradePair = t.tradePair)
LEFT JOIN
(select CONCAT(exchangeName, tradePair) as tradePair, min(recordTime) as minTime from CCIntTickerGSTracker where gsMarker = 1000 group by CONCAT(exchangeName, tradePair)) t8 
ON (t8.tradePair = t.tradePair)
LEFT JOIN
(select CONCAT(exchangeName, tradePair) as tradePair, min(recordTime) as minTime from CCIntTickerGSTracker where gsMarker = 2000 group by CONCAT(exchangeName, tradePair)) t9 
ON (t9.tradePair = t.tradePair)
LEFT JOIN
(select CONCAT(exchangeName, tradePair) as tradePair, min(recordTime) as minTime from CCIntTickerGSTracker where gsMarker = 4000 group by CONCAT(exchangeName, tradePair)) t10 
ON (t10.tradePair = t.tradePair)) tm
where (hr2 <minSpikeTime or hr4 <minSpikeTime or hr8 <minSpikeTime or hr16 <minSpikeTime
or d1 <minSpikeTime or d2 <minSpikeTime or d4 <minSpikeTime or w1 <minSpikeTime
or w2 <minSpikeTime or w4 <minSpikeTime);

use pocu4;
-- del
