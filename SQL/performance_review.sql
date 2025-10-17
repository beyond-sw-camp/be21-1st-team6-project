/*
[공연 후기 게시판]
├─ 후기 작성 : INSERT INTO review_posts (...)
├─ 후기 수정 : UPDATE review_posts ...
├─ 후기 삭제 : UPDATE review_posts SET deleted=TRUE
├─ 후기 목록 조회 : JOIN review_posts + users + performances
├─ 좋아요 등록/취소 : INSERT / DELETE INTO post_likes
├─ 후기 등록 시 공연 후기수 증가 : Trigger - trg_review_count_after_insert
└─ 후기 요약 뷰 : View - vw_performance_reviews
*/

-- 1. 후기 작성
INSERT INTO review_posts (
	 post_id,
	 user_id,
	 performance_id,
	 title,
	 content,
	 view_count,
	 like_count,
	 created_at,
	 updated_at,
	 deleted
) VALUES (
    NULL, 1, 3, '공연후기!', '너무너무 좋은 공연이었습니다. 감사합니다', 500, 10, NOW(), NOW(), FALSE
);

DELIMITER //

CREATE PROCEDURE create_review_post(
    IN in_user_id BIGINT,
    IN in_performance_id BIGINT,
    IN in_title VARCHAR(100),
    IN in_content TEXT
)
BEGIN
    INSERT INTO review_posts (
    	post_id,
        user_id,
        performance_id,
        title,
        content,
        view_count,
        like_count,
        created_at,
        updated_at,
        deleted
    ) VALUES (
    	NULL,
        in_user_id,
        in_performance_id,
        in_title,
        in_content,
        0,          
        0,          
        NOW(),
        NOW(),
        FALSE
    );
END //

DELIMITER ;
CALL create_review_post(5, 3, '공연 후기!', '짱좋다');
     
-- 2. 후기 수정
UPDATE review_posts	
   SET title = '공연 후기입니다!',
       content = '사실 조금 별로였어요.',
       updated_at = NOW()
 WHERE post_id = 21 AND user_id = 1;
-- WHERE 절에 user_id를 함께 검사하여, 글을 작성한 본인만 수정할 수 있도록 제한

DELIMITER //

CREATE PROCEDURE update_review_post(
    IN in_post_id BIGINT,
    IN in_user_id BIGINT,
    IN in_title VARCHAR(100),
    IN in_content TEXT
)
BEGIN
    UPDATE review_posts
       SET title = in_title,
           content = in_content,
           updated_at = NOW()
     WHERE post_id = in_post_id AND user_id = in_user_id;
END //

DELIMITER ;
-- CALL sp_update_review_post(21, 1, '수정된 공연 후기!', '사실 조금 별로였어요.');
CALL update_review_post(21, 1, '수정된 공연 후기!', '별로다');

-- 3. 후기 삭제
UPDATE review_posts
   SET deleted = TRUE
 WHERE post_id = 21 AND user_id = 1; 
-- DELETE 문으로 데이터를 완전히 삭제하는 대신, deleted 컬럼의 값을 TRUE로 변경

DELIMITER //

CREATE PROCEDURE delete_review_post(
    IN in_post_id BIGINT,
    IN in_user_id BIGINT
)
BEGIN
    UPDATE review_posts
       SET deleted = TRUE
     WHERE post_id = in_post_id AND user_id = in_user_id;
END //

DELIMITER ;

CALL delete_review_post(22, 5);

-- 4. 후기 목록 조회
SELECT 
    a.post_id,
    a.title,
    a.like_count,
    a.view_count,
    b.nickname,
    c.name AS performance_name,
    a.created_at
FROM 
    review_posts AS a
JOIN 
    user_profiles AS b ON a.user_id = b.user_id
JOIN 
    performances AS c ON a.performance_id = c.performance_id
WHERE 
    a.deleted IS NOT TRUE
ORDER BY 
    a.post_id DESC
LIMIT 20; 
-- 예시: 한 페이지에 20개씩 최신순으로 조회

DELIMITER //

CREATE PROCEDURE get_review_post_list(
    IN in_page_number INT,
    IN in_page_size INT
)
BEGIN
    DECLARE offset_val INT;
    SET offset_val = (in_page_number - 1) * in_page_size;

    SELECT
        a.post_id,
        a.title,
        a.like_count,
        a.view_count,
        b.nickname,
        c.name AS performance_name,
        a.created_at
    FROM
        review_posts AS a
    JOIN
        user_profiles AS b ON a.user_id = b.user_id
    JOIN
        performances AS c ON a.performance_id = c.performance_id
    WHERE
        a.deleted IS NOT TRUE
    ORDER BY
        a.post_id DESC
    LIMIT in_page_size OFFSET offset_val;
END //

DELIMITER ;

CALL get_review_post_list(2, 10);
-- 10개씩 나눈 페이징, 2페이지부터 조회


-- 5. 좋아요 등록/취소
INSERT INTO post_likes (user_id, post_id) 
     VALUES (4, 21);
-- 좋아요를 누른 user_id, 좋아요를 받은 post_id 값

UPDATE review_posts 
   SET like_count = like_count + 1 
 WHERE post_id = 21;


DELIMITER //

CREATE PROCEDURE toggle_like_post(
    IN in_user_id BIGINT,
    IN in_post_id BIGINT
)
BEGIN
    DECLARE like_exists INT;

    SELECT COUNT(*)
      INTO like_exists
      FROM post_likes
     WHERE user_id = in_user_id AND post_id = in_post_id;

    START TRANSACTION;

    IF like_exists > 0 THEN
        DELETE FROM post_likes
         WHERE user_id = in_user_id AND post_id = in_post_id;

        UPDATE review_posts
           SET like_count = like_count - 1
         WHERE post_id = in_post_id;
    ELSE
        INSERT INTO post_likes (user_id, post_id)
             VALUES (in_user_id, in_post_id);

        UPDATE review_posts
           SET like_count = like_count + 1
         WHERE post_id = in_post_id;
    END IF;

    COMMIT;
END //

DELIMITER ;

-- How to use:
CALL toggle_like_post(4, 21);

SELECT *
  FROM review_posts
 WHERE post_id = 21;


## 댓글

-- 1.사용자가 특정 후기 게시글에 새로운 댓글을 다는 상황
INSERT INTO review_comments (post_id, user_id, parent_comment_id, content, created_at, updated_at, deleted)
VALUES (1, 4, NULL, '송대관밴드 최고의 락스타 송형욱!!', NOW(), NOW(), 0);

-- 2. 게시글에 있는 댓글 대댓 적은 상황
INSERT INTO review_comments (post_id, user_id, parent_comment_id, content, created_at, updated_at, deleted)
VALUES (1, 3, 21, '저도그렇게 느겼어요 !!관우님의 샤우팅은 정말...! 퉁퉁이 인줄 알았어요!!', NOW(), NOW(), 0);

-- 3. 댓글 수정 (updtae)
UPDATE review_comments
SET
    content = '와...저도 이 공연 갔는데 재우님의 540도 터닝슛은 정말 최고였습니다...!! 특히 조명 연출이 인상 깊었구요 공연 추천합니다.',
    updated_at = NOW()
WHERE
    comment_id = 21 AND user_id = 3;


-- 4.댓글 삭제 
-- 댓글을 db에서 완전 지우는 대신 삭제된 댓글이라고 "표시"하기 위해 상태만 변경하는것 . 
UPDATE review_comments
SET
    content = '삭제된 댓글입니다.',
    deleted = 1 -- true 의미
WHERE
    comment_id = 21 AND user_id = 3;

-- 5 댓글 목록조회 
-- 특정 게시글의 달린 댓글과 대댓을 계층 구조에 맞게 정렬 1번 게시글의 모든 댓글 불러오기
SELECT
    c.comment_id,
    c.parent_comment_id,  -- 이 컬럼의 결과 값이 null 이면 댓글 , 1이 나오면 대댓글이라는 뜻
    c.content,
    c.deleted,
    up.nickname,
    c.created_at
FROM
    review_comments AS c
JOIN
    user_profiles AS up ON c.user_id = up.user_id
WHERE
    c.post_id = 1
ORDER BY
    -- 1. 최상위 댓글을 먼저 정렬
    COALESCE(c.parent_comment_id, c.comment_id),
    -- 2. 대댓글들을 그 다음에 정렬.
    c.comment_id;


-- 6. 공연별 후기 요약 (View)
--  후기 게시판(review_posts)와 연결하여 공연별 통계 뷰 생성
CREATE OR REPLACE VIEW vw_performance_reviews AS
SELECT 
    p.performance_id,
    p.name AS performance_name,
    COUNT(r.post_id) AS total_reviews,
    IFNULL(SUM(r.like_count), 0) AS total_likes
FROM performances p
LEFT JOIN review_posts r ON p.performance_id = r.performance_id
GROUP BY p.performance_id;

-- 뷰 확인
SELECT * FROM vw_performance_reviews;
