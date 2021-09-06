-- 문제1. (재현)
-- 창고(WAREHOUSE_NAME) 이름이 7글자을 넘고  보유중인 총수량이 1등인 창고를 아래 정답과 똑같이 출력하시오(WHERE은 1번만 사용가능합니다)
SELECT (LOWER(SUBSTR(A.WAREHOUSE_NAME, 1, 3)) || SUBSTR(A.WAREHOUSE_NAME, 5)) AS NAME, A.SUM AS QSUM
FROM (SELECT W.WAREHOUSE_NAME, SUM(I.QUANTITY) AS SUM,
             RANK() OVER(ORDER BY SUM(I.QUANTITY) DESC) AS RNK
      FROM WAREHOUSES W INNER JOIN INVENTORIES I
                                ON W.WAREHOUSE_ID = I.WAREHOUSE_ID
      GROUP BY W.WAREHOUSE_NAME
      HAVING LENGTH(W.WAREHOUSE_NAME) >= 7) A
WHERE A.RNK = 1
;

-- 문제2. (인복)
-- 판매 직원들별로(사장 제외) 주문 수량이 100개 이상이며, 수익을 낸 주문들의 총 합중에서 가장 큰 값을 작은값으로 나머지값을 구하고(소수점제외)
-- 모든 직원들과 고객들의 핸드폰 번호의 제일 마지막자리가 이전에 구한 값의 차의 숫자중에(1~5자리) 하나라도 포함된 사람들을 출력하시오.
-- 출력필드: ID, FIRST_NAME, LAST_NAME, PHONE, EMAIL (EMPLOYEE와 CUSTOMER를 구분하기 위해 ID앞에 EM 또는 CS표시를 하고 CS사람들을 먼저 출력하시오)
-- EX) 차이가 65432 나오면 휴대전화 마지막 자리가 6, 5, 4, 3, 2 인 사람들을 출력하면 됩니다
-- CS 72명 / EM 54명 나옵니다 68280
SELECT ('(EM)' || E.EMPLOYEE_ID) AS PERSON_ID, E.FIRST_NAME, E.LAST_NAME, E.PHONE, E.EMAIL
FROM EMPLOYEES E INNER JOIN (SELECT FLOOR(MOD(MAX(A.SUM), MIN(A.SUM))) AS RES
                             FROM (SELECT O.SALESMAN_ID, SUM(OI.QUANTITY * OI.UNIT_PRICE) AS SUM
                                   FROM EMPLOYEES E INNER JOIN ORDERS O
                                                            ON E.EMPLOYEE_ID = O.SALESMAN_ID
                                                           AND E.MANAGER_ID IS NOT NULL
                                                    INNER JOIN ORDER_ITEMS OI
                                                            ON O.ORDER_ID = OI.ORDER_ID
                                                           AND OI.QUANTITY >= 100
                                   WHERE O.SALESMAN_ID IS NOT NULL AND O.STATUS != 'Canceled'
                                   GROUP BY O.SALESMAN_ID) A) A
                         ON 1 = 1
WHERE SUBSTR(E.PHONE, -1) IN (0, 2, 6, 8)
UNION
SELECT ('(CS)' || C.CONTACT_ID) AS PERSON_ID, C.FIRST_NAME, C.LAST_NAME, C.PHONE, C.EMAIL
FROM CONTACTS C INNER JOIN (SELECT FLOOR(MOD(MAX(A.SUM), MIN(A.SUM))) AS RES
                             FROM (SELECT O.SALESMAN_ID, SUM(OI.QUANTITY * OI.UNIT_PRICE) AS SUM
                                   FROM EMPLOYEES E INNER JOIN ORDERS O
                                                            ON E.EMPLOYEE_ID = O.SALESMAN_ID
                                                           AND E.MANAGER_ID IS NOT NULL
                                                    INNER JOIN ORDER_ITEMS OI
                                                            ON O.ORDER_ID = OI.ORDER_ID
                                                           AND OI.QUANTITY >= 100
                                   WHERE O.SALESMAN_ID IS NOT NULL AND O.STATUS != 'Canceled'
                                   GROUP BY O.SALESMAN_ID) A) A
                         ON 1 = 1
WHERE SUBSTR(C.PHONE, -1) IN (0, 2, 6, 8)
;

-- 문제3. (인복)
-- 한도가 3500에서 4500사이인 회사들을 구하고 웹사이트 이름의 공통된 부분을 제외하고 회사명의 글자길이(공백제외)와 웹사이트명의 글자 길이를 비교해서
-- 회사명의 글자길이가 웹사이트명의 글자길이보다 크면 한도 1.3배, 같으면 1.5배, 작으면 1.7배 해준뒤 전체 회사들의 한도와 비교하여 6위까지와 300백위 밑을 출력하시오
-- 출력필드: 이름, 웹사이트 이름, 크레딧 포인트, 랭킹
-- EX)https://abcdefg.com -> abcdefg (공통된 부분 제외)
SELECT A.NAME, A.WEBSITE, A.CREDIT, A.RNK
FROM (SELECT C.NAME, C.WEBSITE, 
             CASE WHEN A.CREDIT_LIMIT IS NOT NULL
                  THEN A.CREDIT_LIMIT
                  WHEN C.CREDIT_LIMIT = C.CREDIT_LIMIT
                  THEN C.CREDIT_LIMIT
             END AS CREDIT,
             RANK() OVER(ORDER BY CASE WHEN A.CREDIT_LIMIT IS NOT NULL
                                       THEN A.CREDIT_LIMIT
                                       WHEN C.CREDIT_LIMIT = C.CREDIT_LIMIT
                                       THEN C.CREDIT_LIMIT
                                  END DESC) AS RNK
      FROM (SELECT A.NAME,
                   CASE WHEN NLEN > WLEN
                        THEN A.CREDIT_LIMIT * 1.3
                        WHEN NLEN = WLEN
                        THEN A.CREDIT_LIMIT * 1.5
                        ELSE A.CREDIT_LIMIT * 1.7
                   END AS CREDIT_LIMIT
            FROM (SELECT NAME, WEBSITE, CREDIT_LIMIT,
                         SUBSTR(SUBSTR(WEBSITE, 12), 1, INSTR(SUBSTR(WEBSITE, 12), '.') - 1) AS WEB,
                         LENGTH(SUBSTR(SUBSTR(WEBSITE, 12), 1, INSTR(SUBSTR(WEBSITE, 12), '.') - 1)) AS WLEN,
                         LENGTH(REPLACE(NAME, ' ', '')) AS NLEN
                  FROM CUSTOMERS
                  WHERE CREDIT_LIMIT BETWEEN 3500 AND 4500) A) A RIGHT OUTER JOIN CUSTOMERS C
                                                                               ON A.NAME = C.NAME) A
WHERE (A.RNK BETWEEN 1 AND 6) OR (A.RNK > 300)
;

-- 문제4. (정민)
-- 17년도 하반기에 고객사가 주문한 주문금액의 합(소수 첫째 자리에서 반올림)을 구하고,
-- 상위 5위의 고객사는 신용한도를 30% 인상하고 그 이외의 고객사는 30%인하하여 신용한도를 기준으로 순위를 구하시오.
-- 출력필드 : CUSTOMER_ID, NAME, SUM(주문금액 합계), CREDIT_LIMIT, RLMIT(신용한도 변동 값), RNK
SELECT A.CUSTOMER_ID, A.NAME, A.SUM, A.CREDIT_LIMIT, A.RLIMIT,
       RANK() OVER(ORDER BY A.RLIMIT DESC) AS RNK
FROM (SELECT C.CUSTOMER_ID, A.SUM, C.NAME, C.CREDIT_LIMIT,
             CASE WHEN A.RNK BETWEEN 1 AND 5
                  THEN C.CREDIT_LIMIT * 1.3
                  ELSE C.CREDIT_LIMIT * 0.7
             END AS RLIMIT
      FROM (SELECT O.CUSTOMER_ID, ROUND(SUM(OI.QUANTITY * OI.UNIT_PRICE), 0) AS SUM,
                   RANK() OVER(ORDER BY SUM(OI.QUANTITY * OI.UNIT_PRICE) DESC) AS RNK
            FROM ORDERS O INNER JOIN ORDER_ITEMS OI
                                  ON O.ORDER_ID = OI.ORDER_ID
            WHERE O.STATUS != 'Canceled' AND TO_CHAR(ORDER_DATE, 'YY') = 17 AND FLOOR(TO_CHAR(ORDER_DATE, 'MM') / 7) = 1
            GROUP BY O.CUSTOMER_ID) A INNER JOIN CUSTOMERS C
                                              ON A.CUSTOMER_ID = C.CUSTOMER_ID) A
;