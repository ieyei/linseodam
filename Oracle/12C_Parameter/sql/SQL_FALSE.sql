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

ALTER SYSTEM SET optimizer_adaptive_features = FALSE;
ALTER SYSTEM SET optimizer_adaptive_reporting_only = TRUE;

ALTER SYSTEM FLUSH SHARED_POOL;


--------------------------------------------------------------------------------

-------------------------[Start Time: 2017/02/02 20:35:28]-------------------------
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

--------------------------------------------------------------------------------------------------------------------
| Id  | Operation                               | Name  | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |
--------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                        |       |      1 |        |      1 |00:00:00.01 |      13 |      6 |
|*  1 |  COUNT STOPKEY                          |       |      1 |        |      1 |00:00:00.01 |      13 |      6 |
|   2 |   NESTED LOOPS                          |       |      1 |      1 |      1 |00:00:00.01 |      13 |      6 |
|   3 |    NESTED LOOPS                         |       |      1 |      1 |      1 |00:00:00.01 |      12 |      6 |
|   4 |     NESTED LOOPS                        |       |      1 |      1 |      1 |00:00:00.01 |       9 |      4 |
|   5 |      TABLE ACCESS BY INDEX ROWID BATCHED| T1    |      1 |      1 |      1 |00:00:00.01 |       5 |      2 |
|*  6 |       INDEX RANGE SCAN                  | T1_X1 |      1 |      1 |      1 |00:00:00.01 |       3 |      2 |
|*  7 |      TABLE ACCESS BY INDEX ROWID BATCHED| T1    |      1 |      1 |      1 |00:00:00.01 |       4 |      2 |
|*  8 |       INDEX RANGE SCAN                  | T1_X2 |      1 |     87 |      1 |00:00:00.01 |       3 |      2 |
|*  9 |     INDEX RANGE SCAN                    | T2_X1 |      1 |      1 |      1 |00:00:00.01 |       3 |      2 |
|  10 |    TABLE ACCESS BY INDEX ROWID          | T2    |      1 |      1 |      1 |00:00:00.01 |       1 |      0 |
--------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

1 - filter(ROWNUM<=1)
6 - access("A"."OBJECT_ID"=99)
7 - filter("A"."OBJECT_ID"/1="B"."OBJECT_ID"*1)
8 - access("A"."OBJECT_NAME"="B"."OBJECT_NAME")
9 - access("B"."OBJECT_ID"="C"."OBJECT_ID")


36 rows selected.

SQL Execution Time > 00:00:00.296
Total Elapsed Time > 00:00:00.733


--------------------------------------------------------------------------------

-------------------------[Start Time: 2017/02/02 20:35:43]-------------------------
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

--------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                               | Name  | Starts | E-Rows | A-Rows |   A-Time   | Buffers |  OMem |  1Mem | Used-Mem |
--------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                        |       |      1 |        |      1 |00:00:00.01 |      13 |       |       |          |
|*  1 |  COUNT STOPKEY                          |       |      1 |        |      1 |00:00:00.01 |      13 |       |       |          |
|   2 |   NESTED LOOPS                          |       |      1 |      1 |      1 |00:00:00.01 |      13 |       |       |          |
|   3 |    NESTED LOOPS                         |       |      1 |      1 |      1 |00:00:00.01 |      12 |       |       |          |
|*  4 |     HASH JOIN                           |       |      1 |      1 |      1 |00:00:00.01 |       9 |  1599K|  1599K|  386K (0)|
|   5 |      TABLE ACCESS BY INDEX ROWID BATCHED| T1    |      1 |      1 |      1 |00:00:00.01 |       4 |       |       |          |
|*  6 |       INDEX RANGE SCAN                  | T1_X1 |      1 |      1 |      1 |00:00:00.01 |       3 |       |       |          |
|   7 |      TABLE ACCESS FULL                  | T2    |      1 |   5000K|     99 |00:00:00.01 |       5 |       |       |          |
|*  8 |     INDEX RANGE SCAN                    | T1_X1 |      1 |      1 |      1 |00:00:00.01 |       3 |       |       |          |
|   9 |    TABLE ACCESS BY INDEX ROWID          | T1    |      1 |      1 |      1 |00:00:00.01 |       1 |       |       |          |
--------------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

1 - filter(ROWNUM<=1)
4 - access("A"."OBJECT_NAME"="B"."OBJECT_NAME" AND "A"."OBJECT_ID"/1="B"."OBJECT_ID"*1)
6 - access("A"."OBJECT_ID"=99)
8 - access("B"."OBJECT_ID"="C"."OBJECT_ID")


34 rows selected.

SQL Execution Time > 00:00:00.094
Total Elapsed Time > 00:00:00.234


--------------------------------------------------------------------------------

-------------------------[Start Time: 2017/02/02 20:35:55]-------------------------
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

--------------------------------------------------------------------------------------------------------------------
| Id  | Operation                               | Name  | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |
--------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                        |       |      1 |        |      1 |00:00:00.02 |     221 |     41 |
|   1 |  SORT AGGREGATE                         |       |      1 |      1 |      1 |00:00:00.02 |     221 |     41 |
|   2 |   NESTED LOOPS                          |       |      1 |     87 |     53 |00:00:00.02 |     221 |     41 |
|   3 |    NESTED LOOPS                         |       |      1 |     87 |     53 |00:00:00.02 |     168 |     41 |
|   4 |     NESTED LOOPS                        |       |      1 |     87 |     53 |00:00:00.01 |      60 |      0 |
|   5 |      TABLE ACCESS BY INDEX ROWID BATCHED| T1    |      1 |      1 |      1 |00:00:00.01 |       4 |      0 |
|*  6 |       INDEX RANGE SCAN                  | T1_X1 |      1 |      1 |      1 |00:00:00.01 |       3 |      0 |
|   7 |      TABLE ACCESS BY INDEX ROWID BATCHED| T1    |      1 |     87 |     53 |00:00:00.01 |      56 |      0 |
|*  8 |       INDEX RANGE SCAN                  | T1_X2 |      1 |     87 |     53 |00:00:00.01 |       3 |      0 |
|*  9 |     INDEX RANGE SCAN                    | T2_X1 |     53 |      1 |     53 |00:00:00.02 |     108 |     41 |
|  10 |    TABLE ACCESS BY INDEX ROWID          | T2    |     53 |      1 |     53 |00:00:00.01 |      53 |      0 |
--------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

6 - access("A"."OBJECT_ID"=99)
8 - access("A"."OBJECT_NAME"="B"."OBJECT_NAME")
9 - access("B"."OBJECT_ID"="C"."OBJECT_ID")


33 rows selected.

SQL Execution Time > 00:00:00.141
Total Elapsed Time > 00:00:00.266


