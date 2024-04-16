/* Пакет для работы с блоком пользователей */
CREATE OR REPLACE PACKAGE diplom.fnd_user IS

    --Получить хэш пароля
    FUNCTION get_password(
        p_password in VARCHAR2
    ) RETURN VARCHAR2;

    --Создать нового пользователя
    PROCEDURE add_user(
        p_login in VARCHAR2
        , p_password in VARCHAR2
        , p_user_type in NUMBER
        , p_username in VARCHAR2 default null
        , p_email in VARCHAR2 default null
        , p_phone in VARCHAR2 default null
        , p_end_date in DATE default null
        , p_error out VARCHAR2
    );

    --Поменять пароль учётной записи.
    PROCEDURE change_password(
        p_login in VARCHAR2
        , p_password_old in VARCHAR2
        , p_password_new in VARCHAR2
        , p_error out VARCHAR2
    );

    --Проверка корректности вводимых данных
    PROCEDURE valid_user(
        p_login in VARCHAR2
        , p_password in VARCHAR2
        , p_user_type out NUMBER
    );

    --Ввести новый тип пользователя
    PROCEDURE add_user_type(
        p_meaning in VARCHAR2
    );

    --Связать пользователей
    PROCEDURE add_relationships(
        p_parent in VARCHAR2
        , p_child in VARCHAR2
        , p_error out VARCHAR2
    );

    --Проверка доступа пользователя
    FUNCTION is_admin(
        p_user in VARCHAR2
    ) RETURN BOOLEAN;

    --Вернуть данные по login
    PROCEDURE get_personal_data(
        p_login in VARCHAR2
        , p_username out VARCHAR2
        , p_type_meaning out VARCHAR2
        , p_tutor_name out VARCHAR2
        , p_tutor_type out VARCHAR2
        , p_tutor_phone out VARCHAR2
    );

END FND_USER;

CREATE OR REPLACE PACKAGE BODY diplom.fnd_user IS

    --Глобальные переменные
    no_user_type_found exception; --Не найден тип пользователя
    PRAGMA EXCEPTION_INIT(no_user_type_found, -20001); --Связать с ошибкой в триггере

    --Получить хэш пароля
    FUNCTION get_password(
        p_password in VARCHAR2
    ) RETURN VARCHAR2 IS
    v_salt VARCHAR2(10) := 'DASHINMU'; --соль для хэширования
    BEGIN
        RETURN sys.DBMS_CRYPTO.HASH(UTL_RAW.CAST_TO_RAW(P_PASSWORD||V_SALT), DBMS_CRYPTO.HASH_SH1);
    END get_password;

    --Создать нового пользователя
    PROCEDURE add_user(
        p_login in VARCHAR2
        , p_password in VARCHAR2
        , p_user_type in NUMBER
        , p_username in VARCHAR2 default null
        , p_email in VARCHAR2 default null
        , p_phone in VARCHAR2 default null
        , p_end_date in DATE default null
        , p_error out VARCHAR2
    ) IS
    BEGIN
        --Присвоить имя пользователю
        if p_username is null then 
            INSERT INTO DIPLOM.USERS(
                LOGIN
                , PASSWORD
                , TYPE
                , NAME
                , CONTACT_INFO1
                , CONTACT_INFO2
                , END_DATE
            ) VALUES (
                p_login
                , p_password
                , p_user_type
                , p_login
                , p_email
                , p_phone
                , p_end_date
            );
        else
            INSERT INTO DIPLOM.USERS(
                LOGIN
                , PASSWORD
                , TYPE
                , NAME
                , CONTACT_INFO1
                , CONTACT_INFO2
                , END_DATE
            ) VALUES (
                p_login
                , p_password
                , p_user_type
                , p_username
                , p_email
                , p_phone
                , p_end_date
            );
        end if;
        commit;

        exception 
            when no_user_type_found then p_error := ('ERROR: Не существует тип пользователя с id = '||p_user_type);
            when others then p_error := 'Пользовать '||p_login||' уже существует в системе';
    END add_user;

    PROCEDURE change_password(
        p_login in VARCHAR2
        , p_password_old in VARCHAR2
        , p_password_new in VARCHAR2
        , p_error out VARCHAR2
    ) IS
        flag ROWID;
    BEGIN
        begin
            --Найти пользователя по параметрам
            select
                rowid
            into
                flag
            from
                DIPLOM.USERS
            where 1 = 1
                and login = upper(p_login)
                and password = get_password(p_password_old)
            ;
            --Если пользователь не найден
            exception when others then p_error := 'Введёные данные не совпадают с текущими';
        end;

        --Обновить его данные
        update DIPLOM.USERS
        set password = get_password(p_password_new)
        where 1 = 1
            and rowid = flag
        ;
        --Зафиксировать данные
        commit;
    END change_password;

    --Проверка пользователя
    PROCEDURE valid_user(
        p_login in VARCHAR2
        , p_password in VARCHAR2
        , p_user_type out NUMBER
    ) IS
    BEGIN
        select
            type
        into
            p_user_type
        from
            DIPLOM.USERS
        where 1 = 1
            and login = upper(p_login)
            and password = get_password(p_password)
        ;
        --Если пользователь не найден возвращаем 0
        exception when others then p_user_type := 0;
    END valid_user;

    --Ввести новый тип пользователя
    PROCEDURE add_user_type(
        p_meaning in VARCHAR2
    ) IS
    BEGIN
        insert into DIPLOM.USER_TYPE(meaning) values (p_meaning);
        commit;
    END add_user_type;

    --Связать пользователей
    PROCEDURE add_relationships(
        p_parent in VARCHAR2
        , p_child in VARCHAR2
        , p_error out VARCHAR2
    ) IS 
        p_parent_id NUMBER(5);
        p_child_id NUMBER(5);
    BEGIN
        begin
            select id into p_parent_id from DIPLOM.USERS where login = upper(p_parent);
        end;
        begin
            select id into p_child_id from DIPLOM.USERS where login = upper(p_child);
        end;
        insert into DIPLOM.PERSON_RELATIONS(parent, child) values (p_parent_id, p_child_id);
        commit;

        exception when others then p_error := 'ОШИБКА';
    END add_relationships;

    --Проверка доступа пользователя
    FUNCTION is_admin(
        p_user in VARCHAR2
    ) RETURN BOOLEAN IS
        admin NUMBER(1);
    BEGIN
        select 1 into admin from DIPLOM.users where upper(p_user) = login and type in (1, 2);
        return true;
        exception when others then return false;
    END is_admin;

    --Вернуть данные по login и usertype
    PROCEDURE get_personal_data(
        p_login in VARCHAR2
        , p_username out VARCHAR2
        , p_type_meaning out VARCHAR2
        , p_tutor_name out VARCHAR2
        , p_tutor_type out VARCHAR2
        , p_tutor_phone out VARCHAR2
    ) IS
    BEGIN
        SELECT
            pi.USER_NAME
            , pi.USER_TYPE
            , pi_t.USER_NAME
            , pi_t.USER_TYPE
            , pi_t.USER_PHONE
        INTO
            p_username
            , p_type_meaning
            , p_tutor_name
            , p_tutor_type
            , p_tutor_phone
        FROM
            DIPLOM.PERSONAL_INFO pi
            --Может быть такое, что руководитель не назначен
            left join DIPLOM.PERSON_RELATIONS pr
                on pr.CHILD = pi.USER_ID
                and trunc(sysdate) between pr.START_DATE and pr.END_DATE
            left join DIPLOM.PERSONAL_INFO pi_t
                on pi_t.USER_ID = pr.PARENT
        WHERE 1 = 1
            and pi.USER_LOGIN like upper(p_login)
            and trunc(sysdate) <= to_date(pi.USER_INACTIVE_DATE, 'dd.mm.yyyy')
        ;
        exception when others then p_username := '000';
    END get_personal_data;

END FND_USER;