CREATE TABLE ORDER_ITEMS 
(
  ORDI_ID NUMBER NOT NULL 
, ORDI_ORD_ID NUMBER NOT NULL 
, ORDI_PRO_ID NUMBER(18) NOT NULL 
, ORDI_WARID NUMBER(10)
, ORDI_UNIT_PRICE NUMBER(8,2) NOT NULL 
, ORDI_QUANTITY NUMBER(8) NOT NULL 
, CONSTRAINT ORDER_ITEMS_PK PRIMARY KEY 
  (
    ORDI_ID 
  )
  ENABLE 
);

ALTER TABLE ORDER_ITEMS
ADD CONSTRAINT ORDER_ITEMS_UK UNIQUE 
(
  ORDI_ORD_ID 
, ORDI_PRO_ID 
, ORDI_WARID
)
ENABLE;

ALTER TABLE ORDER_ITEMS
ADD CONSTRAINT ORDER_ITEMS_ORDERS_FK FOREIGN KEY
(
  ORDI_ORD_ID 
)
REFERENCES ORDERS
(
  ORD_ID 
)
ENABLE;

ALTER TABLE ORDER_ITEMS
ADD CONSTRAINT ORDER_ITEMS__PRODUCT_FK FOREIGN KEY
(
  ORDI_PRO_ID 
)
REFERENCES PRODUCTS
(
  PRO_ID 
)
ENABLE;

ALTER TABLE ORDER_ITEMS
ADD CONSTRAINT ORDER_CHECK_QUANTITY CHECK 
(ORDI_QUANTITY > 0)
ENABLE;


ALTER TABLE ORDER_ITEMS 
DROP CONSTRAINT ORDER_ITEMS_ORDERS_FK;

ALTER TABLE ORDER_ITEMS 
DROP CONSTRAINT ORDER_ITEMS__PRODUCT_FK;

ALTER TABLE ORDER_ITEMS
ADD CONSTRAINT ORDER_ITEMS_ORDERS_FK FOREIGN KEY
(
  ORDI_ORD_ID 
)
REFERENCES ORDERS
(
  ORD_ID 
)
ON DELETE CASCADE ENABLE;

ALTER TABLE ORDER_ITEMS
ADD CONSTRAINT ORDER_ITEMS_PRODUCT_FK FOREIGN KEY
(
  ORDI_PRO_ID 
)
REFERENCES PRODUCTS
(
  PRO_ID 
)
ENABLE;



CREATE SEQUENCE ORDER_ITEMS_SEQ START WITH 1 MINVALUE 1;

ALTER SEQUENCE ORDER_ITEMS_SEQ NOCACHE;

------------------------------------------------ TRIGGERS ------------------------

CREATE OR REPLACE TRIGGER ORDER_ITEMS_BI
  BEFORE insert on "ORDER_ITEMS" for each row
declare
  order_item_id number;
begin
  if :new.ordi_id is null then
    select order_items_seq.nextval 
      into order_item_id 
      from dual;
    :new.ordi_id := order_item_id;
  end if;
end;



---

  CREATE OR REPLACE TRIGGER ORDER_ITEMS_AIUD_TOTAL
  after insert or update or delete on order_items

begin
  -- Update the Order Total when any order item is changed
  update orders set ord_total =
  (select sum(ORDI_UNIT_PRICE*ORDI_QUANTITY) from order_items
    where order_items.ORDI_ORD_ID = orders.ord_id);

end;

-----

 CREATE OR REPLACE TRIGGER ORDER_ITEMS_BIU_GET_PRICE
  before insert or update on order_items for each row
declare
  l_list_price number;
begin
  if :new.ordi_unit_price is null then
    -- First, we need to get the current list price of the order line item
    select PRO_PRICE
    into l_list_price
    from products
    where pro_id = :new.ordi_pro_id;
    -- Once we have the correct price, we will update the order line with the correct price
    :new.ordi_unit_price := l_list_price;
  end if;
end;