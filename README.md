
### Simple/basic/limited/incomplete benchmark for operations on tabular data

For structured/tabular/relational/tidy data most transformations for data analysis are based on a [few
primitives](https://github.com/hadley/dplyr). The computationally most demanding two operations are
aggregates and joins. This project aims at a *minimal* benchmark of various tools 
(statistical software, databases etc.) for working with tabular data of some moderately
large size (but still within the reach of interactive data analysis with response times
of a few seconds on a standard server or even a laptop).

The tools analysed are:
1. Statistical software: R (dplyr, data.table) and Python (pandas)
2. Databases (MySQL, Postgres)
3. Analytical databases (3 MPP/columnar stores)
4. Big data systems (Hive, Impala, Spark)




