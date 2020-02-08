CREATE TABLE CUSTOMERS 
(
  CUST_ID NUMBER(18) NOT NULL 
, CUST_COID NUMBER(18)
, CUST_NAME VARCHAR2(30) 
, CUST_SURNAME VARCHAR2(30) 
, CUST_EMAIL VARCHAR2(200) 
, CUST_PHONENUM VARCHAR2(50) 
, CUST_MOBILENUM VARCHAR2(50) 
, CUST_CITY VARCHAR2(30)
, CUST_ZIPCODE VARCHAR2(20) 
, CUST_ADDRESS VARCHAR2(100) 
, CUST_AFM VARCHAR2(50) 
, CONSTRAINT CUSTOMERS_PK PRIMARY KEY 
  (
    CUST_ID 
  )
  ENABLE 
);

ALTER TABLE CUSTOMERS 
ADD (CREATED DATE );

ALTER TABLE CUSTOMERS 
ADD (CREATED_BY VARCHAR2(255) );

ALTER TABLE CUSTOMERS 
ADD (UPDATED DATE );

ALTER TABLE CUSTOMERS 
ADD (UPDATED_BY VARCHAR2(255) );

ALTER TABLE CUSTOMERS  
MODIFY (CREATED TIMESTAMP );

ALTER TABLE CUSTOMERS  
MODIFY (UPDATED TIMESTAMP );

ALTER TABLE CUSTOMERS  
MODIFY (CUST_SURNAME VARCHAR2(50 BYTE) );


CREATE SEQUENCE CUSTOMERS_SEQ START WITH 1 MINVALUE 1;

ALTER SEQUENCE CUSTOMERS_SEQ NOCACHE;

----------------------------------------------------------------------

  CREATE OR REPLACE TRIGGER "CUSTOMERS_TRIG_SEQ" 
   before insert on "CUSTOMERS" 
   for each row 
begin  
   if inserting then 
      if :NEW."CUST_ID" is null then 
         select CUSTOMERS_SEQ.nextval into :NEW."CUST_ID" from dual; 
      end if; 
   end if; 
end;

-----------------------------------------------------------------------	
	
CREATE OR REPLACE TRIGGER CUSTOMERS_TRIG_LG 
BEFORE INSERT OR UPDATE ON CUSTOMERS 
for each row
BEGIN
  if inserting then
           :new.created := localtimestamp;
           :new.created_by := nvl(wwv_flow.g_user,user);
           :new.updated := localtimestamp;
           :new.updated_by := nvl(wwv_flow.g_user,user);
  elsif updating then
           :new.updated := localtimestamp;
           :new.updated_by := nvl(wwv_flow.g_user,user);
  end if;
END;