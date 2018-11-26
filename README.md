# autominer
bash script for automatically mining cryptocurrency with multiple instances of ccminer

Instructions:

1. Place this script in a directory (okay, you've checked it out, so this one will do).
2. Checkout ccminer source and build it.
3. Copy to ccminer to this directory.
4. Find as many forks as you can and copy each version of ccminer to this directory, changing the name as you go eg. cp ../ccminer-xevan/ccminer ccminer
5. Run ./autopool.sh specifying the pool, your wallet ID and optionally the currency.
6. You will get a hashrates.ini for all the algos you can mine. Edit this file.
7. For each algo, it will tell you the command to run the binary.  Copy & paste the command into the shell.
8. As the work progresses, you will see the hashrate.  Enter this in terms of MH/s (so if it's kH/s, divide by 1000).
9. After doing this for each algo, save the file.
10. Run ./autopool.sh as in step 5, this time it will run all your ccminers in the background.

You can also add a cpuminer into the mix for non-GPU coins (not quite working yet, still in progress).

To stop mining, kill all the miners.  Easy way to do this, type ccminer-*

Fine-tuning- If a miner doesn't work on a particular algo or isn't as fast as another, edit its ini file eg. decred.ini & delete the miners you don't want to run.
