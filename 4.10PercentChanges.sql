/*
This is the fourth script. This creates the table hikeStepDurations which is another version of CCIntTicker from the 3rd script, where
a recrod represents a change in price by 10% of the min price (and the time for when that change happens). The smallest step in the table
would be 1 indicating a price of 10% of the min. 2 would be 20% and so on.

The other table stepMinMaxByDay gets the minimum and maximum of the price step and the price and the trading info. This table is generated
and then queried to find those pairs and the days when they have have risen dramatically (by checking that the min step and the max step 
is greater than a certain value like 4. Instead of steps, the regular CCIntTicker maybe also used for getting these dramatic rises but 
hikeStepDurations is smaller than CCIntTicker so querying it ans tudying will be easier).
*/

use pocu3;

CREATE TABLE hikeStepDurations (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
    stepCounter FLOAT NULL,
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

INSERT INTO hikeStepDurations
SELECT CCIntTickerTemp.exchangeName, CCIntTickerTemp.tradePair, 
/* the priceStepCounterVar increments when the price changes by 10% of the min value. This variable/column is being
created so that records within a step (every 10% hike) can be grouped and then the duration for that step can be 
calculated (in addition to some other data)
the priceStepVar calculates the 10th digit of the price to enable us to determine the step that the specifc record belongs to.

the following switch case like construct returns the same value of the priceStepCounterVar if the priceStepVar
hasn't changed from the previous record. It increments priceStepCounterVar by 1 if it did.
*/
(case @priceStepVar != FLOOR(((CCIntTickerTemp.askPriceUSD - mthDiffMinMaxWithTradingInfoTemp.minPriceUSD)
/mthDiffMinMaxWithTradingInfoTemp.minPriceUSD*100)/10) 
WHEN true then @priceStepCounterVar := @priceStepCounterVar +1 
WHEN false then @priceStepCounterVar := @priceStepCounterVar END) as priceHikeStepCounter,
(@priceStepVar := FLOOR(((CCIntTickerTemp.askPriceUSD - mthDiffMinMaxWithTradingInfoTemp.minPriceUSD)
/mthDiffMinMaxWithTradingInfoTemp.minPriceUSD*100)/10)) as priceHikeStep,
ROUND(time_to_sec(timediff(max(CCIntTickerTemp.recordTime), min(CCIntTickerTemp.recordTime)))/3600, 2) as priceStepDurationHrs,
ROUND(avg(CCIntTickerTemp.askPriceUSD),2) as avgPriceUSD,
ROUND(avg(CCIntTickerTemp.askPriceBTC),2) as avgPriceBTC,
mthDiffMinMaxWithTradingInfoTemp.buyHistoryAmount,
mthDiffMinMaxWithTradingInfoTemp.openBuyAmount,
max(CCIntTickerTemp.recordTime),
time_to_sec(timediff(min(CCIntTickerTemp.recordTime), mthDiffMinMaxWithTradingInfoTemp.timeOfMin))/3600 as shortestTimeFromMin,
time_to_sec(timediff(mthDiffMinMaxWithTradingInfoTemp.timeOfMax, max(CCIntTickerTemp.recordTime)))/3600 as shortestTimeFromMax
FROM (
select * from CCIntTicker
ORDER BY CONCAT(exchangeName, tradePair), recordTime) CCIntTickerTemp
-- the following join enables us to get the price and time of the min and max for each unique tradePair
	LEFT JOIN mthDiffMinMaxWithTradingInfo mthDiffMinMaxWithTradingInfoTemp 
	ON (mthDiffMinMaxWithTradingInfoTemp.exchangeName = CCIntTickerTemp.exchangeName AND
			mthDiffMinMaxWithTradingInfoTemp.tradePair = CCIntTickerTemp.tradePair)
-- the following is how you define variables in mySql            
	JOIN (select @priceStepVar := 0,  @priceStepCounterVar := 0) t       
WHERE recordTime > mthDiffMinMaxWithTradingInfoTemp.timeOfMin 
-- AND recordTime < mthDiffMinMaxWithTradingInfoTemp.timeOfMax
GROUP BY exchangeName, tradePair, priceHikeStepCounter
ORDER BY CONCAT(CCIntTickerTemp.exchangeName, CCIntTickerTemp.tradePair), CCIntTickerTemp.recordTime;

ALTER TABLE hikeStepDurations ADD INDEX exchangePair (exchangeName, tradePair);

SELECT * FROM hikeStepDurations;
SELECT COUNT(*) FROM hikeStepDurations;
SELECT COUNT(DISTINCT(tradePair)) FROM hikeStepDurations where buyHistoryAmount > 10;
select priceHikeStep, priceStepDurationInHrs from hikeStepDurations where exchangeName ='bittrex' and tradePair = 'BTC-CLUB';


CREATE TABLE stepMinMaxByDay (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,    
    dayOfRecord DATETIME NULL,
    minStep FLOAT NULL,
	maxStep FLOAT NULL,
	minPriceUSD FLOAT NULL,
	maxPriceUSD FLOAT NULL,
	minPriceBTC FLOAT NULL,
    maxPriceBTC FLOAT NULL,    
    buyHistoryAmount FLOAT NULL,
    openBuyAmount FLOAT NULL
);

INSERT INTO stepMinMaxByDay
SELECT exchangeName, tradePair, DATE(maxTimeForStep), min(priceHikeStep) as minStep, max(priceHikeStep) as maxStep, 
min(avgPriceUSD), max(avgPriceUSD),
min(avgPriceBTC), max(avgPriceBTC),
max(buyHistoryAmount), max(openBuyAmount)
from hikeStepDurations 
GROUP by exchangeName, tradePair, DATE(maxTimeForStep)
ORDER by exchangeName, tradePair, DATE(maxTimeForStep);

ALTER TABLE stepMinMaxByDay ADD INDEX exchangePair (exchangeName, tradePair);

Select * from stepMinMaxByDay
where maxStep - minStep > 10
and maxStep < 1000;

-- del 
SELECT priceHikeStep, COUNT(*) FROM hikeStepDurations
where  priceHikeStep <= 20
GROUP BY priceHikeStep ;

SELECT priceHikeStepDurationInHrs FROM hikeStepDurations where priceHikeStep = 11 and priceHikeStepDurationInHrs < 25;

SELECT * FROM hikeStepDurations ORDER BY exchangeName, tradePair, priceHikeStepDurationInHrs;

SELECT * FROM hikeStepDurations ORDER BY priceHikeStepDurationInHrs;

SELECT * FROM hikeStepDurations where priceHikeStepDurationInHrs =0 and priceHikeStep > 0 
ORDER By CONCAT(exchangeName, tradePair);

SELECT COUNT(*) FROM hikeStepDurations where priceHikeStepDurationInHrs < 10 and priceHikeStep > 0 ;

select priceHikeStep, priceHikeStepDurationInHrs from hikeStepDurations where exchangeName ='bittrex' and tradePair = 'BTC-CLUB';


-- ORDER BY CONCAT(CCIntTickerTemp.exchangeName, CCIntTickerTemp.tradePair, CCIntTickerTemp.recordTime);

INSERT INTO hikeStepDurations
SELECT CCIntTickerTemp.exchangeName, CCIntTickerTemp.tradePair, 
FLOOR(((CCIntTickerTemp.askPriceUSD - mthDiffMinMaxWithTradingInfoTemp.minPriceUSD)/mthDiffMinMaxWithTradingInfoTemp.minPriceUSD*100)/10) as priceHikeStep,
time_to_sec(timediff(max(CCIntTickerTemp.recordTime), min(CCIntTickerTemp.recordTime)))/3600 as priceHikeStepDuration,
time_to_sec(timediff(min(CCIntTickerTemp.recordTime), mthDiffMinMaxWithTradingInfoTemp.timeOfMin))/3600 as shortestTimeFromMin,
time_to_sec(timediff(mthDiffMinMaxWithTradingInfoTemp.timeOfMax, max(CCIntTickerTemp.recordTime)))/3600 as shortestTimeFromMax,
mthDiffMinMaxWithTradingInfoTemp.buyHistoryAmount,
mthDiffMinMaxWithTradingInfoTemp.openBuyAmount
FROM CCIntTicker CCIntTickerTemp
	LEFT JOIN mthDiffMinMaxWithTradingInfo mthDiffMinMaxWithTradingInfoTemp 
	ON (mthDiffMinMaxWithTradingInfoTemp.exchangeName = CCIntTickerTemp.exchangeName AND
			mthDiffMinMaxWithTradingInfoTemp.tradePair = CCIntTickerTemp.tradePair)
WHERE recordTime > mthDiffMinMaxWithTradingInfoTemp.timeOfMin AND
recordTime < mthDiffMinMaxWithTradingInfoTemp.timeOfMax
GROUP BY exchangeName, tradePair, priceHikeStep
ORDER BY CONCAT(CCIntTickerTemp.exchangeName, CCIntTickerTemp.tradePair, CCIntTickerTemp.recordTime);

select * from CCIntTicker
ORDER BY CONCAT(exchangeName, tradePair), recordTime;