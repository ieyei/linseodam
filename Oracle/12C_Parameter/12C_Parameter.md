
# Optimizer with Oracle Database 12c

## What is it?

>**Oracle 12c Parameter.**
>
>- **OPTIMIZER_ADAPTIVE_FEATURES (Default:TRUE)**
>
>*OPTIMIZER_ADAPTIVE_FEATURES enables or disables all of the adaptive optimizer features, including adaptive plan (adaptive join methods and bitmap pruning), automatic re-optimization, SQL plan directives, and adaptive distribution methods.*
>
>- **OPTIMIZER_ADAPTIVE_REPORTING_ONLY (Default:FALSE)**
>
> *OPTIMIZER_ADAPTIVE_REPORTING_ONLY controls reporting-only mode for adaptive optimizatons.*
>
> *When OPTIMIZER_ADAPTIVE_REPORTING_ONLY is set to FALSE, reporting-only mode is off, and the adaptive optimizations are enabled as usual.*
>
> *When OPTIMIZER_ADAPTIVE_REPORTING_ONLY is set to TRUE, adaptive optimizations run in reporting-only mode. With this setting, the information required for an adaptive optimization is gathered, but no action is taken to change the plan. For instance, an adaptive plan will always choose the default (optimizer-chosen) plan, but information is collected on what plan to adapt to in non-reporting mode.*
>
>- **_OPTIMIZER_UNNEST_SCALAR_SQ (Default:TRUE)**
>
> *_OPTIMIZER_UNNEST_SCALAR_SQ enables unnesting of scalar subquery.*


## Table of Contents

- [What is it?] (#what-is-it)
- [Test Environment] (#test-environment)
- Test Cases :
      - [Case1] (#case1)
      - [Case2] (#case2)
      - [Stress Test] (#stress-test)
      - [Case3] (#case3)
- [About Video Resources] (#about-video-resources)

## Test Cases

- optimizer_adaptive_features = TRUE ,    optimizer_adaptive_reporting_only = FALSE
- optimizer_adaptive_features = FALSE ,   optimizer_adaptive_reporting_only = TRUE
- _optimizer_unnest_scalar_sq

## Test Environment
```sql
SQL> SELECT * FROM V$VERSION;

BANNER                                                                               CON_ID
-------------------------------------------------------------------------------- ----------
Oracle Database 12c Enterprise Edition Release 12.1.0.2.0 - 64bit Production              0
PL/SQL Release 12.1.0.2.0 - Production                                                    0
CORE    12.1.0.2.0      Production                                                        0
TNS for 64-bit Windows: Version 12.1.0.2.0 - Production                                   0
NLSRTL Version 12.1.0.2.0 - Production                                                    0
```

## Case1
[1.Create Table](sql/CREATE_ADAPTIVE.sql)

2.Parameter

      ALTER SESSION SET optimizer_adaptive_features = TRUE;
      ALTER SESSION SET optimizer_adaptive_reporting_only = FALSE;

[3.Test](sql/test.sql)

[4.SQL Plan] (sql/SQL_TRUE.sql)

## Case2
[1.Create Table](sql/CREATE_ADAPTIVE.sql)

2.Parameter

      ALTER SESSION SET optimizer_adaptive_features = FALSE;
      ALTER SESSION SET optimizer_adaptive_reporting_only = TRUE;

[3.Test](sql/test.sql)

[4.SQL Plan] (sql/SQL_FALSE.sql)

## Stress Test

Stress Test (Case1, Case2)

1.CPU with Same TPS(adaptive on)
![1.CPU with Same TPS(adaptive on)] (png/1.CPU with Same TPS(adaptive on).png)

2.CPU with Same TPS(adaptive off)
![2.CPU with Same TPS(adaptive off)] (png/2.CPU with Same TPS(adaptive off).png)

3.TPS with Same CPU(adaptive on)
![3.TPS with Same CPU(adaptive on)] (png/3.TPS with Same CPU(adaptive on).png)

4.TPS with Same CPU(adaptive off)
![4.TPS with Same CPU(adaptive off)] (png/4.TPS with Same CPU(adaptive off).png)


## Case3

**_optimizer_unnest_scalar_sq** enables unnesting of scalar subquery.

### Create Table
```sql
CREATE TABLE TEST_OBJECTS
AS SELECT * FROM DBA_OBJECTS;

CREATE TABLE TEST_USERS
AS SELECT * FROM DBA_USERS;

EXEC DBMS_STATS.GATHER_TABLE_STATS(OWNNAME=>'HR',TABNAME=>'TEST_OBJECTS',CASCADE=>TRUE,ESTIMATE_PERCENT=>DBMS_STATS.AUTO_SAMPLE_SIZE,NO_INVALIDATE=>FALSE);
EXEC DBMS_STATS.GATHER_TABLE_STATS(OWNNAME=>'HR',TABNAME=>'TEST_USERS',CASCADE=>TRUE,ESTIMATE_PERCENT=>DBMS_STATS.AUTO_SAMPLE_SIZE,NO_INVALIDATE=>FALSE);
```

### SELECT(DEFAULT)
```sql
SELECT /*+ GATHER_PLAN_STATISTICS */
    u.username
  , (SELECT MAX(created) FROM test_objects o WHERE o.owner = u.username)
FROM test_users u
WHERE username LIKE 'S%'
/

SELECT  * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL , NULL , 'ALLSTATS LAST +ROWS +ADAPTIVE'));
```

#### Plan of SELECT(DEFAULT)
```sql
SQL_ID  aa2makwnx0s1v, child number 0
-------------------------------------
SELECT /*+ GATHER_PLAN_STATISTICS */     u.username   , (SELECT 
MAX(created) FROM test_objects o WHERE o.owner = u.username) FROM 
test_users u WHERE username LIKE 'S%'
 
Plan hash value: 78430553
 
-------------------------------------------------------------------------------------------------------------------------
| Id  | Operation           | Name         | Starts | E-Rows | A-Rows |   A-Time   | Buffers |  OMem |  1Mem | Used-Mem |
-------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT    |              |      1 |        |      9 |00:00:00.04 |    1598 |       |       |          |
|   1 |  HASH GROUP BY      |              |      1 |     46 |      9 |00:00:00.04 |    1598 |  3537K|  1259K| 2050K (0)|
|*  2 |   HASH JOIN OUTER   |              |      1 |  35895 |  42747 |00:00:00.05 |    1598 |  1301K|  1301K| 1323K (0)|
|*  3 |    TABLE ACCESS FULL| TEST_USERS   |      1 |      8 |      9 |00:00:00.01 |       3 |       |       |          |
|*  4 |    TABLE ACCESS FULL| TEST_OBJECTS |      1 |  42742 |  42742 |00:00:00.02 |    1595 |       |       |          |
-------------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("O"."OWNER"="U"."USERNAME")
   3 - filter("USERNAME" LIKE 'S%')
   4 - filter("O"."OWNER" LIKE 'S%')
```

### SELECT with NO_UNNEST Hint
```sql
SELECT /*+ GATHER_PLAN_STATISTICS NO_UNNEST(@ssq) */
    u.username
  , (SELECT /*+ QB_NAME(ssq) */ MAX(created) FROM test_objects o WHERE o.owner = u.username)
FROM test_users u
WHERE username LIKE 'S%'
/    
SELECT  * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL , NULL , 'ALLSTATS LAST +ROWS +ADAPTIVE'));
```

#### Plan of SELECT with NO_UNNEST Hint
```sql
SQL_ID  f35v5nkzqkdpm, child number 0
-------------------------------------
SELECT /*+ GATHER_PLAN_STATISTICS NO_UNNEST(@ssq) */     u.username   , 
(SELECT /*+ QB_NAME(ssq) */ MAX(created) FROM test_objects o WHERE 
o.owner = u.username) FROM test_users u WHERE username LIKE 'S%'
 
Plan hash value: 3284448023
 
---------------------------------------------------------------------------------------------
| Id  | Operation          | Name         | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
---------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |              |      1 |        |      9 |00:00:00.01 |       3 |
|   1 |  SORT AGGREGATE    |              |      9 |      1 |      9 |00:00:00.05 |   14355 |
|*  2 |   TABLE ACCESS FULL| TEST_OBJECTS |      9 |   3520 |  42742 |00:00:00.05 |   14355 |
|*  3 |  TABLE ACCESS FULL | TEST_USERS   |      1 |      8 |      9 |00:00:00.01 |       3 |
---------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - filter("O"."OWNER"=:B1)
   3 - filter("USERNAME" LIKE 'S%')
 
```

## About Video Resources


## Links
- [_optimizer_unnest_scalar_sq](http://blog.tanelpoder.com/2013/08/13/oracle-12c-scalar-subquery-unnesting-transformation/)
- [OPTIMIZER_ADAPTIVE_FEATURES](https://docs.oracle.com/database/121/REFRN/GUID-F5E53EFA-B395-4336-B046-1EE7AF12353B.htm#REFRN10344)
- [OPTIMIZER_ADAPTIVE_REPORTING_ONLY](http://docs.oracle.com/database/121/REFRN/GUID-8DD128F9-4891-4061-9B2D-9D45315D44FB.htm#REFRN10327)
- [Oracle 12c: Scalar Subquery Unnesting transformation] (http://blog.tanelpoder.com/2013/08/13/oracle-12c-scalar-subquery-unnesting-transformation/)
