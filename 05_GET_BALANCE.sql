create or replace FUNCTION GET_BALANCE
(
  CUSTOMER IN NUMBER 
) RETURN NUMBER IS

cursor c1 is
   SELECT round(sum(BA_AMOUNT_UP - BA_AMOUNT_DOWN), 2) 
                 FROM balance
                WHERE BA_CUSTID = CUSTOMER;
vvBalance NUMBER;
BEGIN
   open c1;
   fetch c1 into vvBalance;
   close c1;
RETURN vvBalance;
END GET_BALANCE;