********************************************************************************

SELECT /* optimizer_adaptive_features TEST : SQL#1 */
       C.OBJECT_NAME
  FROM SCOTT.T1 A
     , SCOTT.T1 B
     , SCOTT.T2 C
 WHERE A.OBJECT_NAME   = B.OBJECT_NAME
   AND A.OBJECT_ID / 1 = B.OBJECT_ID * 1
   AND B.OBJECT_ID     = C.OBJECT_ID
   AND A.OBJECT_ID     = 99             /* 1 ~ 10000 */
   AND ROWNUM         <= 1


--▶ SQL#2 쿼리는 너무 무거워서(direct path read 발생) 성능테스트 시 제외함
SELECT /* optimizer_adaptive_features TEST : SQL#2 */
       C.OBJECT_NAME
  FROM SCOTT.T1 A
     , SCOTT.T2 B
     , SCOTT.T1 C
 WHERE A.OBJECT_NAME   = B.OBJECT_NAME
   AND A.OBJECT_ID / 1 = B.OBJECT_ID * 1
   AND B.OBJECT_ID     = C.OBJECT_ID
   AND A.OBJECT_ID     = 99             /* 1 ~ 10000 */
   AND ROWNUM         <= 1


SELECT /* optimizer_adaptive_features TEST : SQL#3 */
       MAX(C.OBJECT_NAME)
  FROM SCOTT.T1 A
     , SCOTT.T1 B
     , SCOTT.T2 C
 WHERE A.OBJECT_NAME   = B.OBJECT_NAME
   AND B.OBJECT_ID     = C.OBJECT_ID
   AND A.OBJECT_ID     = 99             /* 1 ~ 10000 */

********************************************************************************

ALTER SYSTEM SET optimizer_adaptive_features = TRUE;
ALTER SYSTEM SET optimizer_adaptive_reporting_only = FALSE;

ALTER SYSTEM FLUSH SHARED_POOL;


--------------------------------------------------------------------------------

-------------------------[Start Time: 2017/02/02 20:33:03]-------------------------
SQL> SELECT  *
FROM    TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL , NULL , 'ALLSTATS LAST +ROWS +ADAPTIVE'));

PLAN_TABLE_OUTPUT
-------------------------------------
SQL_ID  gu4p1fw7du1mx, child number 0
-------------------------------------
SELECT /* optimizer_adaptive_features TEST : SQL#1 */
C.OBJECT_NAME
   FROM SCOTT.T1 A
      , SCOTT.T1 B
      , SCOTT.T2 C
WHERE A.OBJECT_NAME   = B.OBJECT_NAME
    AND A.OBJECT_ID / 1 =
B.OBJECT_ID * 1
    AND B.OBJECT_ID     = C.OBJECT_ID
    AND
A.OBJECT_ID     = 99             /* 1 ~ 10000 */
    AND ROWNUM
<= 1

Plan hash value: 2829190290

--------------------------------------------------------------------------------------------------------------------------
|   Id  | Operation                                   | Name  | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |
--------------------------------------------------------------------------------------------------------------------------
|     0 | SELECT STATEMENT                            |       |      1 |        |      1 |00:00:00.01 |      65 |      6 |
|  *  1 |  COUNT STOPKEY                              |       |      1 |        |      1 |00:00:00.01 |      65 |      6 |
|- *  2 |   HASH JOIN                                 |       |      1 |      1 |      1 |00:00:00.01 |      65 |      6 |
|     3 |    NESTED LOOPS                             |       |      1 |      1 |      1 |00:00:00.01 |      65 |      6 |
|     4 |     NESTED LOOPS                            |       |      1 |      1 |      1 |00:00:00.01 |      64 |      6 |
|-    5 |      STATISTICS COLLECTOR                   |       |      1 |        |      1 |00:00:00.01 |      61 |      4 |
|- *  6 |       HASH JOIN                             |       |      1 |      1 |      1 |00:00:00.01 |      61 |      4 |
|     7 |        NESTED LOOPS                         |       |      1 |      1 |      1 |00:00:00.01 |      61 |      4 |
|-    8 |         STATISTICS COLLECTOR                |       |      1 |        |      1 |00:00:00.01 |       5 |      2 |
|     9 |          TABLE ACCESS BY INDEX ROWID BATCHED| T1    |      1 |      1 |      1 |00:00:00.01 |       5 |      2 |
|  * 10 |           INDEX RANGE SCAN                  | T1_X1 |      1 |      1 |      1 |00:00:00.01 |       3 |      2 |
|  * 11 |         TABLE ACCESS BY INDEX ROWID BATCHED | T1    |      1 |      1 |      1 |00:00:00.01 |      56 |      2 |
|  * 12 |          INDEX RANGE SCAN                   | T1_X2 |      1 |     87 |     53 |00:00:00.01 |       3 |      2 |
|-   13 |        TABLE ACCESS FULL                    | T1    |      0 |      1 |      0 |00:00:00.01 |       0 |      0 |
|  * 14 |      INDEX RANGE SCAN                       | T2_X1 |      1 |      1 |      1 |00:00:00.01 |       3 |      2 |
|    15 |     TABLE ACCESS BY INDEX ROWID             | T2    |      1 |      1 |      1 |00:00:00.01 |       1 |      0 |
|-   16 |    TABLE ACCESS FULL                        | T2    |      0 |      1 |      0 |00:00:00.01 |       0 |      0 |
--------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

1 - filter(ROWNUM<=1)
2 - access("B"."OBJECT_ID"="C"."OBJECT_ID")
6 - access("A"."OBJECT_NAME"="B"."OBJECT_NAME" AND "A"."OBJECT_ID"/1="B"."OBJECT_ID"*1)
10 - access("A"."OBJECT_ID"=99)
11 - filter("A"."OBJECT_ID"/1="B"."OBJECT_ID"*1)
12 - access("A"."OBJECT_NAME"="B"."OBJECT_NAME")
14 - access("B"."OBJECT_ID"="C"."OBJECT_ID")

Note
-----
- this is an adaptive plan (rows marked '-' are inactive)


48 rows selected.

SQL Execution Time > 00:00:00.281
Total Elapsed Time > 00:00:00.499


--------------------------------------------------------------------------------

-------------------------[Start Time: 2017/02/02 20:33:21]-------------------------
SQL> SELECT  *
FROM    TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL , NULL , 'ALLSTATS LAST +ROWS +ADAPTIVE'));

PLAN_TABLE_OUTPUT
-------------------------------------
SQL_ID  57g4zy3xp76sg, child number 0
-------------------------------------
SELECT /* optimizer_adaptive_features TEST : SQL#2 */
C.OBJECT_NAME
   FROM SCOTT.T1 A
      , SCOTT.T2 B
      , SCOTT.T1 C
WHERE A.OBJECT_NAME   = B.OBJECT_NAME
    AND A.OBJECT_ID / 1 =
B.OBJECT_ID * 1
    AND B.OBJECT_ID     = C.OBJECT_ID
    AND
A.OBJECT_ID     = 99             /* 1 ~ 10000 */
    AND ROWNUM
<= 1

Plan hash value: 1126344170

------------------------------------------------------------------------------------------------------------------------------------------
|   Id  | Operation                                 | Name  | Starts | E-Rows | A-Rows |   A-Time   | Buffers |  OMem |  1Mem | Used-Mem |
------------------------------------------------------------------------------------------------------------------------------------------
|     0 | SELECT STATEMENT                          |       |      1 |        |      1 |00:00:00.68 |   84281 |       |       |          |
|  *  1 |  COUNT STOPKEY                            |       |      1 |        |      1 |00:00:00.68 |   84281 |       |       |          |
|- *  2 |   HASH JOIN                               |       |      1 |      1 |      1 |00:00:00.68 |   84281 |   852K|   852K|          |
|     3 |    NESTED LOOPS                           |       |      1 |      1 |      1 |00:00:00.68 |   84281 |       |       |          |
|     4 |     NESTED LOOPS                          |       |      1 |      1 |      1 |00:00:00.68 |   84280 |       |       |          |
|-    5 |      STATISTICS COLLECTOR                 |       |      1 |        |      1 |00:00:00.68 |   84277 |       |       |          |
|  *  6 |       HASH JOIN                           |       |      1 |      1 |      1 |00:00:00.68 |   84277 |  1599K|  1599K|  390K (0)|
|     7 |        TABLE ACCESS BY INDEX ROWID BATCHED| T1    |      1 |      1 |      1 |00:00:00.01 |       4 |       |       |          |
|  *  8 |         INDEX RANGE SCAN                  | T1_X1 |      1 |      1 |      1 |00:00:00.01 |       3 |       |       |          |
|     9 |        TABLE ACCESS FULL                  | T2    |      1 |   5000K|   5000K|00:00:00.21 |   84273 |       |       |          |
|  * 10 |      INDEX RANGE SCAN                     | T1_X1 |      1 |      1 |      1 |00:00:00.01 |       3 |       |       |          |
|    11 |     TABLE ACCESS BY INDEX ROWID           | T1    |      1 |      1 |      1 |00:00:00.01 |       1 |       |       |          |
|-   12 |    TABLE ACCESS FULL                      | T1    |      0 |      1 |      0 |00:00:00.01 |       0 |       |       |          |
------------------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

1 - filter(ROWNUM<=1)
2 - access("B"."OBJECT_ID"="C"."OBJECT_ID")
6 - access("A"."OBJECT_NAME"="B"."OBJECT_NAME" AND "A"."OBJECT_ID"/1="B"."OBJECT_ID"*1)
8 - access("A"."OBJECT_ID"=99)
10 - access("B"."OBJECT_ID"="C"."OBJECT_ID")

Note
-----
- this is an adaptive plan (rows marked '-' are inactive)


42 rows selected.

SQL Execution Time > 00:00:00.141
Total Elapsed Time > 00:00:00.234


--------------------------------------------------------------------------------

-------------------------[Start Time: 2017/02/02 20:33:40]-------------------------
SQL> SELECT  *
FROM    TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL , NULL , 'ALLSTATS LAST +ROWS +ADAPTIVE'));

PLAN_TABLE_OUTPUT
-------------------------------------
SQL_ID  3qgrb6hk9m12y, child number 0
-------------------------------------
SELECT /* optimizer_adaptive_features TEST : SQL#3 */
MAX(C.OBJECT_NAME)
   FROM SCOTT.T1 A
      , SCOTT.T1 B
      ,
SCOTT.T2 C
  WHERE A.OBJECT_NAME   = B.OBJECT_NAME
    AND B.OBJECT_ID
= C.OBJECT_ID
    AND A.OBJECT_ID     = 99             /* 1 ~ 10000
*/

Plan hash value: 374716562

--------------------------------------------------------------------------------------------------------------------------
|   Id  | Operation                                   | Name  | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |
--------------------------------------------------------------------------------------------------------------------------
|     0 | SELECT STATEMENT                            |       |      1 |        |      1 |00:00:00.02 |     221 |     37 |
|     1 |  SORT AGGREGATE                             |       |      1 |      1 |      1 |00:00:00.02 |     221 |     37 |
|- *  2 |   HASH JOIN                                 |       |      1 |     87 |     53 |00:00:00.02 |     221 |     37 |
|     3 |    NESTED LOOPS                             |       |      1 |     87 |     53 |00:00:00.02 |     221 |     37 |
|     4 |     NESTED LOOPS                            |       |      1 |     87 |     53 |00:00:00.02 |     168 |     37 |
|-    5 |      STATISTICS COLLECTOR                   |       |      1 |        |     53 |00:00:00.01 |      60 |      0 |
|- *  6 |       HASH JOIN                             |       |      1 |     87 |     53 |00:00:00.01 |      60 |      0 |
|     7 |        NESTED LOOPS                         |       |      1 |     87 |     53 |00:00:00.01 |      60 |      0 |
|-    8 |         STATISTICS COLLECTOR                |       |      1 |        |      1 |00:00:00.01 |       4 |      0 |
|     9 |          TABLE ACCESS BY INDEX ROWID BATCHED| T1    |      1 |      1 |      1 |00:00:00.01 |       4 |      0 |
|  * 10 |           INDEX RANGE SCAN                  | T1_X1 |      1 |      1 |      1 |00:00:00.01 |       3 |      0 |
|    11 |         TABLE ACCESS BY INDEX ROWID BATCHED | T1    |      1 |     87 |     53 |00:00:00.01 |      56 |      0 |
|  * 12 |          INDEX RANGE SCAN                   | T1_X2 |      1 |     87 |     53 |00:00:00.01 |       3 |      0 |
|-   13 |        TABLE ACCESS FULL                    | T1    |      0 |     87 |      0 |00:00:00.01 |       0 |      0 |
|  * 14 |      INDEX RANGE SCAN                       | T2_X1 |     53 |      1 |     53 |00:00:00.02 |     108 |     37 |
|    15 |     TABLE ACCESS BY INDEX ROWID             | T2    |     53 |      1 |     53 |00:00:00.01 |      53 |      0 |
|-   16 |    TABLE ACCESS FULL                        | T2    |      0 |      1 |      0 |00:00:00.01 |       0 |      0 |
--------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

2 - access("B"."OBJECT_ID"="C"."OBJECT_ID")
6 - access("A"."OBJECT_NAME"="B"."OBJECT_NAME")
10 - access("A"."OBJECT_ID"=99)
12 - access("A"."OBJECT_NAME"="B"."OBJECT_NAME")
14 - access("B"."OBJECT_ID"="C"."OBJECT_ID")

Note
-----
- this is an adaptive plan (rows marked '-' are inactive)


45 rows selected.

SQL Execution Time > 00:00:00.156
Total Elapsed Time > 00:00:00.453


