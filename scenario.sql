-- mysql 사용.

-- 사용 table : guild / player 
DESC guild;
DESC player;

SELECT * FROM guild;
SELECT * FROM player;

-- 시나리오 정리
-- 1. 캐릭터간 밸런스 분석을 위해 전체 캐릭터 중 직업별, 성별로 차지하는 비율을 구해보고자 합니다.
SELECT job AS 직업, count(*) AS '직업별 총 인원수',
	count(CASE WHEN sex='M' THEN 1 end) AS '남자 수',
	count(CASE WHEN sex='F' THEN 1 END) AS '여자 수',
	round((count(*)/(SELECT count(*) FROM player))*100, 1) AS '직업별 비율'
	FROM player 
	GROUP BY job 
	ORDER BY 5 DESC;


-- 2. 친구찾기(대표 아이디(rid)를 사용해서 친구의 모든 id를 검색하는 프로시저를 만들어주세요.)
-- 만드려는 프로시저 이름 : friend_group 
SELECT DISTINCT rid FROM player;

DROP PROCEDURE IF EXISTS friend_group;

delimiter //
CREATE PROCEDURE friend_group(player_rid varchar(30) BINARY)
BEGIN 
	SELECT id 
	FROM player
	WHERE rid = player_rid;
END //
delimiter ;

CALL FRIEND_GROUP('빅토르'); 

-- 3. 휴면 계정 처리(오늘 날짜에서 마지막 접속일자와의 차가 3달 이상인 경우, 휴면계정으로 처리합니다.)
-- 	3달 이상 6달 미만인 경우 접속시 복귀 이벤트를 받습니다. 받을 수 있는 player id를 찾아주세요.
-- 	6달 이상인 경우 접속시 플래티넘 복귀 이벤트를 받습니다. 받을 수 있는 player id를 찾아주세요.
SELECT id, last_date AS '최종 접속일', TIMESTAMPDIFF(MONTH, last_date, curdate()) AS '마지막 접속일로부터 경과시간(month)',
	CASE 
		WHEN TIMESTAMPDIFF(MONTH, last_date, curdate()) BETWEEN 3 AND 5 THEN '복귀 이벤트 대상자	'
		WHEN TIMESTAMPDIFF(MONTH, last_date, curdate()) >= 6 THEN '플래티넘 복귀 이벤트 대상자'
		ELSE 'X'
	END AS '복귀 이벤트 대상 확인'
FROM player 
ORDER BY 3 DESC;


-- 4. 신규 아이디 생성시 자동으로 신규 모험가 혜택 30일간 적용되도록 하여, 기본 전투력이 1.2배가 되도록 설정합니다.
DROP TRIGGER IF EXISTS new_char_event;

delimiter //
CREATE TRIGGER new_char_event
BEFORE INSERT 
ON player 
FOR EACH ROW
BEGIN
	IF timestampdiff(DAY, (NEW.create_date), curdate()) BETWEEN 0 AND 30 THEN 
		SET NEW.str = NEW.str*1.2;
	END IF;
END //
delimiter ;

INSERT INTO player VALUES ('test1호기', NULL, '전사', 1, 100, 'M', 'test', '2022-04-11', '2022-05-22', 1000);

SELECT str FROM player WHERE id = 'test1호기';


-- 5. PVP 매칭을 하려고 합니다. 특정 유저의 전투력을 바탕으로 +1000, -1000까지의 매칭을 시도합니다.
-- 	유저가 특정 직업과 매칭을 원하지 않는 경우 해당 직업을 제외하고 PVP매칭을 할 수 있도록 리스트를 만들어 주세요.
-- 		조건 1. 검색을 실행하는 유저 id와 매칭을 원하지 않는 특정 직업을 parameter 인자를 받도록 합니다.
-- 		조건 2. 매칭 직업이 상관없다면 parameter 값으로 '없음'을 설정.
-- 		조건 3. 캐릭별 대표 id(rid)가 검색을 실행하는 유저의 rid 와 같을 경우 제외

DROP PROCEDURE IF EXISTS pvp_matching;

delimiter //
CREATE PROCEDURE pvp_matching(player_id varchar(30) BINARY, player_job varchar(10))
BEGIN
	IF player_job = '없음' THEN 
		SELECT id, rid, job, str
		FROM player 
		WHERE str 
			BETWEEN (SELECT str FROM player WHERE id=player_id) - 1000 
				AND (SELECT str FROM player WHERE id=player_id) + 1000 
			AND rid NOT IN (SELECT rid FROM player WHERE id = player_id)
		ORDER BY str DESC;
	
	ELSEIF player_job IN ('궁수', '마법사', '전사', '성직자', '암살자') THEN 
		SELECT id, rid, job, str
		FROM player 
		WHERE str 
			BETWEEN	(SELECT str FROM player WHERE id=player_id) - 1000 
				AND (SELECT str FROM player WHERE id=player_id) + 1000 
			AND rid NOT IN (SELECT rid FROM player WHERE id = player_id)
			AND job != player_job
		ORDER BY str DESC;
	END IF;
END //
delimiter ;

SELECT str, job FROM player WHERE rid = '빅토르';
CALL pvp_matching('빅토르', '암살자');


-- 6. PVE 빠른 파티 매칭을 하려고 합니다. 파티 인원수는 총 4명으로 구성되며, 같은 직업은 파티에 들어갈 수 없습니다.
-- 	특정 던전 전투력을 기준으로 +1000, -1000 전투력을 가진 유저들을 검색하는 기능을 만들어 보세요.
-- 	매칭 시도 때마다 random하게 인원이 결정됩니다. 또한 rid는 하나만 존재가능합니다.(rand 사용)
DROP PROCEDURE IF EXISTS pve_matching;

delimiter //
CREATE PROCEDURE pve_matching(dun_str int)
BEGIN
	SELECT id, str, job, rid
	FROM (
		SELECT * FROM (
				-- limit을 안넣어주면 서브쿼리의 내용이 바뀌지 않음. player table 랜덤 정렬
			SELECT * FROM player ORDER BY rand() LIMIT 18446744073709551615
			) 
				-- rid 중복 제거 후 다시 랜덤 정렬
		AS pla GROUP BY rid ORDER BY rand() LIMIT 18446744073709551615 
		) 
	AS pl
	WHERE str 
		BETWEEN dun_str - 1000 
		AND dun_str + 1000
	GROUP BY job
	ORDER BY rand()
	LIMIT 4;
END//
delimiter ;

-- rid 중복 제거로 인하여 정확하게 4인 나오게 하는건 미구현.
-- matching 돌리다가 4인파티가 나오게 됨. -> while문 적용 필요
-- SELECT rid, count(*) FROM player WHERE str BETWEEN 9000 AND 11000 GROUP BY rid;
CALL pve_matching(10000);


-- 7. 서버 전체 캐릭터 랭킹을 결정지으려고 합니다. -> 미완
-- 	랭킹은 캐릭터 별로 lev, str, 총 접속일수, cash의 순위를 가중치를 주고 총 합산하여 계산됩니다.
--  가중치 넣는 값 필요. 

DROP PROCEDURE IF EXISTS total_rank;

delimiter //
CREATE PROCEDURE total_rank(w_lev int, w_str int, w_date int, w_cash int)
BEGIN
	SELECT id, 
		RANK() OVER(ORDER BY lev )
	
END//
delimiter ;



SELECT * FROM player;
SELECT str, RANK() over(ORDER BY str ASC) * 0.4 FROM player;
