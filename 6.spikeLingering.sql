/*

 */
 
use pocu4;

CREATE TABLE  all25PercSpikesWLingeringInfo (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	minPriceHikeStep FLOAT NULL,
    maxPriceHikeStep FLOAT NULL,
    minOfMaxTimeForStep DATETIME NULL, -- denotes the beginning of the spike
    maxOfMaxTimeForStep DATETIME NULL, -- denotes the end of the spike
	totalDurationOfAllStepsInHrs FLOAT NULL, -- duration of spike
    priceHikePercent FLOAT NULL, -- amount of price change in the spike
    priceHikePercentRate FLOAT NULL, -- net rate of change of price in the spike
    minAvgPriceUSD FLOAT NULL,
	maxAvgPriceUSD FLOAT NULL,
    minAvgPriceBTC FLOAT NULL,
	maxAvgPriceBTC FLOAT NULL,
    avgBuyHistoryAmount FLOAT NULL,
	avgSellHistoryAmount FLOAT NULL,
    avgOpenBuyAmount FLOAT NULL,
    avgOpenSellAmount FLOAT NULL,
	minShortestTimeFromMin FLOAT NULL,
    maxShortestTimeFromMax FLOAT NULL,
    pt1HrBaseDiff FLOAT NULL,
    pt1HrPeakDiff FLOAT NULL,
	pt2HrBaseDiff FLOAT NULL,
    pt2HrPeakDiff FLOAT NULL, 
    pt4HrBaseDiff FLOAT NULL,
    pt4HrPeakDiff FLOAT NULL, 
	pt8HrBaseDiff FLOAT NULL,
    pt8HrPeakDiff FLOAT NULL, 
	pt16HrBaseDiff FLOAT NULL,
    pt16HrPeakDiff FLOAT NULL, 
	pt24HrBaseDiff FLOAT NULL,
    pt24HrPeakDiff FLOAT NULL, 
	pt48HrBaseDiff FLOAT NULL,
    pt48HrPeakDiff FLOAT NULL
    );
    
 -- 38 secs   
INSERT INTO all25PercSpikesWLingeringInfo
select all25PercSpikes.exchangeName, all25PercSpikes.tradePair, all25PercSpikes.minPriceHikeStep, 
all25PercSpikes.maxPriceHikeStep, all25PercSpikes.minOfMaxTimeForStep, all25PercSpikes.maxOfMaxTimeForStep, 
all25PercSpikes.totalDurationOfAllStepsInHrs, all25PercSpikes.priceHikePercent, all25PercSpikes.priceHikePercentRate, 
all25PercSpikes.minAvgPriceUSD, all25PercSpikes.maxAvgPriceUSD, all25PercSpikes.minAvgPriceBTC, 
all25PercSpikes.maxAvgPriceBTC, all25PercSpikes.avgBuyHistoryAmount, all25PercSpikes.avgSellHistoryAmount, 
all25PercSpikes.avgOpenBuyAmount, all25PercSpikes.avgOpenSellAmount, 
all25PercSpikes.minShortestTimeFromMin, all25PercSpikes.maxShortestTimeFromMax, 
 (tempTicker.askPriceUSD - all25PercSpikes.minAvgPriceUSD)*100/all25PercSpikes.minAvgPriceUSD ,
 (tempTicker.askPriceUSD - all25PercSpikes.maxAvgPriceUSD)*100/all25PercSpikes.maxAvgPriceUSD ,
 (tempTicker2.askPriceUSD - all25PercSpikes.minAvgPriceUSD)*100/all25PercSpikes.minAvgPriceUSD ,
 (tempTicker2.askPriceUSD - all25PercSpikes.maxAvgPriceUSD)*100/all25PercSpikes.maxAvgPriceUSD ,
 (tempTicker3.askPriceUSD - all25PercSpikes.minAvgPriceUSD)*100/all25PercSpikes.minAvgPriceUSD ,
 (tempTicker3.askPriceUSD - all25PercSpikes.maxAvgPriceUSD)*100/all25PercSpikes.maxAvgPriceUSD ,
 (tempTicker4.askPriceUSD - all25PercSpikes.minAvgPriceUSD)*100/all25PercSpikes.minAvgPriceUSD ,
 (tempTicker4.askPriceUSD - all25PercSpikes.maxAvgPriceUSD)*100/all25PercSpikes.maxAvgPriceUSD ,
(tempTicker5.askPriceUSD - all25PercSpikes.minAvgPriceUSD)*100/all25PercSpikes.minAvgPriceUSD ,
 (tempTicker5.askPriceUSD - all25PercSpikes.maxAvgPriceUSD)*100/all25PercSpikes.maxAvgPriceUSD ,
 (tempTicker6.askPriceUSD - all25PercSpikes.minAvgPriceUSD)*100/all25PercSpikes.minAvgPriceUSD ,
 (tempTicker6.askPriceUSD - all25PercSpikes.maxAvgPriceUSD)*100/all25PercSpikes.maxAvgPriceUSD ,
 (tempTicker7.askPriceUSD - all25PercSpikes.minAvgPriceUSD)*100/all25PercSpikes.minAvgPriceUSD ,
 (tempTicker7.askPriceUSD - all25PercSpikes.maxAvgPriceUSD)*100/all25PercSpikes.maxAvgPriceUSD 
from steepHikeStepsMinMaxWMinimumHeight AS all25PercSpikes
LEFT JOIN CCIntTicker tempTicker ON (tempTicker.exchangeName = all25PercSpikes.exchangeName AND
																tempTicker.tradePair = all25PercSpikes.tradePair AND
                                                                FROM_UNIXTIME((UNIX_TIMESTAMP(tempTicker.recordTime)) - 3600) = all25PercSpikes.maxOfMaxTimeForStep)
LEFT JOIN CCIntTicker tempTicker2 ON (tempTicker2.exchangeName = all25PercSpikes.exchangeName AND
																	tempTicker2.tradePair = all25PercSpikes.tradePair AND
																	FROM_UNIXTIME((UNIX_TIMESTAMP(tempTicker2.recordTime)) - 7200) = all25PercSpikes.maxOfMaxTimeForStep)
LEFT JOIN CCIntTicker tempTicker3 ON (tempTicker3.exchangeName = all25PercSpikes.exchangeName AND
																	tempTicker3.tradePair = all25PercSpikes.tradePair AND
																	FROM_UNIXTIME((UNIX_TIMESTAMP(tempTicker3.recordTime)) - 14400) = all25PercSpikes.maxOfMaxTimeForStep)
LEFT JOIN CCIntTicker tempTicker4 ON (tempTicker4.exchangeName = all25PercSpikes.exchangeName AND
																	tempTicker4.tradePair = all25PercSpikes.tradePair AND
																	FROM_UNIXTIME((UNIX_TIMESTAMP(tempTicker4.recordTime)) - 28800) = all25PercSpikes.maxOfMaxTimeForStep)
LEFT JOIN CCIntTicker tempTicker5 ON (tempTicker5.exchangeName = all25PercSpikes.exchangeName AND
																	tempTicker5.tradePair = all25PercSpikes.tradePair AND
																	FROM_UNIXTIME((UNIX_TIMESTAMP(tempTicker5.recordTime)) - 57600) = all25PercSpikes.maxOfMaxTimeForStep)
LEFT JOIN CCIntTicker tempTicker6 ON (tempTicker6.exchangeName = all25PercSpikes.exchangeName AND
																	tempTicker6.tradePair = all25PercSpikes.tradePair AND
																	FROM_UNIXTIME((UNIX_TIMESTAMP(tempTicker6.recordTime)) - 86400) = all25PercSpikes.maxOfMaxTimeForStep)
LEFT JOIN CCIntTicker tempTicker7 ON (tempTicker7.exchangeName = all25PercSpikes.exchangeName AND
																	tempTicker7.tradePair = all25PercSpikes.tradePair AND
																	FROM_UNIXTIME((UNIX_TIMESTAMP(tempTicker7.recordTime)) - 172800) = all25PercSpikes.maxOfMaxTimeForStep);


ALTER TABLE all25PercSpikesWLingeringInfo ADD INDEX exchangePair (exchangeName, tradePair, maxOfMaxTimeForStep);                                                                
 select * from all25PercSpikesWLingeringInfo;
select  DISTINCT(CONCAT(exchangeName, tradePair)) from all25PercSpikesWLingeringInfo;  
select DISTINCT(CONCAT(exchangeName, tradePair)) from all25PercSpikesWLingeringInfo where  (pt1HrBaseDiff > 0 or pt2HrBaseDiff > 0 ) and CONCAT(exchangeName, tradePair) NOT in 
(select DISTINCT(CONCAT(exchangeName, tradePair)) from all25PercSpikesWLingeringInfo where  pt1HrBaseDiff > 0 or pt2HrBaseDiff > 0 or pt4HrBaseDiff > 0 or pt8HrBaseDiff > 0 or pt16HrBaseDiff > 0 or pt24HrBaseDiff > 0 or pt48HrBaseDiff > 0);

select DISTINCT(CONCAT(exchangeName, tradePair)) from all25PercSpikesWLingeringInfo where  pt1HrBaseDiff > 0 ;

select DISTINCT(CONCAT(exchangeName, tradePair)) from all25PercSpikesWLingeringInfo  where pt4HrBaseDiff >= 25  AND CONCAT(exchangeName, tradePair) NOT IN
(select DISTINCT(CONCAT(exchangeName, tradePair)) from all25PercSpikesWLingeringInfo where  pt8HrBaseDiff >= 25) ;

select DISTINCT(CONCAT(exchangeName, tradePair)) from all25PercSpikesWLingeringInfo  where pt4HrBaseDiff > 25  AND CONCAT(exchangeName, tradePair) NOT IN
(select DISTINCT(CONCAT(exchangeName, tradePair)) from all25PercSpikesWLingeringInfo where  pt2HrBaseDiff >= 25) ;

select * from all25PercSpikesWLingeringInfo where  pt1HrBaseDiff > 0 ;
select * from all25PercSpikesWLingeringInfo where  pt1HrBaseDiff >= 25 ;
select * from all25PercSpikesWLingeringInfo where  pt1HrBaseDiff >= 25 and pt1HrPeakDiff >= -15 ;


/*
The following table sustainedSpikesWLastSpikeInfo gets more info on the spikes that have show shown persistence 
based on data from the previous table - all25PercSpikesWLingeringInfo. 
This more info is the difference between the mins, maxs and time gap between the current spike and the previous spike. 
Note that spikes themselves were earlier chosen as those that had hiked by more than 25%.  On the other hand, 
persistent Spikes were alos chosen as those that stayed at or over 25% more than when the spike started. This is because
there wasn't a great difference between the count of unique trade pairs that were more than 0% and those that were more than 25%
of the base of the spike. This was determined obviously by running the following commands:
select DISTINCT(CONCAT(exchangeName, tradePair)) from all25PercSpikesWLingeringInfo where  pt1HrBaseDiff > 0 ;
select DISTINCT(CONCAT(exchangeName, tradePair)) from all25PercSpikesWLingeringInfo where  pt1HrBaseDiff >= 25 ;

Note that only pt1HrBaseDiff was used, adding pt2HrBaseDiff or pt4HrBaseDiff didn't add much to the count
*/

CREATE TABLE  sustainedSpikesWLastSpikeInfo (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	minPriceHikeStep FLOAT NULL,
    maxPriceHikeStep FLOAT NULL,
    minOfMaxTimeForStep DATETIME NULL,
    maxOfMaxTimeForStep DATETIME NULL,
	totalDurationOfAllStepsInHrs FLOAT NULL,
	priceHikePercent FLOAT NULL, -- amount of price change in the spike
    priceHikePercentRate FLOAT NULL, -- net rate of change of price in the spike
    minAvgPriceUSD FLOAT NULL,
	maxAvgPriceUSD FLOAT NULL,
    minAvgPriceBTC FLOAT NULL,
	maxAvgPriceBTC FLOAT NULL,
    avgBuyHistoryAmount FLOAT NULL,
	avgSellHistoryAmount FLOAT NULL,
    avgOpenBuyAmount FLOAT NULL,
    avgOpenSellAmount FLOAT NULL,
	minShortestTimeFromMin FLOAT NULL,
    maxShortestTimeFromMax FLOAT NULL,
    percDiffLastTwoMins FLOAT NULL,
	percDiffLastTwoMaxs FLOAT NULL,
    tradePairSpikeOrder FLOAT NULL,
	timeSinceLastSpike FLOAT NULL,
	pt1HrBaseDiff FLOAT NULL,
    pt1HrPeakDiff FLOAT NULL,
	pt2HrBaseDiff FLOAT NULL,
    pt2HrPeakDiff FLOAT NULL, 
    pt4HrBaseDiff FLOAT NULL,
    pt4HrPeakDiff FLOAT NULL, 
	pt8HrBaseDiff FLOAT NULL,
    pt8HrPeakDiff FLOAT NULL, 
	pt16HrBaseDiff FLOAT NULL,
    pt16HrPeakDiff FLOAT NULL, 
	pt24HrBaseDiff FLOAT NULL,
    pt24HrPeakDiff FLOAT NULL, 
	pt48HrBaseDiff FLOAT NULL,
    pt48HrPeakDiff FLOAT NULL
    );

 
INSERT into  sustainedSpikesWLastSpikeInfo
select exchangeName, tradePair, minPriceHikeStep, maxPriceHikeStep, minOfMaxTimeForStep, 
maxOfMaxTimeForStep, totalDurationOfAllStepsInHrs, priceHikePercent, priceHikePercentRate, minAvgPriceUSD, maxAvgPriceUSD, 
minAvgPriceBTC, maxAvgPriceBTC, avgBuyHistoryAmount, avgSellHistoryAmount, avgOpenBuyAmount, 
avgOpenSellAmount, minShortestTimeFromMin, maxShortestTimeFromMax, percDiffLastTwoMins, percDiffLastTwoMaxs, 
tradePairSpikeOrder, timeSinceLastSpike, pt1HrBaseDiff, pt1HrPeakDiff, pt2HrBaseDiff , pt2HrPeakDiff, pt4HrBaseDiff,
pt4HrPeakDiff, pt8HrBaseDiff , pt8HrPeakDiff, pt16HrBaseDiff, pt16HrPeakDiff, pt24HrBaseDiff, pt24HrPeakDiff,
pt48HrBaseDiff, pt48HrPeakDiff 
from 
(select exchangeName, tradePair, minPriceHikeStep, maxPriceHikeStep, minOfMaxTimeForStep, 
maxOfMaxTimeForStep, totalDurationOfAllStepsInHrs, priceHikePercent, priceHikePercentRate, minAvgPriceUSD, maxAvgPriceUSD, 
minAvgPriceBTC, maxAvgPriceBTC, avgBuyHistoryAmount, avgSellHistoryAmount, avgOpenBuyAmount, 
avgOpenSellAmount, minShortestTimeFromMin, maxShortestTimeFromMax, 
pt1HrBaseDiff, pt1HrPeakDiff, pt2HrBaseDiff , pt2HrPeakDiff, pt4HrBaseDiff,
pt4HrPeakDiff, pt8HrBaseDiff , pt8HrPeakDiff, pt16HrBaseDiff, pt16HrPeakDiff, pt24HrBaseDiff, pt24HrPeakDiff,
pt48HrBaseDiff, pt48HrPeakDiff, 
(case @previousTradePair = CONCAT(exchangeName, tradePair) 
WHEN true then @stepDiffPreviousTwoMins := ROUND(((minPriceHikeStep/10+1) - (@previousMinStep/10+1))/(@previousMinStep/10+1)*100, 2)
WHEN false then @stepDiffPreviousTwoMins := 0 END) as percDiffLastTwoMins,
(case @previousTradePair = CONCAT(exchangeName, tradePair) 
WHEN true then @stepDiffPreviousTwoMaxs := ROUND(((maxPriceHikeStep/10+1) - (@previousMaxStep/10+1))/(@previousMaxStep/10+1)*100, 2)
WHEN false then @stepDiffPreviousTwoMaxs := 0 END) as percDiffLastTwoMaxs,
(case @previousTradePair = CONCAT(exchangeName, tradePair) 
WHEN true then @tradePairSpikeOrderTracker := (@tradePairSpikeOrderTracker + 1)
WHEN false then @tradePairSpikeOrderTracker := 1 END) as tradePairSpikeOrder,
(case @previousTradePair = CONCAT(exchangeName, tradePair) 
WHEN true then @timeSincePreviousSpike := ROUND(time_to_sec(timediff(minOfMaxTimeForStep, @lastMaxTime)) / 3600, 2)
WHEN false then @timeSincePreviousSpike := 0 END) as timeSinceLastSpike, 
(@previousMinStep := minPriceHikeStep) as lastMinStep,
(@previousMaxStep := maxPriceHikeStep) as lastMaxStep,
(@lastMaxTime := maxOfMaxTimeForStep) as lastMaxTime,
(@previousTradePair := CONCAT(exchangeName, tradePair)) as lastTradePair
from 
(select * from all25PercSpikesWLingeringInfo where pt1HrBaseDiff >= 25 ) tempTable2
JOIN (select @stepDiffPreviousTwoMins := 0,@previousMinStep := 0, @stepDiffPreviousTwoMaxs := 0,@previousMaxStep := 0, 
@timeSincePreviousSpike := 0, @lastMaxTime := '2017-10-01 00:00:00', @previousTradePair := "none", 
@tradePairSpikeOrderTracker := 1) t) tempTable3;

ALTER TABLE sustainedSpikesWLastSpikeInfo ADD INDEX exchangePair (exchangeName, tradePair);

select * from sustainedSpikesWLastSpikeInfo;

select DISTINCT(CONCAT(exchangeName, tradePair)) from sustainedSpikesWLastSpikeInfo;

-- tradePair distibution by exchanges that pass the following criteria, cryptopia: 32, Bittrex: 22, yoBit: 18, livecoin: 10, poloniex: 4; total: 86
select DISTINCT(CONCAT(exchangeName, tradePair)) from sustainedSpikesWLastSpikeInfo where tradePairSpikeOrder > 1 AND percDiffLastTwoMaxs >= 25 ;

select avg(pt8HrBaseDiff) from sustainedSpikesWLastSpikeInfo where CONCAT(exchangeName, tradePair)  IN
(select DISTINCT(CONCAT(exchangeName, tradePair)) from sustainedSpikesWLastSpikeInfo where tradePairSpikeOrder > 1 AND percDiffLastTwoMaxs >= 25 AND percDiffLastTwoMaxs < 100);


CREATE TABLE  successfulLingeringSpikes (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	minPriceHikeStep FLOAT NULL,
    maxPriceHikeStep FLOAT NULL,
    minOfMaxTimeForStep DATETIME NULL,
    maxOfMaxTimeForStep DATETIME NULL,
	totalDurationOfAllStepsInHrs FLOAT NULL,
	priceHikePercent FLOAT NULL, -- amount of price change in the spike
    priceHikePercentRate FLOAT NULL, -- net rate of change of price in the spike
    minAvgPriceUSD FLOAT NULL,
	maxAvgPriceUSD FLOAT NULL,
    minAvgPriceBTC FLOAT NULL,
	maxAvgPriceBTC FLOAT NULL,
    avgBuyHistoryAmount FLOAT NULL,
	avgSellHistoryAmount FLOAT NULL,
    avgOpenBuyAmount FLOAT NULL,
    avgOpenSellAmount FLOAT NULL,
	minShortestTimeFromMin FLOAT NULL,
    maxShortestTimeFromMax FLOAT NULL,
    percDiffLastTwoMins FLOAT NULL,
	percDiffLastTwoMaxs FLOAT NULL,
    tradePairSpikeOrder FLOAT NULL,
	timeSinceLastSpike FLOAT NULL,
	pt1HrBaseDiff FLOAT NULL,
    pt1HrPeakDiff FLOAT NULL,
	pt2HrBaseDiff FLOAT NULL,
    pt2HrPeakDiff FLOAT NULL, 
    pt4HrBaseDiff FLOAT NULL,
    pt4HrPeakDiff FLOAT NULL, 
	pt8HrBaseDiff FLOAT NULL,
    pt8HrPeakDiff FLOAT NULL, 
	pt16HrBaseDiff FLOAT NULL,
    pt16HrPeakDiff FLOAT NULL, 
	pt24HrBaseDiff FLOAT NULL,
    pt24HrPeakDiff FLOAT NULL, 
	pt48HrBaseDiff FLOAT NULL,
    pt48HrPeakDiff FLOAT NULL
    );
    
INSERT INTO successfulLingeringSpikes
select exchangeName, tradePair, minPriceHikeStep, maxPriceHikeStep, minOfMaxTimeForStep, 
maxOfMaxTimeForStep, totalDurationOfAllStepsInHrs, priceHikePercent, priceHikePercentRate, minAvgPriceUSD, maxAvgPriceUSD, 
minAvgPriceBTC, maxAvgPriceBTC, avgBuyHistoryAmount, avgSellHistoryAmount, avgOpenBuyAmount, 
avgOpenSellAmount, minShortestTimeFromMin, maxShortestTimeFromMax, percDiffLastTwoMins, percDiffLastTwoMaxs, 
tradePairSpikeOrder, timeSinceLastSpike, pt1HrBaseDiff, pt1HrPeakDiff, pt2HrBaseDiff , pt2HrPeakDiff, pt4HrBaseDiff,
pt4HrPeakDiff, pt8HrBaseDiff , pt8HrPeakDiff, pt16HrBaseDiff, pt16HrPeakDiff, pt24HrBaseDiff, pt24HrPeakDiff,
pt48HrBaseDiff, pt48HrPeakDiff 
from 
(select *, 
/*
the following sub table takes the desceding ordered spikes table and marks those rows as true that lead to spikes greater
than 30%
*/
(case @previousTradePair = CONCAT(exchangeName, tradePair) AND @previousPercDiffLastTwoMaxs >= 25 AND percDiffLastTwoMaxs < 25
WHEN true then @upcomingHikeGreaterThanThreshold := true
WHEN false then @upcomingHikeGreaterThanThreshold := false END) as nextHikeGreaterThanThreshold, 
(@previousPercDiffLastTwoMaxs := ROUND(percDiffLastTwoMaxs, 2)) as nextPercDiffLastTwoMaxs,
(@previousTradePair := CONCAT(exchangeName, tradePair)) as nextTradePair
from 
/* the following sub table steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfoTemp simply orders the spikes in descending order.
This is bein done so  that spikes that lead to those subsequent ones greater than 30% can be marked which is done in the above sub table
*/
(select * from sustainedSpikesWLastSpikeInfo 
ORDER BY CONCAT(exchangeName, tradePair), maxOfMaxTimeForStep DESC) sustainedSpikesWLastSpikeInfoTemp
JOIN (select @upcomingHikeGreaterThanThreshold := false, @previousPercDiffLastTwoMaxs := 0, @previousTradePair := "none") t) tempTable1
where tempTable1.percDiffLastTwoMaxs >= 25 OR tempTable1.nextHikeGreaterThanThreshold = true
ORDER BY CONCAT(exchangeName, tradePair), maxOfMaxTimeForStep ;

ALTER TABLE successfulLingeringSpikes ADD INDEX exchangePair (exchangeName, tradePair);


use pocu4;

CREATE TABLE  lingeringSpikesWPreceedingInfo (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	minPriceHikeStep FLOAT NULL,
    maxPriceHikeStep FLOAT NULL,
    minOfMaxTimeForStep DATETIME NULL,
    maxOfMaxTimeForStep DATETIME NULL,
	totalDurationOfAllStepsInHrs FLOAT NULL,
	priceHikePercent FLOAT NULL, -- amount of price change in the spike
    priceHikePercentRate FLOAT NULL, -- net rate of change of price in the spike
    minAvgPriceUSD FLOAT NULL,
	maxAvgPriceUSD FLOAT NULL,
    minAvgPriceBTC FLOAT NULL,
	maxAvgPriceBTC FLOAT NULL,
    avgBuyHistoryAmount FLOAT NULL,
	avgSellHistoryAmount FLOAT NULL,
    avgOpenBuyAmount FLOAT NULL,
    avgOpenSellAmount FLOAT NULL,
	minShortestTimeFromMin FLOAT NULL,
    maxShortestTimeFromMax FLOAT NULL,
    percDiffLastTwoMins FLOAT NULL,
	percDiffLastTwoMaxs FLOAT NULL,
    tradePairSpikeOrder FLOAT NULL,
	timeSinceLastSpike FLOAT NULL,
    pt1HrBaseDiff FLOAT NULL,
	pt2HrBaseDiff FLOAT NULL,
    pt4HrBaseDiff FLOAT NULL,
	pt8HrBaseDiff FLOAT NULL,
	pt16HrBaseDiff FLOAT NULL,
	pt24HrBaseDiff FLOAT NULL,
	pt48HrBaseDiff FLOAT NULL,
    pt96HrBaseDiff FLOAT NULL,
    pt168HrBaseDiff FLOAT NULL
    );
    
 -- 38 secs   
INSERT INTO lingeringSpikesWPreceedingInfo
select lingeringSpikes.exchangeName, lingeringSpikes.tradePair, lingeringSpikes.minPriceHikeStep, 
lingeringSpikes.maxPriceHikeStep, lingeringSpikes.minOfMaxTimeForStep, lingeringSpikes.maxOfMaxTimeForStep, 
lingeringSpikes.totalDurationOfAllStepsInHrs, lingeringSpikes.priceHikePercent, lingeringSpikes.priceHikePercentRate, 
lingeringSpikes.minAvgPriceUSD, lingeringSpikes.maxAvgPriceUSD, lingeringSpikes.minAvgPriceBTC, 
lingeringSpikes.maxAvgPriceBTC, lingeringSpikes.avgBuyHistoryAmount, lingeringSpikes.avgSellHistoryAmount, 
lingeringSpikes.avgOpenBuyAmount, lingeringSpikes.avgOpenSellAmount, lingeringSpikes.minShortestTimeFromMin,
lingeringSpikes.maxShortestTimeFromMax, lingeringSpikes.percDiffLastTwoMins, lingeringSpikes.percDiffLastTwoMaxs,
lingeringSpikes.tradePairSpikeOrder, lingeringSpikes.timeSinceLastSpike,
 (tempTicker.askPriceUSD - lingeringSpikes.minAvgPriceUSD)*100/lingeringSpikes.minAvgPriceUSD ,
 (tempTicker2.askPriceUSD - lingeringSpikes.minAvgPriceUSD)*100/lingeringSpikes.minAvgPriceUSD ,
 (tempTicker3.askPriceUSD - lingeringSpikes.minAvgPriceUSD)*100/lingeringSpikes.minAvgPriceUSD ,
 (tempTicker4.askPriceUSD - lingeringSpikes.minAvgPriceUSD)*100/lingeringSpikes.minAvgPriceUSD ,
(tempTicker5.askPriceUSD - lingeringSpikes.minAvgPriceUSD)*100/lingeringSpikes.minAvgPriceUSD ,
 (tempTicker6.askPriceUSD - lingeringSpikes.minAvgPriceUSD)*100/lingeringSpikes.minAvgPriceUSD ,
 (tempTicker7.askPriceUSD - lingeringSpikes.minAvgPriceUSD)*100/lingeringSpikes.minAvgPriceUSD,
 (tempTicker8.askPriceUSD - lingeringSpikes.minAvgPriceUSD)*100/lingeringSpikes.minAvgPriceUSD,
 (tempTicker9.askPriceUSD - lingeringSpikes.minAvgPriceUSD)*100/lingeringSpikes.minAvgPriceUSD
from sustainedSpikesWLastSpikeInfo AS lingeringSpikes
LEFT JOIN CCIntTicker tempTicker ON (tempTicker.exchangeName = lingeringSpikes.exchangeName AND
																tempTicker.tradePair = lingeringSpikes.tradePair AND
                                                                FROM_UNIXTIME((UNIX_TIMESTAMP(tempTicker.recordTime)) + 3600) = lingeringSpikes.minOfMaxTimeForStep)
LEFT JOIN CCIntTicker tempTicker2 ON (tempTicker2.exchangeName = lingeringSpikes.exchangeName AND
																	tempTicker2.tradePair = lingeringSpikes.tradePair AND
																	FROM_UNIXTIME((UNIX_TIMESTAMP(tempTicker2.recordTime)) + 7200) = lingeringSpikes.minOfMaxTimeForStep)
LEFT JOIN CCIntTicker tempTicker3 ON (tempTicker3.exchangeName = lingeringSpikes.exchangeName AND
																	tempTicker3.tradePair = lingeringSpikes.tradePair AND
																	FROM_UNIXTIME((UNIX_TIMESTAMP(tempTicker3.recordTime)) + 14400) = lingeringSpikes.minOfMaxTimeForStep)
LEFT JOIN CCIntTicker tempTicker4 ON (tempTicker4.exchangeName = lingeringSpikes.exchangeName AND
																	tempTicker4.tradePair = lingeringSpikes.tradePair AND
																	FROM_UNIXTIME((UNIX_TIMESTAMP(tempTicker4.recordTime)) + 28800) = lingeringSpikes.minOfMaxTimeForStep)
LEFT JOIN CCIntTicker tempTicker5 ON (tempTicker5.exchangeName = lingeringSpikes.exchangeName AND
																	tempTicker5.tradePair = lingeringSpikes.tradePair AND
																	FROM_UNIXTIME((UNIX_TIMESTAMP(tempTicker5.recordTime)) + 57600) = lingeringSpikes.minOfMaxTimeForStep)
LEFT JOIN CCIntTicker tempTicker6 ON (tempTicker6.exchangeName = lingeringSpikes.exchangeName AND
																	tempTicker6.tradePair = lingeringSpikes.tradePair AND
																	FROM_UNIXTIME((UNIX_TIMESTAMP(tempTicker6.recordTime)) + 86400) = lingeringSpikes.minOfMaxTimeForStep)
LEFT JOIN CCIntTicker tempTicker7 ON (tempTicker7.exchangeName = lingeringSpikes.exchangeName AND
																	tempTicker7.tradePair = lingeringSpikes.tradePair AND
																	FROM_UNIXTIME((UNIX_TIMESTAMP(tempTicker7.recordTime)) + 172800) = lingeringSpikes.minOfMaxTimeForStep)
LEFT JOIN CCIntTicker tempTicker8 ON (tempTicker8.exchangeName = lingeringSpikes.exchangeName AND
																	tempTicker8.tradePair = lingeringSpikes.tradePair AND
																	FROM_UNIXTIME((UNIX_TIMESTAMP(tempTicker8.recordTime)) + 345600) = lingeringSpikes.minOfMaxTimeForStep)
LEFT JOIN CCIntTicker tempTicker9 ON (tempTicker9.exchangeName = lingeringSpikes.exchangeName AND
																	tempTicker9.tradePair = lingeringSpikes.tradePair AND
																	FROM_UNIXTIME((UNIX_TIMESTAMP(tempTicker9.recordTime)) + 604800) = lingeringSpikes.minOfMaxTimeForStep)                                                                    
;


ALTER TABLE lingeringSpikesWPreceedingInfo ADD INDEX exchangePair (exchangeName, tradePair, maxOfMaxTimeForStep);                                                                

select CONCAT(exchangeName, tradePair) from lingeringSpikesWPreceedingInfo where pt24HrBaseDiff < 0 and tradePairSpikeOrder = 1;


-- test 
select * from successfulLingeringSpikes;

select * from successfulLingeringSpikes where tradePairSpikeOrder = 1;

select avg(pt1HrBaseDiff), avg(pt2HrBaseDiff), avg(pt4HrBaseDiff), avg(pt8HrBaseDiff), avg(pt16HrBaseDiff)
 from successfulLingeringSpikes where percDiffLastTwoMaxs = 0 and tradePairSpikeOrder = 1;
 
 select avg(pt1HrBaseDiff), avg(pt2HrBaseDiff), avg(pt4HrBaseDiff), avg(pt8HrBaseDiff), avg(pt16HrBaseDiff)
 from sustainedSpikesWLastSpikeInfo where CONCAT(exchangeName, tradePair, maxOfMaxTimeForStep) NOT IN 
 (select CONCAT(exchangeName, tradePair, maxOfMaxTimeForStep) from successfulLingeringSpikes where percDiffLastTwoMaxs = 0) and percDiffLastTwoMaxs < 100 and tradePairSpikeOrder = 1;

select exchangeName
-- (pt8HrBaseDiff)
-- , (pt2HrBaseDiff), (pt4HrBaseDiff), (pt8HrBaseDiff), (pt16HrBaseDiff)
 from successfulLingeringSpikes where percDiffLastTwoMaxs = 0 and tradePairSpikeOrder = 1 and pt1HrBaseDiff < 75;
 
 select  exchangeName
 -- (pt8HrBaseDiff)
 -- , (pt2HrBaseDiff), (pt4HrBaseDiff), (pt8HrBaseDiff), (pt16HrBaseDiff)
 from sustainedSpikesWLastSpikeInfo where CONCAT(exchangeName, tradePair, maxOfMaxTimeForStep) NOT IN 
 (select CONCAT(exchangeName, tradePair, maxOfMaxTimeForStep) from successfulLingeringSpikes where percDiffLastTwoMaxs = 0)  and tradePairSpikeOrder = 1 and pt1HrBaseDiff < 75;
 
 select timeSinceLastSpike from successfulLingeringSpikes where timeSinceLastSpike != 0 and timeSinceLastSpike > 1 and timeSinceLastSpike <24 ;
 
 select avg(timeSinceLastSpike) from successfulLingeringSpikes where timeSinceLastSpike != 0;
 
 select DISTINCT(CONCAT(exchangeName, tradePair)) from  potentiallySuccesfulSteepSpikes where CONCAT(exchangeName, tradePair) NOT IN 
 ( select DISTINCT(CONCAT(exchangeName, tradePair)) from successfulLingeringSpikes);
 
  select DISTINCT(CONCAT(exchangeName, tradePair)) from  potentiallySuccesfulSteepSpikesWithin24Hrs where CONCAT(exchangeName, tradePair) NOT IN 
 ( select DISTINCT(CONCAT(exchangeName, tradePair)) from sustainedSpikesWLastSpikeInfo);
 
   select DISTINCT(CONCAT(exchangeName, tradePair)) from  gradualSpikesWMinimumHeight where CONCAT(exchangeName, tradePair) NOT IN 
 ( select DISTINCT(CONCAT(exchangeName, tradePair)) from successfulLingeringSpikes);

  select DISTINCT(CONCAT(exchangeName, tradePair)) 
 from sustainedSpikesWLastSpikeInfo where CONCAT(exchangeName, tradePair) NOT IN (select DISTINCT(CONCAT(exchangeName, tradePair)) from successfulLingeringSpikes) AND CONCAT(exchangeName, tradePair)  IN 
 ( select DISTINCT(CONCAT(exchangeName, tradePair)) from gradualSpikesWMinimumHeight);
 
  
 select recordTime, askPriceUSD from CCIntTicker where CONCAT(exchangeName, tradePair) = 'bittrexBTC-AGRS';

select *  from sustainedSpikesWLastSpikeInfo where  CONCAT(exchangeName, tradePair) = 'bittrexBTC-AGRS';

 select DISTINCT(CONCAT(exchangeName, tradePair)) from successfulLingeringSpikes;
select DISTINCT(CONCAT(exchangeName, tradePair)) 
 from sustainedSpikesWLastSpikeInfo where CONCAT(exchangeName, tradePair) NOT IN (select DISTINCT(CONCAT(exchangeName, tradePair)) from successfulLingeringSpikes) ;

select DISTINCT(CONCAT(exchangeName, tradePair)) from sustainedSpikesWLastSpikeInfo where (CONCAT(exchangeName, tradePair) NOT IN  
(select DISTINCT(CONCAT(exchangeName, tradePair)) from sustainedSpikesWLastSpikeInfo
 where (CONCAT(exchangeName, tradePair) IN 
 (
select DISTINCT(CONCAT(exchangeName, tradePair)) 
 from 
(select exchangeName, tradePair, minPriceHikeStep, maxPriceHikeStep, minOfMaxTimeForStep, 
maxOfMaxTimeForStep, totalDurationOfAllStepsInHrs, priceHikePercent, priceHikePercentRate, minAvgPriceUSD, maxAvgPriceUSD, 
minAvgPriceBTC, maxAvgPriceBTC, avgBuyHistoryAmount, avgSellHistoryAmount, avgOpenBuyAmount, 
avgOpenSellAmount, minShortestTimeFromMin, maxShortestTimeFromMax, 
pt1HrBaseDiff, pt1HrPeakDiff, pt2HrBaseDiff , pt2HrPeakDiff, pt4HrBaseDiff,
pt4HrPeakDiff, pt8HrBaseDiff , pt8HrPeakDiff, pt16HrBaseDiff, pt16HrPeakDiff, pt24HrBaseDiff, pt24HrPeakDiff,
pt48HrBaseDiff, pt48HrPeakDiff, 
(case @previousTradePair = CONCAT(exchangeName, tradePair) 
WHEN true then @stepDiffPreviousTwoMins := ROUND(((minPriceHikeStep/10+1) - (@previousMinStep/10+1))/(@previousMinStep/10+1)*100, 2)
WHEN false then @stepDiffPreviousTwoMins := 0 END) as percDiffLastTwoMins,
(case @previousTradePair = CONCAT(exchangeName, tradePair) 
WHEN true then @stepDiffPreviousTwoMaxs := ROUND(((maxPriceHikeStep/10+1) - (@previousMaxStep/10+1))/(@previousMaxStep/10+1)*100, 2)
WHEN false then @stepDiffPreviousTwoMaxs := 0 END) as percDiffLastTwoMaxs,
(case @previousTradePair = CONCAT(exchangeName, tradePair) 
WHEN true then @tradePairSpikeOrderTracker := (@tradePairSpikeOrderTracker + 1)
WHEN false then @tradePairSpikeOrderTracker := 1 END) as tradePairSpikeOrder,
(case @previousTradePair = CONCAT(exchangeName, tradePair) 
WHEN true then @timeSincePreviousSpike := ROUND(time_to_sec(timediff(minOfMaxTimeForStep, @lastMaxTime)) / 3600, 2)
WHEN false then @timeSincePreviousSpike := 0 END) as timeSinceLastSpike, 
(@previousMinStep := minPriceHikeStep) as lastMinStep,
(@previousMaxStep := maxPriceHikeStep) as lastMaxStep,
(@lastMaxTime := maxOfMaxTimeForStep) as lastMaxTime,
(@previousTradePair := CONCAT(exchangeName, tradePair)) as lastTradePair
from 
(select * from all25PercSpikesWLingeringInfo where pt1HrBaseDiff >= 35 ) tempTable2
JOIN (select @stepDiffPreviousTwoMins := 0,@previousMinStep := 0, @stepDiffPreviousTwoMaxs := 0,@previousMaxStep := 0, 
@timeSincePreviousSpike := 0, @lastMaxTime := '2017-10-01 00:00:00', @previousTradePair := "none", 
@tradePairSpikeOrderTracker := 1) t) tempTable3) 
AND tradePairSpikeOrder > 1)
OR CONCAT(exchangeName, tradePair) IN (select DISTINCT(CONCAT(exchangeName, tradePair)) from gradualSpikesWMinimumHeight)
)
)
 AND pt4HrPeakDiff >= -15 
 AND maxOfMaxTimeForStep < '2017-11-03 21:15:00'
 ;
 

select recordTime, askPriceUSD from CCIntTicker where CONCAT(exchangeName, tradePair) = 'bittrexBTC-BRX';

select * from all25PercSpikesWLingeringInfo where CONCAT(exchangeName, tradePair) = 'bittrexBTC-BRX';

select DISTINCT(CONCAT(exchangeName, tradePair)) from all25PercSpikesWLingeringInfo where pt1HrBaseDiff >= 0 and  pt1HrBaseDiff < 25;

-- del
CREATE TABLE  potentiallySuccesfulSteepSpikesWNextSpikeTime (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	minPriceHikeStep FLOAT NULL,
    maxPriceHikeStep FLOAT NULL,
    minOfMaxTimeForStep DATETIME NULL,
    maxOfMaxTimeForStep DATETIME NULL,
	totalDurationOfAllStepsInHrs FLOAT NULL,
	priceHikePercent FLOAT NULL, -- amount of price change in the spike
    priceHikePercentRate FLOAT NULL, -- net rate of change of price in the spike
    minAvgPriceUSD FLOAT NULL,
	maxAvgPriceUSD FLOAT NULL,
    minAvgPriceBTC FLOAT NULL,
	maxAvgPriceBTC FLOAT NULL,
    avgBuyHistoryAmount FLOAT NULL,
	avgSellHistoryAmount FLOAT NULL,
    avgOpenBuyAmount FLOAT NULL,
    avgOpenSellAmount FLOAT NULL,
	minShortestTimeFromMin FLOAT NULL,
    maxShortestTimeFromMax FLOAT NULL,
    percDiffLastTwoMins FLOAT NULL,
	percDiffLastTwoMaxs FLOAT NULL,
	timeSinceLastSpike FLOAT NULL,
    nextSpikeTimeGap FLOAT NULL
    );
 
 INSERT INTO potentiallySuccesfulSteepSpikesWNextSpikeTime
 select exchangeName, tradePair, minPriceHikeStep, maxPriceHikeStep, minOfMaxTimeForStep,
 maxOfMaxTimeForStep, totalDurationOfAllStepsInHrs, priceHikePercent, priceHikePercentRate, minAvgPriceUSD, maxAvgPriceUSD, 
 minAvgPriceBTC, maxAvgPriceBTC, avgBuyHistoryAmount, avgSellHistoryAmount , avgOpenBuyAmount,
 avgOpenSellAmount, minShortestTimeFromMin, maxShortestTimeFromMax, percDiffLastTwoMins,
percDiffLastTwoMaxs, timeSinceLastSpike, nextSpikeTimeGap
 from 
 (select exchangeName, tradePair, minPriceHikeStep, maxPriceHikeStep, minOfMaxTimeForStep,
 maxOfMaxTimeForStep, totalDurationOfAllStepsInHrs, priceHikePercent, priceHikePercentRate, minAvgPriceUSD, maxAvgPriceUSD, 
 minAvgPriceBTC, maxAvgPriceBTC, avgBuyHistoryAmount, avgSellHistoryAmount , avgOpenBuyAmount,
 avgOpenSellAmount, minShortestTimeFromMin, maxShortestTimeFromMax, percDiffLastTwoMins,
percDiffLastTwoMaxs, timeSinceLastSpike,
(case @previousTradePair = CONCAT(exchangeName, tradePair) 
WHEN true then @spikeTimeGapTracker
WHEN false then 0 END) as nextSpikeTimeGap, 
(@spikeTimeGapTracker := timeSinceLastSpike) as nextSpikeTimeGapTracker,
(@previousTradePair := CONCAT(exchangeName, tradePair)) as lastTradePairTracker
 from 
 (select * from potentiallySuccesfulSteepSpikes 
 ORDER BY CONCAT(exchangeName, tradePair), maxOfMaxTimeForStep DESC) tempTable1
 JOIN (select @spikeTimeGapTracker := 0, @previousTradePair := "none") t) temp2
ORDER BY CONCAT(exchangeName, tradePair), maxOfMaxTimeForStep;
 
ALTER TABLE potentiallySuccesfulSteepSpikesWNextSpikeTime ADD INDEX exchangePair (exchangeName, tradePair, maxOfMaxTimeForStep);                                                                
 
select * from potentiallySuccesfulSteepSpikesWNextSpikeTime;

CREATE TABLE  postSuccessPeakPercentChangeFromSpikeBaseNPeak (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
    spikePeakTime DATETIME NULL,
    pt1HrBaseDiff FLOAT NULL,
    pt1HrPeakDiff FLOAT NULL,
	pt2HrBaseDiff FLOAT NULL,
    pt2HrPeakDiff FLOAT NULL, 
    pt4HrBaseDiff FLOAT NULL,
    pt4HrPeakDiff FLOAT NULL, 
	pt8HrBaseDiff FLOAT NULL,
    pt8HrPeakDiff FLOAT NULL, 
	pt16HrBaseDiff FLOAT NULL,
    pt16HrPeakDiff FLOAT NULL, 
	pt24HrBaseDiff FLOAT NULL,
    pt24HrPeakDiff FLOAT NULL, 
	pt48HrBaseDiff FLOAT NULL,
    pt48HrPeakDiff FLOAT NULL
    );
    
INSERT INTO postSuccessPeakPercentChangeFromSpikeBaseNPeak
select successSpikes.exchangeName, successSpikes.tradePair, successSpikes.maxOfMaxTimeForStep, 
(case (successSpikes.nextSpikeTimeGap >= 1 OR successSpikes.nextSpikeTimeGap = 0) when true then (tempTicker.askPriceUSD - successSpikes.minAvgPriceUSD)*100/successSpikes.minAvgPriceUSD else -1 END),
(case (successSpikes.nextSpikeTimeGap >= 1 OR successSpikes.nextSpikeTimeGap = 0) when true then (tempTicker.askPriceUSD - successSpikes.maxAvgPriceUSD)*100/successSpikes.maxAvgPriceUSD else -1 END),
(case (successSpikes.nextSpikeTimeGap >= 2 OR successSpikes.nextSpikeTimeGap = 0) when true then (tempTicker2.askPriceUSD - successSpikes.minAvgPriceUSD)*100/successSpikes.minAvgPriceUSD else -1 END),
(case (successSpikes.nextSpikeTimeGap >= 2 OR successSpikes.nextSpikeTimeGap = 0) when true then (tempTicker2.askPriceUSD - successSpikes.maxAvgPriceUSD)*100/successSpikes.maxAvgPriceUSD else -1 END),
(case (successSpikes.nextSpikeTimeGap >= 4 OR successSpikes.nextSpikeTimeGap = 0) when true then (tempTicker3.askPriceUSD - successSpikes.minAvgPriceUSD)*100/successSpikes.minAvgPriceUSD else -1 END),
(case (successSpikes.nextSpikeTimeGap >= 4 OR successSpikes.nextSpikeTimeGap = 0) when true then (tempTicker3.askPriceUSD - successSpikes.maxAvgPriceUSD)*100/successSpikes.maxAvgPriceUSD else -1 END),
(case (successSpikes.nextSpikeTimeGap >= 8 OR successSpikes.nextSpikeTimeGap = 0) when true then (tempTicker4.askPriceUSD - successSpikes.minAvgPriceUSD)*100/successSpikes.minAvgPriceUSD else -1 END),
(case (successSpikes.nextSpikeTimeGap >= 8 OR successSpikes.nextSpikeTimeGap = 0) when true then (tempTicker4.askPriceUSD - successSpikes.maxAvgPriceUSD)*100/successSpikes.maxAvgPriceUSD else -1 END),
(case (successSpikes.nextSpikeTimeGap >= 16 OR successSpikes.nextSpikeTimeGap = 0) when true then (tempTicker5.askPriceUSD - successSpikes.minAvgPriceUSD)*100/successSpikes.minAvgPriceUSD else -1 END),
(case (successSpikes.nextSpikeTimeGap >= 16 OR successSpikes.nextSpikeTimeGap = 0) when true then (tempTicker5.askPriceUSD - successSpikes.maxAvgPriceUSD)*100/successSpikes.maxAvgPriceUSD else -1 END),
(case (successSpikes.nextSpikeTimeGap >= 24 OR successSpikes.nextSpikeTimeGap = 0) when true then (tempTicker6.askPriceUSD - successSpikes.minAvgPriceUSD)*100/successSpikes.minAvgPriceUSD else -1 END),
(case (successSpikes.nextSpikeTimeGap >= 24 OR successSpikes.nextSpikeTimeGap = 0) when true then (tempTicker6.askPriceUSD - successSpikes.maxAvgPriceUSD)*100/successSpikes.maxAvgPriceUSD else -1 END),
(case (successSpikes.nextSpikeTimeGap >= 48 OR successSpikes.nextSpikeTimeGap = 0) when true then (tempTicker7.askPriceUSD - successSpikes.minAvgPriceUSD)*100/successSpikes.minAvgPriceUSD else -1 END),
(case (successSpikes.nextSpikeTimeGap >= 48 OR successSpikes.nextSpikeTimeGap = 0) when true then (tempTicker7.askPriceUSD - successSpikes.maxAvgPriceUSD)*100/successSpikes.maxAvgPriceUSD else -1 END)
from potentiallySuccesfulSteepSpikesWNextSpikeTime AS successSpikes
LEFT JOIN CCIntTicker tempTicker ON (tempTicker.exchangeName = successSpikes.exchangeName AND
																tempTicker.tradePair = successSpikes.tradePair AND
                                                                FROM_UNIXTIME((UNIX_TIMESTAMP(tempTicker.recordTime)) - 3600) = successSpikes.maxOfMaxTimeForStep)
LEFT JOIN CCIntTicker tempTicker2 ON (tempTicker2.exchangeName = successSpikes.exchangeName AND
																	tempTicker2.tradePair = successSpikes.tradePair AND
																	FROM_UNIXTIME((UNIX_TIMESTAMP(tempTicker2.recordTime)) - 7200) = successSpikes.maxOfMaxTimeForStep)
LEFT JOIN CCIntTicker tempTicker3 ON (tempTicker3.exchangeName = successSpikes.exchangeName AND
																	tempTicker3.tradePair = successSpikes.tradePair AND
																	FROM_UNIXTIME((UNIX_TIMESTAMP(tempTicker3.recordTime)) - 14400) = successSpikes.maxOfMaxTimeForStep)
LEFT JOIN CCIntTicker tempTicker4 ON (tempTicker4.exchangeName = successSpikes.exchangeName AND
																	tempTicker4.tradePair = successSpikes.tradePair AND
																	FROM_UNIXTIME((UNIX_TIMESTAMP(tempTicker4.recordTime)) - 28800) = successSpikes.maxOfMaxTimeForStep)
LEFT JOIN CCIntTicker tempTicker5 ON (tempTicker5.exchangeName = successSpikes.exchangeName AND
																	tempTicker5.tradePair = successSpikes.tradePair AND
																	FROM_UNIXTIME((UNIX_TIMESTAMP(tempTicker5.recordTime)) - 57600) = successSpikes.maxOfMaxTimeForStep)
LEFT JOIN CCIntTicker tempTicker6 ON (tempTicker6.exchangeName = successSpikes.exchangeName AND
																	tempTicker6.tradePair = successSpikes.tradePair AND
																	FROM_UNIXTIME((UNIX_TIMESTAMP(tempTicker6.recordTime)) - 86400) = successSpikes.maxOfMaxTimeForStep)
LEFT JOIN CCIntTicker tempTicker7 ON (tempTicker7.exchangeName = successSpikes.exchangeName AND
																	tempTicker7.tradePair = successSpikes.tradePair AND
																	FROM_UNIXTIME((UNIX_TIMESTAMP(tempTicker7.recordTime)) - 172800) = successSpikes.maxOfMaxTimeForStep);
                                                                
                                                                
ALTER TABLE postSuccessPeakPercentChangeFromSpikeBaseNPeak ADD INDEX exchangePair (exchangeName, tradePair, spikePeakTime);                                                                

select * from postSuccessPeakPercentChangeFromSpikeBaseNPeak;

-- failed spikes

CREATE TABLE  failedSteepSpikesWNextSpikeTime (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	minPriceHikeStep FLOAT NULL,
    maxPriceHikeStep FLOAT NULL,
    minOfMaxTimeForStep DATETIME NULL,
    maxOfMaxTimeForStep DATETIME NULL,
	totalDurationOfAllStepsInHrs FLOAT NULL,
	priceHikePercent FLOAT NULL, -- amount of price change in the spike
    priceHikePercentRate FLOAT NULL, -- net rate of change of price in the spike
    minAvgPriceUSD FLOAT NULL,
	maxAvgPriceUSD FLOAT NULL,
    minAvgPriceBTC FLOAT NULL,
	maxAvgPriceBTC FLOAT NULL,
    avgBuyHistoryAmount FLOAT NULL,
	avgSellHistoryAmount FLOAT NULL,
    avgOpenBuyAmount FLOAT NULL,
    avgOpenSellAmount FLOAT NULL,
	minShortestTimeFromMin FLOAT NULL,
    maxShortestTimeFromMax FLOAT NULL,
    percDiffLastTwoMins FLOAT NULL,
	percDiffLastTwoMaxs FLOAT NULL,
	timeSinceLastSpike FLOAT NULL,
    nextSpikeTimeGap FLOAT NULL
    );
 
 INSERT INTO failedSteepSpikesWNextSpikeTime
 select exchangeName, tradePair, minPriceHikeStep, maxPriceHikeStep, minOfMaxTimeForStep,
 maxOfMaxTimeForStep, totalDurationOfAllStepsInHrs, priceHikePercent, priceHikePercentRate, minAvgPriceUSD, maxAvgPriceUSD, 
 minAvgPriceBTC, maxAvgPriceBTC, avgBuyHistoryAmount, avgSellHistoryAmount , avgOpenBuyAmount,
 avgOpenSellAmount, minShortestTimeFromMin, maxShortestTimeFromMax, percDiffLastTwoMins,
percDiffLastTwoMaxs, timeSinceLastSpike, nextSpikeTimeGap
 from 
 (select exchangeName, tradePair, minPriceHikeStep, maxPriceHikeStep, minOfMaxTimeForStep,
 maxOfMaxTimeForStep, totalDurationOfAllStepsInHrs, priceHikePercent, priceHikePercentRate, minAvgPriceUSD, maxAvgPriceUSD, 
 minAvgPriceBTC, maxAvgPriceBTC, avgBuyHistoryAmount, avgSellHistoryAmount , avgOpenBuyAmount,
 avgOpenSellAmount, minShortestTimeFromMin, maxShortestTimeFromMax, percDiffLastTwoMins,
percDiffLastTwoMaxs, timeSinceLastSpike,
(case @previousTradePair = CONCAT(exchangeName, tradePair) 
WHEN true then @spikeTimeGapTracker
WHEN false then 0 END) as nextSpikeTimeGap, 
(@spikeTimeGapTracker := timeSinceLastSpike) as nextSpikeTimeGapTracker,
(@previousTradePair := CONCAT(exchangeName, tradePair)) as lastTradePairTracker
 from 
 (select * from failedSteepSpikes 
 ORDER BY CONCAT(exchangeName, tradePair), maxOfMaxTimeForStep DESC) tempTable1
 JOIN (select @spikeTimeGapTracker := 0, @previousTradePair := "none") t) temp2
ORDER BY CONCAT(exchangeName, tradePair), maxOfMaxTimeForStep;
 
ALTER TABLE failedSteepSpikesWNextSpikeTime ADD INDEX exchangePair (exchangeName, tradePair, maxOfMaxTimeForStep);                                                                
 
select * from failedSteepSpikesWNextSpikeTime;

CREATE TABLE  postFailedPeakPercentChangeFromSpikeBaseNPeak (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
    spikePeakTime DATETIME NULL,
    pt1HrBaseDiff FLOAT NULL,
    pt1HrPeakDiff FLOAT NULL,
	pt2HrBaseDiff FLOAT NULL,
    pt2HrPeakDiff FLOAT NULL, 
    pt4HrBaseDiff FLOAT NULL,
    pt4HrPeakDiff FLOAT NULL, 
	pt8HrBaseDiff FLOAT NULL,
    pt8HrPeakDiff FLOAT NULL, 
	pt16HrBaseDiff FLOAT NULL,
    pt16HrPeakDiff FLOAT NULL, 
	pt24HrBaseDiff FLOAT NULL,
    pt24HrPeakDiff FLOAT NULL, 
	pt48HrBaseDiff FLOAT NULL,
    pt48HrPeakDiff FLOAT NULL
    );
    
INSERT INTO postFailedPeakPercentChangeFromSpikeBaseNPeak
select failedSpikes.exchangeName, failedSpikes.tradePair, failedSpikes.maxOfMaxTimeForStep, 
(case (failedSpikes.nextSpikeTimeGap >= 1 OR failedSpikes.nextSpikeTimeGap = 0) when true then (tempTicker.askPriceUSD - failedSpikes.minAvgPriceUSD)*100/failedSpikes.minAvgPriceUSD else -1 END),
(case (failedSpikes.nextSpikeTimeGap >= 1 OR failedSpikes.nextSpikeTimeGap = 0) when true then (tempTicker.askPriceUSD - failedSpikes.maxAvgPriceUSD)*100/failedSpikes.maxAvgPriceUSD else -1 END),
(case (failedSpikes.nextSpikeTimeGap >= 2 OR failedSpikes.nextSpikeTimeGap = 0) when true then (tempTicker2.askPriceUSD - failedSpikes.minAvgPriceUSD)*100/failedSpikes.minAvgPriceUSD else -1 END),
(case (failedSpikes.nextSpikeTimeGap >= 2 OR failedSpikes.nextSpikeTimeGap = 0) when true then (tempTicker2.askPriceUSD - failedSpikes.maxAvgPriceUSD)*100/failedSpikes.maxAvgPriceUSD else -1 END),
(case (failedSpikes.nextSpikeTimeGap >= 4 OR failedSpikes.nextSpikeTimeGap = 0) when true then (tempTicker3.askPriceUSD - failedSpikes.minAvgPriceUSD)*100/failedSpikes.minAvgPriceUSD else -1 END),
(case (failedSpikes.nextSpikeTimeGap >= 4 OR failedSpikes.nextSpikeTimeGap = 0) when true then (tempTicker3.askPriceUSD - failedSpikes.maxAvgPriceUSD)*100/failedSpikes.maxAvgPriceUSD else -1 END),
(case (failedSpikes.nextSpikeTimeGap >= 8 OR failedSpikes.nextSpikeTimeGap = 0) when true then (tempTicker4.askPriceUSD - failedSpikes.minAvgPriceUSD)*100/failedSpikes.minAvgPriceUSD else -1 END),
(case (failedSpikes.nextSpikeTimeGap >= 8 OR failedSpikes.nextSpikeTimeGap = 0) when true then (tempTicker4.askPriceUSD - failedSpikes.maxAvgPriceUSD)*100/failedSpikes.maxAvgPriceUSD else -1 END),
(case (failedSpikes.nextSpikeTimeGap >= 16 OR failedSpikes.nextSpikeTimeGap = 0) when true then (tempTicker5.askPriceUSD - failedSpikes.minAvgPriceUSD)*100/failedSpikes.minAvgPriceUSD else -1 END),
(case (failedSpikes.nextSpikeTimeGap >= 16 OR failedSpikes.nextSpikeTimeGap = 0) when true then (tempTicker5.askPriceUSD - failedSpikes.maxAvgPriceUSD)*100/failedSpikes.maxAvgPriceUSD else -1 END),
(case (failedSpikes.nextSpikeTimeGap >= 24 OR failedSpikes.nextSpikeTimeGap = 0) when true then (tempTicker6.askPriceUSD - failedSpikes.minAvgPriceUSD)*100/failedSpikes.minAvgPriceUSD else -1 END),
(case (failedSpikes.nextSpikeTimeGap >= 24 OR failedSpikes.nextSpikeTimeGap = 0) when true then (tempTicker6.askPriceUSD - failedSpikes.maxAvgPriceUSD)*100/failedSpikes.maxAvgPriceUSD else -1 END),
(case (failedSpikes.nextSpikeTimeGap >= 48 OR failedSpikes.nextSpikeTimeGap = 0) when true then (tempTicker7.askPriceUSD - failedSpikes.minAvgPriceUSD)*100/failedSpikes.minAvgPriceUSD else -1 END),
(case (failedSpikes.nextSpikeTimeGap >= 48 OR failedSpikes.nextSpikeTimeGap = 0) when true then (tempTicker7.askPriceUSD - failedSpikes.maxAvgPriceUSD)*100/failedSpikes.maxAvgPriceUSD else -1 END)
from failedSteepSpikesWNextSpikeTime AS failedSpikes
LEFT JOIN CCIntTicker tempTicker ON (tempTicker.exchangeName = failedSpikes.exchangeName AND
																tempTicker.tradePair = failedSpikes.tradePair AND
                                                                FROM_UNIXTIME((UNIX_TIMESTAMP(tempTicker.recordTime)) - 3600) = failedSpikes.maxOfMaxTimeForStep)
LEFT JOIN CCIntTicker tempTicker2 ON (tempTicker2.exchangeName = failedSpikes.exchangeName AND
																	tempTicker2.tradePair = failedSpikes.tradePair AND
																	FROM_UNIXTIME((UNIX_TIMESTAMP(tempTicker2.recordTime)) - 7200) = failedSpikes.maxOfMaxTimeForStep)
LEFT JOIN CCIntTicker tempTicker3 ON (tempTicker3.exchangeName = failedSpikes.exchangeName AND
																	tempTicker3.tradePair = failedSpikes.tradePair AND
																	FROM_UNIXTIME((UNIX_TIMESTAMP(tempTicker3.recordTime)) - 14400) = failedSpikes.maxOfMaxTimeForStep)
LEFT JOIN CCIntTicker tempTicker4 ON (tempTicker4.exchangeName = failedSpikes.exchangeName AND
																	tempTicker4.tradePair = failedSpikes.tradePair AND
																	FROM_UNIXTIME((UNIX_TIMESTAMP(tempTicker4.recordTime)) - 28800) = failedSpikes.maxOfMaxTimeForStep)
LEFT JOIN CCIntTicker tempTicker5 ON (tempTicker5.exchangeName = failedSpikes.exchangeName AND
																	tempTicker5.tradePair = failedSpikes.tradePair AND
																	FROM_UNIXTIME((UNIX_TIMESTAMP(tempTicker5.recordTime)) - 57600) = failedSpikes.maxOfMaxTimeForStep)
LEFT JOIN CCIntTicker tempTicker6 ON (tempTicker6.exchangeName = failedSpikes.exchangeName AND
																	tempTicker6.tradePair = failedSpikes.tradePair AND
																	FROM_UNIXTIME((UNIX_TIMESTAMP(tempTicker6.recordTime)) - 86400) = failedSpikes.maxOfMaxTimeForStep)
LEFT JOIN CCIntTicker tempTicker7 ON (tempTicker7.exchangeName = failedSpikes.exchangeName AND
																	tempTicker7.tradePair = failedSpikes.tradePair AND
																	FROM_UNIXTIME((UNIX_TIMESTAMP(tempTicker7.recordTime)) - 172800) = failedSpikes.maxOfMaxTimeForStep);
                                                                
                                                                
ALTER TABLE postFailedPeakPercentChangeFromSpikeBaseNPeak ADD INDEX exchangePair (exchangeName, tradePair, spikePeakTime);                                                                

select * from postFailedPeakPercentChangeFromSpikeBaseNPeak;


