use pocu4;

CREATE TABLE spikeStringTable (
	spikeString VARCHAR(100) NULL
);

INSERT into spikeStringTable
select CONCAT(exchangeName, tradePair, minOfMaxTimeForStep) from steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo;
select * from spikeStringTable;


CREATE TABLE CCIntTickerWSpikeInfo (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	askPriceUSD FLOAT NULL,
	askPriceBTC FLOAT NULL,
	recordTime DATETIME NULL,
    spikeStarts TINYINT(1) DEFAULT 0
);

INSERT INTO CCIntTickerWSpikeInfo
select exchangeName, tradePair, askPriceUSD, askPriceBTC, recordTime, 
(case CONCAT(exchangeName, tradePair, recordTime) IN (select * from spikeStringTable)
WHEN true then 1
WHEN false then 0 END) as spikeStarts
from CCIntTicker ;

ALTER TABLE CCIntTickerWSpikeInfo ADD INDEX exchangePair (exchangeName, tradePair);

select * from CCIntTickerWSpikeInfo where spikeStarts = 1;

CREATE TABLE CCIntTickerWPriceDiff (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	askPriceUSD FLOAT NULL,
	askPriceBTC FLOAT NULL,
	recordTime DATETIME NULL,
    spikeStarts TINYINT(1) DEFAULT 0,
    diff2Hr FLOAT NULL,
    diff4Hr FLOAT NULL,
    diff8Hr FLOAT NULL,
    diff16Hr FLOAT NULL,
    diff1Day FLOAT NULL,
    diff2Day FLOAT NULL,
    diff4Day FLOAT NULL,
    diff1Wk FLOAT NULL,
    diff2Wk FLOAT NULL,
    diff4Wk FLOAT NULL
);

-- del
select DISTINCT(CONCAT(exchangeName, tradePair, minOfMaxTimeForStep)) from steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo limit 10;
select CONCAT(exchangeName, tradePair, recordTime) from CCIntTicker 
where CONCAT(exchangeName, tradePair, recordTime)  IN
(select CONCAT(exchangeName, tradePair, minOfMaxTimeForStep) from steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo );

select CONCAT(exchangeName, tradePair, recordTime) from CCIntTicker 
where CONCAT(exchangeName, tradePair, recordTime)  IN
(select * from spikeStringTable);

select recordTime, askPriceUSD from CCIntTicker where CONCAT(exchangeName, tradePair) = 'bittrexBTC-GRC';

select * from all25PercSpikesWLingeringInfo where CONCAT(exchangeName, tradePair) = 'bittrexBTC-BCY';

bittrexBTC-2GIVE2017-11-05 16:45:00
cryptopia4CHN/BTC2017-10-01 02:15:00