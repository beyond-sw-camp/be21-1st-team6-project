-- ============================================
-- 신고 / 관리자 기능 SQL
-- ============================================

-- 1️. 신고 등록
-- 사용자가 다른 사용자를 신고하거나, 게시글을 신고하는 단계
-- 예시: user_id=21(신고자)가 user_id=5(피신고자)를 신고

INSERT INTO reports (
    reporter_id,   -- 신고자 ID
    reported_id,   -- 피신고자 ID
    report_type,   -- 신고 유형 (USER, MATCH_POST, REVIEW_POST, COMMENT)
    reason,        -- 신고 사유
    description,   -- 상세 내용
    status,        -- 기본 'PENDING'
    created_at
)
VALUES (
    21,            -- 신고자 (새 유저)
    5,             -- 피신고자 (기존 유저)
    'USER',        -- 유형: 유저 신고
    '부적절한 언행', 
    '매칭 게시판에서 비속어 사용', 
    'PENDING', 
    NOW()
);

-- 결과 확인
SELECT report_id, reporter_id, reported_id, report_type, reason, status
FROM reports
ORDER BY report_id DESC;


-- 2️. 관리자 신고 처리 (상태 변경)
-- 관리자가 해당 신고를 검토 후 처리 완료
-- 예: report_id = 1

UPDATE reports
SET status = 'RESOLVED',
    resolved_at = NOW()
WHERE report_id = 1;

-- 확인
SELECT report_id, status, resolved_at FROM reports WHERE report_id = 1;


-- 3️. 관리자 로그 등록
-- 관리자가 어떤 조치를 취했는지 기록 (예: report_id=1에 대한 조치)
-- 예시: admin_id = 20 (기존 users 더미데이터 중 관리자 계정)
-- target_entity = 'REPORT', target_id = 신고 ID

INSERT INTO administrators (
    admin_id,
    action_type,
    target_entity,
    target_id,
    details,
    created_at
)
VALUES (
    20,
    'REPORT_REVIEW',
    'REPORT',
    1,
    '사용자 신고 검토 완료 — 경고 조치',
    NOW()
);

-- 확인
SELECT admin_log_id, admin_id, action_type, target_entity, target_id, details, created_at
FROM administrators
ORDER BY admin_log_id DESC;


-- 4️. 미처리 신고 현황 조회
-- 관리자가 현재 PENDING 상태의 신고 목록을 조회

SELECT 
    r.report_id,
    u1.nickname AS reporter_nickname,
    u2.nickname AS reported_nickname,
    r.report_type,
    r.reason,
    r.status,
    r.created_at
FROM reports r
JOIN user_profiles u1 ON r.reporter_id = u1.user_id
JOIN user_profiles u2 ON r.reported_id = u2.user_id
WHERE r.status = 'PENDING';
