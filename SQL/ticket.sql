-- 3. 티켓 자동 발급 프로시저
---- 결제 정보 조회

SELECT 	user_id, 
		performance_id, 
		total_price / (SELECT ticket_price FROM performances WHERE performance_id = payments.performance_id) AS 'quantity'
FROM payments
WHERE payment_id = 21;

-- 확인용
SELECT * FROM payments WHERE payment_id;

---- 입장 코드 생성

SELECT CONCAT(
    CHAR(65 + FLOOR(RAND() * 26)),
    FLOOR(RAND() * 10),             
    CHAR(65 + FLOOR(RAND() * 26)),  
    FLOOR(RAND() * 10),              
    CHAR(65 + FLOOR(RAND() * 26)),  
    FLOOR(RAND() * 10),             
    CHAR(65 + FLOOR(RAND() * 26)), 
    FLOOR(RAND() * 10),             
    CHAR(65 + FLOOR(RAND() * 26)),  
    FLOOR(RAND() * 10)               
) AS enter_code;

---- 티켓 발급

INSERT INTO tickets (user_id, performance_id, payment_id, quantity, status, enter_code, is_entered, created_at, updated_at)
VALUES (6, 4, 21, 1, 'ISSUED', 'T3345678901', FALSE, NOW(), NOW());

-- 확인용
SELECT * FROM tickets
ORDER BY ticket_id DESC
LIMIT 1;
    

---- 공연 판매 티켓 수 증가

UPDATE performances 
SET sold_tickets = sold_tickets + 1,
    updated_at = NOW()
WHERE performance_id = 4

-- 확인용
SELECT sold_tickets FROM performances WHERE performance_id = 4;


-- 유저 티켓 조회
    SELECT 
        t.ticket_id,
        t.quantity,
        t.status,
        t.enter_code,
        t.is_entered,
        t.entered_at,
        p.name AS performance_name,
        p.performance_date,
        p.performance_time,
        p.venue,
        p.poster_image_url,
        pay.total_price,
        pay.method,
        t.created_at
    FROM tickets t
    JOIN performances p ON t.performance_id = p.performance_id
    JOIN payments pay ON t.payment_id = pay.payment_id
    WHERE t.user_id = 5
    ORDER BY t.created_at DESC;

-- 결제 완료 시 티켓 자동 발급 <트리거>
DELIMITER $$

DROP TRIGGER IF EXISTS trg_issue_ticket$$

CREATE TRIGGER trg_issue_ticket
AFTER UPDATE ON payments
FOR EACH ROW
BEGIN
    IF NEW.status = 'COMPLETED' AND OLD.status != 'COMPLETED' THEN
        CALL issue_ticket(NEW.payment_id);
    END IF;
END$$
DELIMITER ;