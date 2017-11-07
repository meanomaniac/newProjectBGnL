
SELECT CCIntTickerTemp.exchangeName, CCIntTickerTemp.tradePair, 
FLOOR(((CCIntTickerTemp.askPriceUSD - mthDiffMinMaxWithTradingInfoTemp.minPriceUSD)/mthDiffMinMaxWithTradingInfoTemp.minPriceUSD*100)/10) as priceHikeStep,
time_to_sec(timediff(max(CCIntTickerTemp.recordTime), min(CCIntTickerTemp.recordTime)))/3600 as priceHikeStepDuration
FROM CCIntTicker CCIntTickerTemp
	LEFT JOIN mthDiffMinMaxWithTradingInfo mthDiffMinMaxWithTradingInfoTemp 
	ON (mthDiffMinMaxWithTradingInfoTemp.exchangeName = CCIntTickerTemp.exchangeName AND
			mthDiffMinMaxWithTradingInfoTemp.tradePair = CCIntTickerTemp.tradePair)
WHERE recordTime > mthDiffMinMaxWithTradingInfoTemp.timeOfMin AND
recordTime < mthDiffMinMaxWithTradingInfoTemp.timeOfMax
GROUP BY exchangeName, tradePair, priceHikeStep
ORDER BY CONCAT(CCIntTickerTemp.exchangeName, CCIntTickerTemp.tradePair, CCIntTickerTemp.recordTime);
