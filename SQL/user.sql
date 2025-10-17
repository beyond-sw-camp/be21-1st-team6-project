-- -------------------------------------------------
-- 회원가입
-- -------------------------------------------------

-- 일반 유저 회원가입
INSERT INTO users (email, password, permission, provider, provider_id, created_at)
    VALUES ('testcase5@sample.com', '1q2w3e4r', 'USER', NULL, NULL, NOW());

-- SNS 유저 회원가입
INSERT INTO users (email, password, permission, provider, provider_id, created_at)
    VALUES ('testcase7@sample.com', 'qwer1234', 'USER', 'kakao', 'kakaosns2@daum.net'
           , NOW());

SELECT * FROM users;

-- -------------------------------------------------
-- 로그인
-- -------------------------------------------------

-- 일반 유저 로그인
SELECT 
    u.user_id,
    u.email,
    u.permission,
    u.provider,
    up.nickname,
    up.profile_image_url,
    up.introduction,
    up.exciting_index
FROM users u
INNER JOIN user_profiles up USING(user_id)
WHERE u.email = 'testcase5@sample.com'
  AND u.password = '1q2w3e4r'
  AND u.deleted_at IS NULL;

-- SNS 유저 로그인
-- 먼가먼가 API에 요청오고 최종적으로 아이디 확인 느낌?
SELECT 
    u.user_id,
    u.email,
    u.permission,
    u.provider,
    up.nickname,
    up.profile_image_url,
    up.introduction,
    up.exciting_index
FROM users u
INNER JOIN user_profiles up USING(user_id)
WHERE u.provider = 'kakao'
  AND u.provider_id = 'kakaosns2@daum.net'
  AND u.deleted_at IS NULL;

----------------------------------------------------
-- 프로필 생성
----------------------------------------------------

-- users 테이블 업데이트
UPDATE users
SET 
    email 		= COALESCE('testcase7@sample.com', email),
    password 	= COALESCE('qwer1234', password)
WHERE user_id = (SELECT MAX(user_id) FROM users);

-- users 어드민 권한 변경
UPDATE users
SET 
    permission  = 'ADMIN'
WHERE user_id = 29;

-- user_profiles 테이블 업데이트
UPDATE user_profiles
SET 
    nickname 			= COALESCE('테스트', nickname),
    profile_image_url 	= COALESCE('beyond-SW-21th-first-6team', profile_image_url),
    changed_img 		= COALESCE('변경된 프로필 이미지', changed_img),
    introduction 		= COALESCE('소개글', introduction),
    birthdate 			= COALESCE('2002-01-01', birthdate),
    gender 				= COALESCE('MALE', gender),
    updated_at = NOW()
WHERE user_id = (SELECT MAX(user_id) FROM users);

-- 선호 장르 업데이트
-- 선호 장르 추가
INSERT INTO user_favorite_genres (user_id, genre_id) VALUES (29, 1);

-- 선호 밴드 업데이트
-- 선호 밴드 추가
INSERT INTO user_favorite_bands (user_id, band_id) VALUES (29, 1);



-- 선호 장르 삭제
DELETE FROM user_favorite_genres WHERE user_id = 29 and genre_id = 1;

-- 선호 밴드 삭제
DELETE FROM user_favorite_bands WHERE user_id = 29 and band_id = 1;



-- -------------------------------------------------
-- 마이페이지 조회
-- -------------------------------------------------
-- 유저의 모든 정보 조회
SELECT 
    u.user_id,
    u.email,
    u.permission,
    u.provider,
    u.created_at,
    up.nickname,
    up.profile_image_url,
    up.changed_img,
    up.introduction,
    up.birthdate,
    up.gender,
    up.exciting_index,
    up.updated_at, -- 케미 지수
    GROUP_CONCAT(DISTINCT g.genre_name SEPARATOR ', ') AS favorite_genres,
    GROUP_CONCAT(DISTINCT b.band_name SEPARATOR ', ') AS favorite_bands
FROM users u
INNER JOIN user_profiles up USING(user_id)
LEFT JOIN user_favorite_genres ufg USING(user_id)
LEFT JOIN genres g USING(genre_id)
LEFT JOIN user_favorite_bands ufb ON u.user_id = ufb.user_id
LEFT JOIN bands b USING(band_id)
WHERE u.user_id = 29
  AND u.deleted_at IS NULL
GROUP BY u.user_id;

-- -------------------------------------------------
-- 유저 탈퇴
-- -------------------------------------------------

-- 유저 소프트 삭제
UPDATE users
SET deleted_at = NOW()
WHERE user_id = 29
  AND deleted_at IS NULL;

SELECT deleted_at FROM users WHERE user_id = 29;

-- 유저 프로필 자동생성
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

