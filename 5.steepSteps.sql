/*

*/
use pocu3;

drop table steepHikeStepDurationsWAdjTracker;

CREATE TABLE steepHikeStepDurationsWAdjTracker (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	priceHikeStep FLOAT NULL,
	priceStepDurationInHrs FLOAT NULL,
	avgPriceUSD FLOAT NULL,
	avgPriceBTC FLOAT NULL,
    buyHistoryAmount FLOAT NULL,
    openBuyAmount FLOAT NULL,
    minTimeForStep DATETIME NULL,
    maxTimeForStep DATETIME NULL,
	shortestTimeFromMin FLOAT NULL,
    shortestTimeFromMax FLOAT NULL,
    adjacentRowTracker FLOAT NULL,
    lastTradePair  VARCHAR(50) NULL,
    stepCounterFromPreviousRow FLOAT NULL
);

INSERT into steepHikeStepDurationsWAdjTracker
select 	exchangeName, tradePair, priceHikeStep, priceStepDurationInHrs, avgPriceUSD, 
avgPriceBTC, buyHistoryAmount , openBuyAmount , minTimeForStep, maxTimeForStep, shortestTimeFromMin, shortestTimeFromMax, 
(case @stepCounterFromPreviousRecord < priceHikeStep AND @previousTradePair = CONCAT(exchangeName, tradePair) 
AND priceStepDurationInHrs < 3
WHEN true then @adjacentRecordTracker := @adjacentRecordTracker 
WHEN false then @adjacentRecordTracker := @adjacentRecordTracker +1 END) as adjacentRowTracker, 
 (@stepCounterFromPreviousRecord := priceHikeStep) as stepCounterFromPreviousRow,
 (@previousTradePair := CONCAT(exchangeName, tradePair)) as lastTradePair
from hikeStepDurations
JOIN (select @stepCounterFromPreviousRecord := 0, @adjacentRecordTracker := 0, @previousTradePair := "none") t;

ALTER TABLE steepHikeStepDurationsWAdjTracker ADD INDEX exchangePair (exchangeName, tradePair);

select exchangeName, tradePair, priceHikeStep, adjacentRowTracker from steepHikeStepDurationsWAdjTracker;
select * from steepHikeStepDurationsWAdjTracker where tradePair = 'BTC-BCY';

CREATE TABLE steepHikeStepDurationsMinMax (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	minPriceHikeStep FLOAT NULL,
    maxPriceHikeStep FLOAT NULL,
    minOfMaxTimeForStep DATETIME NULL,
    maxOfMaxTimeForStep DATETIME NULL,
	totalDurationOfAllStepsInHrs FLOAT NULL,
    minAvgPriceUSD FLOAT NULL,
	maxAvgPriceUSD FLOAT NULL,
    minAvgPriceBTC FLOAT NULL,
	maxAvgPriceBTC FLOAT NULL,
    avgBuyHistoryAmount FLOAT NULL,
    avgOpenBuyAmount FLOAT NULL,
	minShortestTimeFromMin FLOAT NULL,
    maxShortestTimeFromMax FLOAT NULL
    );
    
INSERT into steepHikeStepDurationsMinMax
select exchangeName, tradePair, min(priceHikeStep), max(priceHikeStep), min(maxTimeForStep), max(maxTimeForStep), 
time_to_sec(timediff(max(minTimeForStep), min(maxTimeForStep))) / 3600,
/* use the above for getting the duration of the whole spike instead of sum(totalDurationOfAllStepsInHrs) as the latter will include the time 
of the first step which is not desirable as the firrst step may have lasted a very long time
*/
min(avgPriceUSD), max(avgPriceUSD), min(avgPriceBTC), max(avgPriceBTC),
avg(buyHistoryAmount) , avg(openBuyAmount),  min(shortestTimeFromMin), max(shortestTimeFromMax)
from steepHikeStepDurationsWAdjTracker group by adjacentRowTracker;

ALTER TABLE steepHikeStepDurationsMinMax ADD INDEX exchangePair (exchangeName, tradePair);

select * from steepHikeStepDurationsMinMax where maxPriceHikeStep - minPriceHikeStep > 4 and minPriceHikeStep < 15;
select * from steepHikeStepDurationsMinMax where maxPriceHikeStep - minPriceHikeStep > 2;

CREATE TABLE steepHikeStepDurationsMinMaxWLastSpikeInfo (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	minPriceHikeStep FLOAT NULL,
    maxPriceHikeStep FLOAT NULL,
    minOfMaxTimeForStep DATETIME NULL,
    maxOfMaxTimeForStep DATETIME NULL,
	totalDurationOfAllStepsInHrs FLOAT NULL,
    minAvgPriceUSD FLOAT NULL,
	maxAvgPriceUSD FLOAT NULL,
    minAvgPriceBTC FLOAT NULL,
	maxAvgPriceBTC FLOAT NULL,
    avgBuyHistoryAmount FLOAT NULL,
    avgOpenBuyAmount FLOAT NULL,
	minShortestTimeFromMin FLOAT NULL,
    maxShortestTimeFromMax FLOAT NULL,
    stepDiffLastTwoMins FLOAT NULL,
    timeSinceLastSpike FLOAT NULL,
	lastMaxStep FLOAT NULL,
    lastMaxTime DATETIME NULL,
	lastTradePair  VARCHAR(50) NULL
    );
 
INSERT into  steepHikeStepDurationsMinMaxWLastSpikeInfo
select exchangeName, tradePair, minPriceHikeStep, maxPriceHikeStep, minOfMaxTimeForStep, 
maxOfMaxTimeForStep, totalDurationOfAllStepsInHrs, minAvgPriceUSD, maxAvgPriceUSD, minAvgPriceBTC,
maxAvgPriceBTC, avgBuyHistoryAmount, avgOpenBuyAmount, minShortestTimeFromMin, maxShortestTimeFromMax,
(case @previousTradePair = CONCAT(exchangeName, tradePair) 
WHEN true then @stepDiffPreviousTwoMins := minPriceHikeStep - @previousMinStep
WHEN false then @stepDiffPreviousTwoMins := 0 END) as stepDiffLastTwoMins, 
(case @previousTradePair = CONCAT(exchangeName, tradePair) 
WHEN true then @timeSincePreviousSpike := ROUND(time_to_sec(timediff(minOfMaxTimeForStep, @lastMaxTime)) / 3600, 2)
WHEN false then @timeSincePreviousSpike := 0 END) as timeSinceLastSpike, 
(@previousMinStep := minPriceHikeStep) as lastMaxStep,
(@lastMaxTime := maxOfMaxTimeForStep) as lastMaxTime,
(@previousTradePair := CONCAT(exchangeName, tradePair)) as lastTradePair
from steepHikeStepDurationsMinMax 
JOIN (select @stepDiffPreviousTwoMins := 0, @timeSincePreviousSpike := 0, 
@previousMinStep := 0, @lastMaxTime := '2017-10-01 00:00:00', @previousTradePair := "none") t;

ALTER TABLE steepHikeStepDurationsMinMaxWLastSpikeInfo ADD INDEX exchangePair (exchangeName, tradePair);

select * from steepHikeStepDurationsMinMaxWLastSpikeInfo where maxPriceHikeStep - minPriceHikeStep > 2
 AND stepDiffLastTwoMins > 2; 
-- AND timeSinceLastSpike < 24;

-- del

drop table steepHikeStepDurations;
CREATE TABLE steepHikeStepDurations (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	priceHikeStep FLOAT NULL,
	priceStepDurationInHrs FLOAT NULL,
	avgPriceUSD FLOAT NULL,
	avgPriceBTC FLOAT NULL,
    buyHistoryAmount FLOAT NULL,
    openBuyAmount FLOAT NULL,
    maxTimeForStep DATETIME NULL,
	shortestTimeFromMin FLOAT NULL,
    shortestTimeFromMax FLOAT NULL
);


INSERT into steepHikeStepDurations
select exchangeName, tradePair , priceHikeStep, priceStepDurationInHrs, avgPriceUSD, 
avgPriceBTC, buyHistoryAmount , openBuyAmount , maxTimeForStep, shortestTimeFromMin, shortestTimeFromMax
from hikeStepDurations where priceStepDurationInHrs <= 3;
