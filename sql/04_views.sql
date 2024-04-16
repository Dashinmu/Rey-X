--Представление личной информации
CREATE OR REPLACE VIEW DIPLOM.PERSONAL_INFO AS
    SELECT
        u.ID as USER_ID
        , u.NAME as USER_NAME
        , u.CONTACT_INFO1 as USER_MAIL
        , u.CONTACT_INFO2 as USER_PHONE
        , to_char(u.END_DATE, 'dd.mm.yyyy') as USER_INACTIVE_DATE
        , ut.MEANING as USER_TYPE
        , u.LOGIN as USER_LOGIN
    FROM
        DIPLOM.USERS u
        left join DIPLOM.USER_TYPE ut
            on u.type = ut.id
            --and u.END_DATE between ut.START_DATE and ut.INACTIVE_DATE
    WHERE 1 = 1
;