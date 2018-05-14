CREATE TABLE spikeStringTable (
	spikeBaseString VARCHAR(100) NULL,
    spikePeakString VARCHAR(100) NULL
);

INSERT into spikeStringTable
select CONCAT(exchangeName, tradePair, minOfMaxTimeForStep),
CONCAT(exchangeName, tradePair, maxOfMaxTimeForStep)
 from steepHikeStepsMinMaxWMinimumHeightWLastSpikeInfo;
 
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
(case CONCAT(exchangeName, tradePair, recordTime) IN (select spikeBaseString from spikeStringTable)
WHEN true then 1
WHEN false then 0 END) as spikeStarts
from CCIntTicker ;

ALTER TABLE CCIntTickerWSpikeInfo ADD INDEX exchangePair (exchangeName, tradePair);

select * from CCIntTickerWSpikeInfo where spikeStarts = 1;


CREATE TABLE CCIntTickerWPriceDiffDel (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	askPriceUSD FLOAT NULL,
	askPriceBTC FLOAT NULL,
	recordTime DATETIME NULL,
    spikeStarts TINYINT(1) DEFAULT 0,
    diff2Hr FLOAT NULL
);

INSERT INTO CCIntTickerWPriceDiffDel
select 
exchangeName, tradePair, askPriceUSD, askPriceBTC, recordTime, spikeStarts, diff2Hr from
(
select 
t1.exchangeName, t1.tradePair, t1.askPriceUSD, t1.askPriceBTC, 
t1.recordTime, t1.spikeStarts, t1.baseGSPriceTime, (t1.askPriceUSD - t2.askPriceUSD)*100/t2.askPriceUSD as diff2Hr
from
(
select 
temp1.exchangeName, temp1.tradePair, temp1.askPriceUSD, temp1.askPriceBTC, 
temp1.recordTime, temp1.spikeStarts, max(temp2.recordTime) as baseGSPriceTime
from CCIntTickerWSpikeInfo as temp1
LEFT JOIN CCIntTicker as temp2 on (temp2.exchangeName = temp1.exchangeName AND
														temp2.tradePair = temp1.tradePair AND
														FROM_UNIXTIME((UNIX_TIMESTAMP(temp2.recordTime)) +7200) <= temp1.recordTime AND
                                                        temp2.askPriceUSD is not null)
group by temp1.exchangeName, temp1.tradePair, temp1.recordTime) t1 
LEFT JOIN CCIntTicker as t2 on (t2.exchangeName = t1.exchangeName AND
												t2.tradePair = t1.tradePair AND
												t2.recordTime = t1.baseGSPriceTime)
) t;

ALTER TABLE CCIntTickerWPriceDiffDel ADD INDEX exchangePair2 (exchangeName, tradePair, recordTime);


CREATE TABLE CCIntTickerWPriceDiffDel2 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	askPriceUSD FLOAT NULL,
	askPriceBTC FLOAT NULL,
	recordTime DATETIME NULL,
    spikeStarts TINYINT(1) DEFAULT 0,
    diff2Hr FLOAT NULL,
    diff4Hr FLOAT NULL
);


INSERT INTO CCIntTickerWPriceDiffDel2
select 
exchangeName, tradePair, askPriceUSD, askPriceBTC, recordTime, spikeStarts, diff2Hr,
diff4Hr from
(
select 
t1.exchangeName, t1.tradePair, t1.askPriceUSD, t1.askPriceBTC, 
t1.recordTime, t1.spikeStarts, t1.baseGSPriceTime, t1.diff2Hr, 
(t1.askPriceUSD - t2.askPriceUSD)*100/t2.askPriceUSD as diff4Hr
from
(
select 
temp1.exchangeName, temp1.tradePair, temp1.askPriceUSD, temp1.askPriceBTC, 
temp1.recordTime, temp1.spikeStarts, temp1.diff2Hr, 
max(temp2.recordTime) as baseGSPriceTime
from CCIntTickerWPriceDiffDel as temp1
LEFT JOIN CCIntTicker as temp2 on (temp2.exchangeName = temp1.exchangeName AND
														temp2.tradePair = temp1.tradePair AND
														FROM_UNIXTIME((UNIX_TIMESTAMP(temp2.recordTime)) +14400) <= temp1.recordTime AND
                                                        temp2.askPriceUSD is not null)
group by temp1.exchangeName, temp1.tradePair, temp1.recordTime) t1 
LEFT JOIN CCIntTicker as t2 on (t2.exchangeName = t1.exchangeName AND
												t2.tradePair = t1.tradePair AND
												t2.recordTime = t1.baseGSPriceTime)
) t;

ALTER TABLE CCIntTickerWPriceDiffDel2 ADD INDEX exchangePair (exchangeName, tradePair, recordTime);

use pocu4;
CREATE TABLE CCIntTickerWPriceDiffDel3 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	askPriceUSD FLOAT NULL,
	askPriceBTC FLOAT NULL,
	recordTime DATETIME NULL,
    spikeStarts TINYINT(1) DEFAULT 0,
    diff2Hr FLOAT NULL,
    diff4Hr FLOAT NULL,
    diff8Hr FLOAT NULL
);


INSERT INTO CCIntTickerWPriceDiffDel3
select 
exchangeName, tradePair, askPriceUSD, askPriceBTC, recordTime, spikeStarts, diff2Hr,
diff4Hr, diff8Hr from
(
select 
t1.exchangeName, t1.tradePair, t1.askPriceUSD, t1.askPriceBTC, 
t1.recordTime, t1.spikeStarts, t1.baseGSPriceTime, t1.diff2Hr, t1.diff4Hr, 
(t1.askPriceUSD - t2.askPriceUSD)*100/t2.askPriceUSD as diff8Hr
from
(
select 
temp1.exchangeName, temp1.tradePair, temp1.askPriceUSD, temp1.askPriceBTC, 
temp1.recordTime, temp1.spikeStarts, temp1.diff2Hr, temp1.diff4Hr, 
max(temp2.recordTime) as baseGSPriceTime
from CCIntTickerWPriceDiffDel2 as temp1
LEFT JOIN CCIntTicker as temp2 on (temp2.exchangeName = temp1.exchangeName AND
														temp2.tradePair = temp1.tradePair AND
														FROM_UNIXTIME((UNIX_TIMESTAMP(temp2.recordTime)) +28800) <= temp1.recordTime AND
                                                        temp2.askPriceUSD is not null)
group by temp1.exchangeName, temp1.tradePair, temp1.recordTime) t1 
LEFT JOIN CCIntTicker as t2 on (t2.exchangeName = t1.exchangeName AND
												t2.tradePair = t1.tradePair AND
												t2.recordTime = t1.baseGSPriceTime)
) t;

ALTER TABLE CCIntTickerWPriceDiffDel3 ADD INDEX exchangePair (exchangeName, tradePair, recordTime);


use pocu4;
CREATE TABLE CCIntTickerWPriceDiffDel4 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
	askPriceUSD FLOAT NULL,
	askPriceBTC FLOAT NULL,
	recordTime DATETIME NULL,
    spikeStarts TINYINT(1) DEFAULT 0,
    diff2Hr FLOAT NULL,
    diff4Hr FLOAT NULL,
    diff8Hr FLOAT NULL,
    diff16Hr FLOAT NULL
);


INSERT INTO CCIntTickerWPriceDiffDel4
select 
exchangeName, tradePair, askPriceUSD, askPriceBTC, recordTime, spikeStarts, diff2Hr,
diff4Hr, diff8Hr, diff16Hr from
(
select 
t1.exchangeName, t1.tradePair, t1.askPriceUSD, t1.askPriceBTC, 
t1.recordTime, t1.spikeStarts, t1.baseGSPriceTime, t1.diff2Hr, t1.diff4Hr, t1.diff8Hr,
(t1.askPriceUSD - t2.askPriceUSD)*100/t2.askPriceUSD as diff16Hr
from
(
select 
temp1.exchangeName, temp1.tradePair, temp1.askPriceUSD, temp1.askPriceBTC, 
temp1.recordTime, temp1.spikeStarts, temp1.diff2Hr, temp1.diff4Hr, temp1.diff8Hr,
max(temp2.recordTime) as baseGSPriceTime
from CCIntTickerWPriceDiffDel3 as temp1
LEFT JOIN CCIntTicker as temp2 on (temp2.exchangeName = temp1.exchangeName AND
														temp2.tradePair = temp1.tradePair AND
														FROM_UNIXTIME((UNIX_TIMESTAMP(temp2.recordTime)) +57600) <= temp1.recordTime AND
                                                        temp2.askPriceUSD is not null)
group by temp1.exchangeName, temp1.tradePair, temp1.recordTime) t1 
LEFT JOIN CCIntTicker as t2 on (t2.exchangeName = t1.exchangeName AND
												t2.tradePair = t1.tradePair AND
												t2.recordTime = t1.baseGSPriceTime)
) t;

ALTER TABLE CCIntTickerWPriceDiffDel4 ADD INDEX exchangePair (exchangeName, tradePair, recordTime);


use pocu4;

CREATE TABLE CCIntTickerWPriceDiffDel5 (
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
    diff20Hr FLOAT NULL
);


INSERT INTO CCIntTickerWPriceDiffDel5
select 
exchangeName, tradePair, askPriceUSD, askPriceBTC, recordTime, spikeStarts, diff2Hr,
diff4Hr, diff8Hr, diff16Hr, diff20Hr from
(
select 
t1.exchangeName, t1.tradePair, t1.askPriceUSD, t1.askPriceBTC, 
t1.recordTime, t1.spikeStarts, t1.baseGSPriceTime, t1.diff2Hr, t1.diff4Hr, t1.diff8Hr, t1.diff16Hr,
(t1.askPriceUSD - t2.askPriceUSD)*100/t2.askPriceUSD as diff20Hr
from
(
select 
temp1.exchangeName, temp1.tradePair, temp1.askPriceUSD, temp1.askPriceBTC, 
temp1.recordTime, temp1.spikeStarts, temp1.diff2Hr, temp1.diff4Hr, temp1.diff8Hr, temp1.diff16Hr,
max(temp2.recordTime) as baseGSPriceTime
from CCIntTickerWPriceDiffDel4 as temp1
LEFT JOIN CCIntTicker as temp2 on (temp2.exchangeName = temp1.exchangeName AND
														temp2.tradePair = temp1.tradePair AND
														FROM_UNIXTIME((UNIX_TIMESTAMP(temp2.recordTime)) +72000) <= temp1.recordTime AND
                                                        temp2.askPriceUSD is not null)
group by temp1.exchangeName, temp1.tradePair, temp1.recordTime) t1 
LEFT JOIN CCIntTicker as t2 on (t2.exchangeName = t1.exchangeName AND
												t2.tradePair = t1.tradePair AND
												t2.recordTime = t1.baseGSPriceTime)
) t;

ALTER TABLE CCIntTickerWPriceDiffDel5 ADD INDEX exchangePair (exchangeName, tradePair, recordTime);

use pocu4;

CREATE TABLE CCIntTickerWPriceDiffDel6 (
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
    diff20Hr FLOAT NULL,
	diff1Day FLOAT NULL
);


INSERT INTO CCIntTickerWPriceDiffDel6
select 
exchangeName, tradePair, askPriceUSD, askPriceBTC, recordTime, spikeStarts, diff2Hr,
diff4Hr, diff8Hr, diff16Hr, diff20Hr, diff1Day from
(
select 
t1.exchangeName, t1.tradePair, t1.askPriceUSD, t1.askPriceBTC, 
t1.recordTime, t1.spikeStarts, t1.baseGSPriceTime, t1.diff2Hr, t1.diff4Hr, t1.diff8Hr, t1.diff16Hr,
t1.diff20Hr,
(t1.askPriceUSD - t2.askPriceUSD)*100/t2.askPriceUSD as diff1Day
from
(
select 
temp1.exchangeName, temp1.tradePair, temp1.askPriceUSD, temp1.askPriceBTC, 
temp1.recordTime, temp1.spikeStarts, temp1.diff2Hr, temp1.diff4Hr, temp1.diff8Hr, temp1.diff16Hr,
temp1.diff20Hr,
max(temp2.recordTime) as baseGSPriceTime
from CCIntTickerWPriceDiffDel5 as temp1
LEFT JOIN CCIntTicker as temp2 on (temp2.exchangeName = temp1.exchangeName AND
														temp2.tradePair = temp1.tradePair AND
														FROM_UNIXTIME((UNIX_TIMESTAMP(temp2.recordTime)) +86400) <= temp1.recordTime AND
                                                        temp2.askPriceUSD is not null)
group by temp1.exchangeName, temp1.tradePair, temp1.recordTime) t1 
LEFT JOIN CCIntTicker as t2 on (t2.exchangeName = t1.exchangeName AND
												t2.tradePair = t1.tradePair AND
												t2.recordTime = t1.baseGSPriceTime)
) t;

ALTER TABLE CCIntTickerWPriceDiffDel6 ADD INDEX exchangePair (exchangeName, tradePair, recordTime);

use pocu4;

CREATE TABLE CCIntTickerWPriceDiffDel7 (
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
    diff20Hr FLOAT NULL,
	diff1Day FLOAT NULL,
    diff2Wk FLOAT NULL
);


INSERT INTO CCIntTickerWPriceDiffDel7
select 
exchangeName, tradePair, askPriceUSD, askPriceBTC, recordTime, spikeStarts, diff2Hr,
diff4Hr, diff8Hr, diff16Hr, diff20Hr, diff1Day, diff2Day from
(
select 
t1.exchangeName, t1.tradePair, t1.askPriceUSD, t1.askPriceBTC, 
t1.recordTime, t1.spikeStarts, t1.baseGSPriceTime, t1.diff2Hr, t1.diff4Hr, t1.diff8Hr, t1.diff16Hr,
t1.diff20Hr, t1.diff1Day,
(t1.askPriceUSD - t2.askPriceUSD)*100/t2.askPriceUSD as diff2Day
from
(
select 
temp1.exchangeName, temp1.tradePair, temp1.askPriceUSD, temp1.askPriceBTC, 
temp1.recordTime, temp1.spikeStarts, temp1.diff2Hr, temp1.diff4Hr, temp1.diff8Hr, temp1.diff16Hr,
temp1.diff20Hr, temp1.diff1Day,
max(temp2.recordTime) as baseGSPriceTime
from CCIntTickerWPriceDiffDel6 as temp1
LEFT JOIN CCIntTicker as temp2 on (temp2.exchangeName = temp1.exchangeName AND
														temp2.tradePair = temp1.tradePair AND
														FROM_UNIXTIME((UNIX_TIMESTAMP(temp2.recordTime)) +1209600) <= temp1.recordTime AND
                                                        temp2.askPriceUSD is not null)
group by temp1.exchangeName, temp1.tradePair, temp1.recordTime) t1 
LEFT JOIN CCIntTicker as t2 on (t2.exchangeName = t1.exchangeName AND
												t2.tradePair = t1.tradePair AND
												t2.recordTime = t1.baseGSPriceTime)
) t;

ALTER TABLE CCIntTickerWPriceDiffDel7 ADD INDEX exchangePair (exchangeName, tradePair, recordTime);

ALTER TABLE CCIntTickerWPriceDiffDel7 CHANGE COLUMN diff2Day diff2Wk FLOAT NULL;

select * from CCIntTickerWPriceDiffDel7 order by recordTime;

use pocu4;

CREATE TABLE CCIntTickerWPriceDiffDel8 (
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
    diff20Hr FLOAT NULL,
	diff1Day FLOAT NULL,
    diff2Day FLOAT NULL,
    diff2Wk FLOAT NULL
);


INSERT INTO CCIntTickerWPriceDiffDel8
select 
exchangeName, tradePair, askPriceUSD, askPriceBTC, recordTime, spikeStarts, diff2Hr,
diff4Hr, diff8Hr, diff16Hr, diff20Hr, diff1Day, diff2Day, diff2Wk from
(
select 
t1.exchangeName, t1.tradePair, t1.askPriceUSD, t1.askPriceBTC, 
t1.recordTime, t1.spikeStarts, t1.baseGSPriceTime, t1.diff2Hr, t1.diff4Hr, t1.diff8Hr, t1.diff16Hr,
t1.diff20Hr, t1.diff1Day, t1.diff2Wk,
(t1.askPriceUSD - t2.askPriceUSD)*100/t2.askPriceUSD as diff2Day
from
(
select 
temp1.exchangeName, temp1.tradePair, temp1.askPriceUSD, temp1.askPriceBTC, 
temp1.recordTime, temp1.spikeStarts, temp1.diff2Hr, temp1.diff4Hr, temp1.diff8Hr, temp1.diff16Hr,
temp1.diff20Hr, temp1.diff1Day, temp1.diff2Wk,
max(temp2.recordTime) as baseGSPriceTime
from CCIntTickerWPriceDiffDel7 as temp1
LEFT JOIN CCIntTicker as temp2 on (temp2.exchangeName = temp1.exchangeName AND
														temp2.tradePair = temp1.tradePair AND
														FROM_UNIXTIME((UNIX_TIMESTAMP(temp2.recordTime)) +172800) <= temp1.recordTime AND
                                                        temp2.askPriceUSD is not null)
group by temp1.exchangeName, temp1.tradePair, temp1.recordTime) t1 
LEFT JOIN CCIntTicker as t2 on (t2.exchangeName = t1.exchangeName AND
												t2.tradePair = t1.tradePair AND
												t2.recordTime = t1.baseGSPriceTime)
) t;

ALTER TABLE CCIntTickerWPriceDiffDel8 ADD INDEX exchangePair (exchangeName, tradePair, recordTime);
select count(*) from CCIntTickerWPriceDiffDel8;

use pocu4;

CREATE TABLE CCIntTickerWPriceDiffDel9 (
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
    diff20Hr FLOAT NULL,
	diff1Day FLOAT NULL,
    diff2Day FLOAT NULL,
    diff4Day FLOAT NULL,
    diff2Wk FLOAT NULL
);


INSERT INTO CCIntTickerWPriceDiffDel9
select 
exchangeName, tradePair, askPriceUSD, askPriceBTC, recordTime, spikeStarts, diff2Hr,
diff4Hr, diff8Hr, diff16Hr, diff20Hr, diff1Day, diff2Day, diff4Day, diff2Wk from
(
select 
t1.exchangeName, t1.tradePair, t1.askPriceUSD, t1.askPriceBTC, 
t1.recordTime, t1.spikeStarts, t1.baseGSPriceTime, t1.diff2Hr, t1.diff4Hr, t1.diff8Hr, t1.diff16Hr,
t1.diff20Hr, t1.diff1Day, t1.diff2Day, t1.diff2Wk,
(t1.askPriceUSD - t2.askPriceUSD)*100/t2.askPriceUSD as diff4Day
from
(
select 
temp1.exchangeName, temp1.tradePair, temp1.askPriceUSD, temp1.askPriceBTC, 
temp1.recordTime, temp1.spikeStarts, temp1.diff2Hr, temp1.diff4Hr, temp1.diff8Hr, temp1.diff16Hr,
temp1.diff20Hr, temp1.diff1Day, temp1.diff2Day, temp1.diff2Wk,
max(temp2.recordTime) as baseGSPriceTime
from CCIntTickerWPriceDiffDel8 as temp1
LEFT JOIN CCIntTicker as temp2 on (temp2.exchangeName = temp1.exchangeName AND
														temp2.tradePair = temp1.tradePair AND
														FROM_UNIXTIME((UNIX_TIMESTAMP(temp2.recordTime)) +345600) <= temp1.recordTime AND
                                                        temp2.askPriceUSD is not null)
group by temp1.exchangeName, temp1.tradePair, temp1.recordTime) t1 
LEFT JOIN CCIntTicker as t2 on (t2.exchangeName = t1.exchangeName AND
												t2.tradePair = t1.tradePair AND
												t2.recordTime = t1.baseGSPriceTime)
) t;

ALTER TABLE CCIntTickerWPriceDiffDel9 ADD INDEX exchangePair (exchangeName, tradePair, recordTime);
select count(*) from CCIntTickerWPriceDiffDel9;

use pocu4;

CREATE TABLE CCIntTickerWPriceDiffDel10 (
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
    diff20Hr FLOAT NULL,
	diff1Day FLOAT NULL,
    diff2Day FLOAT NULL,
    diff4Day FLOAT NULL,
    diff1Wk FLOAT NULL,
    diff2Wk FLOAT NULL
);


INSERT INTO CCIntTickerWPriceDiffDel10
select 
exchangeName, tradePair, askPriceUSD, askPriceBTC, recordTime, spikeStarts, diff2Hr,
diff4Hr, diff8Hr, diff16Hr, diff20Hr, diff1Day, diff2Day, diff4Day, diff1Wk, diff2Wk from
(
select 
t1.exchangeName, t1.tradePair, t1.askPriceUSD, t1.askPriceBTC, 
t1.recordTime, t1.spikeStarts, t1.baseGSPriceTime, t1.diff2Hr, t1.diff4Hr, t1.diff8Hr, t1.diff16Hr,
t1.diff20Hr, t1.diff1Day, t1.diff2Day, t1.diff4Day, t1.diff2Wk,
(t1.askPriceUSD - t2.askPriceUSD)*100/t2.askPriceUSD as diff1Wk
from
(
select 
temp1.exchangeName, temp1.tradePair, temp1.askPriceUSD, temp1.askPriceBTC, 
temp1.recordTime, temp1.spikeStarts, temp1.diff2Hr, temp1.diff4Hr, temp1.diff8Hr, temp1.diff16Hr,
temp1.diff20Hr, temp1.diff1Day, temp1.diff2Day, temp1.diff4Day, temp1.diff2Wk,
max(temp2.recordTime) as baseGSPriceTime
from CCIntTickerWPriceDiffDel9 as temp1
LEFT JOIN CCIntTicker as temp2 on (temp2.exchangeName = temp1.exchangeName AND
														temp2.tradePair = temp1.tradePair AND
														FROM_UNIXTIME((UNIX_TIMESTAMP(temp2.recordTime)) +604800) <= temp1.recordTime AND
                                                        temp2.askPriceUSD is not null)
group by temp1.exchangeName, temp1.tradePair, temp1.recordTime) t1 
LEFT JOIN CCIntTicker as t2 on (t2.exchangeName = t1.exchangeName AND
												t2.tradePair = t1.tradePair AND
												t2.recordTime = t1.baseGSPriceTime)
) t;

ALTER TABLE CCIntTickerWPriceDiffDel10 ADD INDEX exchangePair (exchangeName, tradePair, recordTime);
select count(*) from CCIntTickerWPriceDiffDel10;

CREATE TABLE CCIntTickerWPriceDiffNew11 (
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
    diff20Hr FLOAT NULL,
	diff1Day FLOAT NULL,
    diff2Day FLOAT NULL,
    diff4Day FLOAT NULL,
    diff1Wk FLOAT NULL,
    diff2Wk FLOAT NULL,
    diff4Wk FLOAT NULL
);


INSERT INTO CCIntTickerWPriceDiffNew11
select 
exchangeName, tradePair, askPriceUSD, askPriceBTC, recordTime, spikeStarts, diff2Hr,
diff4Hr, diff8Hr, diff16Hr, diff20Hr, diff1Day, diff2Day, diff4Day, diff1Wk, diff2Wk, diff4Wk from
(
select 
t1.exchangeName, t1.tradePair, t1.askPriceUSD, t1.askPriceBTC, 
t1.recordTime, t1.spikeStarts, t1.baseGSPriceTime, t1.diff2Hr, t1.diff4Hr, t1.diff8Hr, t1.diff16Hr,
t1.diff20Hr, t1.diff1Day, t1.diff2Day, t1.diff4Day, t1.diff1Wk, t1.diff2Wk,
(t1.askPriceUSD - t2.askPriceUSD)*100/t2.askPriceUSD as diff4Wk
from
(
select 
temp1.exchangeName, temp1.tradePair, temp1.askPriceUSD, temp1.askPriceBTC, 
temp1.recordTime, temp1.spikeStarts, temp1.diff2Hr, temp1.diff4Hr, temp1.diff8Hr, temp1.diff16Hr,
temp1.diff20Hr, temp1.diff1Day, temp1.diff2Day, temp1.diff4Day, temp1.diff1Wk, temp1.diff2Wk,
max(temp2.recordTime) as baseGSPriceTime
from CCIntTickerWPriceDiffDel10 as temp1
LEFT JOIN CCIntTicker as temp2 on (temp2.exchangeName = temp1.exchangeName AND
														temp2.tradePair = temp1.tradePair AND
														FROM_UNIXTIME((UNIX_TIMESTAMP(temp2.recordTime)) +2419200) <= temp1.recordTime AND
                                                        temp2.askPriceUSD is not null)
group by temp1.exchangeName, temp1.tradePair, temp1.recordTime) t1 
LEFT JOIN CCIntTicker as t2 on (t2.exchangeName = t1.exchangeName AND
												t2.tradePair = t1.tradePair AND
												t2.recordTime = t1.baseGSPriceTime)
) t;

ALTER TABLE CCIntTickerWPriceDiffNew11 ADD INDEX exchangePair (exchangeName, tradePair, recordTime);
select * from CCIntTickerWPriceDiffNew11 order by recordTime;

CREATE TABLE CCIntTickerOrderedNew (
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
	diff20Hr FLOAT NULL,
    diff1Day FLOAT NULL,
    diff2Day FLOAT NULL,
    diff4Day FLOAT NULL,
    diff1Wk FLOAT NULL,
    diff2Wk FLOAT NULL,
    diff4Wk FLOAT NULL
);

INSERT into CCIntTickerOrderedNew
select * from CCIntTickerWPriceDiffNew11 ORDER BY CONCAT(exchangeName, tradePair), recordTime;

ALTER TABLE CCIntTickerOrderedNew ADD INDEX exchangePair (exchangeName, tradePair, recordTime);


CREATE TABLE CCIntTickerGSTrackerNew (
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
	diff20Hr FLOAT NULL,
    diff1Day FLOAT NULL,
    diff2Day FLOAT NULL,
    diff4Day FLOAT NULL,
    diff1Wk FLOAT NULL,
    diff2Wk FLOAT NULL,
    diff4Wk FLOAT NULL,
    gsMarker FLOAT NULL,
    commonPtPrice FLOAT NULL
);

INSERT into CCIntTickerGSTrackerNew
select exchangeName, tradePair, askPriceUSD, askPriceBTC, recordTime, spikeStarts, 
diff2Hr, diff4Hr, diff8Hr, diff16Hr, diff20Hr, diff1Day, diff2Day, diff4Day, diff1Wk, diff2Wk, diff4Wk, 
gsMarker, commonPtPrice from 
(select *, 
(case 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff2Hr >35) 	 then 2 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff4Hr >35) 	 then 4 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff8Hr >35) 	 then 8 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff16Hr >35) 	 then 16 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff20Hr >35) 	 then 20 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff1Day >35) 	 then 24 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff2Day >35) 	 then 48 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff4Day >35) 	 then 96 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff1Wk >35) 	 then 168 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff2Wk >35) 	 then 336 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff4Wk >35) 	 then 672 
ELSE 0
END) as gsMarker,
(case 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff2Hr >35) 	 then askPriceUSD*100/(diff2Hr + 100) 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff4Hr >35) 	 then askPriceUSD*100/(diff4Hr + 100)  
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff8Hr >35) 	 then askPriceUSD*100/(diff8Hr + 100) 
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff16Hr >35) 	 then askPriceUSD*100/(diff16Hr + 100)
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff20Hr >35) 	 then askPriceUSD*100/(diff20Hr + 100)
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff1Day >35) 	 then askPriceUSD*100/(diff1Day + 100)  
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff2Day >35) 	 then askPriceUSD*100/(diff2Day + 100)  
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff4Day >35) 	 then askPriceUSD*100/(diff4Day + 100)  
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff1Wk >35) 	 then askPriceUSD*100/(diff1Wk + 100)  
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff2Wk >35) 	 then askPriceUSD*100/(diff2Wk + 100)  
 WHEN (@previousTradePair = CONCAT(exchangeName, tradePair)  AND diff4Wk >35) 	 then askPriceUSD*100/(diff4Wk + 100)  
ELSE 0
END) as commonPtPrice,
(@previousTradePair := CONCAT(exchangeName, tradePair)) as lastTradePair
from CCIntTickerOrderedNew
JOIN (select @previousTradePair := "none") t) t2;

ALTER TABLE CCIntTickerGSTrackerNew ADD INDEX exchangePair (exchangeName, tradePair);

select count(DISTINCT(CONCAT(exchangeName, tradePair))) from CCIntTickerGSTracker where gsMarker = 4;

select * from CCIntTickerGSTracker limit 12000;


CREATE TABLE CCIntTickerGSDataNew (
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
	diff20Hr FLOAT NULL,
    diff1Day FLOAT NULL,
    diff2Day FLOAT NULL,
    diff4Day FLOAT NULL,
    diff1Wk FLOAT NULL,
    diff2Wk FLOAT NULL,
    diff4Wk FLOAT NULL,
    gsMarker FLOAT NULL,
    commonPtPrice FLOAT NULL,
    diffCommonPt FLOAT NULL,
    gsTracker FLOAT NULL
);

insert into CCIntTickerGSDataNew
select exchangeName, tradePair, askPriceUSD, askPriceBTC, recordTime, spikeStarts, 
diff2Hr, diff4Hr, diff8Hr, diff16Hr, diff20Hr, diff1Day, diff2Day, diff4Day, diff1Wk, diff2Wk, diff4Wk, 
gsMarker, commonPtPrice, diffCommonPt, gsTracker from 
(select *,

(case 
	WHEN @previousTradePair = CONCAT(exchangeName, tradePair) AND gsMarker != 0 then @percDiffCommonPt := (askPriceUSD - commonPtPrice)/commonPtPrice*100
    WHEN @previousTradePair = CONCAT(exchangeName, tradePair) AND @commonPtPrice != 0 then @percDiffCommonPt := (askPriceUSD - @commonPtPrice)/@commonPtPrice*100
    WHEN false then @percDiffCommonPt := 0
END ) as diffCommonPt,

(case 
	WHEN @previousTradePair != CONCAT(exchangeName, tradePair) then @gsTrackerVar := 0
	WHEN @previousTradePair = CONCAT(exchangeName, tradePair) AND ((gsMarker != 0 AND @commonPtPrice = 0) OR (@commonPtPrice != 0 AND @percDiffCommonPt < 10)) then @gsTrackerVar := @gsTrackerVar +1	-- odd numbers are gradual spikes, even numbers are not
    ELSE @gsTrackerVar := @gsTrackerVar
END ) as gsTracker,

(case 
	WHEN @previousTradePair = CONCAT(exchangeName, tradePair) AND (@gsTrackerVar%2) != 0 AND  @commonPtPrice = 0 then @commonPtPrice := commonPtPrice
    WHEN @previousTradePair = CONCAT(exchangeName, tradePair) AND (@gsTrackerVar%2) = 0 AND @commonPtPrice != 0 then @commonPtPrice := 0
    WHEN @previousTradePair != CONCAT(exchangeName, tradePair) then @commonPtPrice := 0
    ELSE @commonPtPrice := @commonPtPrice
END ) as commonPtPriceVar,

@previousTradePair := CONCAT(exchangeName, tradePair) as exchTradePair
from CCIntTickerGSTrackerNew
JOIN (select @previousTradePair := "none", @commonPtPrice :=0, @percDiffCommonPt := 0, @gsTrackerVar := 0) t
)t2 ;

ALTER TABLE CCIntTickerGSDataNew ADD INDEX exchangePair (exchangeName, tradePair);


select * from CCIntTickerGSDataNew limit 12000;


CREATE TABLE CCIntTickerGSData2New (
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
	diff20Hr FLOAT NULL,
    diff1Day FLOAT NULL,
    diff2Day FLOAT NULL,
    diff4Day FLOAT NULL,
    diff1Wk FLOAT NULL,
    diff2Wk FLOAT NULL,
    diff4Wk FLOAT NULL,
    gsMarker FLOAT NULL,
    commonPtPrice FLOAT NULL,
    diffCommonPt FLOAT NULL,
    gsTracker FLOAT NULL,
    localMaxPrice FLOAT NULL,
    localMaxPriceDiff FLOAT NULL,
    localMaxPriceDiffRounded FLOAT NULL
);

insert into CCIntTickerGSData2New
select exchangeName, tradePair, askPriceUSD, askPriceBTC, recordTime, spikeStarts, 
diff2Hr, diff4Hr, diff8Hr, diff16Hr, diff20Hr, diff1Day, diff2Day, diff4Day, diff1Wk, diff2Wk, diff4Wk, 
gsMarker, commonPtPrice, diffCommonPt, gsTracker, localMaxPrice,  localMaxPriceDiff,
localMaxPriceDiffRounded from 
(select *,

(case 
	WHEN @previousTradePair = CONCAT(exchangeName, tradePair) AND (gsTracker%2) != 0 AND (@localMaxPriceDiff < askPriceUSD OR @localMaxPriceDiff = 0) then @localMaxPriceDiff := askPriceUSD
    WHEN @previousTradePair = CONCAT(exchangeName, tradePair) AND (gsTracker%2) != 0 AND @localMaxPriceDiff > askPriceUSD then @localMaxPriceDiff := @localMaxPriceDiff
	ELSE  @localMaxPriceDiff := 0
END ) as localMaxPrice,

(case 
	WHEN @previousTradePair = CONCAT(exchangeName, tradePair) AND (gsTracker%2) != 0 AND @localMaxPriceDiff !=0 then (askPriceUSD - @localMaxPriceDiff)/@localMaxPriceDiff*100
    ELSE 0
END) as localMaxPriceDiff,

ROUND(((askPriceUSD - @localMaxPriceDiff)/@localMaxPriceDiff*100)/10)*10 as localMaxPriceDiffRounded, 
@previousTradePair := CONCAT(exchangeName, tradePair) as exchTradePair

from CCIntTickerGSDataNew
JOIN (select @previousTradePair := "none", @localMaxPriceDiff := 0) t
)t2;

ALTER TABLE CCIntTickerGSData2New ADD INDEX exchangePair (exchangeName, tradePair);


select max(localMaxPriceDiffRounded) from CCIntTickerGSData2New where localMaxPriceDiffRounded !=0 and localMaxPriceDiffRounded < -30 group by exchangeName, tradePair, gsTracker order by max(localMaxPriceDiffRounded);


create table gsSpikeMetaDataNew (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
    gsTracker FLOAT NULL,
    preThresholdDurOrGSMarker FLOAT NULL,
	postThresholdDuration FLOAT NULL,
    totalDuration FLOAT NULL,
    minGSTime DATETIME NULL,
    maxGSTime DATETIME NULL,
    minSpikeTime DATETIME NULL,
    minGSPrice FLOAT NULL,
    maxGSPrice FLOAT NULL,
    netPercHike FLOAT NULL,
    commonPtPrice FLOAT NULL
);

INSERT INTO gsSpikeMetaDataNew
select t.exchangeName, t.tradePair, t3.gsTracker, t3.gsMarker, t.gsDuration, (t3.gsMarker + t.gsDuration), t.minGSTimeC, t.maxGSTimeC, t.minSpikeTimeC, t3.askPriceUSD as minGSPrice, t4.askPriceUSD as maxGSPrice, (t4.askPriceUSD - t3.commonPtPrice)*100/t3.commonPtPrice as netPercHike, t3.commonPtPrice from 
(
select t1.exchangeName, t1.tradePair, t1.gsDuration, t1.minGSTime as minGSTimeC, t1.maxGSTime as maxGSTimeC, t2.minSpikeTime as minSpikeTimeC from 
	(select exchangeName, tradePair, CONCAT(exchangeName, tradePair) as tp, 
	min(recordTime) as minGSTime, max(recordTime) as maxGSTime,
	ROUND(time_to_sec(timediff(max(recordTime) , min(recordTime))) / 3600, 2) as gsDuration
	from CCIntTickerGSDataNew where (gsTracker%2) != 0
	group by CONCAT(exchangeName, tradePair), gsTracker) as t1
	LEFT JOIN 
	(select CONCAT(exchangeName, tradePair) as tp, min(recordTime) as minSpikeTime from CCIntTickerGSDataNew 
	where spikeStarts=1 group by CONCAT(exchangeName, tradePair)) t2 
	on (t2.tp = t1.tp)
) t
	LEFT JOIN CCIntTickerGSDataNew t3 ON (t3.exchangeName = t.exchangeName AND
																	t3.tradePair = t.tradePair AND 
																	t3.recordTime = t.minGSTimeC)
                                                              
	LEFT JOIN CCIntTickerGSDataNew t4 ON (t4.exchangeName = t.exchangeName AND
																	t4.tradePair = t.tradePair AND 
																	t4.recordTime = t.maxGSTimeC)   
                                                                 
 -- where minGSTimeC <= minSpikeTimeC 
-- and ROUND(time_to_sec(timediff(minSpikeTimeC , minGSTimeC)) / 3600, 2) < 48 
-- and gsDuration > 6
;

ALTER TABLE gsSpikeMetaDataNew ADD INDEX exchangePair (exchangeName, tradePair);
select count(*) from gsSpikeMetaDataNew;


create table gsSpikeMetaDataNew2 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
    gsTracker FLOAT NULL,
    preThresholdDurOrGSMarker FLOAT NULL,
	postThresholdDuration FLOAT NULL,
    totalDuration FLOAT NULL,
    commonPtTime DATETIME NULL,
    minGSTime DATETIME NULL,
    maxGSTime DATETIME NULL,
    minSpikeTime DATETIME NULL,
    minGSPrice FLOAT NULL,
    maxGSPrice FLOAT NULL,
    netPercHike FLOAT NULL,
    commonPtPrice FLOAT NULL,
    relStdDev1WkPreGS FLOAT NULL,
    relVariance1WkPreGS FLOAT NULL,
    commonPtPreDiff FLOAT NULL,
    minGSRelDiff FLOAT NULL
);

INSERT INTO gsSpikeMetaDataNew2
select t1.exchangeName, t1.tradePair, t1.gsTracker, t1.preThresholdDurOrGSMarker, 
t1.postThresholdDuration, t1.totalDuration, 
FROM_UNIXTIME((UNIX_TIMESTAMP(t1.minGSTime)) - (preThresholdDurOrGSMarker*3600)) as commonPtTime, 
t1.minGSTime, t1.maxGSTime, t1.minSpikeTime, 
t1.minGSPrice, t1.maxGSPrice, t1.netPercHike, t1.commonPtPrice,
ROUND((STDDEV(t2.askPriceUSD)/AVG(t2.askPriceUSD)*100), 10) as relStdDev,
ROUND((VARIANCE(t2.askPriceUSD)/POW(AVG(t2.askPriceUSD), 2)*100), 10) as relVariance, 
ROUND((MAX(t2.askPriceUSD) - t1.commonPtPrice)/t1.commonPtPrice*100, 10) as commonPtPreDiff, -- gs commonPtPreDiff should not be a very high positive number to ensure the commonPt of a GS is not a sharp dip
ROUND((MAX(t2.askPriceUSD) - t1.minGSPrice)/t1.minGSPrice*100, 10) as minGSRelDiff -- gs minGSRelDiff should be not be a very high positive number to ensure the minimum 35% pt of a GS is higher than all points in the month and not just a spike back up from a previous dip
from gsSpikeMetaDataNew as t1
LEFT JOIN CCIntTickerGSDataNew as t2 ON (t2.exchangeName = t1.exchangeName AND
																	t2.tradePair = t1.tradePair AND
																	t2.recordTime <=  FROM_UNIXTIME((UNIX_TIMESTAMP(t1.minGSTime)) - (preThresholdDurOrGSMarker*3600)) AND
																	t2.recordTime >= FROM_UNIXTIME((UNIX_TIMESTAMP(t1.minGSTime)) - (preThresholdDurOrGSMarker*3600) - 28*24*3600)
																	)
-- where  t1.preThresholdDuration >=8 and t1.netPercHike > 25                                                                    
group by CONCAT(t1.exchangeName, t1.tradePair, t1.gsTracker)                                                                    
;

ALTER TABLE gsSpikeMetaDataNew2 ADD INDEX exchangePair (exchangeName, tradePair);


create table gsSpikeMetaDataNew3 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
    gsTracker FLOAT NULL,
    preThresholdDurOrGSMarker FLOAT NULL,
	postThresholdDuration FLOAT NULL,
    totalDuration FLOAT NULL,
    commonPtTime DATETIME NULL,
    minGSTime DATETIME NULL,
    maxGSTime DATETIME NULL,
    minSpikeTime DATETIME NULL,
    minGSPrice FLOAT NULL,
    maxGSPrice FLOAT NULL,
    netPercHike FLOAT NULL,
    commonPtPrice FLOAT NULL,
    maxFirst48hPrice FLOAT NULL,
    first48hmaxPercChange FLOAT NULL,
    relStdDev1WkPreGS FLOAT NULL,
    relVariance1WkPreGS FLOAT NULL,
    commonPtPreDiff FLOAT NULL,
    minGSRelDiff FLOAT NULL
);

INSERT INTO gsSpikeMetaDataNew3
select t1.exchangeName, t1.tradePair, t1.gsTracker, t1.preThresholdDurOrGSMarker, 
t1.postThresholdDuration, t1.totalDuration, 
t1.commonPtTime, t1.minGSTime, t1.maxGSTime, t1.minSpikeTime, 
t1.minGSPrice, t1.maxGSPrice, t1.netPercHike, t1.commonPtPrice,
max(t2.askPriceUSD) as maxFirst48hPrice, (max(t2.askPriceUSD)-t1.commonPtPrice)*100/t1.commonPtPrice as first48hmaxPercChange,
t1.relStdDev1WkPreGS, t1.relVariance1WkPreGS, t1.commonPtPreDiff, t1.minGSRelDiff
from gsSpikeMetaDataNew2 as t1
LEFT JOIN CCIntTickerGSDataNew as t2 ON (t2.exchangeName = t1.exchangeName AND
																	t2.tradePair = t1.tradePair AND
																	t2.recordTime >=  FROM_UNIXTIME((UNIX_TIMESTAMP(t1.minGSTime)) - (preThresholdDurOrGSMarker*3600)) AND
																	t2.recordTime <= FROM_UNIXTIME((UNIX_TIMESTAMP(t1.minGSTime)) - (preThresholdDurOrGSMarker*3600) + 48*3600)
																	)                                                                    
-- where  t1.preThresholdDuration >=8 and t1.netPercHike > 25                                                                    
group by CONCAT(t1.exchangeName, t1.tradePair, t1.gsTracker);

ALTER TABLE gsSpikeMetaDataNew3 ADD INDEX exchangePair (exchangeName, tradePair);

select * from gsSpikeMetaDataNew2 where  minGSPrice < 1000 order by minGSRelDiff desc;


create table gsSpikeMetaDataNew4 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
    gsTracker FLOAT NULL,
    preThresholdDurOrGSMarker FLOAT NULL,
	postThresholdDuration FLOAT NULL,
    totalDuration FLOAT NULL,
    commonPtTime DATETIME NULL,
    minGSTime DATETIME NULL,
    maxGSTime DATETIME NULL,
    minSpikeTime DATETIME NULL,
    minGSPrice FLOAT NULL,
    maxGSPrice FLOAT NULL,
    netPercHike FLOAT NULL,
    commonPtPrice FLOAT NULL,
    maxFirst48hPrice FLOAT NULL,
    first48hmaxPercChange FLOAT NULL,
    relStdDev1WkPreGS FLOAT NULL,
    relVariance1WkPreGS FLOAT NULL,
    commonPtPreDiff FLOAT NULL,
    minGSRelDiff FLOAT NULL,
    maxPricePostGS FLOAT NULL,
    maxPricePostGSTime DATETIME NULL,
    minGSMaxBuy FLOAT NULL,
    minGSMaxSell FLOAT NULL,
    maxGSMaxBuy FLOAT NULL,
    maxGSMaxSell FLOAT NULL
);

INSERT into gsSpikeMetaDataNew4
select t7.exchangeName, t7.tradePair, t7.gsTracker, t7.preThresholdDurOrGSMarker, 
t7.postThresholdDuration, t7.totalDuration, 
t7.commonPtTime, t7.minGSTime, t7.maxGSTime, t7.minSpikeTime, 
t7.minGSPrice, t7.maxGSPrice, t7.netPercHike, t7.commonPtPrice,
t7.maxFirst48hPrice, t7.first48hmaxPercChange,
t7.relStdDev1WkPreGS, t7.relVariance1WkPreGS, t7.commonPtPreDiff, t7.minGSRelDiff,
t7.maxPricePostGS, t7.maxPricePostGSTime, 
t7.minGSMaxBuy, t7.minGSMaxSell,
t8.totalBuyAmount as maxGSMaxBuy, t8.totalSellAmount as maxGSMaxSell
 from 
(
select t5.exchangeName, t5.tradePair, t5.gsTracker, t5.preThresholdDurOrGSMarker, 
t5.postThresholdDuration, t5.totalDuration, 
t5.commonPtTime, t5.minGSTime, t5.maxGSTime, t5.minSpikeTime, 
t5.minGSPrice, t5.maxGSPrice, t5.netPercHike, t5.commonPtPrice,
t5.maxFirst48hPrice, t5.first48hmaxPercChange,
t5.relStdDev1WkPreGS, t5.relVariance1WkPreGS, t5.commonPtPreDiff, t5.minGSRelDiff,
t5.minGSMaxBuy, t5.minGSMaxSell,
t5.maxPricePostGS, t6.recordTime as maxPricePostGSTime from
(
select t3.exchangeName, t3.tradePair, t3.gsTracker, t3.preThresholdDurOrGSMarker, 
t3.postThresholdDuration, t3.totalDuration, 
t3.commonPtTime, t3.minGSTime, t3.maxGSTime, t3.minSpikeTime, 
t3.minGSPrice, t3.maxGSPrice, t3.netPercHike, t3.commonPtPrice,
t3.maxFirst48hPrice, t3.first48hmaxPercChange,
t3.relStdDev1WkPreGS, t3.relVariance1WkPreGS, t3.commonPtPreDiff, t3.minGSRelDiff,
t3.minGSMaxBuy, t3.minGSMaxSell, max(t4.askPriceUSD) as maxPricePostGS
from 
(
select t1.exchangeName, t1.tradePair, t1.gsTracker, t1.preThresholdDurOrGSMarker, 
t1.postThresholdDuration, t1.totalDuration, 
t1.commonPtTime, t1.minGSTime, t1.maxGSTime, t1.minSpikeTime, 
t1.minGSPrice, t1.maxGSPrice, t1.netPercHike, t1.commonPtPrice,
t1.maxFirst48hPrice, t1.first48hmaxPercChange,
t1.relStdDev1WkPreGS, t1.relVariance1WkPreGS, t1.commonPtPreDiff, t1.minGSRelDiff,
max(t2.totalBuyAmount) as minGSMaxBuy, max(t2.totalSellAmount) as minGSMaxSell
from gsSpikeMetaDataNew3 as t1
LEFT JOIN openOrders15MinAvg as t2 ON (t2.exchangeName = t1.exchangeName AND
																	t2.tradePair = t1.tradePair AND
																	t2.recordTime >=  FROM_UNIXTIME((UNIX_TIMESTAMP(t1.minGSTime)) - 900) AND
																	t2.recordTime <= FROM_UNIXTIME((UNIX_TIMESTAMP(t1.minGSTime)) + 900 )
																	)                                                                    
-- where  t1.preThresholdDuration >=8 and t1.netPercHike > 25                                                                    
group by CONCAT(t1.exchangeName, t1.tradePair, t1.gsTracker)
) as t3
LEFT JOIN CCIntTickerGSDataNew as t4 ON (t4.exchangeName = t3.exchangeName AND
																	t4.tradePair = t3.tradePair AND
																	t4.recordTime >=  t3.minGSTime AND
                                                                    t4.recordTime <=  t3.maxGSTime
																	)                                                                    
-- where  t1.preThresholdDuration >=8 and t1.netPercHike > 25                                                                    
group by CONCAT(t3.exchangeName, t3.tradePair, t3.gsTracker)
) as t5 
LEFT JOIN CCIntTickerGSDataNew as t6 ON (t6.exchangeName = t5.exchangeName AND
																	t6.tradePair = t5.tradePair AND
																	t6.askPriceUSD =  t5.maxPricePostGS
																	)                                                                    
-- where  t1.preThresholdDuration >=8 and t1.netPercHike > 25                                                                    
group by CONCAT(t5.exchangeName, t5.tradePair, t5.gsTracker)
) as t7
LEFT JOIN openOrders15MinAvg as t8 ON (t8.exchangeName = t7.exchangeName AND
																	t8.tradePair = t7.tradePair AND
																	t8.recordTime =  t7.maxPricePostGSTime
																	)                                                                    
-- where  t1.preThresholdDuration >=8 and t1.netPercHike > 25                                                                    
group by CONCAT(t7.exchangeName, t7.tradePair, t7.gsTracker)
;

select * from gsSpikeMetaDataNew4;

ALTER TABLE gsSpikeMetaDataNew4 ADD INDEX exchangePair (exchangeName, tradePair);


create table gsSpikeMetaDataNew5 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
    symbol VARCHAR(20) NULL,
    gsTracker FLOAT NULL,
    preThresholdDurOrGSMarker FLOAT NULL,
	postThresholdDuration FLOAT NULL,
    totalDuration FLOAT NULL,
    commonPtTime DATETIME NULL,
    minGSTime DATETIME NULL,
    maxGSTime DATETIME NULL,
    minSpikeTime DATETIME NULL,
    minGSPrice FLOAT NULL,
    maxGSPrice FLOAT NULL,
    netPercHike FLOAT NULL,
    commonPtPrice FLOAT NULL,
    maxFirst48hPrice FLOAT NULL,
    first48hmaxPercChange FLOAT NULL,
    relStdDev1WkPreGS FLOAT NULL,
    relVariance1WkPreGS FLOAT NULL,
    commonPtPreDiff FLOAT NULL,
    minGSRelDiff FLOAT NULL,
    maxPricePostGS FLOAT NULL,
    maxPricePostGSTime DATETIME NULL,
    minGSMaxBuy FLOAT NULL,
    minGSMaxSell FLOAT NULL,
    maxGSMaxBuy FLOAT NULL,
    maxGSMaxSell FLOAT NULL
);

insert into gsSpikeMetaDataNew5
select t7.exchangeName, t7.tradePair, 
(case 
	WHEN exchangeName = "bittrex" then SUBSTRING_INDEX(tradePair, "-", -1)
    WHEN exchangeName = "cryptopia" then SUBSTRING_INDEX(tradePair, "/", 1)
	WHEN exchangeName = "hitBTC" and tradePair LIKE '%USD' then LEFT(tradePair, LENGTH(tradePair) - 3)
	WHEN exchangeName = "hitBTC" and tradePair LIKE '%ETH' then LEFT(tradePair, LENGTH(tradePair) - 3)
    WHEN exchangeName = "hitBTC" and tradePair LIKE '%BTC' then LEFT(tradePair, LENGTH(tradePair) - 3)
    WHEN exchangeName = "livecoin" then SUBSTRING_INDEX(tradePair, "/", 1)
    WHEN exchangeName = "novaexchange" then SUBSTRING_INDEX(tradePair, "_", -1)
    WHEN exchangeName = "yoBit" then SUBSTRING_INDEX(tradePair, "_", 1)
    WHEN exchangeName = "poloniex" then SUBSTRING_INDEX(tradePair, "_", -1)
END ) as symbol, 
t7.gsTracker, t7.preThresholdDurOrGSMarker, 
t7.postThresholdDuration, t7.totalDuration, 
t7.commonPtTime, t7.minGSTime, t7.maxGSTime, t7.minSpikeTime, 
t7.minGSPrice, t7.maxGSPrice, t7.netPercHike, t7.commonPtPrice,
t7.maxFirst48hPrice, t7.first48hmaxPercChange,
t7.relStdDev1WkPreGS, t7.relVariance1WkPreGS, t7.commonPtPreDiff, t7.minGSRelDiff,
t7.maxPricePostGS, t7.maxPricePostGSTime, 
t7.minGSMaxBuy, t7.minGSMaxSell, t7.maxGSMaxBuy, t7.maxGSMaxSell
from gsSpikeMetaDataNew4 as t7;

ALTER TABLE gsSpikeMetaDataNew5 ADD INDEX exchangePair (exchangeName, tradePair);


create table gsSpikeMetaDataNew6 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
    symbol VARCHAR(20) NULL,
    gsTracker FLOAT NULL,
    preThresholdDurOrGSMarker FLOAT NULL,
	postThresholdDuration FLOAT NULL,
    totalDuration FLOAT NULL,
    commonPtTime DATETIME NULL,
    minGSTime DATETIME NULL,
    maxGSTime DATETIME NULL,
    minSpikeTime DATETIME NULL,
    minGSPrice FLOAT NULL,
    maxGSPrice FLOAT NULL,
    netPercHike FLOAT NULL,
    commonPtPrice FLOAT NULL,
    maxFirst48hPrice FLOAT NULL,
    first48hmaxPercChange FLOAT NULL,
    relStdDev1WkPreGS FLOAT NULL,
    relVariance1WkPreGS FLOAT NULL,
    commonPtPreDiff FLOAT NULL,
	minGSRelDiff FLOAT NULL,
    maxPricePostGS FLOAT NULL,
    maxPricePostGSTime DATETIME NULL,
    minGSMaxBuy FLOAT NULL,
    minGSMaxSell FLOAT NULL,
    maxGSMaxBuy FLOAT NULL,
    maxGSMaxSell FLOAT NULL,
	volume24hUSD FLOAT NULL,
	marketCapUSD FLOAT NULL
);

insert into gsSpikeMetaDataNew6
select t7.exchangeName, t7.tradePair, t7.symbol, 
t7.gsTracker, t7.preThresholdDurOrGSMarker, 
t7.postThresholdDuration, t7.totalDuration, 
t7.commonPtTime, t7.minGSTime, t7.maxGSTime, t7.minSpikeTime, 
t7.minGSPrice, t7.maxGSPrice, t7.netPercHike, t7.commonPtPrice,
t7.maxFirst48hPrice, t7.first48hmaxPercChange,
t7.relStdDev1WkPreGS, t7.relVariance1WkPreGS, t7.commonPtPreDiff, t7.minGSRelDiff,
t7.maxPricePostGS, t7.maxPricePostGSTime, 
t7.minGSMaxBuy, t7.minGSMaxSell, t7.maxGSMaxBuy, t7.maxGSMaxSell,
t1.volume_24h_usd, t1.market_cap_usd
from gsSpikeMetaDataNew5 as t7

LEFT JOIN 
(select symbol, min(volume_24h_usd) as volume_24h_usd, min(market_cap_usd) as market_cap_usd
from marketCapNVolume group by symbol) 
as t1 ON (t1.symbol = t7.symbol) ;

ALTER TABLE gsSpikeMetaDataNew6 ADD INDEX exchangePair (exchangeName, tradePair);


create table gsSpikeMetaDataNew7 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
    symbol VARCHAR(20) NULL,
    gsTracker FLOAT NULL,
    preThresholdDurOrGSMarker FLOAT NULL,
	postThresholdDuration FLOAT NULL,
    totalDuration FLOAT NULL,
    commonPtTime DATETIME NULL,
    minGSTime DATETIME NULL,
    maxGSTime DATETIME NULL,
    minSpikeTime DATETIME NULL,
    minGSPrice FLOAT NULL,
    maxGSPrice FLOAT NULL,
    netPercHike FLOAT NULL,
    commonPtPrice FLOAT NULL,
    maxFirst48hPrice FLOAT NULL,
    first48hmaxPercChange FLOAT NULL,
    relStdDev1WkPreGS FLOAT NULL,
    relVariance1WkPreGS FLOAT NULL,
    commonPtPreDiff FLOAT NULL,
    minGSRelDiff FLOAT NULL,
    maxPricePostGS FLOAT NULL,
    maxPricePostGSTime DATETIME NULL,
    minGSMaxBuy FLOAT NULL,
    minGSMaxSell FLOAT NULL,
    maxGSMaxBuy FLOAT NULL,
    maxGSMaxSell FLOAT NULL,
	volume24hUSD FLOAT NULL,
	marketCapUSD FLOAT NULL,
    minTime95Perc DATETIME NULL,
    maxTime95Perc DATETIME NULL,
    netDaysMoreThan95Perc FLOAT NULL,
    netTimeWindowMoreThan95Perc FLOAT NULL,
    percNetDaysMoreThan95Perc FLOAT NULL
);

insert into gsSpikeMetaDataNew7
select 
exchangeName, tradePair, symbol, gsTracker, preThresholdDurOrGSMarker, 
postThresholdDuration, totalDuration, commonPtTime, minGSTime, maxGSTime, 
minSpikeTime, minGSPrice, maxGSPrice, netPercHike, commonPtPrice,
maxFirst48hPrice, first48hmaxPercChange, relStdDev1WkPreGS, 
relVariance1WkPreGS, commonPtPreDiff, minGSRelDiff, maxPricePostGS, maxPricePostGSTime, 
minGSMaxBuy, minGSMaxSell, maxGSMaxBuy, maxGSMaxSell, volume24hUSD, 
marketCapUSD, minTime95Perc, maxTime95Perc, netDaysMoreThan95Perc, 
netTimeWindowMoreThan95Perc, 
(netDaysMoreThan95Perc*100/netTimeWindowMoreThan95Perc) as percNetDaysMoreThan95Perc
from
(
select 
t7.exchangeName, t7.tradePair, t7.symbol, t7.gsTracker, t7.preThresholdDurOrGSMarker, 
t7.postThresholdDuration, t7.totalDuration, t7.commonPtTime, t7.minGSTime, t7.maxGSTime, 
t7.minSpikeTime, t7.minGSPrice, t7.maxGSPrice, t7.netPercHike, t7.commonPtPrice,
t7.maxFirst48hPrice, t7.first48hmaxPercChange, t7.relStdDev1WkPreGS, 
t7.relVariance1WkPreGS, t7.commonPtPreDiff, t7.minGSRelDiff,
t7.maxPricePostGS, t7.maxPricePostGSTime, 
t7.minGSMaxBuy, t7.minGSMaxSell, t7.maxGSMaxBuy, t7.maxGSMaxSell, t7.volume24hUSD, 
t7.marketCapUSD, min(t1.recordTime) as minTime95Perc, max(t1.recordTime) as maxTime95Perc, 
((count(*) -1)*15)/(60*24) as netDaysMoreThan95Perc, 
((UNIX_TIMESTAMP((max(t1.recordTime)))) - (UNIX_TIMESTAMP((min(t1.recordTime)))))/(3600*24) as netTimeWindowMoreThan95Perc

from gsSpikeMetaDataNew6 as t7
LEFT JOIN CCIntTickerGSDataNew as t1 ON (t1.exchangeName = t7.exchangeName AND
																	t1.tradePair = t7.tradePair AND
                                                                    t1.askPriceUSD >= (1.95*t7.commonPtPrice) AND
                                                                    t1.recordTime <= t7.maxGSTime AND
                                                                    t1.recordTime >= t7.minGSTime)
group by t7.exchangeName, t7.tradePair, t7.gsTracker) t
;
ALTER TABLE gsSpikeMetaDataNew7 ADD INDEX exchangePair (exchangeName, tradePair);


create table gsSpikeMetaDataNew8 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
    symbol VARCHAR(20) NULL,
    gsTracker FLOAT NULL,
    preThresholdDurOrGSMarker FLOAT NULL,
	postThresholdDuration FLOAT NULL,
    totalDuration FLOAT NULL,
    commonPtTime DATETIME NULL,
    minGSTime DATETIME NULL,
    maxGSTime DATETIME NULL,
    minSpikeTime DATETIME NULL,
    minGSPrice FLOAT NULL,
    maxGSPrice FLOAT NULL,
    netPercHike FLOAT NULL,
    commonPtPrice FLOAT NULL,
    maxFirst48hPrice FLOAT NULL,
    first48hmaxPercChange FLOAT NULL,
    relStdDev1WkPreGS FLOAT NULL,
    relVariance1WkPreGS FLOAT NULL,
    commonPtPreDiff FLOAT NULL,
    minGSRelDiff FLOAT NULL,
    maxPricePostGS FLOAT NULL,
    maxPricePostGSTime DATETIME NULL,
    minGSMaxBuy FLOAT NULL,
    minGSMaxSell FLOAT NULL,
    maxGSMaxBuy FLOAT NULL,
    maxGSMaxSell FLOAT NULL,
	volume24hUSD FLOAT NULL,
	marketCapUSD FLOAT NULL,
    minTime95Perc DATETIME NULL,
    maxTime95Perc DATETIME NULL,
    netDaysMoreThan95Perc FLOAT NULL,
    netTimeWindowMoreThan95Perc FLOAT NULL,
    percNetDaysMoreThan95Perc FLOAT NULL,
    minLocalMaxPriceDiffPreMax FLOAT NULL,
    minLocalMaxPriceDiffPostMax FLOAT NULL
);

insert into gsSpikeMetaDataNew8
select 
t3.exchangeName, t3.tradePair, t3.symbol, t3.gsTracker, t3.preThresholdDurOrGSMarker, 
t3.postThresholdDuration, t3.totalDuration, t3.commonPtTime, t3.minGSTime, t3.maxGSTime, 
t3.minSpikeTime, t3.minGSPrice, t3.maxGSPrice, t3.netPercHike, t3.commonPtPrice,
t3.maxFirst48hPrice, t3.first48hmaxPercChange, t3.relStdDev1WkPreGS, 
t3.relVariance1WkPreGS, t3.commonPtPreDiff, t3.minGSRelDiff, t3.maxPricePostGS, t3.maxPricePostGSTime, 
t3.minGSMaxBuy, t3.minGSMaxSell, t3.maxGSMaxBuy, t3.maxGSMaxSell, t3.volume24hUSD, 
t3.marketCapUSD, t3.minTime95Perc, t3.maxTime95Perc, t3.netDaysMoreThan95Perc, 
t3.netTimeWindowMoreThan95Perc, t3.percNetDaysMoreThan95Perc, t3.minLocalMaxPriceDiffPreMax,
min(t4.localMaxPriceDiff) as minLocalMaxPriceDiffPostMax
from
(
select 
t7.exchangeName, t7.tradePair, t7.symbol, t7.gsTracker, t7.preThresholdDurOrGSMarker, 
t7.postThresholdDuration, t7.totalDuration, t7.commonPtTime, t7.minGSTime, t7.maxGSTime, 
t7.minSpikeTime, t7.minGSPrice, t7.maxGSPrice, t7.netPercHike, t7.commonPtPrice,
t7.maxFirst48hPrice, t7.first48hmaxPercChange, t7.relStdDev1WkPreGS, 
t7.relVariance1WkPreGS, t7.commonPtPreDiff, t7.minGSRelDiff,
t7.maxPricePostGS, t7.maxPricePostGSTime, 
t7.minGSMaxBuy, t7.minGSMaxSell, t7.maxGSMaxBuy, t7.maxGSMaxSell, t7.volume24hUSD, 
t7.marketCapUSD, t7.minTime95Perc, t7.maxTime95Perc, t7.netDaysMoreThan95Perc, 
t7.netTimeWindowMoreThan95Perc, t7.percNetDaysMoreThan95Perc, 
min(t1.localMaxPriceDiff) as minLocalMaxPriceDiffPreMax

from gsSpikeMetaDataNew7 as t7
LEFT JOIN CCIntTickerGSData2New as t1 ON (t1.exchangeName = t7.exchangeName AND
																	t1.tradePair = t7.tradePair AND
                                                                    t1.recordTime >= t7.minGSTime AND
                                                                    t1.recordTime <= t7.maxPricePostGSTime
                                                                    )
group by t7.exchangeName, t7.tradePair, t7.gsTracker) t3

LEFT JOIN CCIntTickerGSData2New as t4 ON (t4.exchangeName = t3.exchangeName AND
																	t4.tradePair = t3.tradePair AND
                                                                    t4.recordTime >= t3.maxPricePostGSTime AND
                                                                    t4.recordTime <= t3.maxGSTime
                                                                    )
group by t3.exchangeName, t3.tradePair, t3.gsTracker;

ALTER TABLE gsSpikeMetaDataNew8 ADD INDEX exchangePair (exchangeName, tradePair);

select minLocalMaxPriceDiffPreMax from gsSpikeMetaDataNew8 where  minLocalMaxPriceDiffPreMax is not null and minLocalMaxPriceDiffPreMax < 0 order by  minLocalMaxPriceDiffPreMax; 
select minLocalMaxPriceDiffPostMax from gsSpikeMetaDataNew8 where  minLocalMaxPriceDiffPostMax is not null and minLocalMaxPriceDiffPostMax < 0 order by  minLocalMaxPriceDiffPostMax; 


create table gsSpikeMetaDataNew9 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
    symbol VARCHAR(20) NULL,
    gsTracker FLOAT NULL,
    preThresholdDurOrGSMarker FLOAT NULL,
	postThresholdDuration FLOAT NULL,
    totalDuration FLOAT NULL,
    commonPtTime DATETIME NULL,
    minGSTime DATETIME NULL,
    maxGSTime DATETIME NULL,
    minSpikeTime DATETIME NULL,
    minGSPrice FLOAT NULL,
    maxGSPrice FLOAT NULL,
    netPercHike FLOAT NULL,
    commonPtPrice FLOAT NULL,
    maxFirst48hPrice FLOAT NULL,
    first48hmaxPercChange FLOAT NULL,
    relStdDev1WkPreGS FLOAT NULL,
    relVariance1WkPreGS FLOAT NULL,
    commonPtPreDiff FLOAT NULL,
    minGSRelDiff FLOAT NULL,
    maxPricePostGS FLOAT NULL,
    maxPricePostGSTime DATETIME NULL,
    minGSMaxBuy FLOAT NULL,
    minGSMaxSell FLOAT NULL,
    maxGSMaxBuy FLOAT NULL,
    maxGSMaxSell FLOAT NULL,
	volume24hUSD FLOAT NULL,
	marketCapUSD FLOAT NULL,
    minTime95Perc DATETIME NULL,
    maxTime95Perc DATETIME NULL,
    netDaysMoreThan95Perc FLOAT NULL,
    netTimeWindowMoreThan95Perc FLOAT NULL,
    percNetDaysMoreThan95Perc FLOAT NULL,
    minLocalMaxPriceDiffPreMax FLOAT NULL,
    minLocalMaxPriceDiffPostMax FLOAT NULL,
    minGSLastHourPercChange FLOAT NULL
);

insert into gsSpikeMetaDataNew9
select 
t4.exchangeName, t4.tradePair, t4.symbol, t4.gsTracker, t4.preThresholdDurOrGSMarker, 
t4.postThresholdDuration, t4.totalDuration, t4.commonPtTime, t4.minGSTime, t4.maxGSTime, 
t4.minSpikeTime, t4.minGSPrice, t4.maxGSPrice, t4.netPercHike, t4.commonPtPrice,
t4.maxFirst48hPrice, t4.first48hmaxPercChange, t4.relStdDev1WkPreGS, 
t4.relVariance1WkPreGS, t4.commonPtPreDiff, t4.minGSRelDiff, t4.maxPricePostGS, t4.maxPricePostGSTime, 
t4.minGSMaxBuy, t4.minGSMaxSell, t4.maxGSMaxBuy, t4.maxGSMaxSell, t4.volume24hUSD, 
t4.marketCapUSD, t4.minTime95Perc, t4.maxTime95Perc, t4.netDaysMoreThan95Perc, 
t4.netTimeWindowMoreThan95Perc, t4.percNetDaysMoreThan95Perc, t4.minLocalMaxPriceDiffPreMax,
t4.minLocalMaxPriceDiffPostMax, (t4.minGSPrice - t2.askPriceUSD)/askPriceUSD*100
from 
(
select 
t3.exchangeName, t3.tradePair, t3.symbol, t3.gsTracker, t3.preThresholdDurOrGSMarker, 
t3.postThresholdDuration, t3.totalDuration, t3.commonPtTime, t3.minGSTime, t3.maxGSTime, 
t3.minSpikeTime, t3.minGSPrice, t3.maxGSPrice, t3.netPercHike, t3.commonPtPrice,
t3.maxFirst48hPrice, t3.first48hmaxPercChange, t3.relStdDev1WkPreGS, 
t3.relVariance1WkPreGS, t3.commonPtPreDiff, t3.minGSRelDiff, t3.maxPricePostGS, t3.maxPricePostGSTime, 
t3.minGSMaxBuy, t3.minGSMaxSell, t3.maxGSMaxBuy, t3.maxGSMaxSell, t3.volume24hUSD, 
t3.marketCapUSD, t3.minTime95Perc, t3.maxTime95Perc, t3.netDaysMoreThan95Perc, 
t3.netTimeWindowMoreThan95Perc, t3.percNetDaysMoreThan95Perc, t3.minLocalMaxPriceDiffPreMax,
t3.minLocalMaxPriceDiffPostMax, max(t1.recordTime) as lastRecorededTimeBeforeMinGS
from gsSpikeMetaDataNew8 as t3
LEFT JOIN CCIntTickerGSData2New as t1 ON (t1.exchangeName = t3.exchangeName AND
																	t1.tradePair = t3.tradePair AND
                                                                    t1.recordTime <= FROM_UNIXTIME((UNIX_TIMESTAMP(t3.minGSTime)) - 3600) AND
                                                                    t1.askPriceUSD IS NOT NULL
                                                                    )
group by t3.exchangeName, t3.tradePair, t3.gsTracker) t4

LEFT JOIN CCIntTickerGSData2New as t2 ON (t2.exchangeName = t4.exchangeName AND
																	t2.tradePair = t4.tradePair AND
                                                                    t2.recordTime = t4.lastRecorededTimeBeforeMinGS
                                                                    )
group by t4.exchangeName, t4.tradePair, t4.gsTracker
;

ALTER TABLE gsSpikeMetaDataNew9 ADD INDEX exchangePair (exchangeName, tradePair);


create table gsSpikeMetaDataNew10 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
    symbol VARCHAR(20) NULL,
    gsTracker FLOAT NULL,
    preThresholdDurOrGSMarker FLOAT NULL,
	postThresholdDuration FLOAT NULL,
    totalDuration FLOAT NULL,
    commonPtTime DATETIME NULL,
    minGSTime DATETIME NULL,
    maxGSTime DATETIME NULL,
    minSpikeTime DATETIME NULL,
    minGSPrice FLOAT NULL,
    maxGSPrice FLOAT NULL,
    netPercHike FLOAT NULL,
    commonPtPrice FLOAT NULL,
    maxFirst48hPrice FLOAT NULL,
    first48hmaxPercChange FLOAT NULL,
    relStdDev1WkPreGS FLOAT NULL,
    relVariance1WkPreGS FLOAT NULL,
    commonPtPreDiff FLOAT NULL,
    minGSRelDiff FLOAT NULL,
    maxPricePostGS FLOAT NULL,
    maxPricePostGSTime DATETIME NULL,
    minGSMaxBuy FLOAT NULL,
    minGSMaxSell FLOAT NULL,
    maxGSMaxBuy FLOAT NULL,
    maxGSMaxSell FLOAT NULL,
	volume24hUSD FLOAT NULL,
	marketCapUSD FLOAT NULL,
    minTime95Perc DATETIME NULL,
    maxTime95Perc DATETIME NULL,
    netDaysMoreThan95Perc FLOAT NULL,
    netTimeWindowMoreThan95Perc FLOAT NULL,
    percNetDaysMoreThan95Perc FLOAT NULL,
    minLocalMaxPriceDiffPreMax FLOAT NULL,
    minLocalMaxPriceDiffPostMax FLOAT NULL,
    minGSLastHourPercChange FLOAT NULL,
	preMinGS3HrPercChange FLOAT NULL
);

insert into gsSpikeMetaDataNew10
select 
t4.exchangeName, t4.tradePair, t4.symbol, t4.gsTracker, t4.preThresholdDurOrGSMarker, 
t4.postThresholdDuration, t4.totalDuration, t4.commonPtTime, t4.minGSTime, t4.maxGSTime, 
t4.minSpikeTime, t4.minGSPrice, t4.maxGSPrice, t4.netPercHike, t4.commonPtPrice,
t4.maxFirst48hPrice, t4.first48hmaxPercChange, t4.relStdDev1WkPreGS, 
t4.relVariance1WkPreGS, t4.commonPtPreDiff, t4.minGSRelDiff, t4.maxPricePostGS, t4.maxPricePostGSTime, 
t4.minGSMaxBuy, t4.minGSMaxSell, t4.maxGSMaxBuy, t4.maxGSMaxSell, t4.volume24hUSD, 
t4.marketCapUSD, t4.minTime95Perc, t4.maxTime95Perc, t4.netDaysMoreThan95Perc, 
t4.netTimeWindowMoreThan95Perc, t4.percNetDaysMoreThan95Perc, t4.minLocalMaxPriceDiffPreMax,
t4.minLocalMaxPriceDiffPostMax, t4.minGSLastHourPercChange, 
(t4.minGSPrice - t2.askPriceUSD)/askPriceUSD*100
from 
(
select 
t3.exchangeName, t3.tradePair, t3.symbol, t3.gsTracker, t3.preThresholdDurOrGSMarker, 
t3.postThresholdDuration, t3.totalDuration, t3.commonPtTime, t3.minGSTime, t3.maxGSTime, 
t3.minSpikeTime, t3.minGSPrice, t3.maxGSPrice, t3.netPercHike, t3.commonPtPrice,
t3.maxFirst48hPrice, t3.first48hmaxPercChange, t3.relStdDev1WkPreGS, 
t3.relVariance1WkPreGS, t3.commonPtPreDiff, t3.minGSRelDiff, t3.maxPricePostGS, t3.maxPricePostGSTime, 
t3.minGSMaxBuy, t3.minGSMaxSell, t3.maxGSMaxBuy, t3.maxGSMaxSell, t3.volume24hUSD, 
t3.marketCapUSD, t3.minTime95Perc, t3.maxTime95Perc, t3.netDaysMoreThan95Perc, 
t3.netTimeWindowMoreThan95Perc, t3.percNetDaysMoreThan95Perc, t3.minLocalMaxPriceDiffPreMax,
t3.minLocalMaxPriceDiffPostMax, t3.minGSLastHourPercChange, 
max(t1.recordTime) as lastRecorededTimeBeforeMinGS
from gsSpikeMetaDataNew9 as t3
LEFT JOIN CCIntTickerGSData2New as t1 ON (t1.exchangeName = t3.exchangeName AND
																	t1.tradePair = t3.tradePair AND
                                                                    t1.recordTime <= FROM_UNIXTIME((UNIX_TIMESTAMP(t3.minGSTime)) - 10800) AND
                                                                    t1.askPriceUSD IS NOT NULL
                                                                    )
group by t3.exchangeName, t3.tradePair, t3.gsTracker) t4

LEFT JOIN CCIntTickerGSData2New as t2 ON (t2.exchangeName = t4.exchangeName AND
																	t2.tradePair = t4.tradePair AND
                                                                    t2.recordTime = t4.lastRecorededTimeBeforeMinGS
                                                                    )
group by t4.exchangeName, t4.tradePair, t4.gsTracker
;

ALTER TABLE gsSpikeMetaDataNew10 ADD INDEX exchangePair (exchangeName, tradePair);

create table gsSpikeMetaDataNew11 (
	exchangeName VARCHAR(15) NULL,
	tradePair VARCHAR(20) NULL,
    symbol VARCHAR(20) NULL,
    gsTracker FLOAT NULL,
    preThresholdDurOrGSMarker FLOAT NULL,
	postThresholdDuration FLOAT NULL,
    totalDuration FLOAT NULL,
    commonPtTime DATETIME NULL,
    minGSTime DATETIME NULL,
    maxGSTime DATETIME NULL,
    minSpikeTime DATETIME NULL,
    minGSPrice FLOAT NULL,
    maxGSPrice FLOAT NULL,
    netPercHike FLOAT NULL,
    commonPtPrice FLOAT NULL,
    maxFirst48hPrice FLOAT NULL,
    first48hmaxPercChange FLOAT NULL,
    relStdDev1WkPreGS FLOAT NULL,
    relVariance1WkPreGS FLOAT NULL,
    commonPtPreDiff FLOAT NULL,
    minGSRelDiff FLOAT NULL,
    maxPricePostGS FLOAT NULL,
    maxPricePostGSTime DATETIME NULL,
    minGSMaxBuy FLOAT NULL,
    minGSMaxSell FLOAT NULL,
    maxGSMaxBuy FLOAT NULL,
    maxGSMaxSell FLOAT NULL,
	volume24hUSD FLOAT NULL,
	marketCapUSD FLOAT NULL,
    minTime95Perc DATETIME NULL,
    maxTime95Perc DATETIME NULL,
    netDaysMoreThan95Perc FLOAT NULL,
    netTimeWindowMoreThan95Perc FLOAT NULL,
    percNetDaysMoreThan95Perc FLOAT NULL,
    minLocalMaxPriceDiffPreMax FLOAT NULL,
    minLocalMaxPriceDiffPostMax FLOAT NULL,
    minGSLastHourPercChange FLOAT NULL,
	preMinGS3HrPercChange FLOAT NULL,
    timeOfMaxB4PreMinGS DATETIME NULL,
    percDiffMaxB4PreMinGS FLOAT NULL
);

insert into gsSpikeMetaDataNew11
select 
t4.exchangeName, t4.tradePair, t4.symbol, t4.gsTracker, t4.preThresholdDurOrGSMarker, 
t4.postThresholdDuration, t4.totalDuration, t4.commonPtTime, t4.minGSTime, t4.maxGSTime, 
t4.minSpikeTime, t4.minGSPrice, t4.maxGSPrice, t4.netPercHike, t4.commonPtPrice,
t4.maxFirst48hPrice, t4.first48hmaxPercChange, t4.relStdDev1WkPreGS, 
t4.relVariance1WkPreGS, t4.commonPtPreDiff, t4.minGSRelDiff, t4.maxPricePostGS, t4.maxPricePostGSTime, 
t4.minGSMaxBuy, t4.minGSMaxSell, t4.maxGSMaxBuy, t4.maxGSMaxSell, t4.volume24hUSD, 
t4.marketCapUSD, t4.minTime95Perc, t4.maxTime95Perc, t4.netDaysMoreThan95Perc, 
t4.netTimeWindowMoreThan95Perc, t4.percNetDaysMoreThan95Perc, t4.minLocalMaxPriceDiffPreMax,
t4.minLocalMaxPriceDiffPostMax, t4.minGSLastHourPercChange, t4.preMinGS3HrPercChange, 
min(t2.recordTime), (t4.maxPriceB4GS - t4.minGSPrice)/minGSPrice*100
from 
(
select 
t3.exchangeName, t3.tradePair, t3.symbol, t3.gsTracker, t3.preThresholdDurOrGSMarker, 
t3.postThresholdDuration, t3.totalDuration, t3.commonPtTime, t3.minGSTime, t3.maxGSTime, 
t3.minSpikeTime, t3.minGSPrice, t3.maxGSPrice, t3.netPercHike, t3.commonPtPrice,
t3.maxFirst48hPrice, t3.first48hmaxPercChange, t3.relStdDev1WkPreGS, 
t3.relVariance1WkPreGS, t3.commonPtPreDiff, t3.minGSRelDiff, t3.maxPricePostGS, t3.maxPricePostGSTime, 
t3.minGSMaxBuy, t3.minGSMaxSell, t3.maxGSMaxBuy, t3.maxGSMaxSell, t3.volume24hUSD, 
t3.marketCapUSD, t3.minTime95Perc, t3.maxTime95Perc, t3.netDaysMoreThan95Perc, 
t3.netTimeWindowMoreThan95Perc, t3.percNetDaysMoreThan95Perc, t3.minLocalMaxPriceDiffPreMax,
t3.minLocalMaxPriceDiffPostMax, t3.minGSLastHourPercChange, t3.preMinGS3HrPercChange, 
max(t1.askPriceUSD) as maxPriceB4GS
from gsSpikeMetaDataNew10 as t3
LEFT JOIN CCIntTickerGSData2New as t1 ON (t1.exchangeName = t3.exchangeName AND
																	t1.tradePair = t3.tradePair AND
                                                                    t1.recordTime <= FROM_UNIXTIME(UNIX_TIMESTAMP(t3.minGSTime)) AND
                                                                    t1.recordTime >= FROM_UNIXTIME(UNIX_TIMESTAMP(t3.commonPtTime)) AND
                                                                    t1.askPriceUSD IS NOT NULL
                                                                    )
group by t3.exchangeName, t3.tradePair, t3.gsTracker) t4

LEFT JOIN CCIntTickerGSData2New as t2 ON (t2.exchangeName = t4.exchangeName AND
																	t2.tradePair = t4.tradePair AND
                                                                    t2.askPriceUSD = t4.maxPriceB4GS
                                                                    )
group by t4.exchangeName, t4.tradePair, t4.gsTracker
;

ALTER TABLE gsSpikeMetaDataNew11 ADD INDEX exchangePair (exchangeName, tradePair);


--

select * from gsSpikeMetaDataNew11 as t1 
-- select * from gsSpikeMetaDataNew7 as t1 
/*
LEFT JOIN CCOpenOrdersGSData t2 ON (t2.exchangeName = t1.exchangeName AND
																	t2.tradePair = t1.tradePair AND
                                                                    t2.recordTime = t1.minGSTime)
*/
where t1.netPercHike >=100 and (t1.maxGSMaxBuy > 14 or  t1.minGSMaxBuy > 14) 
-- and t1.minGSLastHourPercChange < 24
and t1.symbol != 'BTC'  and t1.preThresholdDurOrGSMarker > 8  
and t1.minGSRelDiff < -8
and t1.preMinGS3HrPercChange < 22
-- and t1.preThresholdDurOrGSMarker <= 168
-- and t1.commonPtPreDiff < 25
-- and t1.minGSTime < t1.minSpikeTime
and t1.percDiffMaxB4PreMinGS <=0
order by  t1.minGSRelDiff ;
																
select * from gsSpikeMetaDataNew11 as t1 
-- select * from gsSpikeMetaDataNew7 as t1 
/*
LEFT JOIN CCOpenOrdersGSData t2 ON (t2.exchangeName = t1.exchangeName AND
																	t2.tradePair = t1.tradePair AND
                                                                    t2.recordTime = t1.minGSTime)
*/                                                                    
where t1.netPercHike <=35 and (t1.maxGSMaxBuy > 14 or  t1.minGSMaxBuy > 14) 
-- and t1.minGSLastHourPercChange < 24
and t1.symbol != 'BTC'  and t1.preThresholdDurOrGSMarker > 8 
and t1.minGSRelDiff < -8
and t1.preMinGS3HrPercChange < 22
-- and t1.preThresholdDurOrGSMarker <= 168
-- and t1.minGSTime < t1.minSpikeTime
-- and t1.commonPtPreDiff < 25
and t1.percDiffMaxB4PreMinGS <=0
and CONCAT(t1.exchangeName, t1.tradePair) not in 
(select CONCAT(exchangeName, tradePair) from gsSpikeMetaDataNew11
where netPercHike >=100 and (maxGSMaxBuy > 14 or  minGSMaxBuy > 14) 
and symbol != 'BTC'  and preThresholdDurOrGSMarker > 8
and minGSRelDiff < -8
and t1.preMinGS3HrPercChange < 22
and t1.percDiffMaxB4PreMinGS <=0
-- and t1.preThresholdDurOrGSMarker <= 168
-- and t1.commonPtPreDiff < 25
-- and t1.minGSTime < t1.minSpikeTime
order by  minGSRelDiff )
order by t1.netPercHike ;

select CONCAT(exchangeName, tradePair) from gsSpikeMetaDataNew7 where netPercHike >=100 and (maxGSMaxBuy > 20 or  minGSMaxBuy > 20) and symbol != 'BTC'  and preThresholdDurOrGSMarker > 16  and minGSRelDiff < 0 order by commonPtPreDiff;

select *, CONCAT(exchangeName, tradePair) from gsSpikeMetaDataNew7 where netPercHike <=35 and (maxGSMaxBuy > 20 or  minGSMaxBuy > 20) and symbol != 'BTC'  and preThresholdDurOrGSMarker > 16  and minGSRelDiff < 0 order by commonPtPreDiff 
and CONCAT(exchangeName, tradePair) not in 
(select CONCAT(exchangeName, tradePair) from gsSpikeMetaDataNew7 where netPercHike >=100 and (maxGSMaxBuy > 20 or  minGSMaxBuy > 20) and symbol != 'BTC'  and preThresholdDurOrGSMarker > 16  and minGSRelDiff < 0 order by commonPtPreDiff);

select * from gsSpikeMetaDataNew9 where CONCAT(exchangeName, tradePair) = 'bittrexBTC-VTC';

use pocu4;

--
