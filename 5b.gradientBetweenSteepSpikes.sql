use pocu4;

CREATE TABLE hikeStepDurationsWSteepHikesMarked LIKE hikeStepDurations;     

INSERT INTO hikeStepDurationsWSteepHikesMarked SELECT * FROM hikeStepDurations;  

ALTER TABLE hikeStepDurationsWSteepHikesMarked ADD minOrMaxOfSteepHike VARCHAR(5) NULL;

select * from hikeStepDurationsWSteepHikesMarked LIMIT 1000;

/* the following 2 queries each take about 3 mins to run
this table uses a column called minOrMaxOfSteepHike to mark every row that is the beginning (min) or the end (max) 
of a steep hike as such
*/
update hikeStepDurationsWSteepHikesMarked set minOrMaxOfSteepHike = 'min' 
where CONCAT (exchangeName, tradePair, maxTimeForStep) IN
(select CONCAT (exchangeName, tradePair, minOfMaxTimeForStep) 
from steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo);

update hikeStepDurationsWSteepHikesMarked set minOrMaxOfSteepHike = 'max' 
where CONCAT (exchangeName, tradePair, maxTimeForStep) IN
(select CONCAT (exchangeName, tradePair, maxOfMaxTimeForStep) 
from steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo);

update hikeStepDurationsWSteepHikesMarked set minOrMaxOfSteepHike = 'not' 
where minOrMaxOfSteepHike IS NULL;

CREATE TABLE hikeStepsWNonSteepTimeBlocks LIKE hikeStepDurationsWSteepHikesMarked;

ALTER TABLE hikeStepsWNonSteepTimeBlocks ADD nonSteepHikeTimeBlockTrackingNumber MEDIUMINT NULL;

/* the following table creates uses a column called nonSteepHikeTimeBlockTrackingNumbermarks to mark 
blocks/windows of time with steep Hikes with odd numbers and the other (non steep time blocks) as even numbers
*/
INSERT INTO hikeStepsWNonSteepTimeBlocks SELECT 
exchangeName, tradePair , stepCounter, priceHikeStep , priceStepDurationInHrs, avgPriceUSD, 
avgPriceBTC, buyHistoryAmount, sellHistoryAmount, openBuyAmount, openSellAmount, minTimeForStep, 
maxTimeForStep, shortestTimeFromMin, shortestTimeFromMax, minOrMaxOfSteepHike, 
(CASE  
WHEN (minOrMaxOfSteepHike  = 'min' OR minOrMaxOfSteepHike  = 'max') then @previousNonSteepHikeTimeBlockTrackingNumber := (@previousNonSteepHikeTimeBlockTrackingNumber + 1 )
WHEN minOrMaxOfSteepHike  = 'not' then @previousNonSteepHikeTimeBlockTrackingNumber := (@previousNonSteepHikeTimeBlockTrackingNumber ) 
END) as nonSteepHikeTimeBlockTrackingNumber
from hikeStepDurationsWSteepHikesMarked
JOIN (select @previousNonSteepHikeTimeBlockTrackingNumber := 0) t;

delete from hikeStepsWNonSteepTimeBlocks;
select * from hikeStepsWNonSteepTimeBlocks limit 1000;

/*
The table gradualSpikes collects only those gradual spikes that have spiked up by atleast 30%, 
i.e. the min and max of that step differ in price by atleast 30%. 
*/
CREATE table gradualSpikesWithoutCorrectDifference like steepHikeStepsMinMaxWMinimumHeight;
    
INSERT into gradualSpikesWithoutCorrectDifference
select exchangeName, tradePair, min(priceHikeStep), max(priceHikeStep), min(maxTimeForStep), max(maxTimeForStep), 
time_to_sec(timediff(max(minTimeForStep), min(maxTimeForStep))) / 3600,
/* use the above for getting the duration of the whole spike instead of sum(totalDurationOfAllStepsInHrs) as the latter will include the time 
of the first step which is not desirable as the firrst step may have lasted a very long time
*/
min(avgPriceUSD), max(avgPriceUSD), min(avgPriceBTC), max(avgPriceBTC),
avg(buyHistoryAmount) , avg(sellHistoryAmount),  avg(openBuyAmount) , avg(openSellAmount), 
min(shortestTimeFromMin), max(shortestTimeFromMax)
from hikeStepsWNonSteepTimeBlocks 
where (nonSteepHikeTimeBlockTrackingNumber % 2) = 0
group by nonSteepHikeTimeBlockTrackingNumber;   

CREATE table gradualSpikes like steepHikeStepsMinMaxWMinimumHeight;

INSERT INTO gradualSpikes
select temp.exchangeName, temp.tradePair, 
hikeStepDurationsTemp1.priceHikeStep, hikeStepDurationsTemp2.priceHikeStep, temp.minOfMaxTimeForStep, temp.maxOfMaxTimeForStep, 
temp.totalDurationOfAllStepsInHrs, temp.minAvgPriceUSD, temp.maxAvgPriceUSD, temp.minAvgPriceBTC, temp.maxAvgPriceBTC, temp.avgBuyHistoryAmount, 
temp.avgSellHistoryAmount, temp.avgOpenBuyAmount, temp.avgOpenSellAmount, temp.minShortestTimeFromMin, temp.maxShortestTimeFromMax
from gradualSpikesWithoutCorrectDifference as temp
LEFT JOIN hikeStepDurations hikeStepDurationsTemp1 ON 
(CONCAT(hikeStepDurationsTemp1.exchangeName, hikeStepDurationsTemp1.tradePair, hikeStepDurationsTemp1.maxTimeForStep) 
= CONCAT(temp.exchangeName, temp.tradePair, temp.minOfMaxTimeForStep))
LEFT JOIN hikeStepDurations hikeStepDurationsTemp2 ON 
(CONCAT(hikeStepDurationsTemp2.exchangeName, hikeStepDurationsTemp2.tradePair, hikeStepDurationsTemp2.maxTimeForStep) 
= CONCAT(temp.exchangeName, temp.tradePair, temp.maxOfMaxTimeForStep));



CREATE TABLE gradualSpikesWMinimumHeight LIKE gradualSpikes;  

INSERT INTO gradualSpikesWMinimumHeight
select * from 
( select * from gradualSpikes 
/* below we are converting steps into actual approximate values before comparing for a change of atleast 30%. 
Recall that steps are every 10% change from the min
*/
 where ((maxPriceHikeStep/10+1) - (minPriceHikeStep/10+1))/ (minPriceHikeStep/10+1) >= 0.25) gradualSpikesTemp;
 
select * from gradualSpikesWMinimumHeight;

select DISTINCT(CONCAT(exchangeName, tradePair)) from gradualSpikesWMinimumHeight;

select DISTINCT(CONCAT(exchangeName, tradePair)) from gradualSpikesWMinimumHeight where CONCAT(exchangeName, tradePair)
NOT in (select DISTINCT(CONCAT(exchangeName, tradePair)) from sustainedSpikesWLastSpikeInfo);

use pocu4;