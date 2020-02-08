create table USER_ACCOUNT
(
  USER_NAME    VARCHAR2(30) not null,
  PASSWORD     VARCHAR2(60) not null,
  USER_TYPE    VARCHAR2(10) not null,
  ACTIVE       VARCHAR2(1)  not null,
  FIRST_LOGIN  NUMBER(1)    not null,
  EMAIL        VARCHAR2(64) not null,
  FULL_NAME    VARCHAR2(64) not null
) ;
  
alter table USER_ACCOUNT
  add constraint USER_ACCOUNT_PK primary key (USER_NAME) ;
alter table USER_ACCOUNT
  add constraint USER_ACCOUNT_UK unique (EMAIL) ;
  
ALTER TABLE USER_ACCOUNT  
MODIFY (FIRST_LOGIN DEFAULT 1 );
 
-----------------------------------
 
insert into user_account (USER_NAME, PASSWORD, USER_TYPE,
 ACTIVE, EMAIL, FULL_NAME)
values ('admin', 'admin', 'admin', 'Y', 'admin@example.com', 'Andreas', 0);
 
insert into user_account (USER_NAME, PASSWORD, USER_TYPE,
ACTIVE, EMAIL, FULL_NAME)
values ('pascal', '12345678', 'user', 'Y', 'pascal@example.com', 'Paschalis', 1);
 
insert into user_account (USER_NAME, PASSWORD, USER_TYPE,
ACTIVE, EMAIL, FULL_NAME)
values ('anastasia', '12345678', 'guest', 'N', 'anastasia@example.com', 'Anastasia', 1);
 
Commit;