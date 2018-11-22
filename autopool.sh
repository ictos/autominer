#!/bin/sh
if [ $1 ]
then
    URL=$1
    if [ $2 ]
    then
	WALLET=$2
	if [ $3 ]
	then
	    BTC=$3
	else
	    BTC=BTC
	fi
    else
	WALLET=17W8QC4StQ73c39T35Jbzsz6Ku9E987ryH
	BTC=BTC
    fi
else
    URL=www.ahashpool.com
    WALLET=17W8QC4StQ73c39T35Jbzsz6Ku9E987ryH
    BTC=BTC
fi
STRATUM=$(echo $URL|sed 's/.*\/\///;s/[a-z]*\.//;s/:.*//;s/\/.*//')
echo stratum: $STRATUM $STRATUM
if [ $STRATUM = blazepool.com ]
then
    curl -L $URL/status|tr '{' '\n' |sed 's/.*{//;s/}//g;s/name/algo/;s/"coins.*//'|sort|uniq > $STRATUM.inf
else
    curl -L $URL/api/currencies|sed 's/.*{//;s/}//g;s/name.*//'|sort|uniq > $STRATUM.inf
fi
PASS=ID=t5l,c=$BTC
for RATE in $(grep -v TBD hashrates.ini)
do
    ALGO=$(echo $RATE|sed 's/=.*//')
    if grep $ALGO $STRATUM.inf
    then
	PASS=$PASS,$RATE
    else
	echo $STRATUM does not support $ALGO
    fi
done
echo $PASS
sleep 1
for LINE in $(grep algo $STRATUM.inf)
do
    echo $LINE
    ALGO=$(echo $LINE|sed 's/.*algo":"//;s/".*//')
    PORT=$(echo $LINE|sed 's/.*port"://;s/,.*//')

    if [ $STRATUM = zergpool.com ]
    then
	STRATUMURL=stratum+tcp://mine.$STRATUM:$PORT
    elif [ $STRATUM = yiimp.eu ]
    then
	STRATUMURL=stratum+tcp://$STRATUM:$PORT
    elif [ $STRATUM = hashrefinery.com ]
    then
	STRATUMURL=stratum+tcp://$ALGO.us.$STRATUM:$PORT
    else
	STRATUMURL=stratum+tcp://$ALGO.mine.$STRATUM:$PORT
    fi

    if echo $PASS|grep ,$ALGO=
    then
	if [ -e $ALGO.ini ]
	then
	    REALMINER=$(head -n 1 $ALGO.ini)
	else
	    for MINER in $(ls ccminer*)
	    do
		
		if ./$MINER --help|grep $ALGO
		then
		    #./$MINER -a $ALGO -o $STRATUMURL -u $WALLET -p $PASS -R 120 &
		    echo $MINER >> $ALGO.ini
		    REALMINER=$MINER
		    #break
		    echo $MINER usable for $ALGO
		else
		    echo $MINER not usable for $ALGO
		fi
	    done
	fi
	#./$MINER -a $ALGO -o $STRATUMURL -u $WALLET -p $PASS -R 120 &
	./$REALMINER -a $ALGO -o $STRATUMURL -u $WALLET -p $PASS -R 120 >$ALGO-$REALMINER.log &
    else
	if grep $ALGO hashrates.ini
	then
	    echo Still need to fix $ALGO
	else
	    FOUND=0
	    for MINER in $(ls ccminer*)
	    do
		if ./$MINER --help|grep $ALGO
		then
		    echo $ALGO=TBD,$MINER,$STRATUM >>hashrates.ini
		    FOUND=1
		    break
		fi
	    done
	    if [ !$FOUND ]
	    then
		if grep $ALGO nominer.log
		then
		    echo No miner for $ALGO
		else
		    echo $ALGO=$STRATUM >> nominer.log
		fi
	    fi
	fi
	if ./cpuminer --help|grep $ALGO
	then
	    ./cpuminer -a $ALGO -o $STRATUMURL -u $WALLET -t 1 >$ALGO-cpu.log 2>$ALGO.err &
	fi
    fi
done
