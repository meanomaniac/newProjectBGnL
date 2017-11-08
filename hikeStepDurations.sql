
use pocu3;

CREATE TABLE hikeStepDurations (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	priceHikeStep FLOAT NULL,
	priceHikeStepDurationInHrs FLOAT NULL,
    shortestTimeFromMin FLOAT NULL,
    shortestTimeFromMax FLOAT NULL
);

INSERT INTO hikeStepDurations
SELECT CCIntTickerTemp.exchangeName, CCIntTickerTemp.tradePair, 
FLOOR(((CCIntTickerTemp.askPriceUSD - mthDiffMinMaxWithTradingInfoTemp.minPriceUSD)/mthDiffMinMaxWithTradingInfoTemp.minPriceUSD*100)/10) as priceHikeStep,
time_to_sec(timediff(max(CCIntTickerTemp.recordTime), min(CCIntTickerTemp.recordTime)))/3600 as priceHikeStepDuration,
time_to_sec(timediff(min(CCIntTickerTemp.recordTime), mthDiffMinMaxWithTradingInfoTemp.timeOfMin))/3600 as shortestTimeFromMin,
time_to_sec(timediff(mthDiffMinMaxWithTradingInfoTemp.timeOfMax, max(CCIntTickerTemp.recordTime)))/3600 as shortestTimeFromMax
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

SELECT priceHikeStep, COUNT(*) FROM hikeStepDurations
where  priceHikeStep <= 20
GROUP BY priceHikeStep ;

SELECT * FROM hikeStepDurations Order by priceHikeStep;
