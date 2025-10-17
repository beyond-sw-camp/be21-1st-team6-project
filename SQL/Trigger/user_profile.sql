DELIMITER $$

DROP TRIGGER IF EXISTS trg_create_profile_after_user_insert$$

CREATE TRIGGER trg_create_profile_after_user_insert
AFTER INSERT ON users
FOR EACH ROW
BEGIN
    INSERT INTO user_profiles (
        user_id,
        nickname,
        profile_image_url,
        changed_img,
        introduction,
        birthdate,
        gender,
        exciting_index,
        created_at,
        updated_at
    )
    VALUES (
        NEW.user_id,
        CONCAT('user_', NEW.user_id),
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        50.0,
        NOW(),
        NOW()
    );
END$$

DELIMITER ;