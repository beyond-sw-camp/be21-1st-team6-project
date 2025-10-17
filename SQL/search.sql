-- 장르 목록 검색
select g.genre_name
from genres g;

-- 좋아요한 게시판 보기
select r.title
from post_likes p
join users u on u.user_id = p.user_id
join review_posts r on r.post_id = p.post_id
where p.user_id = 10;

-- 내 매칭 신청 내역 조회
select 
	(select nickname from user_profiles up where u.user_id = m.applicant_id) as '신청자',
	p.title as '매칭'
from users u
join matches m on u.user_id = m.applicant_id
join match_posts p on p.match_post_id = m.match_post_id
where u.user_id = 10;




-- 받은 매칭 신청 조회
select 
	(select nickname from user_profiles up where u.user_id = up.user_id) as '작성자',
	(select nickname from user_profiles up where up.user_id = m.applicant_id) as '신청자',
	mp.title as '매칭 게시판'
from users u
join match_posts mp on u.user_id = mp.user_id
join matches m on m.match_post_id = mp.match_post_id
where u.user_id = 10 and m.applicant_id is not null;

