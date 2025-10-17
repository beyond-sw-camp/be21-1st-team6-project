-- ============================================
-- 공연 기능 SQL 모음
-- ============================================

-- 1️. 공연 등록
--  밴드가 직접 공연을 신청하는 단계
INSERT INTO performances (
    name,
    performance_date, performance_time,
    venue, total_tickets,
    sold_tickets, ticket_price,
    status, description,
    created_at, updated_at
)
VALUES (
    '루나틱의 밤:Dreamlike',
    '2025-10-24', '19:00:00','KT&G 상상마당',
    250,
    0,
    35000,
    'PENDING',
    '꿈결같은 사운드에 빠져보세요',
    NOW(), 	 NOW()
);

-- 확인용
SELECT performance_id, name, performance_date, status 
  FROM performances 
 ORDER BY performance_id DESC;


-- 2️. 공연-밴드 연결
--  공연에 참여하는 밴드를 등록 (N:M 관계)
--  (예: performance_id=7, band_id=2)
INSERT INTO performance_band (performance_id, band_id)
VALUES (22, 21);

-- 확인용
SELECT
       p.performance_id AS 공연ID,
       p.name AS 공연명,
       b.band_id AS 밴드ID,
       b.band_name AS 밴드명,
       p.performance_date AS 공연일자,
       p.venue AS 공연장소
  FROM performance_band pb
  JOIN performances p ON pb.performance_id = p.performance_id
  JOIN bands b ON pb.band_id = b.band_id
 ORDER BY p.performance_date;

-- 3️. 공연 상태 변경
-- 원래 백엔드에서 날짜 시간 대조해서 자동으로 변환되지만
-- 일련의 흐름만 보여주기 위해 수동으로 시연

UPDATE performances
SET status = 'ENDED'
WHERE performance_date < CURDATE()
  AND status NOT IN ('ENDED', 'CANCELLED');

-- 관리자 승인 → 상태를 UPCOMING으로 변경
UPDATE performances
SET status = 'UPCOMING',
    updated_at = NOW()
WHERE performance_id = 6   -- 승인할 공연 ID
  AND status = 'PENDING';

-- 4️. 공연 목록 조회 (일반 사용자)
--  사용자가 볼 수 있는 ‘다가올 공연’ 목록
SELECT 
    p.performance_id,
    p.name AS 공연명,
    p.venue AS 공연장소,
    p.performance_date AS 공연날짜,
    p.ticket_price AS 티켓가격,
    p.status AS 공연상태
 FROM performances p
 JOIN performance_band pb ON p.performance_id = pb.performance_id
 JOIN bands b ON pb.band_id = b.band_id
WHERE status = 'UPCOMING'
ORDER BY p.performance_date ASC;


SELECT 
    p.performance_id,
    p.name AS 공연명,
    p.performance_date AS 공연날짜,
    p.status AS 공연상태
 FROM performances p
 JOIN performance_band pb ON p.performance_id = pb.performance_id
 JOIN bands b ON pb.band_id = b.band_id
WHERE status = 'UPCOMING'
ORDER BY p.performance_date ASC;

