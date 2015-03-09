
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

MySQL/Postgres have been designed for mixed OLTP/analytical workloads but any given query runs
on one processor core only (though the database can use multiple cores to run different queries).

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

All tests have been performed on a 8-core box running Ubuntu 14.04 and 
with plenty of RAM (64GB) for the tasks. All queries have been run 2 times and the second
time was recorded (warm run). In this case various caching mechanisms come into play and data is
already in RAM, therefore the disks (standard or SSD) do not play a role.

While I'm a great fan of reproducibility, in this benchmark I'm more interested in orders
of magnitude and not strict precision and exact reproducibility. With some more work one can create install and test
scripts and run them on a specific EC2 instance for complete reproducibility.

The software tools have been installed using standard instructions with no tuning 
(with a few exceptions as noted).

The following running times have been measured:

1. For R/Python data has been read from csv file and then aggregates/joins happen in memory.
2. For MySQL/Postgres and the analytical databases, the data has to be loaded first into the database, and only then 
can one run queries.
3. For the Hadoop-based systems the data has to be copied into HDFS (much faster than loading it to a database); 
optionally it can be transformed into a columnar format (such as parquet). Queries can run readily.



#### Limitations

This is far from a comprehensive benchmark. It is my attempt to *quickly* get an idea of the order
of magnitude of running times for aggregations and joins on datasets of sizes of interest to *me* at the moment. 

The results are expected to vary with hardware, tuning, and even more with dataset size, 
dataset structure, or the number nodes for the scale-out systems etc. (Perhaps the strongest
critique against the relevance of this benchmark would say why this specific dataset? Why not
vary the size/structure?)

I also specifically want to avoid (at least for now) looking at scaling by number of nodes for the 
scale-out systems. I'm primarily concerned with efficiency on a single (or a small number of nodes).

In the tests the only computation running on the system is the target query, therefore I'm not
studying the behavior in function of the load (e.g. the number of concurrent queries running on the system).

Finally, one might say that queries in practice are complex and the running times depend not only 
on how fast are these primitives, but also on how the query optimizer can deal with complexity. Again,
a comprehensive SQL benchmark is out of the scope here.



#### Results

(times in seconds)

| type | system           |  load/read    |   aggregation  |   join   |
| ---- | ---------------- | ------------- | -------------- | -------- |
|  1   | R data.table     |   30          |       20       |    15    |
|  1   | R data.table key |   45          |       2        |    3     |
|  1   | R dplyrm         |   30          |       70       |    60    |
|  1   | Python pandas    |   40          |       20       |    50    |
|  2   | MySQL MyISAM     |   50          |       70       |    600   |  
|  2   | MySQL InnoDB     |   1500        |       100      |    200   |
|  2   | PostgreSQL       |   120         |       350      |    80    |
|  3   | Analytical DB-1  |   100         |       1        |    2     |
|  3   | Analytical DB-2  |   150         |       10       |    25    |


#### Discussions





