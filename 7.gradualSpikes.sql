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
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff2Hr >35) 	 then 2 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff4Hr >35) 	 then 4 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff8Hr >35) 	 then 8 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff16Hr >35) 	 then 16 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff1Day >35) 	 then 24 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff2Day >35) 	 then 48 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff4Day >35) 	 then 96 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff1Wk >35) 	 then 168 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff2Wk >35) 	 then 336 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff4Wk >35) 	 then 672 
ELSE 0
END) as gsMarker,
(case 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff2Hr >35) 	 then askPriceUSD*100/(diff2Hr + 100) 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff4Hr >35) 	 then askPriceUSD*100/(diff4Hr + 100)  
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff8Hr >35) 	 then askPriceUSD*100/(diff8Hr + 100) 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff16Hr >35) 	 then askPriceUSD*100/(diff16Hr + 100) 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff1Day >35) 	 then askPriceUSD*100/(diff1Day + 100)  
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff2Day >35) 	 then askPriceUSD*100/(diff2Day + 100)  
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff4Day >35) 	 then askPriceUSD*100/(diff4Day + 100)  
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff1Wk >35) 	 then askPriceUSD*100/(diff1Wk + 100)  
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff2Wk >35) 	 then askPriceUSD*100/(diff2Wk + 100)  
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff4Wk >35) 	 then askPriceUSD*100/(diff4Wk + 100)  
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
    commonPtPreDiff FLOAT NULL,
    minGSRelDiff FLOAT NULL
);

INSERT INTO gsSpikeMetaData2
select t1.exchangeName, t1.tradePair, t1.gsTracker, t1.preThresholdDurOrGSMarker, 
t1.postThresholdDuration, t1.totalDuration, 
FROM_UNIXTIME((UNIX_TIMESTAMP(t1.minGSTime)) - (preThresholdDurOrGSMarker*3600)) as commonPtTime, 
t1.minGSTime, t1.maxGSTime, t1.minSpikeTime, 
t1.minGSPrice, t1.maxGSPrice, t1.netPercHike, t1.commonPtPrice,
ROUND((STDDEV(t2.askPriceUSD)/AVG(t2.askPriceUSD)*100), 10) as relStdDev,
ROUND((VARIANCE(t2.askPriceUSD)/POW(AVG(t2.askPriceUSD), 2)*100), 10) as relVariance, 
ROUND((MAX(t2.askPriceUSD) - t1.commonPtPrice)/t1.commonPtPrice*100, 10) as commonPtPreDiff, -- gs commonPtPreDiff should not be a very high positive number to ensure the commonPt of a GS is not a sharp dip
ROUND((MAX(t2.askPriceUSD) - t1.minGSPrice)/t1.minGSPrice*100, 10) as minGSRelDiff -- gs minGSRelDiff should be not be a very high positive number to ensure the minimum 35% pt of a GS is higher than all points in the month and not just a spike back up from a previous dip
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
    commonPtPreDiff FLOAT NULL,
    minGSRelDiff FLOAT NULL
);

INSERT INTO gsSpikeMetaData3
select t1.exchangeName, t1.tradePair, t1.gsTracker, t1.preThresholdDurOrGSMarker, 
t1.postThresholdDuration, t1.totalDuration, 
t1.commonPtTime, t1.minGSTime, t1.maxGSTime, t1.minSpikeTime, 
t1.minGSPrice, t1.maxGSPrice, t1.netPercHike, t1.commonPtPrice,
max(t2.askPriceUSD) as maxFirst48hPrice, (max(t2.askPriceUSD)-t1.commonPtPrice)*100/t1.commonPtPrice as first48hmaxPercChange,
t1.relStdDev1WkPreGS, t1.relVariance1WkPreGS, t1.commonPtPreDiff, t1.minGSRelDiff
from gsSpikeMetaData2 as t1
LEFT JOIN CCIntTickerGSData as t2 ON (t2.exchangeName = t1.exchangeName AND
																	t2.tradePair = t1.tradePair AND
																	t2.recordTime >=  FROM_UNIXTIME((UNIX_TIMESTAMP(t1.minGSTime)) - (preThresholdDurOrGSMarker*3600)) AND
																	t2.recordTime <= FROM_UNIXTIME((UNIX_TIMESTAMP(t1.minGSTime)) - (preThresholdDurOrGSMarker*3600) + 48*3600)
																	)                                                                    
-- where  t1.preThresholdDuration >=8 and t1.netPercHike > 25                                                                    
group by CONCAT(t1.exchangeName, t1.tradePair, t1.gsTracker);

ALTER TABLE gsSpikeMetaData3 ADD INDEX exchangePair (exchangeName, tradePair);

select * from gsSpikeMetaData2 where  minGSPrice < 1000 order by minGSRelDiff desc;

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
    minGSRelDiff FLOAT NULL,
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
t7.relStdDev1WkPreGS, t7.relVariance1WkPreGS, t7.commonPtPreDiff, t7.minGSRelDiff,
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
t5.relStdDev1WkPreGS, t5.relVariance1WkPreGS, t5.commonPtPreDiff, t5.minGSRelDiff,
t5.minGSMaxBuy, t5.minGSMaxSell,
t5.maxPricePostGS, t6.recordTime as maxPricePostGSTime from
(
select t3.exchangeName, t3.tradePair, t3.gsTracker, t3.preThresholdDurOrGSMarker, 
t3.postThresholdDuration, t3.totalDuration, 
t3.commonPtTime, t3.minGSTime, t3.maxGSTime, t3.minSpikeTime, 
t3.minGSPrice, t3.maxGSPrice, t3.netPercHike, t3.commonPtPrice,
t3.maxFirst48hPrice, t3.first48hmaxPercChange,
t3.relStdDev1WkPreGS, t3.relVariance1WkPreGS, t3.commonPtPreDiff, t3.minGSRelDiff,
t3.minGSMaxBuy, t3.minGSMaxSell, max(t4.askPriceUSD) as maxPricePostGS
from 
(
select t1.exchangeName, t1.tradePair, t1.gsTracker, t1.preThresholdDurOrGSMarker, 
t1.postThresholdDuration, t1.totalDuration, 
t1.commonPtTime, t1.minGSTime, t1.maxGSTime, t1.minSpikeTime, 
t1.minGSPrice, t1.maxGSPrice, t1.netPercHike, t1.commonPtPrice,
t1.maxFirst48hPrice, t1.first48hmaxPercChange,
t1.relStdDev1WkPreGS, t1.relVariance1WkPreGS, t1.commonPtPreDiff, t1.minGSRelDiff,
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
LEFT JOIN CCIntTickerGSData as t4 ON (t4.exchangeName = t3.exchangeName AND
																	t4.tradePair = t3.tradePair AND
																	t4.recordTime >=  t3.minGSTime
																	)                                                                    
-- where  t1.preThresholdDuration >=8 and t1.netPercHike > 25                                                                    
group by CONCAT(t3.exchangeName, t3.tradePair, t3.gsTracker)
) as t5 
LEFT JOIN CCIntTickerGSData as t6 ON (t6.exchangeName = t5.exchangeName AND
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
    minGSRelDiff FLOAT NULL,
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
t7.relStdDev1WkPreGS, t7.relVariance1WkPreGS, t7.commonPtPreDiff, t7.minGSRelDiff,
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
	minGSRelDiff FLOAT NULL,
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
t7.relStdDev1WkPreGS, t7.relVariance1WkPreGS, t7.commonPtPreDiff, t7.minGSRelDiff,
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
    minGSRelDiff FLOAT NULL,
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
relVariance1WkPreGS, commonPtPreDiff, minGSRelDiff, maxPricePostGS, maxPricePostGSTime, 
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
t7.relVariance1WkPreGS, t7.commonPtPreDiff, t7.minGSRelDiff,
t7.maxPricePostGS, t7.maxPricePostGSTime, 
t7.minGSMaxBuy, t7.minGSMaxSell, t7.maxGSMaxBuy, t7.maxGSMaxSell, t7.volume24hUSD, 
t7.marketCapUSD, min(t1.recordTime) as minTime95Perc, max(t1.recordTime) as maxTime95Perc, 
((count(*) -1)*15)/(60*24) as netDaysMoreThan95Perc, 
((UNIX_TIMESTAMP((max(t1.recordTime)))) - (UNIX_TIMESTAMP((min(t1.recordTime)))))/(3600*24) as netTimeWindowMoreThan95Perc

from gsSpikeMetaData6 as t7
LEFT JOIN CCIntTickerGSData as t1 ON (t1.exchangeName = t7.exchangeName AND
																	t1.tradePair = t7.tradePair AND
                                                                    t1.askPriceUSD >= (1.95*t7.commonPtPrice) AND
                                                                    t1.recordTime <= t7.maxGSTime AND
                                                                    t1.recordTime >= t7.minGSTime)
group by t7.exchangeName, t7.tradePair, t7.gsTracker) t
;
ALTER TABLE gsSpikeMetaData7 ADD INDEX exchangePair (exchangeName, tradePair);


--

select * from gsSpikeMetaData7 as t1 
-- select * from gsSpikeMetaData7 as t1 
LEFT JOIN CCOpenOrdersGSData t2 ON (t2.exchangeName = t1.exchangeName AND
																	t2.tradePair = t1.tradePair AND
                                                                    t2.recordTime = t1.minGSTime)
where t1.netPercHike >=100 and (t1.maxGSMaxBuy > 14 or  t1.minGSMaxBuy > 14) 
and t1.symbol != 'BTC'  and t1.preThresholdDurOrGSMarker > 16  
and t1.minGSRelDiff < -8
-- and t1.commonPtPreDiff < 25
-- and t1.minGSTime < t1.minSpikeTime
order by  t1.minGSRelDiff ;
																
select * from gsSpikeMetaData7 as t1 
-- select * from gsSpikeMetaData7 as t1 
LEFT JOIN CCOpenOrdersGSData t2 ON (t2.exchangeName = t1.exchangeName AND
																	t2.tradePair = t1.tradePair AND
                                                                    t2.recordTime = t1.minGSTime)
where t1.netPercHike <=35 and (t1.maxGSMaxBuy > 14 or  t1.minGSMaxBuy > 14) 
and t1.symbol != 'BTC'  and t1.preThresholdDurOrGSMarker > 16  
and t1.minGSRelDiff < -8
-- and t1.minGSTime < t1.minSpikeTime
-- and t1.commonPtPreDiff < 30
and CONCAT(t1.exchangeName, t1.tradePair) not in 
(select CONCAT(exchangeName, tradePair) from gsSpikeMetaData7 
where netPercHike >=100 and (maxGSMaxBuy > 14 or  minGSMaxBuy > 14) 
and symbol != 'BTC'  and preThresholdDurOrGSMarker > 16  
and minGSRelDiff < -8
-- and t1.commonPtPreDiff < 25
-- and t1.minGSTime < t1.minSpikeTime
order by  minGSRelDiff )
order by t1.netPercHike ;

select CONCAT(exchangeName, tradePair) from gsSpikeMetaData7 where netPercHike >=100 and (maxGSMaxBuy > 20 or  minGSMaxBuy > 20) and symbol != 'BTC'  and preThresholdDurOrGSMarker > 16  and minGSRelDiff < 0 order by commonPtPreDiff;

select *, CONCAT(exchangeName, tradePair) from gsSpikeMetaData7 where netPercHike <=35 and (maxGSMaxBuy > 20 or  minGSMaxBuy > 20) and symbol != 'BTC'  and preThresholdDurOrGSMarker > 16  and minGSRelDiff < 0 order by commonPtPreDiff 
and CONCAT(exchangeName, tradePair) not in 
(select CONCAT(exchangeName, tradePair) from gsSpikeMetaData7 where netPercHike >=100 and (maxGSMaxBuy > 20 or  minGSMaxBuy > 20) and symbol != 'BTC'  and preThresholdDurOrGSMarker > 16  and minGSRelDiff < 0 order by commonPtPreDiff);



--

select 
/*
exchangeName, tradePair, symbol, gsTracker, preThresholdDurOrGSMarker, 
postThresholdDuration, totalDuration, commonPtTime, minGSTime, maxGSTime, 
minSpikeTime, minGSPrice, maxGSPrice, netPercHike, commonPtPrice,
maxFirst48hPrice, first48hmaxPercChange, relStdDev1WkPreGS, 
relVariance1WkPreGS, commonPtPreDiff, maxPricePostGS, maxPricePostGSTime, 
minGSMaxBuy, minGSMaxSell, maxGSMaxBuy, maxGSMaxSell, volume24hUSD, 
marketCapUSD, 
*/
*, 
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
LEFT JOIN CCIntTickerGSData as t1 ON (t1.exchangeName = t7.exchangeName AND
																	t1.tradePair = t7.tradePair AND
                                                                    t1.askPriceUSD >= (1.31*t7.commonPtPrice) AND
                                                                    t1.recordTime <= t7.maxGSTime AND
                                                                    t1.recordTime >= t7.minGSTime)
group by t7.exchangeName, t7.tradePair, t7.gsTracker) t
where netPercHike <=35 and (maxGSMaxBuy > 20 or  minGSMaxBuy > 20) and symbol != 'BTC'  
and preThresholdDurOrGSMarker > 16
and commonPtPreDiff <55 
and minTime95Perc IS NOT NULL and CONCAT(exchangeName, tradePair) NOT IN 
(select CONCAT(exchangeName, tradePair) from gsSpikeMetaData7 where netPercHike >=100 and (maxGSMaxBuy > 20 or  minGSMaxBuy > 20) and symbol != 'BTC'  and preThresholdDurOrGSMarker > 16  and commonPtPreDiff <55 order by commonPtPreDiff )
order by commonPtPreDiff 
;

select t1.symbol, CONCAT(t1.exchangeName, t1.tradePair), t2.diffCommonPt from gsSpikeMetaDataDel as t1 
LEFT JOIN CCOpenOrdersGSData as t2 ON (t2.exchangeName = t1.exchangeName AND
																	t2.tradePair = t1.tradePair AND
                                                                    t2.recordTime = t1.minGSTime)
                                                                    
where t1.netPercHike <=35 and (t1.maxGSMaxBuy > 20 or  t1.minGSMaxBuy > 20) and t1.symbol != 'BTC'  
and t1.preThresholdDurOrGSMarker > 16
and t1.commonPtPreDiff <55 
and t1.minTime31Perc IS NOT NULL and CONCAT(t1.exchangeName, t1.tradePair) NOT IN 
(select CONCAT(exchangeName, tradePair) from gsSpikeMetaDataDel where 
netPercHike >=100 and (maxGSMaxBuy > 20 or  minGSMaxBuy > 20) and symbol != 'BTC'  
and preThresholdDurOrGSMarker > 16  and commonPtPreDiff <55 order by commonPtPreDiff )
order by commonPtPreDiff 
 ;

select *, CONCAT(exchangeName, tradePair) from gsSpikeMetaData7 where netPercHike >=100 and (maxGSMaxBuy > 20 or  minGSMaxBuy > 20) and symbol != 'BTC'  and preThresholdDurOrGSMarker > 16  and minGSRelDiff < 0 order by commonPtPreDiff ;

select *, CONCAT(exchangeName, tradePair) from gsSpikeMetaData7 where netPercHike <=35 and (maxGSMaxBuy > 20 or  minGSMaxBuy > 20) and symbol != 'BTC'  and preThresholdDurOrGSMarker > 16  and minGSRelDiff < 0 order by commonPtPreDiff 
and CONCAT(exchangeName, tradePair) not in 
(select CONCAT(exchangeName, tradePair) from gsSpikeMetaData7 where netPercHike >=100 and (maxGSMaxBuy > 20 or  minGSMaxBuy > 20) and symbol != 'BTC'  and preThresholdDurOrGSMarker > 16  and minGSRelDiff < 0 order by commonPtPreDiff);


select DISTINCT(CONCAT(exchangeName, tradePair)) from
(
select t1.exchangeName, t1.tradePair, t2.diffCommonPt, t1.gsTracker from
gsSpikeMetaData7 as t1
LEFT JOIN CCOpenOrdersGSData t2 ON (t2.exchangeName = t1.exchangeName AND
																	t2.tradePair = t1.tradePair AND
                                                                    t2.recordTime = t1.minGSTime)
where t1.netPercHike < 35 
 and t1.gsTracker =1

) t
where CONCAT(exchangeName, tradePair)  NOT IN 
(select DISTINCT(CONCAT(exchangeName, tradePair)) from
(
select t1.exchangeName, t1.tradePair, t2.diffCommonPt, t1.gsTracker from
gsSpikeMetaData7 as t1
LEFT JOIN CCOpenOrdersGSData t2 ON (t2.exchangeName = t1.exchangeName AND
																	t2.tradePair = t1.tradePair AND
                                                                    t2.recordTime = t1.minGSTime)
where t1.netPercHike > 35 
and t1.gsTracker =1

) t2);


ALTER TABLE gsSpikeMetaData7 ADD INDEX exchangePair (exchangeName, tradePair);

use pocu4;

select *, CONCAT(t1.exchangeName, t1.tradePair)  from gsSpikeMetaData7 as t1 
LEFT JOIN CCOpenOrdersGSData t2 ON (t2.exchangeName = t1.exchangeName AND
																	t2.tradePair = t1.tradePair AND
                                                                    t2.recordTime = t1.minGSTime)
where t1.netPercHike <=35 
and (t1.maxGSMaxBuy > 20 or  t1.minGSMaxBuy > 20) 
and t1.preThresholdDurOrGSMarker >=16 
and t1.commonPtPreDiff < 35
-- and t2.diffCommonPt > 35
and t1.gsTracker = 1
and CONCAT(t1.exchangeName, t1.tradePair) NOT IN
(select CONCAT(t1.exchangeName, t1.tradePair)  from gsSpikeMetaData7 as t1 
LEFT JOIN CCOpenOrdersGSData t2 ON (t2.exchangeName = t1.exchangeName AND
																	t2.tradePair = t1.tradePair AND
                                                                    t2.recordTime = t1.minGSTime)
where t1.netPercHike >=35 
and (t1.maxGSMaxBuy > 20 or  t1.minGSMaxBuy > 20) 
and t1.preThresholdDurOrGSMarker >=16 
and t1.commonPtPreDiff < 35
-- and t2.diffCommonPt > 35
and t1.gsTracker = 1);


select CONCAT(t1.exchangeName, t1.tradePair)  from gsSpikeMetaData7 as t1 
LEFT JOIN CCOpenOrdersGSData t2 ON (t2.exchangeName = t1.exchangeName AND
																	t2.tradePair = t1.tradePair AND
                                                                    t2.recordTime = t1.minGSTime)
where t1.netPercHike >=35 
and (t1.maxGSMaxBuy > 20 or  t1.minGSMaxBuy > 20) 
and t1.preThresholdDurOrGSMarker >=16 
and t1.commonPtPreDiff < 35
-- and t2.diffCommonPt > 35
and t1.gsTracker = 1;




select *, CONCAT(exchangeName, tradePair) from gsSpikeMetaData7 where netPercHike >=100 and (maxGSMaxBuy > 20 or  minGSMaxBuy > 20) and symbol != 'BTC'  and preThresholdDurOrGSMarker > 8 and first48hmaxPercChange > 35 order by commonPtPreDiff ;

select *, CONCAT(exchangeName, tradePair) from gsSpikeMetaData7 where netPercHike <=35 and (maxGSMaxBuy > 20 or  minGSMaxBuy > 20) and symbol != 'BTC'  and preThresholdDurOrGSMarker > 8  and first48hmaxPercChange > 30 order by commonPtPreDiff ;

--  and commonPtPreDiff < 50 and preThresholdDurOrGSMarker >=16; 

select DISTINCT (CONCAT(exchangeName, tradePair)) from gsSpikeMetaData7 where  (maxGSMaxBuy > 20 or  minGSMaxBuy > 20) ;

select exchangeName, count(*), max(maxGSMaxBuy), max(minGSMaxBuy) from gsSpikeMetaData7 where netPercHike >=100 and netDaysMoreThan95Perc >= 1 and (maxGSMaxBuy > 10 or  minGSMaxBuy > 10) group by exchangeName order by maxGSMaxBuy desc;



/*
1) Avoid curencies with spikes for atleast a month if not more
*/

select * from gsSpikeMetaData6 where netPercHike >= 50 and commonPtPreDiff < 19 and preThresholdDurOrGSMarker >= 16 and exchangeName NOT IN ('yoBit', 'novaexchange', 'livecoin')  order by netPercHike desc ;

select * from gsSpikeMetaData6
where
 -- netPercHike >= 100 and 
 -- relStdDev1WkPreGS < 9 and 
commonPtTime > '2017-10-07 23:59:59' and
-- and
 -- maxGSPrice > minGSPrice
 -- increase threshold from 30 to higher
 -- ensure u wait weeks after a big spike
 netPercHike <= 35
  -- and preThresholdDurOrGSMarker >= 16
  -- and exchangeName NOT IN ('yoBit', 'novaexchange', 'livecoin')
  and  commonPtPreDiff < 19
  --  and volume24hUSD > 10000 
  and marketCapUSD > 1000000
 and CONCAT(exchangeName, tradePair) NOT IN 
 (select CONCAT(exchangeName, tradePair) from gsSpikeMetaData6 where netPercHike > 35)
 order by netPercHike desc;
  
select DISTINCT (CONCAT(exchangeName, tradePair)) from gsSpikeMetaData6
where
 -- netPercHike >= 100 and 
relStdDev1WkPreGS < 11 and 
commonPtTime > '2017-10-07 23:59:59' and
-- and
 -- maxGSPrice > minGSPrice
 -- increase threshold from 30 to higher
 -- ensure u wait weeks after a big spike
 netPercHike <= 35
  -- and preThresholdDurOrGSMarker >= 16
  -- and exchangeName NOT IN ('yoBit', 'novaexchange', 'livecoin')
  and  commonPtPreDiff < 19
  --  and volume24hUSD > 10000 
  and marketCapUSD > 1000000
 and CONCAT(exchangeName, tradePair) NOT IN 
 (select CONCAT(exchangeName, tradePair) from gsSpikeMetaData6 where netPercHike >= 35)
 order by netPercHike desc;
  

select DISTINCT (CONCAT(exchangeName, tradePair)) from gsSpikeMetaData6 where netPercHike >= 50 and marketCapUSD > 1000000 and  commonPtPreDiff < 19 and relStdDev1WkPreGS < 11;

select exchangeName, count(*) from gsSpikeMetaData6 where netPercHike >= 50 and marketCapUSD > 1000000 and  commonPtPreDiff < 19 and relStdDev1WkPreGS < 11 group by exchangeName;

select DISTINCT (symbol) from gsSpikeMetaData6  where netPercHike >= 100

 and CONCAT(exchangeName, tradePair) NOT IN 
(select DISTINCT (CONCAT(exchangeName, tradePair)) from gsSpikeMetaData6 where netPercHike >= 50 and marketCapUSD > 1000000 and  commonPtPreDiff < 19 and relStdDev1WkPreGS < 11);

select * from gsSpikeMetaData7 where (netPercHike >=100 and postThresholdDuration >= 24) or (netDaysMoreThan95Perc >= 1 and percNetDaysMoreThan95Perc >= 50);

select * from gsSpikeMetaData7 where netPercHike >=100 and netDaysMoreThan95Perc >= 1 and maxGSMaxBuy > 5 and 
CONCAT(exchangeName, tradePair, gsTracker) NOT IN
(
select CONCAT(exchangeName, tradePair, gsTracker) from gsSpikeMetaData7 where netPercHike >=100 and netDaysMoreThan95Perc >= 1 and minGSMaxBuy > 5);







select DISTINCT (CONCAT(exchangeName, tradePair)) from gsSpikeMetaData6 where netPercHike >= 35 and volume24hUSD > 10000 and  commonPtPreDiff < 19 and relStdDev1WkPreGS < 11;

select DISTINCT (CONCAT(exchangeName, tradePair)) from gsSpikeMetaData6 where netPercHike >= 35 and volume24hUSD > 10000 and  commonPtPreDiff < 19 and relStdDev1WkPreGS < 9 and netPercHike >= first48hmaxPercChange;
 
select DISTINCT (CONCAT(exchangeName, tradePair)) from gsSpikeMetaData3 where netPercHike >= 50 and commonPtPreDiff < 19 and preThresholdDurOrGSMarker >= 16 and exchangeName NOT IN ('yoBit', 'novaexchange', 'livecoin')  order by netPercHike desc ;
 
select * from gsSpikeMetaData2 where totalDuration >= 100 and commonPtPreDiff < 20 order by netPercHike desc;

select DISTINCT (CONCAT(exchangeName, tradePair)) from gsSpikeMetaData6 where netPercHike >= 35 and maxGSTime < '2017-10-05 23:59:59' and minGSTime != maxGSTime and relStdDev1WkPreGS < 15 and preThresholdDurOrGSMarker >= 8 ;


select count(*) from gsSpikeMetaData2 where commonPtPreDiff < 20;
select DISTINCT (CONCAT(exchangeName, tradePair)) from gsSpikeMetaData2 where preThresholdDurOrGSMarker >= 48 and commonPtPreDiff < 20 and CONCAT(exchangeName, tradePair) 
NOT IN (select DISTINCT (CONCAT(exchangeName, tradePair)) from gsSpikeMetaData2 where netPercHike >= 50 and commonPtPreDiff < 20 order by netPercHike desc) 
order by netPercHike desc;


select * from gsSpikeMetaData6 where netPercHike >= 35 and maxGSTime < '2017-11-06 17:15:00';