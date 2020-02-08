CREATE TABLE WAREHOUSE 
(
  WAR_ID NUMBER(10) NOT NULL 
, WAR_NAME VARCHAR2(100)
, WAR_PRIMARY NUMBER(1) 
, WAR_ADDRESS VARCHAR2(200) 
, WAR_CITY VARCHAR2(50) 
, WAR_REGION VARCHAR2(50) 
, WAR_STATE VARCHAR2(50) 
, WAR_COUNTRY VARCHAR2(50) 
, CONSTRAINT WAREHOUSE_PK PRIMARY KEY 
  (
    WAR_ID 
  )
  ENABLE 
);

CREATE SEQUENCE WAREHOUSE_SEQ START WITH 1 MINVALUE 1;

ALTER SEQUENCE WAREHOUSE_SEQ NOCACHE;

---
  CREATE OR REPLACE TRIGGER WAREHOUSE_SEQ
   before insert on WAREHOUSE
   for each row 
begin  
   if inserting then 
      if :NEW."WAR_ID" is null then 
         select WAREHOUSE_SEQ.nextval into :NEW."WAR_ID" from dual; 
      end if; 
   end if; 
end;
---

------------------------------------------------- DETAIL -------------------------------------------------

CREATE TABLE WAR_PRODUCTS 
(
  WARP_ID NUMBER NOT NULL ENABLE
, WARP_WARID NUMBER(10) NOT NULL ENABLE
, WARP_PROID NUMBER(18) NOT NULL ENABLE
, WARP_FUND NUMBER(10) DEFAULT 0 NOT NULL ENABLE
);

CREATE SEQUENCE WAREHOUSE_PRO_SEQ START WITH 1 MINVALUE 1;

ALTER SEQUENCE WAREHOUSE_PRO_SEQ NOCACHE;

ALTER TABLE WAR_PRODUCTS
ADD CONSTRAINT WAR_PRODUCTS_FK FOREIGN KEY
(
  WARP_PROID 
)
REFERENCES PRODUCTS
(
  PRO_ID 
)
ENABLE;

ALTER TABLE WAR_PRODUCTS
ADD CONSTRAINT WAR_WAREHOUSE_FK FOREIGN KEY
(
  WARP_WARID 
)
REFERENCES WAREHOUSE
(
  WAR_ID 
)
ENABLE;

ALTER TABLE WAR_PRODUCTS
ADD CONSTRAINT WAR_PRODUCTS_UK UNIQUE 
(
  WARP_WARID 
, WARP_PROID 
)
ENABLE;


--- Alter OREDER_ITEMS ---------

ALTER TABLE ORDER_ITEMS
ADD CONSTRAINT ORDER_ITEMS_WAREHOUSE FOREIGN KEY
(
  ORDI_WARID 
)
REFERENCES WAREHOUSE
(
  WAR_ID 
)
ENABLE;
--------------------------------

-----------------------------------------------------------------------------------------------------------
------------------------------------------- TRIGGERS ------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
---
  CREATE OR REPLACE TRIGGER WAR_PRODUCTS_SEQ
   before insert on WAR_PRODUCTS
   for each row 
begin  
   if inserting then 
      if :NEW."WARP_ID" is null then 
         select WAREHOUSE_PRO_SEQ.nextval into :NEW."WARP_ID" from dual; 
      end if; 
   end if; 
end;
---
-----------------------------------------------------------------------------------------------------------
  CREATE OR REPLACE TRIGGER ORDER_ITEMS_WAREHOUSE_INS 
  AFTER INSERT ON order_items
  REFERENCING NEW AS NEW
  FOR EACH ROW

DECLARE
  -- Elegxos an yparxei to proion stin apothiki
  CURSOR CHECK_WAR_PRODUCT (vvwarid number, vvproid number) IS
   select count(*) from war_products where warp_warid = vvwarid and warp_proid = vvproid;

  vvcheckpro number := 0;

  -- Elegxos an eparkei to apothema
  CURSOR CHECK_WAR_FUND (vvwarid number, vvproid number) IS
   select WARP_FUND from war_products where warp_warid = vvwarid and warp_proid = vvproid;  

  vvfund number;

  -- Emfanisi proiontos + apothikis
  CURSOR DISPLAY_PRODUCT (vvwarid number, vvproid number) IS
   select WAR_NAME,PRO_NAME from war_products,warehouse,products 
    where warp_warid = vvwarid 
      and warp_proid = vvproid
      and war_id = war_products.WARP_WARID
      and pro_id = war_products.WARP_PROID;

  vvproname varchar(50);
  vvwarname varchar(100);
begin
 OPEN CHECK_WAR_PRODUCT (:new.ORDI_WARID,:new.ORDI_PRO_ID);
 FETCH CHECK_WAR_PRODUCT INTO vvcheckpro;
 CLOSE CHECK_WAR_PRODUCT;

if vvcheckpro > 0 then
  OPEN CHECK_WAR_FUND (:new.ORDI_WARID,:new.ORDI_PRO_ID);
  FETCH CHECK_WAR_FUND INTO vvfund;
  CLOSE CHECK_WAR_FUND;

  if (vvfund - :new.ORDI_QUANTITY) >= 0 then
       UPDATE war_products
       SET war_products.warp_fund = (war_products.warp_fund - :new.ORDI_QUANTITY) 
       WHERE war_products.WARP_PROID = :new.ORDI_PRO_ID and
             war_products.WARP_WARID = :new.ORDI_WARID;
  else
       OPEN DISPLAY_PRODUCT (:new.ORDI_WARID,:new.ORDI_PRO_ID);
       FETCH DISPLAY_PRODUCT INTO vvwarname,vvproname;
       CLOSE DISPLAY_PRODUCT;
    
        apex_error.add_error (
        p_message          => 'Product stock is insufficient <b>' ||vvproname|| '</b> at the warehouse <b>' ||vvwarname|| '</b> <br>' ||
                               'Available stock <b>' ||vvfund|| '</b> pieces',
        p_display_location => apex_error.c_inline_in_notification );  
  end if;
else
    
apex_error.add_error (
p_message          => 'The product does not exist!!!',
p_display_location => apex_error.c_inline_in_notification );     
end if;

end;

---
-----------------------------------------------------------------------------------------------------------
 CREATE OR REPLACE TRIGGER ORDER_ITEMS_WAREHOUSE_UPD
  AFTER UPDATE ON order_items
  REFERENCING NEW AS NEW OLD AS OLD
  FOR EACH ROW
  
DECLARE
  -- Check if the product is in stock
  CURSOR CHECK_WAR_PRODUCT (vvwarid number, vvproid number) IS
   select count(*) from war_products where warp_warid = vvwarid and warp_proid = vvproid;

  vvcheckpro number := 0;

  -- Check if the stock is sufficient
  CURSOR CHECK_WAR_FUND (vvwarid number, vvproid number) IS
   select WARP_FUND from war_products where warp_warid = vvwarid and warp_proid = vvproid;  

  vvfund  number;

  -- Product Display
  CURSOR DISPLAY_PRODUCT (vvwarid number, vvproid number) IS
   select WAR_NAME,PRO_NAME from war_products,warehouse,products 
    where warp_warid = vvwarid 
      and warp_proid = vvproid
      and war_id = war_products.WARP_WARID
      and pro_id = war_products.WARP_PROID;

  vvproname varchar(50);
  vvwarname varchar(100);
begin

OPEN CHECK_WAR_PRODUCT (:new.ORDI_WARID,:new.ORDI_PRO_ID);
FETCH CHECK_WAR_PRODUCT INTO vvcheckpro;
CLOSE CHECK_WAR_PRODUCT;

if vvcheckpro > 0 then
OPEN CHECK_WAR_FUND (:new.ORDI_WARID,:new.ORDI_PRO_ID);
FETCH CHECK_WAR_FUND INTO vvfund;
CLOSE CHECK_WAR_FUND;
  
  if :new.ORDI_PRO_ID = :old.ORDI_PRO_ID then
         if  :new.ORDI_WARID = :old.ORDI_WARID then
               if ((vvfund + :old.ORDI_QUANTITY) - :new.ORDI_QUANTITY) >= 0 then
                  UPDATE war_products
                  SET warp_fund = (warp_fund + :old.ORDI_QUANTITY)- :new.ORDI_QUANTITY 
                  WHERE war_products.WARP_PROID = :new.ORDI_PRO_ID and
                        war_products.WARP_WARID = :new.ORDI_WARID;
                else
                    OPEN DISPLAY_PRODUCT (:new.ORDI_WARID,:new.ORDI_PRO_ID);
                    FETCH DISPLAY_PRODUCT INTO vvwarname,vvproname;
                    CLOSE DISPLAY_PRODUCT;
        
                    apex_error.add_error (
                    p_message          => 'Product stock is insufficient <b>' ||vvproname|| '</b> at the warehouse <b>' ||vvwarname|| '</b> <br>' ||
                                           'Available stock <b>' ||vvfund|| '</b> pieces',
                    p_display_location => apex_error.c_inline_in_notification );  
                end if;
          else           
               if (vvfund - :new.ORDI_QUANTITY) >= 0 then
                  UPDATE war_products
                   SET warp_fund = (warp_fund + :old.ORDI_QUANTITY)
                   WHERE war_products.WARP_PROID = :old.ORDI_PRO_ID and
                         war_products.WARP_WARID = :old.ORDI_WARID;
            
                  UPDATE war_products
                   SET warp_fund = (warp_fund - :new.ORDI_QUANTITY) 
                   WHERE war_products.WARP_PROID = :new.ORDI_PRO_ID and
                         war_products.WARP_WARID = :new.ORDI_WARID;  
                else
                    OPEN DISPLAY_PRODUCT (:new.ORDI_WARID,:new.ORDI_PRO_ID);
                    FETCH DISPLAY_PRODUCT INTO vvwarname,vvproname;
                    CLOSE DISPLAY_PRODUCT;
        
                    apex_error.add_error (
                    p_message          => 'Product stock is insufficient <b>' ||vvproname|| '</b> at the warehouse <b>' ||vvwarname|| '</b> <br>' ||
                                           'Available stock <b>' ||vvfund|| '</b> pieces',
                    p_display_location => apex_error.c_inline_in_notification );  
                end if;        
         end if;
  else        
       if (vvfund - :new.ORDI_QUANTITY) >= 0 then
          UPDATE war_products
          SET warp_fund = warp_fund - :new.ORDI_QUANTITY 
          WHERE war_products.WARP_PROID = :new.ORDI_PRO_ID and
                war_products.WARP_WARID = :new.ORDI_WARID;
                
          UPDATE war_products
          SET warp_fund = warp_fund + :old.ORDI_QUANTITY 
          WHERE war_products.WARP_PROID = :old.ORDI_PRO_ID and
                war_products.WARP_WARID = :old.ORDI_WARID;                        
        else
            OPEN DISPLAY_PRODUCT (:new.ORDI_WARID,:new.ORDI_PRO_ID);
            FETCH DISPLAY_PRODUCT INTO vvwarname,vvproname;
            CLOSE DISPLAY_PRODUCT;

            apex_error.add_error (
            p_message          => 'Product stock is insufficient <b>' ||vvproname|| '</b>  at the warehouse <b>' ||vvwarname|| '</b> <br>' ||
                                   'Available stock <b>' ||vvfund|| '</b> pieces',
            p_display_location => apex_error.c_inline_in_notification );  
        end if;
  end if;
else

apex_error.add_error (
p_message          => 'The product you have in stock does not exist!!!',
p_display_location => apex_error.c_inline_in_notification );     
end if;

end;

---
-----------------------------------------------------------------------------------------------------------

create or replace TRIGGER ORDER_ITEMS_WAREHOUSE_DEL
  AFTER DELETE ON order_items
  REFERENCING NEW AS NEW OLD AS OLD
  FOR EACH ROW
begin

   UPDATE war_products
   SET warp_fund = (warp_fund + :old.ORDI_QUANTITY) 
   WHERE war_products.WARP_PROID = :old.ORDI_PRO_ID and
         war_products.WARP_WARID = :old.ORDI_WARID;

end;

---
-----------------------------------------------------------------------------------------------------------

