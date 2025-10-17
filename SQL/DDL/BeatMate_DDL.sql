-- =================================================================
-- 비트메이트 ver.5 통합본
-- 설명: CREATE TABLE 문에 기본 키, 외래 키, AUTO_INCREMENT를 통합한 스크립트입니다.
-- =================================================================


-- users 테이블: 사용자 기본 정보
CREATE TABLE `users` (
	`user_id`	BIGINT	NOT NULL AUTO_INCREMENT,
	`email`	VARCHAR(255)	NOT NULL UNIQUE,
	`password`	VARCHAR(255)	NULL,
	`permission`	ENUM('USER', 'ADMIN')	NOT NULL	DEFAULT 'USER',
	`provider`	VARCHAR(20)	NULL,
	`provider_id`	VARCHAR(255)	NULL,
	`created_at`	DATETIME	NOT NULL,
	`deleted_at`	DATETIME	NULL,
	PRIMARY KEY (`user_id`)
);

-- user_profiles 테이블: 사용자 프로필 상세 정보
CREATE TABLE `user_profiles` (
	`user_id`	BIGINT	NOT NULL,
	`nickname`	VARCHAR(50)	NOT NULL UNIQUE,
	`profile_image_url`	VARCHAR(255)	NULL,
	`changed_img`	VARCHAR(255)	NULL,
	`introduction`	TEXT	NULL,
	`birthdate`	DATE	NULL,
	`gender`	ENUM('MALE', 'FEMALE', 'OTHER')	NULL,
	`exciting_index`	DECIMAL(4, 1)	NOT NULL,
	`created_at`	DATETIME	NOT NULL,
	`updated_at`	DATETIME	NOT NULL,
	PRIMARY KEY (`user_id`),
	FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
);

-- genres 테이블: 음악 장르 정보
CREATE TABLE `genres` (
	`genre_id`	BIGINT	NOT NULL AUTO_INCREMENT,
	`genre_name`	VARCHAR(50)	NOT NULL UNIQUE,
	PRIMARY KEY (`genre_id`)
);

-- bands 테이블: 밴드 정보
CREATE TABLE `bands` (
	`band_id`	BIGINT	NOT NULL AUTO_INCREMENT,
	`band_name`	VARCHAR(100)	NOT NULL UNIQUE,
	`description`	TEXT	NULL,
	`contact`	VARCHAR(100)	NULL,
	`created_at`	DATETIME	NOT NULL,
	`updated_at`	DATETIME	NOT NULL,
	PRIMARY KEY (`band_id`)
);

-- performances 테이블: 공연 정보
CREATE TABLE `performances` (
	`performance_id`	BIGINT	NOT NULL AUTO_INCREMENT,
	`name`	VARCHAR(100)	NOT NULL,
	`performance_date`	DATE	NOT NULL,
	`performance_time`	TIME	NOT NULL,
	`venue`	VARCHAR(200)	NOT NULL,
	`total_tickets`	INT	NOT NULL,
	`sold_tickets`	INT	NOT NULL,
	`ticket_price`	INT	NOT NULL,
	`status`	ENUM('PENDING', 'UPCOMING', 'ACTIVE', 'ENDED', 'CANCELLED')	NOT NULL	DEFAULT 'PENDING',
	`description`	TEXT	NULL,
	`poster_image_url`	VARCHAR(255)	NULL,
	`change_poster_image_url`	VARCHAR(255)	NULL,
	`created_at`	DATETIME	NOT NULL,
	`updated_at`	DATETIME	NOT NULL,
	PRIMARY KEY (`performance_id`)
);

-- review_posts 테이블: 공연 후기 게시글
CREATE TABLE `review_posts` (
	`post_id`	BIGINT	NOT NULL AUTO_INCREMENT,
	`user_id`	BIGINT	NOT NULL,
	`performance_id`	BIGINT	NOT NULL,
	`title`	VARCHAR(100)	NOT NULL,
	`content`	TEXT	NOT NULL,
	`view_count`	INT	NOT NULL,
	`like_count`	INT	NOT NULL,
	`created_at`	DATETIME	NOT NULL,
	`updated_at`	DATETIME	NOT NULL,
	`deleted`	BOOLEAN	NULL,
	PRIMARY KEY (`post_id`),
    FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
    FOREIGN KEY (`performance_id`) REFERENCES `performances` (`performance_id`)
);

-- review_comments 테이블: 공연 후기 댓글
CREATE TABLE `review_comments` (
	`comment_id`	BIGINT	NOT NULL AUTO_INCREMENT,
	`post_id`	BIGINT	NOT NULL,
	`user_id`	BIGINT	NOT NULL,
	`parent_comment_id`	BIGINT	NULL,
	`content`	TEXT	NOT NULL,
	`created_at`	DATETIME	NOT NULL,
	`updated_at`	DATETIME	NOT NULL,
	`deleted`	BOOLEAN	NULL,
	PRIMARY KEY (`comment_id`),
    FOREIGN KEY (`post_id`) REFERENCES `review_posts` (`post_id`),
    FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
    FOREIGN KEY (`parent_comment_id`) REFERENCES `review_comments` (`comment_id`)
);

-- match_posts 테이블: 메이트 매칭 게시글
CREATE TABLE `match_posts` (
	`match_post_id`	BIGINT	NOT NULL AUTO_INCREMENT,
	`user_id`	BIGINT	NOT NULL,
	`performance_id`	BIGINT	NOT NULL,
	`title`	VARCHAR(100)	NOT NULL,
	`content`	TEXT	NOT NULL,
	`view_count`	INT	NOT NULL,
	`created_at`	DATETIME	NOT NULL,
	`updated_at`	DATETIME	NOT NULL,
	`deleted`	BOOLEAN	NULL,
	PRIMARY KEY (`match_post_id`),
    FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
    FOREIGN KEY (`performance_id`) REFERENCES `performances` (`performance_id`)
);

-- match_comments 테이블: 메이트 매칭 게시글 댓글
CREATE TABLE `match_comments` (
	`comment_id`	BIGINT	NOT NULL AUTO_INCREMENT,
	`match_post_id`	BIGINT	NOT NULL,
	`user_id`	BIGINT	NOT NULL,
	`parent_comment_id`	BIGINT	NULL,
	`content`	TEXT	NOT NULL,
	`created_at`	DATETIME	NOT NULL,
	`updated_at`	DATETIME	NOT NULL,
	`deleted`	BOOLEAN	NULL,
	PRIMARY KEY (`comment_id`),
    FOREIGN KEY (`match_post_id`) REFERENCES `match_posts` (`match_post_id`),
    FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
    FOREIGN KEY (`parent_comment_id`) REFERENCES `match_comments` (`comment_id`)
);

-- matches 테이블: 메이트 매칭 신청 및 상태
CREATE TABLE `matches` (
	`match_id`	BIGINT	NOT NULL AUTO_INCREMENT,
	`applicant_id`	BIGINT	NOT NULL,
	`match_post_id`	BIGINT	NOT NULL,
	`status`	ENUM('PENDING', 'CONFIRMED', 'REJECTED', 'CANCELLED')	NOT NULL	DEFAULT 'PENDING',
	`message`	TEXT	NULL,
	`created_at`	DATETIME	NOT NULL,
	`updated_at`	DATETIME	NOT NULL,
	PRIMARY KEY (`match_id`),
    FOREIGN KEY (`applicant_id`) REFERENCES `users` (`user_id`),
    FOREIGN KEY (`match_post_id`) REFERENCES `match_posts` (`match_post_id`)
);

-- payments 테이블: 결제 정보
CREATE TABLE `payments` (
	`payment_id`	BIGINT	NOT NULL AUTO_INCREMENT,
	`user_id`	BIGINT	NOT NULL,
	`performance_id`	BIGINT	NOT NULL,
	`method`	ENUM('CARD', 'BANK_TRANSFER', 'VIRTUAL_ACCOUNT', 'MOBILE')	NOT NULL,
	`status`	ENUM('PENDING', 'COMPLETED', 'FAILED', 'CANCELLED', 'REFUNDED')	NOT NULL	DEFAULT 'PENDING',
	`transaction_id`	VARCHAR(100)	NULL,
	`created_at`	DATETIME	NOT NULL,
	`updated_at`	DATETIME	NOT NULL,
	`total_price`	INT	NULL,
	PRIMARY KEY (`payment_id`),
    FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
    FOREIGN KEY (`performance_id`) REFERENCES `performances` (`performance_id`)
);

-- payment_info 테이블: 결제 상세 정보
CREATE TABLE `payment_info` (
	`payment_id`	BIGINT	NOT NULL,
	`payment_date`	DATETIME	NULL,
	`cancelled_date`	DATETIME	NULL,
	`card_issuer`	VARCHAR(50)	NULL,
	`bank_name`	VARCHAR(50)	NULL,
	`account_holder`	VARCHAR(50)	NULL,
	`refund_account`	VARCHAR(50)	NULL,
	PRIMARY KEY (`payment_id`),
	FOREIGN KEY (`payment_id`) REFERENCES `payments` (`payment_id`)
);

-- tickets 테이블: 발급된 티켓 정보
CREATE TABLE `tickets` (
	`ticket_id`	BIGINT	NOT NULL AUTO_INCREMENT,
	`user_id`	BIGINT	NOT NULL,
	`performance_id`	BIGINT	NOT NULL,
	`payment_id`	BIGINT	NOT NULL,
	`quantity`	INT	NOT NULL,
	`status`	ENUM('ISSUED', 'USED', 'CANCELLED', 'REFUNDED')	NOT NULL	DEFAULT 'ISSUED',
	`enter_code`	VARCHAR(20)	NOT NULL UNIQUE,
	`is_entered`	BOOLEAN	NOT NULL,
	`entered_at`	DATETIME	NULL,
	`created_at`	DATETIME	NOT NULL,
	`updated_at`	DATETIME	NOT NULL,
	PRIMARY KEY (`ticket_id`),
    FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
    FOREIGN KEY (`performance_id`) REFERENCES `performances` (`performance_id`),
    FOREIGN KEY (`payment_id`) REFERENCES `payments` (`payment_id`)
);

-- administrators 테이블: 관리자 활동 로그
CREATE TABLE `administrators` (
	`admin_log_id`	BIGINT	NOT NULL AUTO_INCREMENT,
	`admin_id`	BIGINT	NOT NULL,
	`action_type`	VARCHAR(50)	NOT NULL,
	`target_entity`	VARCHAR(50)	NOT NULL,
	`target_id`	BIGINT	NOT NULL,
	`details`	TEXT	NULL,
	`created_at`	DATETIME	NOT NULL,
	PRIMARY KEY (`admin_log_id`),
    FOREIGN KEY (`admin_id`) REFERENCES `users` (`user_id`)
);

-- reports 테이블: 사용자 신고 정보
CREATE TABLE `reports` (
	`report_id`	BIGINT	NOT NULL AUTO_INCREMENT,
	`reporter_id`	BIGINT	NOT NULL,
	`reported_id`	BIGINT	NOT NULL,
	`report_type`	ENUM('USER', 'MATCH_POST', 'REVIEW_POST', 'COMMENT')	NOT NULL,
	`reason`	VARCHAR(255)	NOT NULL,
	`description`	TEXT	NULL,
	`status`	ENUM('PENDING', 'REVIEWED', 'RESOLVED', 'REJECTED')	NOT NULL	DEFAULT 'PENDING',
	`created_at`	DATETIME	NOT NULL,
	`resolved_at`	DATETIME	NULL,
	PRIMARY KEY (`report_id`),
    FOREIGN KEY (`reporter_id`) REFERENCES `users` (`user_id`),
    FOREIGN KEY (`reported_id`) REFERENCES `users` (`user_id`)
);

-- =================================================================
-- 중간 테이블 (Junction Tables)
-- =================================================================

-- user_favorite_bands 테이블: 사용자가 선호하는 밴드
CREATE TABLE `user_favorite_bands` (
	`user_id`	BIGINT	NOT NULL,
	`band_id`	BIGINT	NOT NULL,
	PRIMARY KEY (`user_id`, `band_id`),
	FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
	FOREIGN KEY (`band_id`) REFERENCES `bands` (`band_id`)
);

-- band_genre 테이블: 밴드의 음악 장르
CREATE TABLE `band_genre` (
	`band_id`	BIGINT	NOT NULL,
	`genre_id`	BIGINT	NOT NULL,
	PRIMARY KEY (`band_id`, `genre_id`),
	FOREIGN KEY (`band_id`) REFERENCES `bands` (`band_id`),
	FOREIGN KEY (`genre_id`) REFERENCES `genres` (`genre_id`)
);

-- post_likes 테이블: 게시글 좋아요
CREATE TABLE `post_likes` (
	`user_id`	BIGINT	NOT NULL,
	`post_id`	BIGINT	NOT NULL,
	PRIMARY KEY (`user_id`, `post_id`),
	FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
	FOREIGN KEY (`post_id`) REFERENCES `review_posts` (`post_id`)
);

-- user_favorite_genres 테이블: 사용자가 선호하는 장르
CREATE TABLE `user_favorite_genres` (
	`user_id`	BIGINT	NOT NULL,
	`genre_id`	BIGINT	NOT NULL,
	PRIMARY KEY (`user_id`, `genre_id`),
	FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
	FOREIGN KEY (`genre_id`) REFERENCES `genres` (`genre_id`)
);

-- performance_band 테이블: 공연에 참여하는 밴드
CREATE TABLE `performance_band` (
	`performance_id`	BIGINT	NOT NULL,
	`band_id`	BIGINT	NOT NULL,
	PRIMARY KEY (`performance_id`, `band_id`),
	FOREIGN KEY (`performance_id`) REFERENCES `performances` (`performance_id`),
	FOREIGN KEY (`band_id`) REFERENCES `bands` (`band_id`)
);