CREATE TABLE INVOICES 
(
  INV_ID NUMBER(18) NOT NULL 
, INV_ORDID NUMBER 
, INV_NUMBER NUMBER 
, INV_TYPE VARCHAR2(1) DEFAULT 1 
, INV_DATE DATE 
, INV_TRANS_DATE DATE
, INV_SERIES VARCHAR2(2)
, INV_VEHICLE VARCHAR2(20)
, INV_FPA NUMBER
, INV_TOTAL NUMBER
, INV_PAYMENT NUMBER(1)
, INV_DESCR VARCHAR2(4000) 
, CREATED TIMESTAMP 
, CREATED_BY VARCHAR2(255) 
, UPDATED TIMESTAMP 
, UPDATED_BY VARCHAR2(255) 
, CONSTRAINT INVOICES_PK PRIMARY KEY 
  (
    INV_ID 
  )
  ENABLE 
);

ALTER TABLE INVOICES
ADD CONSTRAINT INVOICES_ORDERS_FK FOREIGN KEY
(
  INV_ORDID 
)
REFERENCES ORDERS
(
  ORD_ID 
)
ENABLE;


CREATE SEQUENCE INVOICES_SEQ START WITH 1 MINVALUE 1;

ALTER SEQUENCE INVOICES_SEQ NOCACHE;

--------

CREATE OR REPLACE TRIGGER INVOICES_TRIG_LG 
BEFORE INSERT OR UPDATE ON INVOICES 
for each row
BEGIN
  if inserting then
           :new.created := localtimestamp;
           :new.created_by := nvl(wwv_flow.g_user,user);
  elsif updating then
           :new.updated := localtimestamp;
           :new.updated_by := nvl(wwv_flow.g_user,user);
  end if;
END;

-------

  CREATE OR REPLACE TRIGGER INVOICES_TRIG_SEQ
   before insert on INVOICES
   for each row 
begin  
   if inserting then 
      if :NEW."INV_ID" is null then 
         select INVOICES_SEQ.nextval into :NEW."INV_ID" from dual; 
      end if; 
   end if; 
end;


--------------------------------------------------------------

CREATE TABLE INSURANCE 
(
  INS_ID NUMBER(5) NOT NULL 
, INS_NAME VARCHAR2(30) 
, CONSTRAINT INSURANCE_PK PRIMARY KEY 
  (
    INS_ID 
  )
  ENABLE 
);

