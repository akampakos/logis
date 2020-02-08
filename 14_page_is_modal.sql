CREATE OR REPLACE FUNCTION page_is_modal(  
    p_app_id  NUMBER,  
    p_page_id NUMBER)  
  RETURN boolean  
AS  
  l_page_is_modal NUMBER;  
BEGIN  
  SELECT 1  
  INTO l_page_is_modal  
  FROM apex_application_pages  
  WHERE application_id = p_app_id  
  AND page_id          = p_page_id  
  AND page_mode        = 'Modal Dialog';  
  RETURN true;  
EXCEPTION  
WHEN no_data_found THEN  
  RETURN false;  
END;  