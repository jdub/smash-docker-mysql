# Smash MySQL on Docker for Mac

Cheesy, non-scientific performance test for MySQL on Docker for Mac. I wanted to compare the performance of MySQL with its datadir on the host vs. on the image.

## How to run the test

```
$ docker-compose up
```

It's as simple as that. After about 6 minutes you'll see a report that `sysbench_1 exited with code 0`.

To test with MySQL's datadir on the image, comment out the `volumes:` section in `docker-compose.yml` and execute the test again as above.

If you wish to repeat the test with datadir on host, make sure to delete the `data` directory to begin with a completely fresh database.

## Results

*Throughput:* With datadir on the host, sysbench completes more events over the 5 minute test run -- 8230.66 read/write requests per second to the image's 6609.84.

*Latency:* Although the maximum latency of datadir on host is nearly twice that of image, host's minimum, average, and 95th percentile are all substantially ahead.

### Benchmark platform

- MacBook Air 11" (2013)
- Docker for Mac 1.13.0 (15072) with default settings

### Observations

The CPU cores dedicated to Docker are fully utilised, with 16 threads active in the sysbench test.

When running with datadir on the image, there's a huge amount of SSD write activity (as shown in iStats Menus). With datadir on the host, there's very little visible SSD write activity. I suspect this is because the image is operating within the context of the Docker VM, and must ultimately write changes to its qcow2, while the host filesystem can make full use of the host's page cache. A more scientific test would sprinkle a bit of DTrace over the test rig to see how muchh is being written and by which moving part.

### datadir on host directory

```
OLTP test statistics:
    queries performed:
        read:                            1819664
        write:                           649746
        other:                           259899
        total:                           2729309
    transactions:                        129923 (433.04 per sec.)
    deadlocks:                           53     (0.18 per sec.)
    read/write requests:                 2469410 (8230.66 per sec.)
    other operations:                    259899 (866.26 per sec.)

Test execution summary:
    total time:                          300.0259s
    total number of events:              129923
    total time taken by event execution: 4799.2068
    per-request statistics:
         min:                                  3.29ms
         avg:                                 36.94ms
         max:                               1097.63ms
         approx.  95 percentile:              55.54ms

Threads fairness:
    events (avg/stddev):           8120.1875/93.70
    execution time (avg/stddev):   299.9504/0.01
```

### datadir on image

```
OLTP test statistics:
    queries performed:
        read:                            1461250
        write:                           521807
        other:                           208723
        total:                           2191780
    transactions:                        104348 (347.81 per sec.)
    deadlocks:                           27     (0.09 per sec.)
    read/write requests:                 1983057 (6609.84 per sec.)
    other operations:                    208723 (695.71 per sec.)

Test execution summary:
    total time:                          300.0160s
    total number of events:              104348
    total time taken by event execution: 4799.0546
    per-request statistics:
         min:                                  8.89ms
         avg:                                 45.99ms
         max:                                467.57ms
         approx.  95 percentile:              77.47ms

Threads fairness:
    events (avg/stddev):           6521.7500/96.30
    execution time (avg/stddev):   299.9409/0.01
```
