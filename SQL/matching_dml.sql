-- ============================================
--  매칭 게시판 기능 SQL
-- ============================================

-- 1️. 매칭 글 작성 (user_id=21, 공연 id=6 기준)
INSERT INTO match_posts (
    user_id,
    performance_id,
    title,
    content,
    view_count,
    created_at,
    updated_at,
    deleted
)
VALUES (
    21,
    6,
    'Neon Pulse 공연 같이 보러가실 분!',
    '혼자 가기 아쉬워서 같이 보러가실 분 구해요!',
    0,
    NOW(),
    NOW(),
    FALSE
);

-- 확인
SELECT match_post_id, title, created_at FROM match_posts ORDER BY match_post_id DESC;

-- 유저가 보는 화면
SELECT mp.title, u.nickname, m.status
FROM match_posts mp
JOIN matches m ON m.match_post_id = mp.match_post_id
JOIN user_profiles u ON mp.user_id = u.user_id
ORDER BY mp.match_post_id DESC
LIMIT 8, 6;



-- 2️. 매칭 글 수정/삭제 (글 비활성화)
-- 실제 삭제 대신 deleted 플래그만 변경
UPDATE match_posts
SET deleted = TRUE, updated_at = NOW()
WHERE match_post_id = 3; -- 예시 ID


-- 3️. 댓글 작성 (유저 B가 댓글 달기)
INSERT INTO match_comments (
    match_post_id,
    user_id,
    content,
    parent_comment_id,
    created_at,
    updated_at,
    deleted
)
VALUES (
    3,          -- 위의 match_post_id
    5,          -- 댓글 단 유저 (다른 사람)
    '저도 같이 가고 싶어요!',
    NULL,
    NOW(),
    NOW(),
    FALSE
);

-- 확인
SELECT comment_id, user_id, content FROM match_comments WHERE match_post_id = 3;


-- 4️. 매칭 신청 (유저 B가 유저 A의 글에 신청)
INSERT INTO matches (
    applicant_id,
    match_post_id,
    message,
    status,
    created_at,
    updated_at
)
VALUES (
    5,  -- 신청자
    3,  -- 매칭 게시글
    '저 같이 가고 싶습니다!',
    'PENDING',
    NOW(),
    NOW()
);

-- 확인
SELECT match_id, applicant_id, status FROM matches ORDER BY match_id DESC;


-- 5️. 매칭 수락/거절 (유저 A가 처리)
-- 수락 시
UPDATE matches
SET status = 'CONFIRMED', updated_at = NOW()
WHERE match_id = 2;

-- 거절 시
UPDATE matches
SET status = 'REJECTED', updated_at = NOW()
WHERE match_id = 2;


-- 6️. 매칭 현황 보기 (게시글별 신청 목록)
SELECT 
    m.match_id,
    m.applicant_id,
    u.nickname AS applicant_nickname,
    m.message,
    m.status,
    m.created_at
FROM matches m
JOIN user_profiles u ON m.applicant_id = u.user_id
WHERE m.match_post_id = 3;
