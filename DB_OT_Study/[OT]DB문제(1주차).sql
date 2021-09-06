-- 문제1. (재현)오더 STATUS가 'Canceled' 상태인  사원들이 가장 많이 모시고 있는 매니저를 출력하시오
-- 출력: 사원번호,이름(퍼스트+라스트),이메일,JOB_TITLE
SELECT E.EMPLOYEE_ID, (E.FIRST_NAME || E.LAST_NAME) AS FULL_NAME, E.EMAIL, E.JOB_TITLE
FROM (SELECT E.MANAGER_ID, COUNT(*) AS CNT, RANK() OVER(ORDER BY COUNT(*) DESC) AS RNK
      FROM ORDERS O INNER JOIN EMPLOYEES E
                            ON O.SALESMAN_ID = E.EMPLOYEE_ID
      WHERE O.STATUS = 'Canceled'
      GROUP BY E.MANAGER_ID) A INNER JOIN EMPLOYEES E
                                       ON A.MANAGER_ID = E.EMPLOYEE_ID
WHERE A.RNK = 1
;

-- 문제2. (인복) 주문이 취소된 물건이 가장 많이나온 웹사이트 고객의 풀네임과 글자수와
-- 글자수가 같은 사람들을 직원들중에서 출력하시오
-- 출력필드: 사원번호, 사원풀네임, 직업
SELECT A.EMPLOYEE_ID, A.FULLNAME, A.JOB_TITLE
FROM (SELECT A.NAME_LENGTH, (E.FIRST_NAME || E.LAST_NAME) AS FULLNAME, E.EMPLOYEE_ID, E.JOB_TITLE
      FROM (SELECT LENGTH(CT.FIRST_NAME || CT.LAST_NAME) AS NAME_LENGTH
            FROM (SELECT C.WEBSITE, COUNT(*), RANK() OVER(ORDER BY COUNT(*) DESC) AS RNK
                  FROM ORDERS O INNER JOIN CUSTOMERS C
                                        ON O.CUSTOMER_ID = C.CUSTOMER_ID
                  WHERE O.STATUS = 'Canceled'
                  GROUP BY C.WEBSITE) A INNER JOIN CUSTOMERS C
                                                ON A.WEBSITE = C.WEBSITE
                                        INNER JOIN CONTACTS CT
                                                ON C.CUSTOMER_ID = CT.CUSTOMER_ID
            WHERE A.RNK = 1) A INNER JOIN EMPLOYEES E
                                       ON 1 = 1) A
WHERE A.NAME_LENGTH = LENGTH(A.FULLNAME)
;

-- 문제3. (정민) 제품ID가 200번대이면서 수량이 200개이상인 제품중 마진(판매가격-표준원가)이 가장 큰 제품과 가장 작은 제품의 차이를 구하고
-- 그 차이보다 큰 판매가격을 가진 제품들중 가장 많은 카테고리의 카테고리 이름을 구하시오.
SELECT PC.CATEGORY_NAME
FROM (SELECT P.CATEGORY_ID, COUNT(*), RANK() OVER(ORDER BY COUNT(*) DESC) AS RNK
      FROM PRODUCTS P INNER JOIN (SELECT MAX(A.MARGIN) - MIN(A.MARGIN) AS RMARGIN
                                  FROM (SELECT I.PRODUCT_ID, P.PRODUCT_NAME, (P.LIST_PRICE - P.STANDARD_COST) AS MARGIN,
                                               RANK() OVER(ORDER BY (P.LIST_PRICE - P.STANDARD_COST) DESC) AS RNK
                                        FROM INVENTORIES I INNER JOIN PRODUCTS P
                                                                   ON I.PRODUCT_ID = P.PRODUCT_ID
                                        WHERE I.PRODUCT_ID LIKE '2%_%_%' AND I.QUANTITY >= 200) A) A
                              ON 1 = 1
      WHERE P.LIST_PRICE > A.RMARGIN
      GROUP BY P.CATEGORY_ID) A INNER JOIN PRODUCT_CATEGORIES PC
                                        ON A.CATEGORY_ID = PC.CATEGORY_ID
WHERE A.RNK = 1
;

-- 문제4. (인복) 주문 기록중에 배송이 완료된 주문중에서 / 주문한 물품들의 총 합 지불 금액이 가장 큰 주문(실구매가=소매가)의 
-- 물품들의 총 금액이 / 원래 원가로 샀을때와 비교해서 얼마만큼의 금액차이가 있는지 구하시오
-- 출력필드: 물품 번호, 물품 이름, 개당마진, 원가로 샀을 때 가격, 실제로 회사가 지불한 소매가, 마진
SELECT P.PRODUCT_ID, P.PRODUCT_NAME, (P.LIST_PRICE - P.STANDARD_COST) AS UNIT_MARGIN, (OI.QUANTITY * P.STANDARD_COST) AS S_COST_BUY, A.L_SUM, (A.L_SUM - A.S_SUM) AS MARGIN
FROM (SELECT O.ORDER_ID, SUM(OI.QUANTITY * OI.UNIT_PRICE) AS L_SUM, SUM(OI.QUANTITY * P.STANDARD_COST) AS S_SUM, RANK() OVER(ORDER BY SUM(OI.QUANTITY * OI.UNIT_PRICE) DESC) AS RNK
      FROM ORDERS O INNER JOIN ORDER_ITEMS OI
                            ON O.ORDER_ID = OI.ORDER_ID
                    INNER JOIN PRODUCTS P
                            ON OI.PRODUCT_ID = P.PRODUCT_ID
      WHERE STATUS = 'Shipped'
      GROUP BY O.ORDER_ID) A INNER JOIN ORDER_ITEMS OI
                                     ON A.ORDER_ID = OI.ORDER_ID
                             INNER JOIN PRODUCTS P
                                     ON OI.PRODUCT_ID = P.PRODUCT_ID
WHERE A.RNK = 1
;