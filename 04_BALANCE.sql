CREATE TABLE BALANCE 
(
  BA_ID NUMBER(18) NOT NULL 
, BA_CUSTID NUMBER(18) NOT NULL 
, BA_ORD_ID NUMBER
, BA_TYPE VARCHAR2(1) 
, BA_DESCR VARCHAR2(200) 
, BA_AMOUNT_UP FLOAT 
, BA_AMOUNT_DOWN FLOAT 
, BA_DATE DATE 
, CONSTRAINT BALANCE_PK PRIMARY KEY 
  (
    BA_ID 
  )
  ENABLE 
);

COMMENT ON COLUMN BALANCE.BA_TYPE IS 'F= First row, X= Χρέωση, P= Πίστωση';

ALTER TABLE BALANCE
ADD CONSTRAINT BALANCE_FK FOREIGN KEY
(
  BA_CUSTID 
)
REFERENCES CUSTOMERS
(
  CUST_ID 
)
ENABLE;


ALTER TABLE BALANCE 
ADD (CREATED TIMESTAMP );

ALTER TABLE BALANCE 
ADD (CREATED_BY VARCHAR2(255) );

ALTER TABLE BALANCE 
ADD (UPDATED TIMESTAMP );

ALTER TABLE BALANCE 
ADD (UPDATED_BY VARCHAR2(255) );

ALTER TABLE BALANCE  
MODIFY (BA_AMOUNT_UP DEFAULT 0 );

ALTER TABLE BALANCE  
MODIFY (BA_AMOUNT_DOWN DEFAULT 0 );

ALTER TABLE BALANCE  
MODIFY (BA_DESCR VARCHAR2(500 BYTE) );

ALTER TABLE BALANCE  
MODIFY (BA_AMOUNT_UP NUMBER(10,2) );

ALTER TABLE BALANCE  
MODIFY (BA_AMOUNT_DOWN NUMBER(10,2) );

ALTER TABLE BALANCE  
MODIFY (BA_DESCR VARCHAR2(1000 BYTE) );

CREATE SEQUENCE BALANCE_SEQ START WITH 1 MINVALUE 1;

ALTER SEQUENCE BALANCE_SEQ NOCACHE;


----------------------------------------------------------------

CREATE OR REPLACE TRIGGER BALANCE_TRIG_LG 
BEFORE INSERT OR UPDATE ON BALANCE 
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


-------------------------------------------------------------------

  CREATE OR REPLACE TRIGGER BALANCE_TRIG_SEQ
   before insert on BALANCE 
   for each row 
begin  
   if inserting then 
      if :NEW."BA_ID" is null then 
         select BALANCE_SEQ.nextval into :NEW."BA_ID" from dual; 
      end if; 
   end if; 
end;