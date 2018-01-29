/*
This is the 5th script. 
The first table (steepHikeStepDurationsWAdjTracker) uses hikeStepDurations to do 2 things:
	a) gets all rows that have a step duration of less than 3 hours
    b) categorizes rows that have a step value higher than the previous row under a single group - tracked by the
		adjacentRowTracker column
The 2nd table (steepHikeStepDurationsMinMax) uses the categorization from the first table and records the 
min and max of the stepHikes, price and time for each category/group (adjacentRowTracker) 
The 3rd table steepHikeStepsMinMaxWMinimumHeight collects only those spikes that have spiked up by atleast 25%, 
i.e. the min and max of that step differ in price by atleast 25%. 
The 4th table steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo gets more info on the spikes from the 3rd table
by getting the difference between the mins, maxs and time gap between the current spike and the previous spike. 
The 5th potentiallySuccesfulSteepSpikes table gets all spikes that a have peak of 25% more than the previous spike. It also includes these previous spikes
that lead to these subsequent 25% higher spikes.  
The 6th table failedSteepSpikes is created by choosing those trade pairs that are not included in the previous 
table potentiallySuccesfulSteepSpikes.

 */
 
use pocu4;


CREATE TABLE steepHikeStepDurationsWAdjTracker (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	priceHikeStep FLOAT NULL,
	priceStepDurationInHrs FLOAT NULL,
	avgPriceUSD FLOAT NULL,
	avgPriceBTC FLOAT NULL,
    buyHistoryAmount FLOAT NULL,
    sellHistoryAmount FLOAT NULL,
    openBuyAmount FLOAT NULL,
    openSellAmount FLOAT NULL,
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
avgPriceBTC, buyHistoryAmount , sellHistoryAmount, openBuyAmount , openSellAmount, minTimeForStep, maxTimeForStep, 
shortestTimeFromMin, shortestTimeFromMax, 
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
select * from steepHikeStepDurationsWAdjTracker where tradePair = 'BTC-MONA';
select count(*) from steepHikeStepDurationsMinMax;


CREATE TABLE steepHikeStepDurationsMinMax (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	minPriceHikeStep FLOAT NULL,
    maxPriceHikeStep FLOAT NULL,
    minOfMaxTimeForStep DATETIME NULL, -- denotes the beginning of the spike
    maxOfMaxTimeForStep DATETIME NULL, -- denotes the end of the spike
	totalDurationOfAllStepsInHrs FLOAT NULL, -- duration of spike
    minAvgPriceUSD FLOAT NULL,
	maxAvgPriceUSD FLOAT NULL,
    minAvgPriceBTC FLOAT NULL,
	maxAvgPriceBTC FLOAT NULL,
    avgBuyHistoryAmount FLOAT NULL,
	avgSellHistoryAmount FLOAT NULL,
    avgOpenBuyAmount FLOAT NULL,
    avgOpenSellAmount FLOAT NULL,
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
avg(buyHistoryAmount) , avg(sellHistoryAmount),  avg(openBuyAmount) , avg(openSellAmount), 
min(shortestTimeFromMin), max(shortestTimeFromMax)
from steepHikeStepDurationsWAdjTracker group by adjacentRowTracker;

ALTER TABLE steepHikeStepDurationsMinMax ADD INDEX exchangePair (exchangeName, tradePair);

select * from steepHikeStepDurationsMinMax where maxPriceHikeStep - minPriceHikeStep > 4 and minPriceHikeStep < 15;
select * from steepHikeStepDurationsMinMax where maxPriceHikeStep - minPriceHikeStep > 2;


CREATE TABLE steepHikeStepsMinMaxWMinimumHeight (
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
    maxShortestTimeFromMax FLOAT NULL
    );

INSERT into steepHikeStepsMinMaxWMinimumHeight
select 	exchangeName, tradePair, minPriceHikeStep, maxPriceHikeStep, minOfMaxTimeForStep, maxOfMaxTimeForStep,
totalDurationOfAllStepsInHrs, ((maxPriceHikeStep/10+1) - (minPriceHikeStep/10+1))*100/ (minPriceHikeStep/10+1), 
((maxPriceHikeStep/10+1) - (minPriceHikeStep/10+1))*100/ ((minPriceHikeStep/10+1)*totalDurationOfAllStepsInHrs),
minAvgPriceUSD, maxAvgPriceUSD, minAvgPriceBTC, maxAvgPriceBTC, 
avgBuyHistoryAmount, avgSellHistoryAmount, avgOpenBuyAmount, avgOpenSellAmount, minShortestTimeFromMin,
maxShortestTimeFromMax from
( select * from steepHikeStepDurationsMinMax 
/* below we are converting steps into actual approximate values before comparing for a change of atleast 25%. 
Recall that steps are every 10% change from the min. 25% seemed to be a threshold number for low frequency when a 
histogram and a scatter graph of all spikes was generated and observed.
*/
 where ((maxPriceHikeStep/10+1) - (minPriceHikeStep/10+1))/ (minPriceHikeStep/10+1) >= 0.25) steepHikeStepDurationsMinMaxWLastStepDiffTemp;

ALTER TABLE steepHikeStepsMinMaxWMinimumHeight ADD INDEX exchangePair (exchangeName, tradePair);


CREATE TABLE  steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo (
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
	lastMinStep FLOAT NULL,
	lastMaxStep FLOAT NULL,
    lastMaxTime DATETIME NULL,
    lastTradePair  VARCHAR(50) NULL
    );

 
INSERT into  steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo
select exchangeName, tradePair, minPriceHikeStep, maxPriceHikeStep, minOfMaxTimeForStep, 
maxOfMaxTimeForStep, totalDurationOfAllStepsInHrs, priceHikePercent, priceHikePercentRate, minAvgPriceUSD, maxAvgPriceUSD, 
minAvgPriceBTC, maxAvgPriceBTC, avgBuyHistoryAmount, avgSellHistoryAmount, avgOpenBuyAmount, 
avgOpenSellAmount, minShortestTimeFromMin, maxShortestTimeFromMax,
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
from steepHikeStepsMinMaxWMinimumHeight
JOIN (select @stepDiffPreviousTwoMins := 0,@previousMinStep := 0, @stepDiffPreviousTwoMaxs := 0,@previousMaxStep := 0, 
@timeSincePreviousSpike := 0, @lastMaxTime := '2017-10-01 00:00:00', @previousTradePair := "none",
@tradePairSpikeOrderTracker := 1) t;

ALTER TABLE steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo ADD INDEX exchangePair (exchangeName, tradePair);

select * from steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo;

/* the following table gets all spikes that a have peak of 25% more than the previous spike. It also includes these previous spikes
that lead to these subsequent 25% higher spikes.  
 */

CREATE TABLE  potentiallySuccesfulSteepSpikes (
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
	timeSinceLastSpike FLOAT NULL
    );
 
INSERT INTO potentiallySuccesfulSteepSpikes
select exchangeName, tradePair, minPriceHikeStep, maxPriceHikeStep, minOfMaxTimeForStep, 
maxOfMaxTimeForStep, totalDurationOfAllStepsInHrs, priceHikePercent, priceHikePercentRate, minAvgPriceUSD, maxAvgPriceUSD, 
minAvgPriceBTC, maxAvgPriceBTC, avgBuyHistoryAmount, avgSellHistoryAmount, avgOpenBuyAmount, 
avgOpenSellAmount, minShortestTimeFromMin, maxShortestTimeFromMax, percDiffLastTwoMins, percDiffLastTwoMaxs, 
tradePairSpikeOrder, timeSinceLastSpike
from (select *, 
/*
the following sub table takes the desceding ordered spikes table and marks those rows as true that lead to spikes greater
than 25%
*/
(case @previousTradePair = CONCAT(exchangeName, tradePair) AND @previousPercDiffLastTwoMaxs >= 25 AND percDiffLastTwoMaxs < 25
WHEN true then @upcomingHikeGreaterThanThreshold := true
WHEN false then @upcomingHikeGreaterThanThreshold := false END) as nextHikeGreaterThanThreshold, 
(@previousPercDiffLastTwoMaxs := ROUND(percDiffLastTwoMaxs, 2)) as nextPercDiffLastTwoMaxs,
(@previousTradePair := CONCAT(exchangeName, tradePair)) as nextTradePair
from 
/* the following sub table steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfoTemp simply orders the spikes in descending order.
This is bein done so  that spikes that lead to those subsequent ones greater than 25% can be marked which is done in the above sub table
*/
(select * from steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo 
ORDER BY CONCAT(exchangeName, tradePair), maxOfMaxTimeForStep DESC) steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfoTemp
JOIN (select @upcomingHikeGreaterThanThreshold := false, @previousPercDiffLastTwoMaxs := 0, @previousTradePair := "none") t) tempTable1
where tempTable1.percDiffLastTwoMaxs >= 25 OR tempTable1.nextHikeGreaterThanThreshold = true
ORDER BY CONCAT(exchangeName, tradePair), maxOfMaxTimeForStep ;

ALTER TABLE potentiallySuccesfulSteepSpikes ADD INDEX exchangePair (exchangeName, tradePair);

select * from potentiallySuccesfulSteepSpikes;
select DISTINCT(CONCAT(exchangeName, tradePair))  from potentiallySuccesfulSteepSpikes;
select * from potentiallySuccesfulSteepSpikes where percDiffLastTwoMaxs !=0;
select * from potentiallySuccesfulSteepSpikes where percDiffLastTwoMaxs !=0 AND timeSinceLastSpike <=28;

select timeSinceLastSpike from potentiallySuccesfulSteepSpikes where percDiffLastTwoMaxs !=0;

-- the following table is created by choosing those trade pairs that are not included in the  potentiallySuccesfulSteepSpikes

CREATE TABLE  failedSteepSpikes (
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
	timeSinceLastSpike FLOAT NULL
    );

INSERT INTO failedSteepSpikes   
select exchangeName, tradePair, minPriceHikeStep, maxPriceHikeStep, minOfMaxTimeForStep, 
maxOfMaxTimeForStep, totalDurationOfAllStepsInHrs, priceHikePercent, priceHikePercentRate, minAvgPriceUSD, maxAvgPriceUSD, 
minAvgPriceBTC, maxAvgPriceBTC, avgBuyHistoryAmount, avgSellHistoryAmount, avgOpenBuyAmount, 
avgOpenSellAmount, minShortestTimeFromMin, maxShortestTimeFromMax, percDiffLastTwoMins, percDiffLastTwoMaxs, 
tradePairSpikeOrder, timeSinceLastSpike
from steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo 
where CONCAT(exchangeName, tradePair) NOT IN
(select DISTINCT(CONCAT(exchangeName, tradePair)) from potentiallySuccesfulSteepSpikes);

ALTER TABLE failedSteepSpikes ADD INDEX exchangePair (exchangeName, tradePair);

select DISTINCT(CONCAT(exchangeName, tradePair))  from failedSteepSpikes;


CREATE TABLE  potentiallySuccesfulSteepSpikesWithin24Hrs (
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
	timeSinceLastSpike FLOAT NULL
    );
    
INSERT Into potentiallySuccesfulSteepSpikesWithin24Hrs  

select * from potentiallySuccesfulSteepSpikes where CONCAT(exchangeName, tradePair) IN
(select CONCAT(exchangeName, tradePair) from potentiallySuccesfulSteepSpikes where timeSinceLastSpike <=24 AND timeSinceLastSpike !=0);

select distinct CONCAT(exchangeName, tradePair) from potentiallySuccesfulSteepSpikesWithin24Hrs;

select distinct CONCAT(exchangeName, tradePair)  from steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo where CONCAT(exchangeName, tradePair) NOT IN
(select distinct CONCAT(exchangeName, tradePair) from potentiallySuccesfulSteepSpikes where timeSinceLastSpike <=24 AND timeSinceLastSpike !=0);
-- test 

select * from hikeStepDurations 
where CONCAT(exchangeName, tradePair, (FROM_UNIXTIME((UNIX_TIMESTAMP(maxTimeForStep)) div 10800*10800))) IN
(select CONCAT(exchangeName, tradePair, (FROM_UNIXTIME((UNIX_TIMESTAMP(maxOfMaxTimeForStep)) div 10800*10800)))
FROM  failedSteepSpikes);

select exchangeName, tradePair, priceHikeStep, priceStepDurationInHrs, avgPriceUSD, buyHistoryAmount, maxTimeForStep from hikeStepDurations 
where CONCAT(exchangeName, tradePair, (FROM_UNIXTIME((UNIX_TIMESTAMP(maxTimeForStep)) div 86400*86400))) IN
(select CONCAT(exchangeName, tradePair, (FROM_UNIXTIME((UNIX_TIMESTAMP(maxOfMaxTimeForStep)) div 86400*86400)))
FROM  potentiallySuccesfulSteepSpikes);

select * from potentiallySuccesfulSteepSpikes;
select * from failedSteepSpikes;

select DISTINCT(CONCAT(exchangeName, tradePair)) from steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo where percDiffLastTwoMaxs >= 40;

select * from steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo 
where CONCAT(exchangeName, tradePair, maxOfMaxTimeForStep) NOT IN
(select DISTINCT(CONCAT(exchangeName, tradePair, maxOfMaxTimeForStep)) from potentiallySuccesfulSteepSpikes);

select * from steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo;

select count(DISTINCT(CONCAT(exchangeName, tradePair))) from steepHikeStepDurationsMinMax;    
select count(DISTINCT(CONCAT(exchangeName, tradePair))) from steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo;
select count(DISTINCT(CONCAT(exchangeName, tradePair))) from  
(select * from steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo where stepDiffLastTwoMins >= 2) t;

select * from steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo ORDER BY CONCAT(exchangeName, tradePair), maxOfMaxTimeForStep DESC; 

select * from steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo where percDiffLastTwoMaxs >= 25; 

select DISTINCT(CONCAT(exchangeName, tradePair)) from steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo;

select DISTINCT(CONCAT(exchangeName, tradePair)) from steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo where percDiffLastTwoMaxs >= 25;


select DISTINCT(CONCAT(exchangeName, tradePair)) from steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo where CONCAT(exchangeName, tradePair) NOT IN
(select DISTINCT(CONCAT(exchangeName, tradePair)) from steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo where percDiffLastTwoMaxs >= 25);

select * from steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo where CONCAT(exchangeName, tradePair) IN
(select DISTINCT(CONCAT(exchangeName, tradePair)) from steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo where percDiffLastTwoMaxs >= 25);

select * from steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo where CONCAT(exchangeName, tradePair) NOT IN
(select DISTINCT(CONCAT(exchangeName, tradePair)) from steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo where percDiffLastTwoMaxs >= 25);

select * from steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo where tradePair = 'BTC-MONA';
select * from steepHikeStepDurationsWAdjTracker where tradePair = 'BTC-MONA';
select * from steepHikeStepDurationsWAdjTracker where tradePair = 'BTC-GRS';
select * from steepHikeStepDurationsWAdjTracker where tradePair = 'BTC-ZEN';
select * from steepHikeStepDurationsWAdjTracker where tradePair = 'BTC-BCY';

select DISTINCT(CONCAT(exchangeName, tradePair)) from steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo where (CONCAT(exchangeName, tradePair)) NOT IN 
(select DISTINCT(CONCAT(exchangeName, tradePair)) from steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo where stepDiffLastTwoMins >= 2);

select * from steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo where tradePair = 'BTC-2GIVE';
select * from steepHikeStepDurationsWAdjTracker where tradePair = 'BTC-2GIVE';
-- del

use pocu4;

select DISTINCT(CONCAT(exchangeName, tradePair)) from
(select exchangeName, tradePair, minPriceHikeStep, maxPriceHikeStep, minOfMaxTimeForStep, 
maxOfMaxTimeForStep, totalDurationOfAllStepsInHrs, priceHikePercent, priceHikePercentRate, minAvgPriceUSD, maxAvgPriceUSD, 
minAvgPriceBTC, maxAvgPriceBTC, avgBuyHistoryAmount, avgSellHistoryAmount, avgOpenBuyAmount, 
avgOpenSellAmount, minShortestTimeFromMin, maxShortestTimeFromMax, percDiffLastTwoMins, percDiffLastTwoMaxs, 
timeSinceLastSpike
from (select *, 
/*
the following sub table takes the desceding ordered spikes table and marks those rows as true that lead to spikes greater
than 25%
*/
(case @previousTradePair = CONCAT(exchangeName, tradePair) AND @previousPercDiffLastTwoMaxs >= 25 AND percDiffLastTwoMaxs < 25
WHEN true then @upcomingHikeGreaterThanThreshold := true
WHEN false then @upcomingHikeGreaterThanThreshold := false END) as nextHikeGreaterThanThreshold, 
(@previousPercDiffLastTwoMaxs := ROUND(percDiffLastTwoMaxs, 2)) as nextPercDiffLastTwoMaxs,
(@previousTradePair := CONCAT(exchangeName, tradePair)) as nextTradePair
from 
/* the following sub table steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfoTemp simply orders the spikes in descending order.
This is bein done so  that spikes that lead to those subsequent ones greater than 25% can be marked which is done in the above sub table
*/
(select * from steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo 
ORDER BY CONCAT(exchangeName, tradePair), maxOfMaxTimeForStep DESC) steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfoTemp
JOIN (select @upcomingHikeGreaterThanThreshold := false, @previousPercDiffLastTwoMaxs := 0, @previousTradePair := "none") t) tempTable1
where tempTable1.percDiffLastTwoMaxs >= 25 OR tempTable1.nextHikeGreaterThanThreshold = true
ORDER BY CONCAT(exchangeName, tradePair), maxOfMaxTimeForStep) t;

select percDiffLastTwoMaxs from steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo where percDiffLastTwoMaxs > 0 and percDiffLastTwoMaxs < 100 order by percDiffLastTwoMaxs DESC;

select percDiffLastTwoMaxs from steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo where percDiffLastTwoMaxs >50;

select * from 
(select 	ROUND((((maxPriceHikeStep/10+1) - (minPriceHikeStep/10+1))*100/ (minPriceHikeStep/10+1)), 2) as test from steepHikeStepDurationsMinMax) t 
where  test > 20 and test <100;
