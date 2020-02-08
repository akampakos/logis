create or replace FUNCTION GET_SALARY
(
  EMPLOYEE IN NUMBER, SALYEAR IN NUMBER, SALMONTH IN NUMBER, SALARY_AMOUNT IN NUMBER 
) RETURN NUMBER IS

cursor c1 is
    SELECT round(sum(SAL_AMOUNT), 2)
                     FROM salary
                    WHERE SAL_EMPNO = EMPLOYEE AND
                          TO_CHAR(SAL_DATE,'YYYY') = TO_CHAR(SALYEAR) AND
                          TO_CHAR(SAL_DATE,'MM') =  lpad(to_char(SALMONTH),2,'00');
vvSalary NUMBER;
BEGIN
   open c1;
   fetch c1 into vvSalary;
   close c1;

vvSalary := SALARY_AMOUNT - vvSalary;

if vvSalary is null then
  vvSalary := SALARY_AMOUNT;
end if;

RETURN vvSalary;

END GET_SALARY;