-- 문제1.(도헌)
-- 제품 원가 순위중 금액이 높은 2위와 10위의 차를 구하고(소수 1째자리 반올림), 차이보다 낮은 판매원가 금액은 2.7배 증가, 높으면 0.5배감소 시키고,
-- 변경된 판매원가의 2위의 주문수량과 변경된 판매원가와 기존 판매원가의 차를 구하고, 제품회사명을 출력하시오.
-- 출력필드 : 제품번호, 제품회사명, 카테고리명, 주문수량, 판매가, 변경된판매원가, 차이
SELECT A.PRODUCT_ID, SUBSTR(A.PRODUCT_NAME, 1, 5) AS COMPANY_NAME, 
       PC.CATEGORY_NAME, OI.QUANTITY, A.LIST_PRICE, A.F_PRICE, (A.F_PRICE - A.LIST_PRICE) AS CHA
FROM (SELECT P.PRODUCT_ID, P.PRODUCT_NAME, CATEGORY_ID, 
             CASE WHEN A.CHA > P.LIST_PRICE
                  THEN P.LIST_PRICE * 2.7
                  WHEN A.CHA < P.LIST_PRICE
                  THEN P.LIST_PRICE * 0.5
             END AS F_PRICE, 
             RANK() OVER(ORDER BY CASE WHEN A.CHA > P.LIST_PRICE
                                       THEN P.LIST_PRICE * 2.7
                                       WHEN A.CHA < P.LIST_PRICE
                                       THEN P.LIST_PRICE * 0.5
                                  END DESC) AS RNK, P.LIST_PRICE
      FROM (SELECT ROUND(MAX(P.STANDARD_COST) - MIN(P.STANDARD_COST), 0) AS CHA
            FROM (SELECT STANDARD_COST, RANK() OVER(ORDER BY STANDARD_COST DESC) AS RNK
                  FROM PRODUCTS) P
            WHERE P.RNK IN (2, 10)) A INNER JOIN PRODUCTS P
                                              ON 1 = 1) A INNER JOIN PRODUCT_CATEGORIES PC
                                                                  ON A.CATEGORY_ID = PC.CATEGORY_ID
                                                          INNER JOIN ORDER_ITEMS OI
                                                                  ON A.PRODUCT_ID = OI.PRODUCT_ID
                                                          INNER JOIN ORDERS O
                                                                  ON OI.ORDER_ID = O.ORDER_ID
WHERE A.RNK = 2
;

--문제2.(희두)
-- 모든 입사일에 100일을 더한 뒤 월별(연도는 제외합니다) 입사자 수를 구하여 그 중 입사자가 가장 많은 달을 뽑으시오
-- 출력 : 해당 달,해당 달의 마지막 일자
SELECT E.MONTH, E.LAST
FROM (SELECT TO_CHAR(HIRE_DATE + 100, 'MM') AS MONTH, MAX(LAST_DAY(HIRE_DATE + 100)) AS LAST, COUNT(*), 
             RANK() OVER(ORDER BY COUNT(*) DESC) AS RNK
      FROM EMPLOYEES
      GROUP BY TO_CHAR(HIRE_DATE + 100, 'MM')) E
WHERE E.RNK = 1
;
      
--문제3.(시연)
-- 물건 주문을 완료한 고객들은 자신이 주문한 물건이 현재 어디에 있는지 궁금해 합니다.
-- 하지만 그러기 위해선 영어와 숫자가 혼합된 10자리 임시비밀번호가 필요한데요, 
-- 고객들이 자신이 주문한 물건을 조회할 수 있도록 영어와 숫자가 혼합된 10자리 임시비밀번호를 만들어 주세요
-- [고객아이디, 고객이름, 임시비밀번호]
SELECT O.CUSTOMER_ID, C.NAME, DBMS_RANDOM.STRING('X', 10) AS C_PW
FROM ORDERS O INNER JOIN CUSTOMERS C
                      ON O.CUSTOMER_ID = C.CUSTOMER_ID
WHERE O.STATUS = 'Pending'
;

--문제4.(건정)
-- first name이 4자 이하인 고객의 주문이 발송된상태와 주소를 구하시오. 
-- 출력 : first_name, address, status
SELECT C.FIRST_NAME, CU.ADDRESS, O.STATUS
FROM CONTACTS C INNER JOIN ORDERS O
                        ON C.CUSTOMER_ID = O.CUSTOMER_ID
                INNER JOIN CUSTOMERS CU
                        ON C.CUSTOMER_ID = CU.CUSTOMER_ID
WHERE LENGTH(C.FIRST_NAME) <= 4 AND O.STATUS = 'Shipped'
;