
### Simple/basic/limited/incomplete benchmark for operations on tabular data (aggregates and joins)

For structured/tabular/relational data most transformations for data analysis are based on a few
primitives. Computationally, aggregates and joins are taking the majority
of time. This project aims at a *minimal* benchmark of various tools 
(statistical software, databases etc.) for working with tabular data of moderately
large sizes (but still within the reach of interactive data analysis - response times
of a few seconds on commodity hardware).


#### Tools

The tools analysed are:

1. Statistical software: R (dplyr, data.table) and Python (pandas)
2. Databases (MySQL, PostgreSQL)
3. Analytical databases (3 MPP/columnar stores)
4. Big data systems (Hive, Impala, Spark)

All but the analytical databases are open source. The analytical databases have free (community) editions
or unexpensive cloud offerings. 

R/Python operate in memory and can integrate the tabular operations
with rich visualization, statistical modeling etc. On the other hand, they are limited to data sizes
that fit in RAM, run single-threaded, and unlike the other systems do not have a query optimizer.

MySQL/PostgreSQL have been designed for mixed OLTP/analytical workloads and while 
the database can use multiple cores to run different queries, any given query runs
on one processor core only.

The analytical databases and the "big data" systems can scale-out to multiple nodes (and use all cores on them). 
The analytical (MPP) databases have parallel/shared-nothing architecture, columnar storage, compression and are specifically
designed for large aggregations and joins.

Hive/Spark are based on the map-reduce paradigm, SQL operations are translated to 
map/shuffle/reduce primitives (Hive generates traditional Hadoop jobs, while Spark leverages in-memory
architecture). Impala uses MPP-like technology to query data in HDFS (Hadoop's distributed file system).


#### Data

The data is [randomly generated](https://github.com/szilard/benchm-databases/blob/master/gen-data.txt): 
one table `d` (`x` integer, `y` float) of 100 million rows for aggregation
(`x` takes 1 million distinct values) and another table `dm` (`x` integer) of 1 million rows for the join only.
(The larger table `d` is of ~2GB size in the CSV format and results in ~1GB usage when loaded in database or
read in memory.)


#### Transformations

SQL query for aggregation:

```
select x, avg(y) as ym 
from d 
group by x
order by ym desc 
limit 5;
```

and for join:

```
select count(*) as cnt 
from d
inner join dm on d.x = dm.x;
```


#### Setup

The tests have been performed on a m3.2xlarge EC2 instance (8 cores, 30GB RAM) running Ubuntu 14.04. 
The queries have been run 2 times and the second
time was recorded (warm run). In this case various caching mechanisms come into play and the data is
effectively in RAM.

While I'm a great fan of reproducibility, in this benchmark I'm more interested in orders
of magnitude and not strict precision and exact reproducibility. With some more work one can create install and test
scripts that can run in a fully automated fashion for complete reproducibility.

The software tools have been installed using standard instructions with no tuning 
(with a few exceptions as noted). For Hive/Impala Amazon's EMR was used to avoid a more ellaborate installation.

The following running times have been measured:

1. For R/Python data has been read from csv file and then aggregates/joins happen in memory.
2. For MySQL/Postgres and the analytical databases, the data has to be loaded first into the database, and only then 
can one run queries.
3. For the Hadoop-based systems the data has to be copied into HDFS (much faster than loading it to a database); 
optionally it can be transformed into a columnar format (such as parquet). Queries can run readily.



#### Limitations

This is far from a comprehensive benchmark. It is my attempt to *quickly* get an idea of the order
of magnitude of running times for aggregations and joins on datasets of sizes of interest to *me* at the moment. 

The results are expected to vary with hardware, tuning, and likely even more with dataset size, 
dataset structure, or the number of nodes for the scale-out systems etc. Perhaps the strongest
critique against the general relevance of this benchmark could be that it uses a certain
data size and structure only, instead of examining a variety of.

I'm not looking in detail either at the scaling by the number of nodes for the 
big data systems as I'm primarily concerned with the efficiency on a single or a small number of nodes.

In the tests the only computation running on the system is the target query, therefore I'm not
studying the behavior in function of the load (e.g. the number of concurrent queries running on the system).

Finally, one might say that queries in practice are complex and the running times depend not only 
on how fast are these primitives, but also on how the query optimizer can deal with complexity. Again,
a comprehensive SQL benchmark is out of the scope here (but see e.g. TPC-DS).



#### Results

(times in seconds)

|  Type      | System           |  Load/Read    |   Aggregation  |   Join   |
| ---------- | ---------------- | ------------- | -------------- | -------- |
|  Stats     | R DT             |   30          |       5.5      |    6.5   |
|  Stats     | R DT key         |   35          |       1.3      |    1.7   |
|  Stats     | R dplyr          |   30          |       45       |    40    |
|  Stats     | Py pandas        |   30          |       8        |    25    |
|  DB        | MySQL MyISAM     |   40          |       45       |    470   |  
|  DB        | MySQL InnoDB     |   430         |       70       |    140   |
|  DB        | PostgreSQL       |   120         |       175      |    55    |
|  MPP       | MPP-1            |   70          |       0.5      |    2.5   |
|  MPP       | MPP-2            |   130         |       9        |    4     |
|  MPP       | MPP-3            |   130         |       6.5      |    15    |
|  Big Data  | Hive             |   20          |       250      |    80    |
|  Big Data  | Impala           |   20          |       25       |    15    |

![plots](https://github.com/szilard/benchm-databases/blob/master/plot.png)

| System    | Aggr 1-node | Aggr 5-node | Join 1-node | Join 5-node |
| --------- | ----------- | ----------- | ----------- | ----------- |
| Hive      |    250      |   160       |    80       |     50      |
| Impala    |    25       |   16        |    15       |     10      |


#### Discussions

It seems that for data manipulation with ~100-million rows / ~1GB datasets MPP databases
are the fastest, next statistical software, then traditional databases and finally big data
systems (see graph above).

The largest surprize (to me) is that traditional databases (MySQL/PostgreSQL) perform so poorly
at this size. 

Naturally, analytical databases are the fastest. Even on 1 node, their columnar architecture and
the features that come with it (efficient binary storage format, compression) along with the 
ability to process a query on multiple processor cores are ideal for the task.

Statistical software fairs pretty well. While not able to use multiple cores and no query planning,
the data is in RAM in a format that makes processing fast. (For the primitives studied query
planning does not play an important role such as for complex queries built using these primitives.)

As an MPP-like tool but with data stored in Hadoop, Impala achieves higher performance than traditional
Hadoop tools, but it is significantly slower than the full MPPs that can marshall their data as they 
please. 

While traditional databases like MySQL/PostgreSQL aim to be reasonable for both OLTP and analytical 
workloads, it comes as a surprize that even for 1GB sizes (which in today's terms is not large at all)
they perform so poorly.

Finally, it is no surprize that Hive (which generates traditional Hadoop map-reduce jobs) is the slowest, 
though the order of magnitude (100x vs analytical databases) is surprizing a bit.

For ever larger datasets, statistical software will run out of memory, while traditional databases
seem to become prohibitively slow. MPPs and big data systems can scale-out to multiple nodes, though 
the speed advantage of MPPs seems so large that it's hard to imagine anything but extreme data sizes
when the big data systems can overcome the MPPs.



