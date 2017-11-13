
use pocu3;

CREATE TABLE hikeStepDurations (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	priceHikeStep FLOAT NULL,
	priceHikeStepDurationInHrs FLOAT NULL,
    shortestTimeFromMin FLOAT NULL,
    shortestTimeFromMax FLOAT NULL,
    buyHistoryAmount FLOAT NULL,
    openBuyAmount FLOAT NULL
);

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

ALTER TABLE hikeStepDurations ADD INDEX exchangePair (exchangeName, tradePair);

SELECT * FROM hikeStepDurations;
SELECT COUNT(*) FROM hikeStepDurations;
SELECT COUNT(DISTINCT(tradePair)) FROM hikeStepDurations where buyHistoryAmount > 10;
select priceHikeStep, priceHikeStepDurationInHrs from hikeStepDurations where exchangeName ='bittrex' and tradePair = 'BTC-CLUB';
SELECT exchangeName, tradePair, priceHikeStep, priceHikeStepDurationInHrs, buyHistoryAmount FROM hikeStepDurations;

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


SELECT CCIntTickerTemp.exchangeName, CCIntTickerTemp.tradePair, 
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
mthDiffMinMaxWithTradingInfoTemp.openBuyAmount
FROM (
select * from CCIntTicker
ORDER BY CONCAT(exchangeName, tradePair, recordTime)) CCIntTickerTemp
	LEFT JOIN mthDiffMinMaxWithTradingInfo mthDiffMinMaxWithTradingInfoTemp 
	ON (mthDiffMinMaxWithTradingInfoTemp.exchangeName = CCIntTickerTemp.exchangeName AND
			mthDiffMinMaxWithTradingInfoTemp.tradePair = CCIntTickerTemp.tradePair)
	JOIN (select @priceStepVar := 0,  @priceStepCounterVar := 0) t       
WHERE recordTime > mthDiffMinMaxWithTradingInfoTemp.timeOfMin AND
recordTime < mthDiffMinMaxWithTradingInfoTemp.timeOfMax
GROUP BY exchangeName, tradePair, priceHikeStepCounter;
-- ORDER BY CONCAT(CCIntTickerTemp.exchangeName, CCIntTickerTemp.tradePair, CCIntTickerTemp.recordTime);


select exchangeName, tradePair, @a := @a + askPriceUSD as newCol1, 
(case 1<3 
WHEN true then @b := @a*2
WHEN false then @b := 0 END) as newCol2
from cTicker15MinAvgBTCPrice
JOIN (select @a := 0,  @b := 0) t
where tradePair = 'BTC-BCY' and exchangeName = 'bittrex';