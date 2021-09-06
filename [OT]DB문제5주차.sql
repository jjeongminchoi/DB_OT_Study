-- [5주차 문제1]
-- 분기별로 가장 빠르게 입사한 사람들중에서 입사한 월이 해당 분기의 첫 번째 달인 사람들의 직업을
-- 구하여 아래와 같이 출력하시오
-- 출력필드: 회원 번호, 풀네임, 직업, 입사 날짜
SELECT A.EMPLOYEE_ID, FULL_NAME, A.JOB_TITLE, A.HIRE_DATE
FROM (SELECT EMPLOYEE_ID, (FIRST_NAME || ' ' || LAST_NAME) AS FULL_NAME, JOB_TITLE,
             TO_CHAR(HIRE_DATE, 'Q'), HIRE_DATE, RANK() OVER(PARTITION BY TO_CHAR(HIRE_DATE, 'Q') ORDER BY TRUNC(HIRE_DATE, 'DD') ASC) AS RNK
      FROM EMPLOYEES) A
WHERE A.RNK = 1
;

SELECT EMPLOYEE_ID, (FIRST_NAME || ' ' || LAST_NAME) AS FULL_NAME, JOB_TITLE,
       TO_CHAR(HIRE_DATE, 'Q'), HIRE_DATE, RANK() OVER(PARTITION BY TO_CHAR(HIRE_DATE, 'Q') ORDER BY TRUNC(HIRE_DATE, 'DD') ASC) AS RNK
FROM EMPLOYEES
;
-- [5주차 문제2]
-- 주문 상태가 'Canceled' 면  0번 'Shipped'이면 1번  Pending' 이면  2번 으로 상태번호 테이블 생성하고, msg에 메시지 자유롭게 넣어주시면 됩니다.
SELECT ORDER_ID, CUSTOMER_ID, STATUS, SALESMAN_ID, ORDER_DATE,
       CASE WHEN STATUS = 'Canceled'
            THEN 0
            WHEN STATUS = 'Shipped'
            THEN 1
            ELSE 2
       END AS STATUS_NO,
       CASE WHEN STATUS = 'Canceled'
            THEN 'GDJ35 화이팅 ^^*'
            WHEN STATUS = 'Shipped'
            THEN 'GDJ35 화이팅 ^^*'
            WHEN STATUS = 'Pending'
            THEN 'GDJ35 화이팅 ^^*'
       END AS MSG
FROM ORDERS
;

-- [5주차 문제3]
-- 창고중에서 'Samsung'제품이 가장 많은 창고를 구하고 그 창고는 어느 나라에 있는 창고 인지 구하시오.
-- 출력 : WAREHOUSE_ID(창고번호), WAREHOUSE_NAME, COUNTRY, QSUM(제품수량합계)
SELECT A.WAREHOUSE_ID, W.WAREHOUSE_NAME,
      (SUBSTR(C.COUNTRY_NAME, 1, 1) || 
       SUBSTR(C.COUNTRY_NAME, 8, 1) || 
       SUBSTR(C.COUNTRY_NAME, 18, 1)) AS COUNTRY, A.QSUM
FROM (SELECT I.WAREHOUSE_ID, SUM(I.QUANTITY) AS QSUM, RANK() OVER(ORDER BY SUM(I.QUANTITY) DESC) AS RNK
      FROM PRODUCTS P INNER JOIN INVENTORIES I
                              ON P.PRODUCT_ID = I.PRODUCT_ID
      WHERE P.PRODUCT_NAME LIKE 'Samsung%'
      GROUP BY I.WAREHOUSE_ID) A INNER JOIN WAREHOUSES W
                                         ON A.WAREHOUSE_ID = W.WAREHOUSE_ID
                                 INNER JOIN LOCATIONS L
                                         ON W.LOCATION_ID = L.LOCATION_ID
                                 INNER JOIN COUNTRIES C
                                         ON L.COUNTRY_ID = C.COUNTRY_ID
WHERE A.RNK = 1
;