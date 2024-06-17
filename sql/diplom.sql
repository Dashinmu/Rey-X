set SERVEROUTPUT on;

select chr(39) from dual;

declare
begin
    dbms_output.put_line('Hi');
end;

/* Добавить роли */
declare
begin
    diplom.fnd_user.add_user_type('Администратор');
    diplom.fnd_user.add_user_type('Руководитель');
    diplom.fnd_user.add_user_type('Студент');
end;

/* Добавить пользователя */
declare
    p_error VARCHAR2(400);
begin
    diplom.FND_USER.ADD_USER(
        P_LOGIN  => 'system',
        P_PASSWORD  => '321Start',
        P_USER_TYPE => 1,
        P_USERNAME  => 'System Account',
        P_EMAIL  => 'sys@gmail.com'
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
end;

select * from DIPLOM.users;

select * from diplom.stages;