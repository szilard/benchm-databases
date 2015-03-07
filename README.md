
### Simple/basic/limited/incomplete benchmark for operations on tabular data

For structured/tabular/relational data most transformations for data analysis are based on a [few
primitives](https://github.com/hadley/dplyr). Computationally, aggregates and joins are taking the majority
of time. This project aims at a *minimal* benchmark of various tools 
(statistical software, databases etc.) for working with tabular data of moderately
large size (but still within the reach of interactive data analysis that is with response times
of a few seconds on commodity hardware).

#### Tools

The tools analysed are:

1. Statistical software: R (dplyr, data.table) and Python (pandas)
2. Databases (MySQL, Postgres)
3. Analytical databases (3 MPP/columnar stores)
4. Big data systems (Hive, Impala, Spark)

All but the analytical databases are open source. The analytical database have free (community) editions
or unexpensive cloud offerings. 

R/Python operate in memory and can integrate the basic tabular operations
with reach visualization, statistical modeling etc. On the other hand, they are limited to data sizes
that fit in RAM, run single-threaded, and unlike the other systems do not have a query optimizer.

MySQL/Postgres have been designed for mixed OLTP/analytical loads and any given query runs
on one processor core only (though the database can use multiple cores to run different queries).

The analytical databases and the "big data" systems can scale-out to multiple nodes. The analytical
databases have shared-nothing architecture, columnar storage, compression and are specifically
designed for large aggregations and joins.

Hive/Spark are based on the map-reduce paradigm, SQL operations are translated to 
map/shuffle/reduce tasks (Hive generates traditional Hadoop jobs, while Spark leverages in-memory
architecture). Impala uses MPP-like technology to query data in HDFS (Hadoop's distributed file system).


#### Data

The data is randomly generated: one table of 100 million rows for aggregation
(1 million groups) and another table of 1 million rows for the join with the first table.
(The larger table is of GB size.)


#### Hardware

All tests have been performed on a 8-core commodity server running Ubuntu 14.04 and 
with plenty of RAM (64GB) for the tasks. All queries have been run 2 times and the second
time was recorded (warm run). In this case various caching mechanism come into play and data is
already in RAM, therefore the disks used do not play a role.

While I'm a great fan of reproducibility, in this benchmark I'm more interested in orders
of magnitude and not strict precision. With some more work one can create install and test
scripts and run them on a specific EC2 instance.

The software tools have been installed using just standard instructions and no special tuning 
(with a few exceptions as noted).


#### Limitations




