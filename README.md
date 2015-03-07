
### Simple/basic/limited/incomplete benchmark for operations on tabular data

For structured/tabular/relational/tidy data most transformations for data analysis are based on a [few
primitives](https://github.com/hadley/dplyr). Aggregates and joins are taking computationally the majority
of time. This project aims at a *minimal* benchmark of various tools 
(statistical software, databases etc.) for working with tabular data of moderately
large size (but still within the reach of interactive data analysis with response times
of a few seconds on standard hardware).

The tools analysed are:

1. Statistical software: R (dplyr, data.table) and Python (pandas)
2. Databases (MySQL, Postgres)
3. Analytical databases (3 MPP/columnar stores)
4. Big data systems (Hive, Impala, Spark)

The data is randomly generated: one table of 100 million rows for aggregation
(1 million groups) and another table of 1 million rows for the join with the first table.
(The larger table is of GB size.)



