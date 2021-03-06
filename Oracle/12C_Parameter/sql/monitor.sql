SELECT  *
FROM   (
        SELECT  INST_ID, SQL_FULLTEXT, SQL_ID, PLAN_HASH_VALUE, EXECUTIONS, ROWS_PROCESSED, BUFFER_GETS, ROUND(CPU_TIME / 1000000, 6) AS CPU_TIME
              , ROUND(BUFFER_GETS / EXECUTIONS) AS AVG_BUFFER_GETS, ROUND(CPU_TIME / EXECUTIONS / 1000000, 6) AS AVG_CPU_TIME, ROUND(ELAPSED_TIME / EXECUTIONS / 1000000, 6) AS AVG_ELAPSED_TIME
              , PARSING_SCHEMA_NAME, MODULE, FIRST_LOAD_TIME, LAST_LOAD_TIME, LAST_ACTIVE_TIME
              , CASE WHEN (LAST_ACTIVE_TIME - LAST_LOAD_TIME) = 0 THEN EXECUTIONS ELSE ROUND(EXECUTIONS / ((LAST_ACTIVE_TIME - LAST_LOAD_TIME) * 24 * 60), 1) END EXEC_COUNT_PER_MIN
        FROM    GV$SQLAREA
        WHERE   1 = 1
        AND     EXECUTIONS >= 1
        AND     BUFFER_GETS / EXECUTIONS >= 1
        AND     LAST_ACTIVE_TIME >= SYSDATE - 10/1440
        AND     SQL_TEXT LIKE '%/* SQL#%'
        ORDER BY
                LAST_ACTIVE_TIME DESC
                --BUFFER_GETS DESC
                --EXECUTIONS DESC
       )
WHERE   ROWNUM <= 100
;
