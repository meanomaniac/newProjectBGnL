CREATE TABLE CCOpenOrdersWSpikeInfo (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	askPriceUSD FLOAT NULL,
	askPriceBTC FLOAT NULL,
	recordTime DATETIME NULL,
    spikeStarts TINYINT(1) DEFAULT 0
);

INSERT INTO CCOpenOrdersWSpikeInfo
select exchangeName, tradePair, askPriceUSD, askPriceBTC, recordTime, 
(case CONCAT(exchangeName, tradePair, recordTime) IN (select spikeBaseString from spikeStringTable)
WHEN true then 1
WHEN false then 0 END) as spikeStarts
from CCOpenOrders ;

ALTER TABLE CCOpenOrdersWSpikeInfo ADD INDEX exchangePair (exchangeName, tradePair);

select * from CCOpenOrdersWSpikeInfo where spikeStarts = 1;


CREATE TABLE CCOpenOrdersWPriceDiff (
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

INSERT INTO CCOpenOrdersWPriceDiff
select 
temp1.exchangeName, temp1.tradePair, temp1.askPriceUSD, temp1.askPriceBTC, 
temp1.recordTime, temp1.spikeStarts, (temp1.askPriceUSD - temp2.askPriceUSD)*100/temp2.askPriceUSD as diff2Hr
from CCOpenOrdersWSpikeInfo temp1
LEFT JOIN CCOpenOrders temp2 on (temp2.exchangeName = temp1.exchangeName AND
														temp2.tradePair = temp1.tradePair AND
														FROM_UNIXTIME((UNIX_TIMESTAMP(temp2.recordTime)) +7200) = temp1.recordTime);

ALTER TABLE CCOpenOrdersWPriceDiff ADD INDEX exchangePair (exchangeName, tradePair);

select * from CCOpenOrdersWPriceDiff limit 10000;


CREATE TABLE CCOpenOrdersWPriceDiff2 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	askPriceUSD FLOAT NULL,
	askPriceBTC FLOAT NULL,
	recordTime DATETIME NULL,
    spikeStarts TINYINT(1) DEFAULT 0,
    diff2Hr FLOAT NULL,
    diff4Hr FLOAT NULL
);

INSERT INTO CCOpenOrdersWPriceDiff2
select 
temp1.exchangeName, temp1.tradePair, temp1.askPriceUSD, temp1.askPriceBTC, 
temp1.recordTime, temp1.spikeStarts, temp1.diff2Hr,
(temp1.askPriceUSD - temp2.askPriceUSD)*100/temp2.askPriceUSD as diff4Hr
from CCOpenOrdersWPriceDiff temp1
LEFT JOIN CCOpenOrders temp2 on (temp2.exchangeName = temp1.exchangeName AND
														temp2.tradePair = temp1.tradePair AND
														FROM_UNIXTIME((UNIX_TIMESTAMP(temp2.recordTime)) +14400) = temp1.recordTime);

ALTER TABLE CCOpenOrdersWPriceDiff2 ADD INDEX exchangePair (exchangeName, tradePair);

select * from CCOpenOrdersWPriceDiff2 limit 3000;

CREATE TABLE CCOpenOrdersWPriceDiff3 (
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

INSERT INTO CCOpenOrdersWPriceDiff3
select 
temp1.exchangeName, temp1.tradePair, temp1.askPriceUSD, temp1.askPriceBTC, 
temp1.recordTime, temp1.spikeStarts, temp1.diff2Hr, temp1.diff4Hr,
(temp1.askPriceUSD - temp2.askPriceUSD)*100/temp2.askPriceUSD as diff8Hr
from CCOpenOrdersWPriceDiff2 temp1
LEFT JOIN CCOpenOrders temp2 on (temp2.exchangeName = temp1.exchangeName AND
														temp2.tradePair = temp1.tradePair AND
														FROM_UNIXTIME((UNIX_TIMESTAMP(temp2.recordTime)) +28800) = temp1.recordTime);

ALTER TABLE CCOpenOrdersWPriceDiff3 ADD INDEX exchangePair (exchangeName, tradePair);

select * from CCOpenOrdersWPriceDiff3 limit 6000;

CREATE TABLE CCOpenOrdersWPriceDiff4 (
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

INSERT INTO CCOpenOrdersWPriceDiff4
select 
temp1.exchangeName, temp1.tradePair, temp1.askPriceUSD, temp1.askPriceBTC, 
temp1.recordTime, temp1.spikeStarts, temp1.diff2Hr, temp1.diff4Hr, temp1.diff8Hr,
(temp1.askPriceUSD - temp2.askPriceUSD)*100/temp2.askPriceUSD as diff16Hr
from CCOpenOrdersWPriceDiff3 temp1
LEFT JOIN CCOpenOrders temp2 on (temp2.exchangeName = temp1.exchangeName AND
														temp2.tradePair = temp1.tradePair AND
														FROM_UNIXTIME((UNIX_TIMESTAMP(temp2.recordTime)) +57600) = temp1.recordTime);

ALTER TABLE CCOpenOrdersWPriceDiff4 ADD INDEX exchangePair (exchangeName, tradePair);

select * from CCOpenOrdersWPriceDiff4 limit 12000;

CREATE TABLE CCOpenOrdersWPriceDiff5 (
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

INSERT INTO CCOpenOrdersWPriceDiff5
select 
temp1.exchangeName, temp1.tradePair, temp1.askPriceUSD, temp1.askPriceBTC, 
temp1.recordTime, temp1.spikeStarts, temp1.diff2Hr, temp1.diff4Hr, temp1.diff8Hr,
temp1.diff16Hr,
(temp1.askPriceUSD - temp2.askPriceUSD)*100/temp2.askPriceUSD as diff1Day
from CCOpenOrdersWPriceDiff4 temp1
LEFT JOIN CCOpenOrders temp2 on (temp2.exchangeName = temp1.exchangeName AND
														temp2.tradePair = temp1.tradePair AND
														FROM_UNIXTIME((UNIX_TIMESTAMP(temp2.recordTime)) +86400) = temp1.recordTime);

ALTER TABLE CCOpenOrdersWPriceDiff5 ADD INDEX exchangePair (exchangeName, tradePair);

select * from CCOpenOrdersWPriceDiff5 limit 12000;

CREATE TABLE CCOpenOrdersWPriceDiff6 (
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

INSERT INTO CCOpenOrdersWPriceDiff6
select 
temp1.exchangeName, temp1.tradePair, temp1.askPriceUSD, temp1.askPriceBTC, 
temp1.recordTime, temp1.spikeStarts, temp1.diff2Hr, temp1.diff4Hr, temp1.diff8Hr,
temp1.diff16Hr, temp1.diff1Day,
(temp1.askPriceUSD - temp2.askPriceUSD)*100/temp2.askPriceUSD as diff2Day
from CCOpenOrdersWPriceDiff5 temp1
LEFT JOIN CCOpenOrders temp2 on (temp2.exchangeName = temp1.exchangeName AND
														temp2.tradePair = temp1.tradePair AND
														FROM_UNIXTIME((UNIX_TIMESTAMP(temp2.recordTime)) +172800) = temp1.recordTime);

ALTER TABLE CCOpenOrdersWPriceDiff6 ADD INDEX exchangePair (exchangeName, tradePair);

select * from CCOpenOrdersWPriceDiff6 limit 12000;

CREATE TABLE CCOpenOrdersWPriceDiff7 (
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

INSERT INTO CCOpenOrdersWPriceDiff7
select 
temp1.exchangeName, temp1.tradePair, temp1.askPriceUSD, temp1.askPriceBTC, 
temp1.recordTime, temp1.spikeStarts, temp1.diff2Hr, temp1.diff4Hr, temp1.diff8Hr,
temp1.diff16Hr, temp1.diff1Day, temp1.diff2Day,
(temp1.askPriceUSD - temp2.askPriceUSD)*100/temp2.askPriceUSD as diff4Day
from CCOpenOrdersWPriceDiff6 temp1
LEFT JOIN CCOpenOrders temp2 on (temp2.exchangeName = temp1.exchangeName AND
														temp2.tradePair = temp1.tradePair AND
														FROM_UNIXTIME((UNIX_TIMESTAMP(temp2.recordTime)) +345600) = temp1.recordTime);

ALTER TABLE CCOpenOrdersWPriceDiff7 ADD INDEX exchangePair (exchangeName, tradePair);

select * from CCOpenOrdersWPriceDiff7 limit 12000;

CREATE TABLE CCOpenOrdersWPriceDiff8 (
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

INSERT INTO CCOpenOrdersWPriceDiff8
select 
temp1.exchangeName, temp1.tradePair, temp1.askPriceUSD, temp1.askPriceBTC, 
temp1.recordTime, temp1.spikeStarts, temp1.diff2Hr, temp1.diff4Hr, temp1.diff8Hr,
temp1.diff16Hr, temp1.diff1Day, temp1.diff2Day, temp1.diff4Day,
(temp1.askPriceUSD - temp2.askPriceUSD)*100/temp2.askPriceUSD as diff1Wk
from CCOpenOrdersWPriceDiff7 temp1
LEFT JOIN CCOpenOrders temp2 on (temp2.exchangeName = temp1.exchangeName AND
														temp2.tradePair = temp1.tradePair AND
														FROM_UNIXTIME((UNIX_TIMESTAMP(temp2.recordTime)) +604800) = temp1.recordTime);

ALTER TABLE CCOpenOrdersWPriceDiff8 ADD INDEX exchangePair (exchangeName, tradePair);

select * from CCOpenOrdersWPriceDiff8 limit 12000;

CREATE TABLE CCOpenOrdersWPriceDiff9 (
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

INSERT INTO CCOpenOrdersWPriceDiff9
select 
temp1.exchangeName, temp1.tradePair, temp1.askPriceUSD, temp1.askPriceBTC, 
temp1.recordTime, temp1.spikeStarts, temp1.diff2Hr, temp1.diff4Hr, temp1.diff8Hr,
temp1.diff16Hr, temp1.diff1Day, temp1.diff2Day, temp1.diff4Day, temp1.diff1Wk,
(temp1.askPriceUSD - temp2.askPriceUSD)*100/temp2.askPriceUSD as diff2Wk
from CCOpenOrdersWPriceDiff8 temp1
LEFT JOIN CCOpenOrders temp2 on (temp2.exchangeName = temp1.exchangeName AND
														temp2.tradePair = temp1.tradePair AND
														FROM_UNIXTIME((UNIX_TIMESTAMP(temp2.recordTime)) +1209600) = temp1.recordTime);

ALTER TABLE CCOpenOrdersWPriceDiff9 ADD INDEX exchangePair (exchangeName, tradePair);

select * from CCOpenOrdersWPriceDiff9 limit 12000;

CREATE TABLE CCOpenOrdersWPriceDiff10 (
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

INSERT INTO CCOpenOrdersWPriceDiff10
select 
temp1.exchangeName, temp1.tradePair, temp1.askPriceUSD, temp1.askPriceBTC, 
temp1.recordTime, temp1.spikeStarts, temp1.diff2Hr, temp1.diff4Hr, temp1.diff8Hr,
temp1.diff16Hr, temp1.diff1Day, temp1.diff2Day, temp1.diff4Day, temp1.diff1Wk, temp1.diff2Wk,
(temp1.askPriceUSD - temp2.askPriceUSD)*100/temp2.askPriceUSD as diff4Wk
from CCOpenOrdersWPriceDiff9 temp1
LEFT JOIN CCOpenOrders temp2 on (temp2.exchangeName = temp1.exchangeName AND
														temp2.tradePair = temp1.tradePair AND
														FROM_UNIXTIME((UNIX_TIMESTAMP(temp2.recordTime)) +2419200) = temp1.recordTime);

ALTER TABLE CCOpenOrdersWPriceDiff10 ADD INDEX exchangePair (exchangeName, tradePair);

select * from CCOpenOrdersWPriceDiff10 limit 12000;

select count(*) from CCOpenOrdersWPriceDiff10 where diff2Wk > 30;

CREATE TABLE CCOpenOrdersOrdered (
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

INSERT into CCOpenOrdersOrdered
select * from CCOpenOrdersWPriceDiff10 ORDER BY CONCAT(exchangeName, tradePair), recordTime;

CREATE TABLE CCOpenOrdersGSTracker (
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
    gsMarker FLOAT NULL,
    commonPtPrice FLOAT NULL
);

INSERT into CCOpenOrdersGSTracker
select exchangeName, tradePair, askPriceUSD, askPriceBTC, recordTime, spikeStarts, 
diff2Hr, diff4Hr, diff8Hr, diff16Hr, diff1Day, diff2Day, diff4Day, diff1Wk, diff2Wk, diff4Wk, 
gsMarker, commonPtPrice from 
(select *, 
(case 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff2Hr >30) 	 then 2 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff4Hr >30) 	 then 4 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff8Hr >30) 	 then 8 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff16Hr >30) 	 then 16 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff1Day >30) 	 then 24 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff2Day >30) 	 then 48 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff4Day >30) 	 then 96 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff1Wk >30) 	 then 168 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff2Wk >30) 	 then 336 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff4Wk >30) 	 then 672 
ELSE 0
END) as gsMarker,
(case 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff2Hr >30) 	 then askPriceUSD*100/(diff2Hr + 100) 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff4Hr >30) 	 then askPriceUSD*100/(diff4Hr + 100)  
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff8Hr >30) 	 then askPriceUSD*100/(diff8Hr + 100) 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff16Hr >30) 	 then askPriceUSD*100/(diff16Hr + 100) 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff1Day >30) 	 then askPriceUSD*100/(diff1Day + 100)  
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff2Day >30) 	 then askPriceUSD*100/(diff2Day + 100)  
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff4Day >30) 	 then askPriceUSD*100/(diff4Day + 100)  
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff1Wk >30) 	 then askPriceUSD*100/(diff1Wk + 100)  
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff2Wk >30) 	 then askPriceUSD*100/(diff2Wk + 100)  
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff4Wk >30) 	 then askPriceUSD*100/(diff4Wk + 100)  
ELSE 0
END) as commonPtPrice,
(@previousTradePair := CONCAT(exchangeName, tradePair)) as lastTradePair
from CCOpenOrdersOrdered
JOIN (select @previousTradePair := "none") t) t2;

ALTER TABLE CCOpenOrdersGSTracker ADD INDEX exchangePair (exchangeName, tradePair);

select count(DISTINCT(CONCAT(exchangeName, tradePair))) from CCOpenOrdersGSTracker where gsMarker = 4;

select * from CCOpenOrdersGSTracker limit 12000;


CREATE TABLE CCOpenOrdersGSData (
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
    gsMarker FLOAT NULL,
    commonPtPrice FLOAT NULL,
    diffCommonPt FLOAT NULL,
    gsTracker FLOAT NULL
);

insert into CCOpenOrdersGSData
select exchangeName, tradePair, askPriceUSD, askPriceBTC, recordTime, spikeStarts, 
diff2Hr, diff4Hr, diff8Hr, diff16Hr, diff1Day, diff2Day, diff4Day, diff1Wk, diff2Wk, diff4Wk, 
gsMarker, commonPtPrice, diffCommonPt, gsTracker from 
(select *,

(case 
	WHEN @previousTradePair = CONCAT(exchangeName, tradePair) AND gsMarker != 0 then @percDiffCommonPt := (askPriceUSD - commonPtPrice)/commonPtPrice*100
    WHEN @previousTradePair = CONCAT(exchangeName, tradePair) AND @commonPtPrice != 0 then @percDiffCommonPt := (askPriceUSD - @commonPtPrice)/@commonPtPrice*100
    WHEN false then @percDiffCommonPt := 0
END ) as diffCommonPt,

(case 
	WHEN @previousTradePair != CONCAT(exchangeName, tradePair) then @gsTrackerVar := 0
	WHEN @previousTradePair = CONCAT(exchangeName, tradePair) AND ((gsMarker != 0 AND @commonPtPrice = 0) OR (@commonPtPrice != 0 AND @percDiffCommonPt < 10)) then @gsTrackerVar := @gsTrackerVar +1	-- odd numbers are gradual spikes, even numbers are not
    ELSE @gsTrackerVar := @gsTrackerVar
END ) as gsTracker,

(case 
	WHEN @previousTradePair = CONCAT(exchangeName, tradePair) AND (@gsTrackerVar%2) != 0 AND  @commonPtPrice = 0 then @commonPtPrice := commonPtPrice
    WHEN @previousTradePair = CONCAT(exchangeName, tradePair) AND (@gsTrackerVar%2) = 0 AND @commonPtPrice != 0 then @commonPtPrice := 0
    WHEN @previousTradePair != CONCAT(exchangeName, tradePair) then @commonPtPrice := 0
    ELSE @commonPtPrice := @commonPtPrice
END ) as commonPtPriceVar,

@previousTradePair := CONCAT(exchangeName, tradePair) as exchTradePair
from CCOpenOrdersGSTracker
JOIN (select @previousTradePair := "none", @commonPtPrice :=0, @percDiffCommonPt := 0, @gsTrackerVar := 0) t
)t2 ;

ALTER TABLE CCOpenOrdersGSData ADD INDEX exchangePair (exchangeName, tradePair);


select * from CCOpenOrdersGSData limit 12000;


create table gsSpikeMetaData (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
    gsTracker FLOAT NULL,
    preThresholdDurOrGSMarker FLOAT NULL,
	postThresholdDuration FLOAT NULL,
    totalDuration FLOAT NULL,
    minGSTime DATETIME NULL,
    maxGSTime DATETIME NULL,
    minSpikeTime DATETIME NULL,
    minGSPrice FLOAT NULL,
    maxGSPrice FLOAT NULL,
    netPercHike FLOAT NULL,
    commonPtPrice FLOAT NULL
);

INSERT INTO gsSpikeMetaData
select t.exchangeName, t.tradePair, t3.gsTracker, t3.gsMarker, t.gsDuration, (t3.gsMarker + t.gsDuration), t.minGSTimeC, t.maxGSTimeC, t.minSpikeTimeC, t3.askPriceUSD as minGSPrice, t4.askPriceUSD as maxGSPrice, (t4.askPriceUSD - t3.commonPtPrice)*100/t3.commonPtPrice as netPercHike, t3.commonPtPrice from 
(
select t1.exchangeName, t1.tradePair, t1.gsDuration, t1.minGSTime as minGSTimeC, t1.maxGSTime as maxGSTimeC, t2.minSpikeTime as minSpikeTimeC from 
	(select exchangeName, tradePair, CONCAT(exchangeName, tradePair) as tp, 
	min(recordTime) as minGSTime, max(recordTime) as maxGSTime,
	ROUND(time_to_sec(timediff(max(recordTime) , min(recordTime))) / 3600, 2) as gsDuration
	from CCOpenOrdersGSData where (gsTracker%2) != 0
	group by CONCAT(exchangeName, tradePair), gsTracker) as t1
	LEFT JOIN 
	(select CONCAT(exchangeName, tradePair) as tp, min(recordTime) as minSpikeTime from CCOpenOrdersGSData 
	where spikeStarts=1 group by CONCAT(exchangeName, tradePair)) t2 
	on (t2.tp = t1.tp)
) t
	LEFT JOIN CCOpenOrdersGSData t3 ON (t3.exchangeName = t.exchangeName AND
																	t3.tradePair = t.tradePair AND 
																	t3.recordTime = t.minGSTimeC)
                                                              
	LEFT JOIN CCOpenOrdersGSData t4 ON (t4.exchangeName = t.exchangeName AND
																	t4.tradePair = t.tradePair AND 
																	t4.recordTime = t.maxGSTimeC)   
                                                                 
 -- where minGSTimeC <= minSpikeTimeC 
-- and ROUND(time_to_sec(timediff(minSpikeTimeC , minGSTimeC)) / 3600, 2) < 48 
-- and gsDuration > 6
;

ALTER TABLE gsSpikeMetaData ADD INDEX exchangePair (exchangeName, tradePair);
select count(*) from gsSpikeMetaData;


create table gsSpikeMetaData2 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
    gsTracker FLOAT NULL,
    preThresholdDurOrGSMarker FLOAT NULL,
	postThresholdDuration FLOAT NULL,
    totalDuration FLOAT NULL,
    commonPtTime DATETIME NULL,
    minGSTime DATETIME NULL,
    maxGSTime DATETIME NULL,
    minSpikeTime DATETIME NULL,
    minGSPrice FLOAT NULL,
    maxGSPrice FLOAT NULL,
    netPercHike FLOAT NULL,
    commonPtPrice FLOAT NULL,
    relStdDev1WkPreGS FLOAT NULL,
    relVariance1WkPreGS FLOAT NULL,
    commonPtPreDiff FLOAT NULL
);

INSERT INTO gsSpikeMetaData2
select t1.exchangeName, t1.tradePair, t1.gsTracker, t1.preThresholdDurOrGSMarker, 
t1.postThresholdDuration, t1.totalDuration, 
FROM_UNIXTIME((UNIX_TIMESTAMP(t1.minGSTime)) - (preThresholdDurOrGSMarker*3600)) as commonPtTime, 
t1.minGSTime, t1.maxGSTime, t1.minSpikeTime, 
t1.minGSPrice, t1.maxGSPrice, t1.netPercHike, t1.commonPtPrice,
ROUND((STDDEV(t2.askPriceUSD)/AVG(t2.askPriceUSD)*100), 10) as relStdDev,
ROUND((VARIANCE(t2.askPriceUSD)/POW(AVG(t2.askPriceUSD), 2)*100), 10) as relVariance, 
ROUND((MAX(t2.askPriceUSD) - t1.commonPtPrice)/t1.commonPtPrice*100, 10) as commonPtPreDiff -- gs commonPtPreDiff should not be a very high positive number to ensure the commonPt of a GS is not a sharp dip
from gsSpikeMetaData as t1
LEFT JOIN CCOpenOrdersGSData as t2 ON (t2.exchangeName = t1.exchangeName AND
																	t2.tradePair = t1.tradePair AND
																	t2.recordTime <=  FROM_UNIXTIME((UNIX_TIMESTAMP(t1.minGSTime)) - (preThresholdDurOrGSMarker*3600)) AND
																	t2.recordTime >= FROM_UNIXTIME((UNIX_TIMESTAMP(t1.minGSTime)) - (preThresholdDurOrGSMarker*3600) - 28*24*3600)
																	)
-- where  t1.preThresholdDuration >=8 and t1.netPercHike > 25                                                                    
group by CONCAT(t1.exchangeName, t1.tradePair, t1.gsTracker)                                                                    
;

ALTER TABLE gsSpikeMetaData2 ADD INDEX exchangePair (exchangeName, tradePair);


create table gsSpikeMetaData3 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
    gsTracker FLOAT NULL,
    preThresholdDurOrGSMarker FLOAT NULL,
	postThresholdDuration FLOAT NULL,
    totalDuration FLOAT NULL,
    commonPtTime DATETIME NULL,
    minGSTime DATETIME NULL,
    maxGSTime DATETIME NULL,
    minSpikeTime DATETIME NULL,
    minGSPrice FLOAT NULL,
    maxGSPrice FLOAT NULL,
    netPercHike FLOAT NULL,
    commonPtPrice FLOAT NULL,
    maxFirst48hPrice FLOAT NULL,
    first48hmaxPercChange FLOAT NULL,
    relStdDev1WkPreGS FLOAT NULL,
    relVariance1WkPreGS FLOAT NULL,
    commonPtPreDiff FLOAT NULL
);

INSERT INTO gsSpikeMetaData3
select t1.exchangeName, t1.tradePair, t1.gsTracker, t1.preThresholdDurOrGSMarker, 
t1.postThresholdDuration, t1.totalDuration, 
t1.commonPtTime, t1.minGSTime, t1.maxGSTime, t1.minSpikeTime, 
t1.minGSPrice, t1.maxGSPrice, t1.netPercHike, t1.commonPtPrice,
max(t2.askPriceUSD) as maxFirst48hPrice, (max(t2.askPriceUSD)-t1.commonPtPrice)*100/t1.commonPtPrice as first48hmaxPercChange,
t1.relStdDev1WkPreGS, t1.relVariance1WkPreGS, t1.commonPtPreDiff
from gsSpikeMetaData2 as t1
LEFT JOIN CCOpenOrdersGSData as t2 ON (t2.exchangeName = t1.exchangeName AND
																	t2.tradePair = t1.tradePair AND
																	t2.recordTime >=  FROM_UNIXTIME((UNIX_TIMESTAMP(t1.minGSTime)) - (preThresholdDurOrGSMarker*3600)) AND
																	t2.recordTime <= FROM_UNIXTIME((UNIX_TIMESTAMP(t1.minGSTime)) - (preThresholdDurOrGSMarker*3600) + 48*3600)
																	)                                                                    
-- where  t1.preThresholdDuration >=8 and t1.netPercHike > 25                                                                    
group by CONCAT(t1.exchangeName, t1.tradePair, t1.gsTracker);

ALTER TABLE gsSpikeMetaData3 ADD INDEX exchangePair (exchangeName, tradePair);


create table gsSpikeMetaData4 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
    gsTracker FLOAT NULL,
    preThresholdDurOrGSMarker FLOAT NULL,
	postThresholdDuration FLOAT NULL,
    totalDuration FLOAT NULL,
    commonPtTime DATETIME NULL,
    minGSTime DATETIME NULL,
    maxGSTime DATETIME NULL,
    minSpikeTime DATETIME NULL,
    minGSPrice FLOAT NULL,
    maxGSPrice FLOAT NULL,
    netPercHike FLOAT NULL,
    commonPtPrice FLOAT NULL,
    maxFirst48hPrice FLOAT NULL,
    first48hmaxPercChange FLOAT NULL,
    relStdDev1WkPreGS FLOAT NULL,
    relVariance1WkPreGS FLOAT NULL,
    commonPtPreDiff FLOAT NULL,
    maxPricePostGS FLOAT NULL,
    maxPricePostGSTime DATETIME NULL,
    minGSMaxBuy FLOAT NULL,
    minGSMaxSell FLOAT NULL,
    maxGSMaxBuy FLOAT NULL,
    maxGSMaxSell FLOAT NULL
);

INSERT into gsSpikeMetaData4
select t7.exchangeName, t7.tradePair, t7.gsTracker, t7.preThresholdDurOrGSMarker, 
t7.postThresholdDuration, t7.totalDuration, 
t7.commonPtTime, t7.minGSTime, t7.maxGSTime, t7.minSpikeTime, 
t7.minGSPrice, t7.maxGSPrice, t7.netPercHike, t7.commonPtPrice,
t7.maxFirst48hPrice, t7.first48hmaxPercChange,
t7.relStdDev1WkPreGS, t7.relVariance1WkPreGS, t7.commonPtPreDiff,
t7.maxPricePostGS, t7.maxPricePostGSTime, 
t7.minGSMaxBuy, t7.minGSMaxSell,
t8.totalBuyAmount as maxGSMaxBuy, t8.totalSellAmount as maxGSMaxSell
 from 
(
select t5.exchangeName, t5.tradePair, t5.gsTracker, t5.preThresholdDurOrGSMarker, 
t5.postThresholdDuration, t5.totalDuration, 
t5.commonPtTime, t5.minGSTime, t5.maxGSTime, t5.minSpikeTime, 
t5.minGSPrice, t5.maxGSPrice, t5.netPercHike, t5.commonPtPrice,
t5.maxFirst48hPrice, t5.first48hmaxPercChange,
t5.relStdDev1WkPreGS, t5.relVariance1WkPreGS, t5.commonPtPreDiff,
t5.minGSMaxBuy, t5.minGSMaxSell,
t5.maxPricePostGS, t6.recordTime as maxPricePostGSTime from
(
select t3.exchangeName, t3.tradePair, t3.gsTracker, t3.preThresholdDurOrGSMarker, 
t3.postThresholdDuration, t3.totalDuration, 
t3.commonPtTime, t3.minGSTime, t3.maxGSTime, t3.minSpikeTime, 
t3.minGSPrice, t3.maxGSPrice, t3.netPercHike, t3.commonPtPrice,
t3.maxFirst48hPrice, t3.first48hmaxPercChange,
t3.relStdDev1WkPreGS, t3.relVariance1WkPreGS, t3.commonPtPreDiff, 
t3.minGSMaxBuy, t3.minGSMaxSell, max(t4.askPriceUSD) as maxPricePostGS

from 
(
select t1.exchangeName, t1.tradePair, t1.gsTracker, t1.preThresholdDurOrGSMarker, 
t1.postThresholdDuration, t1.totalDuration, 
t1.commonPtTime, t1.minGSTime, t1.maxGSTime, t1.minSpikeTime, 
t1.minGSPrice, t1.maxGSPrice, t1.netPercHike, t1.commonPtPrice,
t1.maxFirst48hPrice, t1.first48hmaxPercChange,
t1.relStdDev1WkPreGS, t1.relVariance1WkPreGS, t1.commonPtPreDiff, 
max(t2.totalBuyAmount) as minGSMaxBuy, max(t2.totalSellAmount) as minGSMaxSell
from gsSpikeMetaData3 as t1
LEFT JOIN openOrders15MinAvg as t2 ON (t2.exchangeName = t1.exchangeName AND
																	t2.tradePair = t1.tradePair AND
																	t2.recordTime >=  FROM_UNIXTIME((UNIX_TIMESTAMP(t1.minGSTime)) - 900) AND
																	t2.recordTime <= FROM_UNIXTIME((UNIX_TIMESTAMP(t1.minGSTime)) + 900 )
																	)                                                                    
-- where  t1.preThresholdDuration >=8 and t1.netPercHike > 25                                                                    
group by CONCAT(t1.exchangeName, t1.tradePair, t1.gsTracker)
) as t3
LEFT JOIN CCOpenOrdersGSData as t4 ON (t4.exchangeName = t3.exchangeName AND
																	t4.tradePair = t3.tradePair AND
																	t4.recordTime >=  t3.minGSTime
																	)                                                                    
-- where  t1.preThresholdDuration >=8 and t1.netPercHike > 25                                                                    
group by CONCAT(t3.exchangeName, t3.tradePair, t3.gsTracker)
) as t5 
LEFT JOIN CCOpenOrdersGSData as t6 ON (t6.exchangeName = t5.exchangeName AND
																	t6.tradePair = t5.tradePair AND
																	t6.askPriceUSD =  t5.maxPricePostGS
																	)                                                                    
-- where  t1.preThresholdDuration >=8 and t1.netPercHike > 25                                                                    
group by CONCAT(t5.exchangeName, t5.tradePair, t5.gsTracker)
) as t7
LEFT JOIN openOrders15MinAvg as t8 ON (t8.exchangeName = t7.exchangeName AND
																	t8.tradePair = t7.tradePair AND
																	t8.recordTime =  t7.maxPricePostGSTime
																	)                                                                    
-- where  t1.preThresholdDuration >=8 and t1.netPercHike > 25                                                                    
group by CONCAT(t7.exchangeName, t7.tradePair, t7.gsTracker)
;

select * from gsSpikeMetaData4;

ALTER TABLE gsSpikeMetaData4 ADD INDEX exchangePair (exchangeName, tradePair);


create table gsSpikeMetaData5 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
    symbol VARCHAR(20) NULL,
    gsTracker FLOAT NULL,
    preThresholdDurOrGSMarker FLOAT NULL,
	postThresholdDuration FLOAT NULL,
    totalDuration FLOAT NULL,
    commonPtTime DATETIME NULL,
    minGSTime DATETIME NULL,
    maxGSTime DATETIME NULL,
    minSpikeTime DATETIME NULL,
    minGSPrice FLOAT NULL,
    maxGSPrice FLOAT NULL,
    netPercHike FLOAT NULL,
    commonPtPrice FLOAT NULL,
    maxFirst48hPrice FLOAT NULL,
    first48hmaxPercChange FLOAT NULL,
    relStdDev1WkPreGS FLOAT NULL,
    relVariance1WkPreGS FLOAT NULL,
    commonPtPreDiff FLOAT NULL,
    maxPricePostGS FLOAT NULL,
    maxPricePostGSTime DATETIME NULL,
    minGSMaxBuy FLOAT NULL,
    minGSMaxSell FLOAT NULL,
    maxGSMaxBuy FLOAT NULL,
    maxGSMaxSell FLOAT NULL
);

insert into gsSpikeMetaData5
select t7.exchangeName, t7.tradePair, 
(case 
	WHEN exchangeName = "bittrex" then SUBSTRING_INDEX(tradePair, "-", -1)
    WHEN exchangeName = "cryptopia" then SUBSTRING_INDEX(tradePair, "/", 1)
	WHEN exchangeName = "hitBTC" and tradePair LIKE '%USD' then LEFT(tradePair, LENGTH(tradePair) - 3)
	WHEN exchangeName = "hitBTC" and tradePair LIKE '%ETH' then LEFT(tradePair, LENGTH(tradePair) - 3)
    WHEN exchangeName = "hitBTC" and tradePair LIKE '%BTC' then LEFT(tradePair, LENGTH(tradePair) - 3)
    WHEN exchangeName = "livecoin" then SUBSTRING_INDEX(tradePair, "/", 1)
    WHEN exchangeName = "novaexchange" then SUBSTRING_INDEX(tradePair, "_", -1)
    WHEN exchangeName = "yoBit" then SUBSTRING_INDEX(tradePair, "_", 1)
    WHEN exchangeName = "poloniex" then SUBSTRING_INDEX(tradePair, "_", -1)
END ) as symbol, 
t7.gsTracker, t7.preThresholdDurOrGSMarker, 
t7.postThresholdDuration, t7.totalDuration, 
t7.commonPtTime, t7.minGSTime, t7.maxGSTime, t7.minSpikeTime, 
t7.minGSPrice, t7.maxGSPrice, t7.netPercHike, t7.commonPtPrice,
t7.maxFirst48hPrice, t7.first48hmaxPercChange,
t7.relStdDev1WkPreGS, t7.relVariance1WkPreGS, t7.commonPtPreDiff,
t7.maxPricePostGS, t7.maxPricePostGSTime, 
t7.minGSMaxBuy, t7.minGSMaxSell, t7.maxGSMaxBuy, t7.maxGSMaxSell
from gsSpikeMetaData4 as t7;

ALTER TABLE gsSpikeMetaData5 ADD INDEX exchangePair (exchangeName, tradePair);


create table gsSpikeMetaData6 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
    symbol VARCHAR(20) NULL,
    gsTracker FLOAT NULL,
    preThresholdDurOrGSMarker FLOAT NULL,
	postThresholdDuration FLOAT NULL,
    totalDuration FLOAT NULL,
    commonPtTime DATETIME NULL,
    minGSTime DATETIME NULL,
    maxGSTime DATETIME NULL,
    minSpikeTime DATETIME NULL,
    minGSPrice FLOAT NULL,
    maxGSPrice FLOAT NULL,
    netPercHike FLOAT NULL,
    commonPtPrice FLOAT NULL,
    maxFirst48hPrice FLOAT NULL,
    first48hmaxPercChange FLOAT NULL,
    relStdDev1WkPreGS FLOAT NULL,
    relVariance1WkPreGS FLOAT NULL,
    commonPtPreDiff FLOAT NULL,
    maxPricePostGS FLOAT NULL,
    maxPricePostGSTime DATETIME NULL,
    minGSMaxBuy FLOAT NULL,
    minGSMaxSell FLOAT NULL,
    maxGSMaxBuy FLOAT NULL,
    maxGSMaxSell FLOAT NULL,
	volume24hUSD FLOAT NULL,
	marketCapUSD FLOAT NULL
);

insert into gsSpikeMetaData6
select t7.exchangeName, t7.tradePair, t7.symbol, 
t7.gsTracker, t7.preThresholdDurOrGSMarker, 
t7.postThresholdDuration, t7.totalDuration, 
t7.commonPtTime, t7.minGSTime, t7.maxGSTime, t7.minSpikeTime, 
t7.minGSPrice, t7.maxGSPrice, t7.netPercHike, t7.commonPtPrice,
t7.maxFirst48hPrice, t7.first48hmaxPercChange,
t7.relStdDev1WkPreGS, t7.relVariance1WkPreGS, t7.commonPtPreDiff,
t7.maxPricePostGS, t7.maxPricePostGSTime, 
t7.minGSMaxBuy, t7.minGSMaxSell, t7.maxGSMaxBuy, t7.maxGSMaxSell,
t1.volume_24h_usd, t1.market_cap_usd
from gsSpikeMetaData5 as t7

LEFT JOIN 
(select symbol, min(volume_24h_usd) as volume_24h_usd, min(market_cap_usd) as market_cap_usd
from marketCapNVolume group by symbol) 
as t1 ON (t1.symbol = t7.symbol) ;

ALTER TABLE gsSpikeMetaData6 ADD INDEX exchangePair (exchangeName, tradePair);


create table gsSpikeMetaData7 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
    symbol VARCHAR(20) NULL,
    gsTracker FLOAT NULL,
    preThresholdDurOrGSMarker FLOAT NULL,
	postThresholdDuration FLOAT NULL,
    totalDuration FLOAT NULL,
    commonPtTime DATETIME NULL,
    minGSTime DATETIME NULL,
    maxGSTime DATETIME NULL,
    minSpikeTime DATETIME NULL,
    minGSPrice FLOAT NULL,
    maxGSPrice FLOAT NULL,
    netPercHike FLOAT NULL,
    commonPtPrice FLOAT NULL,
    maxFirst48hPrice FLOAT NULL,
    first48hmaxPercChange FLOAT NULL,
    relStdDev1WkPreGS FLOAT NULL,
    relVariance1WkPreGS FLOAT NULL,
    commonPtPreDiff FLOAT NULL,
    maxPricePostGS FLOAT NULL,
    maxPricePostGSTime DATETIME NULL,
    minGSMaxBuy FLOAT NULL,
    minGSMaxSell FLOAT NULL,
    maxGSMaxBuy FLOAT NULL,
    maxGSMaxSell FLOAT NULL,
	volume24hUSD FLOAT NULL,
	marketCapUSD FLOAT NULL,
    minTime95Perc DATETIME NULL,
    maxTime95Perc DATETIME NULL,
    netDaysMoreThan95Perc FLOAT NULL,
    netTimeWindowMoreThan95Perc FLOAT NULL,
    percNetDaysMoreThan95Perc FLOAT NULL
);

insert into gsSpikeMetaData7
select 
exchangeName, tradePair, symbol, gsTracker, preThresholdDurOrGSMarker, 
postThresholdDuration, totalDuration, commonPtTime, minGSTime, maxGSTime, 
minSpikeTime, minGSPrice, maxGSPrice, netPercHike, commonPtPrice,
maxFirst48hPrice, first48hmaxPercChange, relStdDev1WkPreGS, 
relVariance1WkPreGS, commonPtPreDiff, maxPricePostGS, maxPricePostGSTime, 
minGSMaxBuy, minGSMaxSell, maxGSMaxBuy, maxGSMaxSell, volume24hUSD, 
marketCapUSD, minTime95Perc, maxTime95Perc, netDaysMoreThan95Perc, 
netTimeWindowMoreThan95Perc, 
(netDaysMoreThan95Perc*100/netTimeWindowMoreThan95Perc) as percNetDaysMoreThan95Perc
from
(
select 
t7.exchangeName, t7.tradePair, t7.symbol, t7.gsTracker, t7.preThresholdDurOrGSMarker, 
t7.postThresholdDuration, t7.totalDuration, t7.commonPtTime, t7.minGSTime, t7.maxGSTime, 
t7.minSpikeTime, t7.minGSPrice, t7.maxGSPrice, t7.netPercHike, t7.commonPtPrice,
t7.maxFirst48hPrice, t7.first48hmaxPercChange, t7.relStdDev1WkPreGS, 
t7.relVariance1WkPreGS, t7.commonPtPreDiff, t7.maxPricePostGS, t7.maxPricePostGSTime, 
t7.minGSMaxBuy, t7.minGSMaxSell, t7.maxGSMaxBuy, t7.maxGSMaxSell, t7.volume24hUSD, 
t7.marketCapUSD, min(t1.recordTime) as minTime95Perc, max(t1.recordTime) as maxTime95Perc, 
((count(*) -1)*15)/(60*24) as netDaysMoreThan95Perc, 
((UNIX_TIMESTAMP((max(t1.recordTime)))) - (UNIX_TIMESTAMP((min(t1.recordTime)))))/(3600*24) as netTimeWindowMoreThan95Perc

from gsSpikeMetaData6 as t7
LEFT JOIN CCOpenOrdersGSData as t1 ON (t1.exchangeName = t7.exchangeName AND
																	t1.tradePair = t7.tradePair AND
                                                                    t1.askPriceUSD >= (1.95*t7.commonPtPrice) AND
                                                                    t1.recordTime <= t7.maxGSTime AND
                                                                    t1.recordTime >= t7.minGSTime)
group by t7.exchangeName, t7.tradePair, t7.gsTracker) t
;


ALTER TABLE gsSpikeMetaData7 ADD INDEX exchangePair (exchangeName, tradePair);

use pocu4;
