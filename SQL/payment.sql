-- 1. 결제 생성
    
---- 공연 티켓 가격 조회

SELECT ticket_price
FROM performances 
WHERE performance_id = 4;

-- 조회시 44,000

---- 결제 생성

INSERT INTO payments (user_id, performance_id, method, status, total_price, created_at, updated_at)
VALUES (6, 4, 'CARD', 'PENDING', 44000 * 1, NOW(), NOW());

-- 확인용
SELECT * FROM payments
ORDER BY payment_id DESC
LIMIT 1;

-- 2. 결제 완료 처리

-- 결제 상태 업데이트
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_complete_payment$$

CREATE PROCEDURE sp_complete_payment(
    IN p_payment_id BIGINT,
    IN p_transaction_id VARCHAR(100),
    IN p_card_issuer VARCHAR(50),
    IN p_bank_name VARCHAR(50)
)
BEGIN
    -- 결제 상태 업데이트

-- 팬딩
UPDATE payments 
SET status = 'COMPLETED', 
    transaction_id = 'T3345678901',
    updated_at = NOW()
WHERE payment_id = 21;

-- 확인용
SELECT payment_id, status, transaction_id FROM payments WHERE payment_id = 21;

-- 결제 상세 정보 업데이트

UPDATE payment_info 
SET payment_date = NOW(),
    card_issuer = '삼성카드',
    bank_name = null
WHERE payment_id = 21;

-- 확인용
SELECT * FROM payment_info WHERE payment_id = 8;

-- 4. 결제 취소/환불

-- 결제 정보 조회

SELECT performance_id
FROM payments
WHERE payment_id = 21;

-- 티켓 수량 조회

SELECT quantity
FROM tickets
WHERE payment_id = 21;

-- 결제 상태 업데이트

UPDATE payments 
SET status = 'CANCELLED',
    updated_at = NOW()
WHERE payment_id = 15;

-- 확인용
SELECT * FROM payments WHERE payment_id = 15;

-- 결제 상세 정보 업데이트

UPDATE payment_info 
SET cancelled_date = NOW(),
    refund_account = '농협은행 123-****-******'
WHERE payment_id = 21;

-- 확인용
SELECT * FROM payment_info WHERE payment_id = 21;

-- 티켓 취소 처리
UPDATE tickets 
SET status = 'CANCELLED',
    updated_at = NOW()
WHERE payment_id = 21;

-- 확인용
SELECT * FROM tickets WHERE payment_id = 21;

-- 공연 판매 티켓 수 감소
-- 수량, 공연 아이디는 위에서 가져옴

UPDATE performances 
SET sold_tickets = sold_tickets - 1,
    updated_at = NOW()
WHERE performance_id = 21;

-- 확인용
SELECT * FROM performances WHERE performance_id = 21;


-- 결제 상세 정보 초기화

INSERT INTO payment_info (payment_id)
VALUES (21);

-- 확인용
SELECT * FROM payment_info
ORDER BY payment_id DESC
LIMIT 1;

-- 상태를 승인 대기로 변경
UPDATE payments 
SET status = 'PENDING', 
    transaction_id = 'T3345678901',
    updated_at = NOW()
WHERE payment_id = 13;


    UPDATE payments 
    SET status = 'COMPLETED', 
        transaction_id = p_transaction_id,
        updated_at = NOW()
    WHERE payment_id = p_payment_id;
    
    -- 결제 상세 정보 업데이트
    UPDATE payment_info 
    SET payment_date = NOW(),
        card_issuer = p_card_issuer,
        bank_name = p_bank_name
    WHERE payment_id = p_payment_id;
END$$
DELIMITER ;


