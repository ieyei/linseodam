SET TIME ON
SET TIMING ON


DROP TABLE SCOTT.T1 PURGE;

CREATE TABLE SCOTT.T1 NOLOGGING AS SELECT * FROM DBA_OBJECTS WHERE 1 = 0;

INSERT /*+ APPEND */ INTO SCOTT.T1
      (OWNER, OBJECT_NAME, SUBOBJECT_NAME, OBJECT_ID, DATA_OBJECT_ID, OBJECT_TYPE, CREATED, LAST_DDL_TIME, TIMESTAMP, STATUS, TEMPORARY, GENERATED, SECONDARY, NAMESPACE, EDITION_NAME, SHARING, EDITIONABLE, ORACLE_MAINTAINED)
SELECT /*+ LEADING(B, A) USE_NL(A) */
       OWNER, OBJECT_NAME, SUBOBJECT_NAME,    ROWNUM, DATA_OBJECT_ID, OBJECT_TYPE, CREATED, LAST_DDL_TIME, TIMESTAMP, STATUS, TEMPORARY, GENERATED, SECONDARY, NAMESPACE, EDITION_NAME, SHARING, EDITIONABLE, ORACLE_MAINTAINED
  FROM DBA_OBJECTS A
     ,(SELECT 1
         FROM DUAL
      CONNECT BY LEVEL <= 1000
      ) B
 WHERE ROWNUM <= 5000000
Test;

CREATE INDEX SCOTT.T1_X1 ON SCOTT.T1 (OBJECT_ID) NOLOGGING;
CREATE INDEX SCOTT.T1_X2 ON SCOTT.T1 (OBJECT_NAME) NOLOGGING;

--------------------------------------------------------------------------------

DROP TABLE SCOTT.T2 PURGE;

CREATE TABLE SCOTT.T2 NOLOGGING AS SELECT * FROM SCOTT.T1;

CREATE INDEX SCOTT.T2_X1 ON SCOTT.T2 (OBJECT_ID) NOLOGGING;


--------------------------------------------------------------------------------

EXEC DBMS_STATS.GATHER_TABLE_STATS(OWNNAME=>'SCOTT',TABNAME=>'T1',CASCADE=>TRUE,ESTIMATE_PERCENT=>DBMS_STATS.AUTO_SAMPLE_SIZE,NO_INVALIDATE=>FALSE);
EXEC DBMS_STATS.GATHER_TABLE_STATS(OWNNAME=>'SCOTT',TABNAME=>'T2',CASCADE=>TRUE,ESTIMATE_PERCENT=>DBMS_STATS.AUTO_SAMPLE_SIZE,NO_INVALIDATE=>FALSE);

SELECT COUNT(*) FROM SCOTT.T1
UNION ALL
SELECT COUNT(*) FROM SCOTT.T2;


ALTER SYSTEM FLUSH SHARED_POOL;