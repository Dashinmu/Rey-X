/* Добавить роли */
declare
begin
    diplom.fnd_user.add_user_type('Администратор');
    diplom.fnd_user.add_user_type('Руководитель');
    diplom.fnd_user.add_user_type('Студент');
end;

/* Добавить пользователя */
declare
    p_error VARCHAR2(100);
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

    p_error := null;
    diplom.FND_USER.ADD_USER(
        P_LOGIN  => 'dashinmu',
        P_PASSWORD  => 'dashinmu23',
        P_USER_TYPE => 2,
        P_USERNAME  => 'Daniil Dashinmu',
        P_EMAIL  => 'dashinmu@gmail.com',
        P_PHONE  => '+7-919-446-04-27'
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;

    p_error := null;
    diplom.FND_USER.ADD_USER(
        P_LOGIN  => 'myasnikova_av',
        P_PASSWORD  => '321Student',
        P_USER_TYPE => 3,
        P_USERNAME  => 'Аврора Мясникова',
        P_EMAIL  => 'aurora.mv_20@gmail.com',
        P_PHONE  => '+7-919-534-14-90'
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;

    p_error := null;
    diplom.FND_USER.ADD_USER(
        P_LOGIN  => 'Solovyov_DM',
        P_PASSWORD  => '321student',
        P_USER_TYPE => 3,
        P_USERNAME  => 'Дмитрий Соловьёв',
        P_EMAIL  => 'dm.solovey@gmail.com',
        P_PHONE  => '+7-912-101-01-48',
        P_END_DATE => to_date('270624','ddmmyyyy')
        , p_error => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
end;

/* Проверить пользователя */
declare
    p_error VARCHAR2(100);
begin
    DIPLOM.FND_USER.VALID_USER(P_LOGIN => 'dashinmu', P_PASSWORD => 'dashinmu23', p_error => p_error);
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
end;

/* Проверить права пользователя */
declare
begin
    if DIPLOM.FND_USER.IS_ADMIN(P_USER => 'dashinmu')
        then DBMS_OUTPUT.PUT_LINE('Права администратора');
        else DBMS_OUTPUT.PUT_LINE('Не является администратором');
    end if;
end;

/* Связать пользователей */
declare
    p_error VARCHAR2(20);
begin
    DIPLOM.FND_USER.ADD_RELATIONSHIPS(
        P_PARENT  => 'dashinmu',
        P_CHILD  => 'myasnikova_av',
        P_ERROR  => p_error
    );
    if p_error is not null then DBMS_OUTPUT.PUT_LINE(p_error); end if;
end;

/* Личная информация */
select
    *
from
    DIPLOM.PERSONAL_INFO
where
    USER_LOGIN like upper('dashinmu')
;

