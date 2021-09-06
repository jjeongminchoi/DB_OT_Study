-- 문제1. (도헌)
-- 주문 상태가 Pending이고, 주소에 1과 S가 들어가는 고객중 주문날짜가 가장 오래된 고객을 찾고, // 
-- 그 고객의 풀네임의 길이와, 전체 고객중 풀네임의 길이가 일치하고, 주문이 완료된 고객의 주문번호와 고객의 이름, 폰번호, 주문상태, 주문날짜를 출력하시오.
-- 추가로, 주문날짜가 오래된 순서로 정렬하시오.
SELECT B.ORDER_ID, B.FIRST_NAME, B.PHONE, B.STATUS, B.ORDER_DATE
FROM (SELECT LENGTH (A.F_NAME) AS LEN
      FROM (SELECT O.ORDER_ID, O.CUSTOMER_ID, (CO.FIRST_NAME || CO.LAST_NAME) AS F_NAME, O.ORDER_DATE,
                   RANK() OVER(ORDER BY O.ORDER_DATE ASC) AS RNK
            FROM ORDERS O INNER JOIN CUSTOMERS C
                                  ON O.CUSTOMER_ID = C.CUSTOMER_ID
                                 AND C.ADDRESS LIKE '%1%S%'
                          INNER JOIN CONTACTS CO
                                  ON O.CUSTOMER_ID = CO.CUSTOMER_ID
           WHERE O.STATUS = 'Pending') A
      WHERE A.RNK = 1) A INNER JOIN (SELECT O.ORDER_ID, C.FIRST_NAME, C.PHONE, O.STATUS, O.ORDER_DATE, (C.FIRST_NAME || C.LAST_NAME) AS FF_NAME
                                     FROM ORDERS O INNER JOIN CONTACTS C
                                                           ON O.CUSTOMER_ID = C.CUSTOMER_ID
                                     WHERE O.STATUS = 'Shipped') B
                                 ON 1 = 1
                                AND A.LEN = LENGTH(FF_NAME)
ORDER BY B.ORDER_DATE ASC
;

-- 문제2. (시연) 
-- 현재 판매가 기준으로 가장 많은 매출을 낸 사원의 이름을 출력하고 매출액의 200%만큼 보너스를 부여하시오
-- 출력필드 [FIRST_NAME,보너스]
SELECT E.FIRST_NAME, A.SAL * 2 AS BONUS
FROM (SELECT O.SALESMAN_ID, SUM(OI.QUANTITY * UNIT_PRICE) AS SAL,
             RANK() OVER(ORDER BY SUM(OI.QUANTITY * UNIT_PRICE) DESC) AS RNK
      FROM ORDERS O INNER JOIN ORDER_ITEMS OI
                            ON O.ORDER_ID = OI.ORDER_ID
      WHERE SALESMAN_ID IS NOT NULL AND STATUS != 'Canceled'
      GROUP BY O.SALESMAN_ID) A INNER JOIN EMPLOYEES E
                                        ON A.SALESMAN_ID = E.EMPLOYEE_ID
WHERE A.RNK = 1
;

-- 문제3. (희두)
-- 신용한도가 600이상인 회사중 가장 많은 주문을 한 회사를 찾고 해당 회사들 중 이름이 6글자 이상인 담당자를 찾으시오.(LAST_NAME기준)
-- 출력 : FULL NAME, WITHOUT DOMAIN, KOREA NUMBER(단, 답과 똑같이 출력하시오)
SELECT (C.FIRST_NAME || ' ' || C.LAST_NAME) AS "FULL NAME", 
       (LOWER(C.FIRST_NAME) || '.' || LOWER(C.LAST_NAME)) AS "WITHOUT DOMAIN", 
        REPLACE(C.PHONE, '+1', '+82') AS "KOREA NUMBER"
FROM (SELECT C.CUSTOMER_ID, COUNT(*), RANK() OVER(ORDER BY COUNT(*) DESC) AS RNK
      FROM CUSTOMERS C INNER JOIN ORDERS O
                               ON C.CUSTOMER_ID = O.CUSTOMER_ID
      WHERE C.CREDIT_LIMIT >= 600
      GROUP BY C.CUSTOMER_ID) A INNER JOIN CONTACTS C
                                        ON A.CUSTOMER_ID = C.CONTACT_ID
                                       AND LENGTH(LAST_NAME) >= 6
WHERE A.RNK = 1
;

-- 문제4. (건정)
-- ASUS사 CPU종류의 주문수량을 오름차순하시오.
--출력 : 오름차순, PRODUCT_NAME, DESCRIPTION
SELECT OI.QUANTITY, RANK() OVER(ORDER BY OI.QUANTITY ASC) AS RNK, P.PRODUCT_NAME, P.DESCRIPTION
FROM PRODUCTS P INNER JOIN ORDER_ITEMS OI
                        ON P.PRODUCT_ID = OI.PRODUCT_ID
WHERE P.PRODUCT_NAME LIKE 'Asus%' AND P.DESCRIPTION LIKE 'CPU%'
;