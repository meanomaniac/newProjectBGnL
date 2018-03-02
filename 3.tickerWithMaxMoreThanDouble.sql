/*
This is the 3rd script. This creates a subset of the cTicker15MinAvgBTCPrice table from the 1st script to include only those trade pairs where the 
max is atleast double or more of that of the min
*/

use pocu4;

CREATE TABLE CCIntTicker (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	askPriceUSD FLOAT NULL,
	askPriceBTC FLOAT NULL,
	recordTime DATETIME NULL
);

INSERT INTO CCIntTicker
SELECT exchangeName, tradePair, askPriceUSD, askPriceBTC, recordTime from cTicker15MinAvgBTCPrice where CONCAT(exchangeName, tradePair) IN 
-- the following gives all the unique tradePair combos that have a max value more than twice of the min and that the max has occured after the min
(SELECT CONCAT(exchangeName, tradePair) AS exchTP
from mthDiffMinMaxWithTradingInfo 
where timeOfMax > timeOfMin AND (maxPriceUSD-minPriceUSD)/minPriceUSD > 1
AND exchangeName != 'coinMarketCap' AND exchangeName != 'coinExchange' );

ALTER TABLE CCIntTicker ADD INDEX exchangePair (exchangeName, tradePair);

select count(*) from CCIntTicker;

SELECT * FROM CCIntTicker where tradePair = 'BTC-MONA';

CREATE TABLE CCIntOpenOrders (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	totalBuyAmount FLOAT NULL,
	totalSellAmount FLOAT NULL,
	recordTime DATETIME NULL
);

INSERT INTO CCIntOpenOrders
SELECT exchangeName, tradePair, totalBuyAmount, totalSellAmount, recordTime 
from openOrders15MinAvg where CONCAT(exchangeName, tradePair) IN 
-- the following gives all the unique tradePair combos that have a max value more than twice of the min and that the max has occured after the min
(SELECT CONCAT(exchangeName, tradePair) AS exchTP
from mthDiffMinMaxWithTradingInfo 
where timeOfMax > timeOfMin AND (maxPriceUSD-minPriceUSD)/minPriceUSD > 1
AND exchangeName != 'coinMarketCap' AND exchangeName != 'coinExchange' );

ALTER TABLE CCIntOpenOrders ADD INDEX exchangePair2 (exchangeName, tradePair, recordTime);
-- ALTER TABLE CCIntOpenOrders ADD INDEX exchangePair (exchangeName, tradePair);

-- del
-- 20 mins

SELECT * from cTicker where CONCAT(exchangeName, tradePair) IN 
(SELECT CONCAT(exchangeName, tradePair, DATE(timeOfMax)) AS exchPairDate from dayDiffMinMaxWithTradingInfo 
where timeOfMax > timeOfMin AND (maxPriceUSD-minPriceUSD)/minPriceUSD > 1
AND ((atMaxPlus15+atMaxPlus30+atMaxPlus45+atMaxPlus60)/4 > 2*minPriceUSD OR
(atMaxMinus15+atMaxMinus30+atMaxMinus45+atMaxMinus60)/4 > 2*minPriceUSD OR
(atMaxPlus15+atMaxPlus30+atMaxMinus15+atMaxMinus30)/4 > 2*minPriceUSD)
AND exchangeName != 'coinMarketCap' AND exchangeName != 'coinExchange' 
AND UPPER(tradePair) REGEXP 
"BCH|ETH|XRP|USDT|LTC|EOS|DASH|ETC|QTUM|NEO|ZEC|XMR|OMG|VTC|BCC|XLM|HSR|GRS|WAVES|ZEN|MIOTA|WTC|STRAT|SYS|LSK|BTG|ETP|STORJ|MCO|GNT|FCT|BAT|POWR|SNT|VRC|XEM|KMD|BTS|NXT|SYNX|ARK|XVG|XDN|SALT|MTL|BCN|NAS|ADA|PAY|ADX|ARDR|DOGE|MONA|LINK|BQX|BNB|KNC|RISE|DGB|XST|MOD|TRST|OK|CVC|EVX|ZRX|AST|VIA|DNT|SC|GXS|SNGLS|ATB|MAID|TRX|PIVX|KCS|BNT|RPX|NAV|CTR|XZC|GAS|TX|REP|STEEM|MCAP|FTC|GNO|RBY|GAME|ICN");

describe cTicker;