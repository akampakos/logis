create or replace Package Pkg_Security Is
 
  Function Authenticate_User(p_User_Name Varchar2
                            ,p_Password  Varchar2) Return Boolean;

  -----
  Procedure Process_Login(p_User_Name Varchar2
                         ,p_Password  Varchar2
                         ,p_App_Id    Number);

End Pkg_Security;

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------

create or replace Package Body Pkg_Security Is
 
  Function Authenticate_User(p_User_Name Varchar2
                            ,p_Password  Varchar2) Return Boolean As
     v_Password User_Account.Password%Type;
     v_Active   User_Account.Active%Type;
     v_Email    User_Account.Email%Type;
  Begin
     If p_User_Name Is Null Or p_Password Is Null Then

        -- Write to Session, Notification must enter a username and password
        Apex_Util.Set_Session_State('LOGIN_MESSAGE'
                                   ,'Please enter Username and Password');
        Return False;
     End If;
     ----
     Begin
        Select u.Active
              ,u.Password
              ,u.Email
        Into   v_Active
              ,v_Password
              ,v_Email
        From   User_Account u
        Where  UPPER(u.User_Name) = UPPER(p_User_Name);
     Exception
        When No_Data_Found Then

           -- Write to Session, User not found.
           Apex_Util.Set_Session_State('LOGIN_MESSAGE'
                                      ,'User not found');
           Return False;
     End;
     If v_Password <> p_Password Then

        -- Write to Session, Password incorrect.
        Apex_Util.Set_Session_State('LOGIN_MESSAGE'
                                   ,'Wrong password !!!');
        Return False;
     End If;
     If v_Active <> 'Y' Then
        Apex_Util.Set_Session_State('LOGIN_MESSAGE'
                                   ,'The user is locked');
        Return False;
     End If;
     ---
     -- Write user information to Session.
     --
     Apex_Util.Set_Session_State('SESSION_USER_NAME'
                                ,p_User_Name);
     Apex_Util.Set_Session_State('SESSION_EMAIL'
                                ,v_Email);
     ---
     ---
     Return True;
  End;

  --------------------------------------
  Procedure Process_Login(p_User_Name Varchar2
                         ,p_Password  Varchar2
                         ,p_App_Id    Number) As
     v_Result Boolean := False;
  Begin
     v_Result := Authenticate_User(p_User_Name
                                  ,p_Password);
     If v_Result = True Then
        -- Redirect to Page 1 (Home Page).
        Wwv_Flow_Custom_Auth_Std.Post_Login(p_User_Name -- p_User_Name
                                           ,p_Password -- p_Password
                                           ,v('APP_SESSION') -- p_Session_Id
                                           ,p_App_Id || ':1' -- p_Flow_page
                                            );
     Else
        -- Login Failure, redirect to page 101 (Login Page).
        Owa_Util.Redirect_Url('f?p=:101:');
     End If;
  End;

End Pkg_Security;