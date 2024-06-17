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
        , p_start_date in VARCHAR2 default null
        , p_end_date in VARCHAR2 default null
        , p_user in NUMBER default null
        , p_give_stage in NUMBER default null
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
        , p_user_id out NUMBER
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
        p_user in NUMBER
    ) RETURN BOOLEAN;

    --Вернуть данные по login
    PROCEDURE get_personal_data(
        p_login in VARCHAR2
        , p_username out VARCHAR2
        , p_userphone out VARCHAR2
        , p_usermail out VARCHAR2
        , p_type_meaning out VARCHAR2
        , p_tutor_name out VARCHAR2
        , p_tutor_type out VARCHAR2
        , p_tutor_phone out VARCHAR2
    );

    --Обновить данные пользователя
    PROCEDURE update_user(
        p_login in VARCHAR2 default null
        , p_password in VARCHAR2 default null
        , p_username in VARCHAR2 default null
        , p_email in VARCHAR2 default null
        , p_phone in VARCHAR2 default null
        , p_start_date in VARCHAR2 default null
        , p_end_date in VARCHAR2 default null
        , p_user in NUMBER
        , p_tutor in NUMBER
        , p_error out VARCHAR2
    );

END FND_USER;

CREATE OR REPLACE PACKAGE BODY diplom.fnd_user IS

    --Глобальные переменные
    no_user_type_found exception; --Не найден тип пользователя
    userNotFound EXCEPTION; --Не найден пользователь по логину
    PRAGMA EXCEPTION_INIT(no_user_type_found, -20001); --Связать с ошибкой в триггере
    PRAGMA EXCEPTION_INIT(userNotFound, -20006);

    --Получить хэш пароля
    FUNCTION get_password(
        p_password in VARCHAR2
    ) RETURN VARCHAR2 IS
    v_salt VARCHAR2(10) := 'DASHINMU'; --соль для хэширования
    BEGIN
        RETURN sys.DBMS_CRYPTO.HASH(UTL_RAW.CAST_TO_RAW(P_PASSWORD||V_SALT), DBMS_CRYPTO.HASH_SH1);
    END get_password;

    --Привязать пользователя
    PROCEDURE link_user(
        p_user in NUMBER
        , p_student in VARCHAR2
    ) IS
        student_id NUMBER(5);
    BEGIN
        SELECT
            ID
        INTO
            student_id
        FROM
            DIPLOM.USERS
        WHERE 1 = 1
            and LOGIN = upper(p_student)
        ;
        INSERT INTO DIPLOM.PERSON_RELATIONS(
            PARENT
            , CHILD
        ) VALUES (
            p_user
            , student_id
        );
        commit;
    END;

    --Получить ID по LOGIN
    FUNCTION get_userID(
        p_login in VARCHAR2
    ) RETURN NUMBER IS
        userID NUMBER(5);
    BEGIN
        SELECT
            ID
        INTO
            userID
        FROM
            DIPLOM.USERS
        WHERE 1 = 1
            and LOGIN = upper(p_login)
        ;
        RETURN userID;
        EXCEPTION WHEN OTHERS THEN return 0;
    END;

    --Создать нового пользователя
    PROCEDURE add_user(
        p_login in VARCHAR2
        , p_password in VARCHAR2
        , p_user_type in NUMBER
        , p_username in VARCHAR2 default null
        , p_email in VARCHAR2 default null
        , p_phone in VARCHAR2 default null
        , p_start_date in VARCHAR2 default null
        , p_end_date in VARCHAR2 default null
        , p_user in NUMBER default null
        , p_give_stage in NUMBER default null
        , p_error out VARCHAR2
    ) IS
        /* p_error VARCHAR2(400); */
    BEGIN
        --Присвоить имя пользователю
        INSERT INTO DIPLOM.USERS(
            LOGIN
            , PASSWORD
            , TYPE
            , NAME
            , CONTACT_INFO1
            , CONTACT_INFO2
            , START_DATE
            , END_DATE
        ) VALUES (
            p_login
            , p_password
            , p_user_type
            , nvl(p_username, p_login)
            , p_email
            , p_phone
            , to_date(p_start_date, 'YYYY-MM-DD')
            , to_date(p_end_date, 'YYYY-MM-DD')
        );

        commit;

        if p_user is not null and p_user != 1 then 
            link_user(
                p_user => p_user
                , p_student => p_login
            );
            if get_userID(p_login) != 0 
                then
                    if p_give_stage is not null
                        then 
                            DIPLOM.FND_TASKS.GIVE_STAGE(
                                P_USER  => p_user,
                                P_STAGE  => p_give_stage,
                                P_STUDENT  => get_userID(p_login),
                                P_ERROR  => p_error
                            );
                        else
                            DIPLOM.FND_TASKS.GIVE_STAGE(
                                P_USER  => p_user,
                                P_STAGE  => 1,
                                P_STUDENT  => get_userID(p_login),
                                P_ERROR  => p_error
                            );
                    end if;
                else
                    raise_application_error(-20006, 'Пользователь не найден по логину.');
            end if;
            if p_error is not null then raise_application_error(-20006, SQLERRM); end if;
        end if;

        exception 
            when no_user_type_found then p_error := 'ERROR: Не существует тип пользователя с id = '||p_user_type;
            when userNotFound then p_error := SQLERRM;
            when others then p_error := SQLERRM;
    END add_user;

    --Обновить данные пользователя
    PROCEDURE update_user(
        p_login in VARCHAR2 default null
        , p_password in VARCHAR2 default null
        , p_username in VARCHAR2 default null
        , p_email in VARCHAR2 default null
        , p_phone in VARCHAR2 default null
        , p_start_date in VARCHAR2 default null
        , p_end_date in VARCHAR2 default null
        , p_user in NUMBER
        , p_tutor in NUMBER
        , p_error out VARCHAR2
    ) IS
    BEGIN
        UPDATE
            DIPLOM.USERS
        SET
            LOGIN = p_login
            , NAME = p_username
            , PASSWORD = p_password
            , CONTACT_INFO1 = p_email
            , CONTACT_INFO2 = p_phone
            , START_DATE = to_date(p_start_date, 'YYYY-MM-DD')
            , END_DATE = to_date(p_end_date, 'YYYY-MM-DD')
        WHERE 1 = 1
            and ID = p_user
        ;
        commit;
        UPDATE
            DIPLOM.PERSON_RELATIONS
        SET
            START_DATE = to_date(p_start_date, 'YYYY-MM-DD')
            , END_DATE = to_date(p_end_date, 'YYYY-MM-DD')
        WHERE
            CHILD = p_user
            and PARENT = p_tutor
        ;
        commit;

        exception when others then p_error := SQLERRM;
    END;

    --Поменять пароль учётной записи.
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
        , p_user_id out NUMBER
    ) IS
    BEGIN
        select
            type
            , id
        into
            p_user_type
            , p_user_id
        from
            DIPLOM.USERS
        where 1 = 1
            and login = upper(p_login)
            and password = get_password(p_password)
            and trunc(sysdate) between START_DATE and END_DATE
        ;
        --Если пользователь не найден возвращаем 0
        exception when others then p_user_type := 0; p_user_id := 0;
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
        p_user in NUMBER
    ) RETURN BOOLEAN IS
        admin NUMBER(1);
    BEGIN
        select 1 into admin from DIPLOM.users where p_user = id and type in (1, 2);
        return true;
        exception when others then return false;
    END is_admin;

    --Вернуть данные по login и usertype
    PROCEDURE get_personal_data(
        p_login in VARCHAR2
        , p_username out VARCHAR2
        , p_userphone out VARCHAR2
        , p_usermail out VARCHAR2
        , p_type_meaning out VARCHAR2
        , p_tutor_name out VARCHAR2
        , p_tutor_type out VARCHAR2
        , p_tutor_phone out VARCHAR2
    ) IS
    BEGIN
        SELECT
            pi.USER_NAME
            , nvl(pi.USER_PHONE, 'UNKNOWN')
            , nvl(pi.USER_MAIL, 'UNKNOWN')
            , pi.USER_TYPE
            , nvl(pi_t.USER_NAME, 'UNKNOWN')
            , nvl(pi_t.USER_TYPE, 'UNKNOWN')
            , nvl(pi_t.USER_PHONE, 'UNKNOWN')
        INTO
            p_username
            , p_userphone
            , p_usermail
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
            and trunc(sysdate) <= pi.USER_INACTIVE_DATE
        ;
        exception when others then p_username := '000';
    END get_personal_data;

END FND_USER;