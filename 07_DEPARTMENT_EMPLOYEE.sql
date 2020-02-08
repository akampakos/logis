create table DEPARTMENT(
  dept_no number(2,0),
  dept_name  varchar2(50),
  dept_loc    varchar2(50),
  constraint pk_dept primary key (dept_no)
);
 
create table EMPLOYEE(
  emp_no    number(4,0),
  emp_name    varchar2(20),
  emp_surname    varchar2(30),
  emp_job      varchar2(20),
  emp_hiredate date,
  emp_sal      number(7,2),
  emp_deptno   number(2,0),
  EMP_AFM VARCHAR2(20),
  EMP_AMKA VARCHAR2(30),
  EMP_INSID NUMBER(5),
  constraint pk_emp primary key (emp_no),
  constraint fk_deptno foreign key (emp_deptno) references department (dept_no)
);

ALTER TABLE EMPLOYEE 
ADD (CREATED TIMESTAMP );

ALTER TABLE EMPLOYEE 
ADD (CREATED_BY VARCHAR2(255) );

ALTER TABLE EMPLOYEE 
ADD (UPDATED TIMESTAMP );

ALTER TABLE EMPLOYEE 
ADD (UPDATED_BY VARCHAR2(255) );

CREATE SEQUENCE EMPLOYEE_SEQ START WITH 1 MINVALUE 1;

ALTER SEQUENCE EMPLOYEE_SEQ NOCACHE;

--------------------------------------------------------------------

CREATE OR REPLACE TRIGGER EMPLOYEE_TRIG_LG 
BEFORE INSERT OR UPDATE ON EMPLOYEE 
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

---------------------------------------------------------------------

  CREATE OR REPLACE TRIGGER EMPLOYEE_TRIG_SEQ
   before insert on EMPLOYEE
   for each row 
begin  
   if inserting then 
      if :NEW."EMP_NO" is null then 
         select EMPLOYEE_SEQ.nextval into :NEW."EMP_NO" from dual; 
      end if; 
   end if; 
end;