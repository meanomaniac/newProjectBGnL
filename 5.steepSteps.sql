/*
This is the 5th script. 
The first table (steepHikeStepDurationsWAdjTracker) uses hikeStepDurations to do 2 things:
	a) gets all rows that have a step duration of less than 3 hours
    b) categorizes rows that have a step value higher than the previous row under a single group - tracked by the
		adjacentRowTracker column
The 2nd table (steepHikeStepDurationsMinMax) uses the categorization from the first table and records the 
min and max of the stepHikes, price and time for each category/group (adjacentRowTracker) 
The next step is to get the time difference between subsequent spikes for each trade pair.
But before we do that we need to ensure that we first get a table of only those rows that represent valid spikes (otherwise
no point getting time difference between invalid spikes). This is why this process needs to be separated into 2 
different tables. The 3rd table steepHikeStepDurationsMinMaxWLastStepDiff gets the difference between the mins
of the current spike and the previous spike. Then finally the 4th table, 
steepHikeStepDurationsMinMaxWLastSpikeInfo gets the time difference between only those spikes that have their 
mins exceed the mins of the previous spikes by atleast 2 steps (20% of min) and that have a stepHike of more than
30%.

*/
use pocu3;

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
select * from steepHikeStepDurationsWAdjTracker where tradePair = 'BTC-MONA';

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

CREATE TABLE steepHikeStepsMinMaxWMinimumHeight (
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

INSERT into steepHikeStepsMinMaxWMinimumHeight
select * from 
( select * from steepHikeStepDurationsMinMax 
/* below we are converting steps into actual approximate values before comparing for a change of atleast 30%. 
Recall that steps are every 10% change from the min
*/
 where ((maxPriceHikeStep/10+1) - (minPriceHikeStep/10+1))/ (minPriceHikeStep/10+1) > 0.3) steepHikeStepDurationsMinMaxWLastStepDiffTemp;

ALTER TABLE steepHikeStepsMinMaxWMinimumHeight ADD INDEX exchangePair (exchangeName, tradePair);

CREATE TABLE  steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo (
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

 
INSERT into  steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo
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
from steepHikeStepsMinMaxWMinimumHeight
JOIN (select @stepDiffPreviousTwoMins := 0,@previousMinStep := 0, 
@timeSincePreviousSpike := 0, @lastMaxTime := '2017-10-01 00:00:00', @previousTradePair := "none") t;
    
select count(DISTINCT(CONCAT(exchangeName, tradePair))) from steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo;

ALTER TABLE steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo ADD INDEX exchangePair (exchangeName, tradePair);

select count(DISTINCT(CONCAT(exchangeName, tradePair))) from  
(select * from steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo where stepDiffLastTwoMins >= 2) t;

select * from steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo; 

select * from steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo where stepDiffLastTwoMins >= 2; 

-- del

