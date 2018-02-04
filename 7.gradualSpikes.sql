use pocu4;

CREATE TABLE spikeStringTable (
	spikeBaseString VARCHAR(100) NULL,
    spikePeakString VARCHAR(100) NULL
);

INSERT into spikeStringTable
select CONCAT(exchangeName, tradePair, minOfMaxTimeForStep),
CONCAT(exchangeName, tradePair, maxOfMaxTimeForStep)
 from steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo;
 
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
(case CONCAT(exchangeName, tradePair, recordTime) IN (select spikeBaseString from spikeStringTable)
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
    gsMarker FLOAT NULL,
    commonPtPrice FLOAT NULL
);

INSERT into CCIntTickerGSTracker
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
from CCIntTickerOrdered
JOIN (select @previousTradePair := "none") t) t2;

ALTER TABLE CCIntTickerGSTracker ADD INDEX exchangePair (exchangeName, tradePair);

select count(DISTINCT(CONCAT(exchangeName, tradePair))) from CCIntTickerGSTracker where gsMarker = 4;

select * from CCIntTickerGSTracker limit 12000;


CREATE TABLE CCIntTickerGSData (
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

insert into CCIntTickerGSData
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
from CCIntTickerGSTracker
JOIN (select @previousTradePair := "none", @commonPtPrice :=0, @percDiffCommonPt := 0, @gsTrackerVar := 0) t
)t2 ;

ALTER TABLE CCIntTickerGSData ADD INDEX exchangePair (exchangeName, tradePair);


select * from CCIntTickerGSData limit 12000;


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
	from CCIntTickerGSData where (gsTracker%2) != 0
	group by CONCAT(exchangeName, tradePair), gsTracker) as t1
	LEFT JOIN 
	(select CONCAT(exchangeName, tradePair) as tp, min(recordTime) as minSpikeTime from CCIntTickerGSData 
	where spikeStarts=1 group by CONCAT(exchangeName, tradePair)) t2 
	on (t2.tp = t1.tp)
) t
	LEFT JOIN CCIntTickerGSData t3 ON (t3.exchangeName = t.exchangeName AND
																	t3.tradePair = t.tradePair AND 
																	t3.recordTime = t.minGSTimeC)
                                                              
	LEFT JOIN CCIntTickerGSData t4 ON (t4.exchangeName = t.exchangeName AND
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
LEFT JOIN CCIntTickerGSData as t2 ON (t2.exchangeName = t1.exchangeName AND
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
LEFT JOIN CCIntTickerGSData as t2 ON (t2.exchangeName = t1.exchangeName AND
																	t2.tradePair = t1.tradePair AND
																	t2.recordTime >=  FROM_UNIXTIME((UNIX_TIMESTAMP(t1.minGSTime)) - (preThresholdDurOrGSMarker*3600)) AND
																	t2.recordTime <= FROM_UNIXTIME((UNIX_TIMESTAMP(t1.minGSTime)) - (preThresholdDurOrGSMarker*3600) + 48*3600)
																	)                                                                    
-- where  t1.preThresholdDuration >=8 and t1.netPercHike > 25                                                                    
group by CONCAT(t1.exchangeName, t1.tradePair, t1.gsTracker);

ALTER TABLE gsSpikeMetaData3 ADD INDEX exchangePair (exchangeName, tradePair);

-- 
select netPercHike from gsSpikeMetaData2 where netPercHike < 500 
-- and preThresholdDurOrGSMarker >=4  
and maxGSPrice > minGSPrice;

select count(*) from gsSpikeMetaData2 
where netPercHike >= 20 and variance1WkPreGS < 1 and commonPtPreDiff < 100
and maxGSPrice > minGSPrice
order by preThresholdDurOrGSMarker, totalDuration;

select * from gsSpikeMetaData2;
select relStdDev1WkPreGS from gsSpikeMetaData2 where relStdDev1WkPreGS ;

select preThresholdDurOrGSMarker,  postThresholdDuration, netPercHike, stdDev1WkPreGS, 
variance1WkPreGS, commonPtPreDiff from gsSpikeMetaData2
where maxGSPrice < minGSPrice and variance1WkPreGS < 1 and commonPtPreDiff < 100;


select preThresholdDurOrGSMarker, count(*), avg(netPercHike) from gsSpikeMetaData2 
where netPercHike < 500 and maxGSPrice > minGSPrice
group by preThresholdDurOrGSMarker;

select avg(stdDev1WkPreGS), 
avg(variance1WkPreGS), avg(commonPtPreDiff) from gsSpikeMetaData2
where maxGSPrice > minGSPrice
and netPercHike < 500 and variance1WkPreGS < 100 and commonPtPreDiff < 100;

select avg(stdDev1WkPreGS), 
avg(variance1WkPreGS), avg(commonPtPreDiff) from gsSpikeMetaData2
where maxGSPrice < minGSPrice
and netPercHike < 500 and variance1WkPreGS < 1 and commonPtPreDiff < 100;

select * from gsSpikeMetaData3 
where
 -- netPercHike >= 100 and 
relStdDev1WkPreGS < 8
and commonPtTime > '2017-10-08 23:59:59'
and CONCAT(exchangeName, tradePair) = 'bittrexBTC-DYN'
-- and
 -- maxGSPrice > minGSPrice
 -- increase threshold from 30 to higher
 -- ensure u wait weeks after a big spike
and netPercHike < 50
  and preThresholdDurOrGSMarker >= 48
  -- and commonPtPreDiff < 30
 and CONCAT(exchangeName, tradePair) NOT IN 
 (select CONCAT(exchangeName, tradePair) from gsSpikeMetaData2 where netPercHike > 50)
  order by netPercHike desc;

select DISTINCT (CONCAT(exchangeName, tradePair)) from gsSpikeMetaData3 
where
 -- netPercHike >= 100 and 
-- relStdDev1WkPreGS < 8 and 
 commonPtTime > '2017-10-08 23:59:59' and
-- and
 -- maxGSPrice > minGSPrice
 -- increase threshold from 30 to higher
 -- ensure u wait weeks after a big spike
 netPercHike < 50
  and preThresholdDurOrGSMarker >= 48
  and exchangeName NOT IN ('yoBit', 'novaexchange')
  and  commonPtPreDiff < 30
 and CONCAT(exchangeName, tradePair) NOT IN 
 (select CONCAT(exchangeName, tradePair) from gsSpikeMetaData2 where netPercHike > 50)
  order by netPercHike desc;
 
 select DISTINCT (CONCAT(exchangeName, tradePair)) from gsSpikeMetaData2 where netPercHike >= 100 and commonPtPreDiff < 20 and exchangeName NOT IN ('yoBit', 'novaexchange') and relStdDev1WkPreGS < 8 order by netPercHike desc ;
 
select * from gsSpikeMetaData2 where totalDuration >= 100 and commonPtPreDiff < 20 order by netPercHike desc;


select count(*) from gsSpikeMetaData2 where commonPtPreDiff < 20;
select DISTINCT (CONCAT(exchangeName, tradePair)) from gsSpikeMetaData2 where preThresholdDurOrGSMarker >= 48 and commonPtPreDiff < 20 and CONCAT(exchangeName, tradePair) 
NOT IN (select DISTINCT (CONCAT(exchangeName, tradePair)) from gsSpikeMetaData2 where netPercHike >= 50 and commonPtPreDiff < 20 order by netPercHike desc) 
order by netPercHike desc;




select DISTINCT (CONCAT(exchangeName, tradePair)) from gsSpikeMetaData2;

-- del2
select CONCAT(exchangeName, tradePair), gsTracker, gsDuration, minGSTime, maxGSTime, minSpikeTime, minGSPrice, maxGSPrice, netPercHike
 from gsSpikeMetaData where gsDuration > 12 and netPercHike > 30
 order by gsTracker, gsDuration;

select preThresholdDuration, count(*) from gsSpikeMetaData group by preThresholdDuration;

select exchangeName,  count(*) from gsSpikeMetaData 
where preThresholdDuration >=8 and netPercHike > 30
group by exchangeName;

select * from gsSpikeMetaData 
where preThresholdDuration >=8 and netPercHike > 30
order by preThresholdDuration, totalDuration;

select * from 
(
select ROUND(time_to_sec(timediff(minSpikeTime , maxGSTime)) / (24*3600), 2) as timeToSpike from 
(
select * from gsSpikeMetaData where gsDuration > 6 and netPercHike > 20) t
) t2
where timeToSpike <= 6;

use pocu4;

/*analysis
1) avoid coins priced in 100s of USDs
2) use only coins listed in CMC
3) try avoiding exchanges like novaexchange
3) avoid using dips for getting gradual spikes
4) avoid crazy spikey times - try using variance to determine this
5) don't seggragate spikes as gradual and steep




for testing
1) use a min netPercHike
2) use a min gsDuration
3) ensure the spike that follows is greater than the preceeding GS
4) use lingering spikes not regular spikes for stopping GS
5) see if u can avoid situations where there was a genuine GS but a dip at the end of the GS as the GS was too long - in essence try using a fixed times for these GSs. That way you may also avoid extremely slow spikes which also u are trying to eliminate.
 
 crazy spikes
 1) yoBitbit16_btc
 2) cryptopiaEVO/BTC
*/

-- test

select t1.exchangeName as exchangeName, t1.tradePair as tradePair, 
(t3.askPriceUSD - t2.askPriceUSD) as gsFinalDiff, (t1.maxTime - t1.minTime) as gsDuration from 
(
	(select exchangeName, tradePair, min(recordTime) as minTime, max(recordTime) as maxTime
	from CCIntTickerGSData where (gsTracker%2) != 0
	group by CONCAT(exchangeName, tradePair), gsTracker) t1
	LEFT JOIN CCIntTickerGSData t2 ON (t2.exchangeName = t1.exchangeName AND
																	t2.tradePair = t1.tradePair AND 
																	t2.recordTime = t1.minTime)
	LEFT JOIN CCIntTickerGSData t3 ON (t3.exchangeName = t1.exchangeName AND
																	t3.tradePair = t1.tradePair AND 
																	t3.recordTime = t1.maxTime)
) ;

select count(DISTINCT(CONCAT(exchangeName, tradePair))) from CCIntTickerGSTracker where CONCAT(exchangeName, tradePair, recordTime) in 
(select DISTINCT(CONCAT(exchangeName, tradePair, recordTime)) from CCIntTickerGSTracker where gsMarker = 4) 
and CONCAT(exchangeName, tradePair, recordTime) in 
(select DISTINCT(CONCAT(exchangeName, tradePair, recordTime)) from CCIntTickerGSTracker where gsMarker = 2);

select DISTINCT(CONCAT(exchangeName, tradePair, recordTime)) from CCIntTickerGSTracker where gsMarker = 2 limit 100;

select CONCAT(exchangeName, tradePair) from CCIntTickerGSTracker group by  CONCAT(exchangeName, tradePair) ;

select count(*) from 
(
select * from 
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
or w2 <minSpikeTime or w4 <minSpikeTime)) tm2
where (hr2 <minSpikeTime or hr4 <minSpikeTime or hr8 <minSpikeTime or hr16 <minSpikeTime
or d1 <minSpikeTime or d2 <minSpikeTime or d4 <minSpikeTime or w1 <minSpikeTime
or w2 <minSpikeTime or w4 <minSpikeTime) 


and (w1 > minSpikeTime or w1 is null)
and (d4 > minSpikeTime or d4 is null)
and (d2 > minSpikeTime or d2 is null)
and (d1 > minSpikeTime or d1 is null)
and (hr16 > minSpikeTime or hr16 is null)
and (hr8 > minSpikeTime or hr8 is null)
and (hr4 > minSpikeTime or hr4 is null)
and (hr2 > minSpikeTime or hr2 is null);


-- del

select t.exchangeName, t.tradePair, t4.gsTracker, t3.initialGSMarker, t.gsDuration, (t3.initialGSMarker + t.gsDuration), t.minGSTimeC, t.maxGSTimeC, t.minSpikeTimeC, t3.askPriceUSD as minGSPrice, t4.askPriceUSD as maxGSPrice, (t4.askPriceUSD - t3.commonPtPrice)*100/t3.commonPtPrice as netPercHike from 
(
select t1.exchangeName, t1.tradePair, t1.gsDuration, t1.minGSTime as minGSTimeC, t1.maxGSTime as maxGSTimeC, t2.minSpikeTime as minSpikeTimeC from 
	(select exchangeName, tradePair, CONCAT(exchangeName, tradePair) as tp, 
	min(recordTime) as minGSTime, max(recordTime) as maxGSTime,
	ROUND(time_to_sec(timediff(max(recordTime) , min(recordTime))) / 3600, 2) as gsDuration
	from CCIntTickerGSData2 where (gsTracker%2) != 0
	group by CONCAT(exchangeName, tradePair), gsTracker) as t1
	LEFT JOIN 
	(select CONCAT(exchangeName, tradePair) as tp, min(recordTime) as minSpikeTime from CCIntTickerGSData2 
	where spikeStarts=1 group by CONCAT(exchangeName, tradePair)) t2 
	on (t2.tp = t1.tp)
) t
	LEFT JOIN CCIntTickerGSData2 t3 ON (t3.exchangeName = t.exchangeName AND
																	t3.tradePair = t.tradePair AND 
																	t3.recordTime = t.minGSTimeC)
                                                              
	LEFT JOIN CCIntTickerGSData2 t4 ON (t4.exchangeName = t.exchangeName AND
																	t4.tradePair = t.tradePair AND 
																	t4.recordTime = t.maxGSTimeC)   
                                                                 
 where minGSTimeC <= minSpikeTimeC 
-- and ROUND(time_to_sec(timediff(minSpikeTimeC , minGSTimeC)) / 3600, 2) < 48 
-- and gsDuration > 6
;

select *  from CCIntTickerGSData2 where exchangeName = 'bittrex' 
AND tradePair in ('BTC-CLUB', 'BTC-CURE', 'BTC-DYN');

select * from CCIntTickerGSDataDelete 
-- where gsTracker !=0 
limit 12000;

select * from  CCIntTickerGSDataDelete  
where CONCAT(exchangeName, tradePair, recordTime)  in 
(select CONCAT(exchangeName, tradePair, min(recordTime)) from  CCIntTickerGSDataDelete
where gsMarker !=0
group by CONCAT(exchangeName, tradePair), gsTracker)
and gsMarker =0;
-- where gsMarker !=0 ;



use pocu4;


-- backup

CREATE TABLE CCIntTickerGSData (
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

INSERT into CCIntTickerGSData
select exchangeName, tradePair, askPriceUSD, askPriceBTC, recordTime, spikeStarts, 
diff2Hr, diff4Hr, diff8Hr, diff16Hr, diff1Day, diff2Day, diff4Day, diff1Wk, diff2Wk, diff4Wk, 
gsMarker, commonPtPrice, diffCommonPt, gsTracker from 
(select *,
(case 
	WHEN @previousTradePair = CONCAT(exchangeName, tradePair) AND @gsTrackerWatcher != @commonPtPrice then @gsTrackerVar := @gsTrackerVar +1	-- odd numbers are gradual spikes, even numbers are not
	WHEN @previousTradePair = CONCAT(exchangeName, tradePair) AND @gsTrackerWatcher = @commonPtPrice then @gsTrackerVar := @gsTrackerVar
    ELSE @gsTrackerVar := 0
END ) as gsTracker,
( case
	WHEN @previousTradePair = CONCAT(exchangeName, tradePair) then @gsTrackerWatcher := @commonPtPrice
    ELSE @gsTrackerWatcher := 0
END) as gsTrackerWatcher,
(case 
	WHEN @previousTradePair = CONCAT(exchangeName, tradePair) AND gsMarker !=0 AND  @commonPtPrice = 0 then @commonPtPrice := commonPtPrice
    WHEN @previousTradePair = CONCAT(exchangeName, tradePair) AND (@percDiffCommonPt < 10 OR  spikeStarts = 1) AND @commonPtPrice != 0 then @commonPtPrice := 0
    WHEN @previousTradePair != CONCAT(exchangeName, tradePair) then @commonPtPrice := 0
    ELSE @commonPtPrice := @commonPtPrice
END ) as commonPtPriceVar,
(case @previousTradePair = CONCAT(exchangeName, tradePair) AND (gsMarker != 0 OR @commonPtPrice != 0)
	WHEN true then @percDiffCommonPt := (askPriceUSD - @commonPtPrice)/@commonPtPrice*100
    WHEN false then @percDiffCommonPt := 0
END ) as diffCommonPt,
@previousTradePair := CONCAT(exchangeName, tradePair) as exchTradePair
from CCIntTickerGSTracker
JOIN (select @previousTradePair := "none", @commonPtPrice :=0, @percDiffCommonPt := 0, @gsTrackerVar := 0, @gsTrackerWatcher := 0) t
)t2 ;

ALTER TABLE CCIntTickerGSData ADD INDEX exchangePair (exchangeName, tradePair);

-- next backup

CREATE TABLE CCIntTickerGSData2 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	askPriceUSD FLOAT NULL,
	askPriceBTC FLOAT NULL,
	recordTime DATETIME NULL,
    spikeStarts TINYINT(1) DEFAULT 0,
    spikeEnds TINYINT(1) DEFAULT 0,
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
    gsTracker FLOAT NULL,
    initialGSMarker FLOAT NULL
);

INSERT into CCIntTickerGSData2
select exchangeName, tradePair, askPriceUSD, askPriceBTC, recordTime, spikeStarts, spikeEnds,
diff2Hr, diff4Hr, diff8Hr, diff16Hr, diff1Day, diff2Day, diff4Day, diff1Wk, diff2Wk, diff4Wk, 
gsMarker, commonPtPrice, diffCommonPt, gsTracker, initialGSMarker from 

(select *, 
(case @previousTradePair = CONCAT(exchangeName, tradePair) AND @previousGSTracker != gsTracker 
	WHEN TRUE then @previousGSMarker 	
	WHEN FALSE then 0
END ) as initialGSMarker,
@previousTradePair := CONCAT(exchangeName, tradePair) as exchTradePair,
@previousGSMarker := gsMarker as prevGSMarker, 
@previousGSTracker := gsTracker as prevGSTracker

from CCIntTickerGSDataWMaxPeakTime
JOIN (select @previousTradePair := "none", @previousGSMarker :=0, @previousGSTracker :=0) t
)t2 ;

ALTER TABLE CCIntTickerGSData2 ADD INDEX exchangePair (exchangeName, tradePair);

select * from CCIntTickerGSData2 limit 10000;




-- next backup 

-- adding max time which I realized the need for only at this point
CREATE TABLE CCIntTickerGSDataWMaxPeakTime (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	askPriceUSD FLOAT NULL,
	askPriceBTC FLOAT NULL,
	recordTime DATETIME NULL,
    spikeStarts TINYINT(1) DEFAULT 0,
    spikeEnds TINYINT(1) DEFAULT 0,
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

INSERT into CCIntTickerGSDataWMaxPeakTime
select exchangeName, tradePair, askPriceUSD, askPriceBTC, recordTime, spikeStarts, 
(case CONCAT(exchangeName, tradePair, recordTime) IN (select spikePeakString from spikeStringTable)
WHEN true then 1
WHEN false then 0 END) as spikeEnds, 
diff2Hr, diff4Hr, diff8Hr, diff16Hr, diff1Day, diff2Day, diff4Day, diff1Wk, diff2Wk, diff4Wk, 
gsMarker, commonPtPrice, diffCommonPt, gsTracker from CCIntTickerGSData;

ALTER TABLE CCIntTickerGSDataWMaxPeakTime ADD INDEX exchangePair (exchangeName, tradePair);

select * from CCIntTickerGSDataWMaxPeakTime limit 10000; 

select * from 
(select t1.exchangeName, t1.tradePair, t1.gsTracker, t1.preThresholdDurOrGSMarker, 
t1.postThresholdDuration, t1.totalDuration, 
t1.commonPtTime, t1.minGSTime, t1.maxGSTime, t1.minSpikeTime, 
t1.minGSPrice, t1.maxGSPrice, t1.netPercHike, t1.commonPtPrice,
max(t2.askPriceUSD) as maxFirst48hPrice, (max(t2.askPriceUSD)-t1.commonPtPrice)*100/t1.commonPtPrice as first48hmaxPercChange,
t1.relStdDev1WkPreGS, t1.relVariance1WkPreGS, t1.commonPtPreDiff
from gsSpikeMetaData2 as t1
LEFT JOIN CCIntTickerGSData as t2 ON (t2.exchangeName = t1.exchangeName AND
																	t2.tradePair = t1.tradePair AND
																	t2.recordTime >=  FROM_UNIXTIME((UNIX_TIMESTAMP(t1.minGSTime)) - (preThresholdDurOrGSMarker*3600)) AND
																	t2.recordTime <= FROM_UNIXTIME((UNIX_TIMESTAMP(t1.minGSTime)) - (preThresholdDurOrGSMarker*3600) + 48*3600)
																	)                                                                    
-- where  t1.preThresholdDuration >=8 and t1.netPercHike > 25                                                                    
group by CONCAT(t1.exchangeName, t1.tradePair, t1.gsTracker);


select * from 
(
select t1.exchangeName, t1.tradePair, t1.gsTracker, t1.preThresholdDurOrGSMarker, 
t1.postThresholdDuration, t1.totalDuration, 
FROM_UNIXTIME((UNIX_TIMESTAMP(t1.minGSTime)) - (preThresholdDurOrGSMarker*3600)) as commonPtTime, 
t1.minGSTime, t1.maxGSTime, t1.minSpikeTime, 
t1.minGSPrice, t1.maxGSPrice, t1.netPercHike, t1.commonPtPrice,
ROUND((STDDEV(t2.askPriceUSD)/AVG(t2.askPriceUSD)*100), 10) as relStdDev,
ROUND((VARIANCE(t2.askPriceUSD)/POW(AVG(t2.askPriceUSD), 2)*100), 10) as relVariance, 
ROUND((AVG(t2.askPriceUSD) - t1.commonPtPrice)/t1.commonPtPrice*100, 10) as commonPtPreDiff -- gs commonPtPreDiff should not be a very high positive number to ensure the commonPt of a GS is not a sharp dip
from gsSpikeMetaData as t1
LEFT JOIN CCIntTickerGSData as t2 ON (t2.exchangeName = t1.exchangeName AND
																	t2.tradePair = t1.tradePair AND
																	t2.recordTime <=  FROM_UNIXTIME((UNIX_TIMESTAMP(t1.minGSTime)) - (preThresholdDurOrGSMarker*3600)) AND
																	t2.recordTime >= FROM_UNIXTIME((UNIX_TIMESTAMP(t1.minGSTime)) - (preThresholdDurOrGSMarker*3600) - 7*24*3600)
																	)
-- where  t1.preThresholdDuration >=8 and t1.netPercHike > 25                                                                    
group by CONCAT(t1.exchangeName, t1.tradePair, t1.gsTracker)                                                                    
)t
where CONCAT(exchangeName, tradePair) = 'bittrexBTC-EFL';
