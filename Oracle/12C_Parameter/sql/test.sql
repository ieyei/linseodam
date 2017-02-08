SET SERVEROUTPUT ON
SET TIMING ON

ALTER SYSTEM FLUSH SHARED_POOL;

DECLARE
    type rc is ref cursor;
    l_rc    rc;
    l_object_name    T1.OBJECT_NAME%TYPE;
BEGIN
    FOR i IN 1..100000
    LOOP
        IF i = 1 THEN
            EXECUTE IMMEDIATE 'ALTER SESSION SET OPTIMIZER_MODE = ALL_ROWS';
        ELSIF i = 50001 THEN
            EXECUTE IMMEDIATE 'ALTER SESSION SET OPTIMIZER_MODE = FIRST_ROWS';
        END IF;

        OPEN l_rc FOR
           'SELECT /* SQL#1 : BIND + optimizer_adaptive_features = TRUE */
                   C.OBJECT_NAME
              FROM SCOTT.T1 A
                 , SCOTT.T1 B
                 , SCOTT.T2 C
             WHERE A.OBJECT_NAME   = B.OBJECT_NAME
               AND A.OBJECT_ID / 1 = B.OBJECT_ID * 1
               AND B.OBJECT_ID     = C.OBJECT_ID
               AND A.OBJECT_ID     = :object_id
               AND ROWNUM         <= 1' USING i;

        FETCH l_rc INTO l_object_name;
        CLOSE l_rc;

        OPEN l_rc FOR
           'SELECT /* SQL#2 : LITERAL + optimizer_adaptive_features = TRUE, SID = ' || USERENV('SID') || ' */
                   C.OBJECT_NAME
              FROM SCOTT.T1 A
                 , SCOTT.T1 B
                 , SCOTT.T2 C
             WHERE A.OBJECT_NAME   = B.OBJECT_NAME
               AND A.OBJECT_ID / 1 = B.OBJECT_ID * 1
               AND B.OBJECT_ID     = C.OBJECT_ID
               AND A.OBJECT_ID     = ' || (MOD(i, 10) + 1) || '
               AND ROWNUM         <= 1';

        FETCH l_rc INTO l_object_name;
        CLOSE l_rc;

        OPEN l_rc FOR
           'SELECT /* SQL#3 : LITERAL + optimizer_adaptive_features = TRUE, SID = ' || USERENV('SID') || ' */
                   C.OBJECT_NAME
              FROM SCOTT.T1 A
                 , SCOTT.T2 B
                 , SCOTT.T1 C
             WHERE A.OBJECT_NAME   = B.OBJECT_NAME
               AND A.OBJECT_ID / 1 = B.OBJECT_ID * 1
               AND B.OBJECT_ID     = C.OBJECT_ID
               AND A.OBJECT_ID     = ' || (MOD(i, 10) + 1) || '
               AND ROWNUM         <= 1';

        FETCH l_rc INTO l_object_name;
        CLOSE l_rc;
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error !!! => ' || SQLERRM);
END;
/
