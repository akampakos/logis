CREATE TABLE SALARY 
(
  SAL_ID NUMBER(18) NOT NULL 
, SAL_EMPNO NUMBER(18) NOT NULL 
, SAL_DESCR VARCHAR2(1000)
, SAL_AMOUNT NUMBER(5) 
, SAL_DATE DATE
, CREATED TIMESTAMP 
, CREATED_BY VARCHAR2(255) 
, UPDATED TIMESTAMP 
, UPDATED_BY VARCHAR2(255) 
, CONSTRAINT SALARY_PK PRIMARY KEY 
  (
    SAL_ID 
  )
  ENABLE 
);

ALTER TABLE SALARY  
MODIFY (SAL_AMOUNT NUMBER(8,2) );


ALTER TABLE SALARY
ADD CONSTRAINT SALARY_FK1 FOREIGN KEY
(
  SAL_EMPNO 
)
REFERENCES EMPLOYEE
(
  EMP_NO 
)
ENABLE;

COMMENT ON TABLE SALARY IS 'Μισθοδοσία';

CREATE SEQUENCE SALARY_SEQ START WITH 1 MINVALUE 1;

ALTER SEQUENCE SALARY_SEQ NOCACHE;

--------------------------------------------------------------------------

  CREATE OR REPLACE TRIGGER SALARY_TRIG_SEQ
   before insert on SALARY
   for each row 
begin  
   if inserting then 
      if :NEW."SAL_ID" is null then 
         select SALARY_SEQ.nextval into :NEW."SAL_ID" from dual; 
      end if; 
   end if; 
end;
	
--------------------------------------------------------------------------
	
CREATE OR REPLACE TRIGGER SALARY_TRIG_LG 
BEFORE INSERT OR UPDATE ON SALARY 
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