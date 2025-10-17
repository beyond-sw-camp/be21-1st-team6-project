-- 1. 장르 등록 (INSERT INTO genres)
-- 새로운 음악 장르를 추가하는 쿼리입니다.
-- 
-- 상황: 관리자가 'Synthwave'라는 새로운 장르를 시스템에 추가하려고 합니다.
INSERT INTO genres (genre_name) 
VALUES ('funkpop');

SELECT * FROM genres
ORDER BY genre_id ASC;


-- 2. 밴드 등록 (INSERT INTO bands)
-- 새로운 밴드 정보를 추가하는 쿼리입니다.
-- 
-- 상황: 관리자가 'The Midnight'라는 신규 밴드 정보를 시스템에 등록합니다.
INSERT INTO bands (band_name, description, contact, created_at, updated_at) 
VALUES ('The Mid', 'LA 기반의 신스웨이브 밴드1', 
        'contact12@themidnight.io1', NOW(), NOW());

SELECT * FROM bands
ORDER BY band_id ASC;

-- 3. 밴드 장르 매핑 (INSERT INTO band_genre)
-- 등록된 밴드와 장르를 연결하는 쿼리입니다.

INSERT INTO band_genre (band_id, genre_id)
VALUES (21, 10);

SELECT * FROM band_genre WHERE band_id = 21;

-- 4. 밴드 조회 (JOIN bands + genres)
-- 특정 밴드의 정보와 그 밴드가 어떤 장르에 속하는지를 함께 조회하는 쿼리입니다.
-- 
-- 상황: '데이즈'(band_id: 1) 밴드의 상세 정보를 보려고 할 때, 밴드 설명과 함께 속한 장르 목록('Indie', 'Pop')을 모두 가져옵니다.
SELECT
    b.band_name,
    GROUP_CONCAT(g.genre_name SEPARATOR ', ') AS genres
FROM
    bands AS b
LEFT JOIN
    band_genre AS bg ON b.band_id = bg.band_id 
    LEFT JOIN
    genres AS g ON bg.genre_id = g.genre_id
WHERE
    b.band_id = 1
GROUP BY
    b.band_id;