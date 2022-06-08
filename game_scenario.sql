USE playdata;

SELECT * FROM player;
SELECT * FROM guild;

-- -----------------------------------------------------------------
-- 1. 플레이어 생성

-- <갓겜 MMORPG '엔코아연대기'에 들어오신 걸 환영합니다!>
-- <이름, 직업(전사/궁수/마법사/성직자/암살자 택1), 캐릭터 성별(F/M), 플레이어 id를 적어 캐릭터를 생성해주세요!>
-- 다음 문장을 사용하세요: INSERT INTO player (id, job, sex, fid, create_date, last date) VALUES (, , , ,sysdate(), sysdate());
​
-- ex) INSERT INTO player (id, job, sex, rid, create_date, last_date) VALUES ('용사짱','전사','F','예지',curdate(), curdate());
​
-- 다음 문장을 사용하여 무사히 캐릭터가 생성되었는지 확인합니다.
-- select * from charwin where id = ;


-- -----------------------------------------------------------------
-- 2. 신규 모험가 전투력 1.2배 이벤트
-- 캐릭터 생성을 축하드립니다! 신규 아이디 생성시 자동으로 신규 모험가 혜택이 적용되며, 
-- 기본 전투력이 자동으로 1.2배가 됩니다. trigger를 사용하여 설정해주세요.

DROP TRIGGER IF EXISTS new_char_event;

delimiter //
CREATE TRIGGER new_char_event
BEFORE INSERT 
ON player 
FOR EACH ROW
BEGIN
	SET NEW.str = NEW.str*1.2;
END //
delimiter ;


INSERT INTO player VALUES ('test1호기', NULL, '전사', 1, 100, 'M', 'test', '2022-05-11', '2022-05-22', 1000);
SELECT str FROM player WHERE id = 'test1호기';

DELETE FROM player WHERE id = 'test1호기';

-- ----------------------------------------------------------------------
-- 3. 유료 장비 구입
-- 첫 모험을 떠난 당신, 레벨을 빨리 올리기 위해서는 게임 내 유료 장비를 구입하는 것이 유리합니다.
-- 초보자만 누릴 수 있는 혜택! 500%의 효율!
-- id를 입력받아 실행할 때마다 자동으로 5000 cash씩 충전해주는 프로시저를 실행시켜 볼까요?
-- 프로시저를 시행하면 전투력(str)이 5000/(플레이어레벨)*5)만큼 상승합니다.

drop procedure auto_charge;

delimiter //
create procedure auto_charge (v_id VARCHAR(10))
begin
 update player set cash = cash+5000 where id = v_id;
 update player set str = str+5000/((player.lev)*5) where id = v_id;
end//
delimiter ;

SELECT str, cash FROM player WHERE id = 'Silent';
call auto_charge('Silent');
ROLLBACK;
​
-- 다음 문장을 써서 얼마나 질렀는지 확인해 봅시다.
-- select id, cash, str from player where id = '';

-- ------------------------------------------------------------------
-- 4. 레벨업
-- 좋은 무기로 전투력을 갖췄으니, 사냥을 통해 레벨을 올릴 차례입니다! 
-- 1레벨이 오를 때마다 전투력이 100씩 증가하는 초보자용 사냥터입니다.
-- id를 입력받으면 레벨은 1, 전투력은 100씩 올려주는 프로시저를 만들어 주세요.
-- 프로시저 안에서 'id', '레벨', '전투력'이라는 항목으로 id, lev, str을 출력할 수 있도록 해주세요.
DROP PROCEDURE IF EXISTS level_up;

delimiter //
CREATE PROCEDURE level_up(player_id VARCHAR(30) BINARY)
BEGIN
    UPDATE player
    SET lev = lev + 1, str = str + 100
    WHERE id = player_id;
    COMMIT;
    SELECT id, lev AS '레벨', str AS '전투력'
    FROM player
    WHERE id = player_id;
END//
delimiter ;

SELECT id, lev, str FROM player WHERE id = '10점만점';
CALL level_up('10점만점');
ROLLBACK;

-- -------------------------------------------------------------------
-- 5. 길드 생성
-- 혼자 게임을 하려니 너무 심심하네요, 길드를 하나 만들어 볼까요?
-- 길드 생성을 원하시면 길드명을 정해주세요.
DROP PROCEDURE IF EXISTS create_guild;

delimiter //
CREATE PROCEDURE create_guild(guild_name VARCHAR(30) BINARY)
BEGIN
	INSERT INTO guild (name, create_date)
	VALUES (guild_name, CURDATE());
	SELECT *
	FROM guild
	WHERE name = guild_name;
END//
delimiter ;

CALL create_guild('신규길드01');

SELECT * FROM guild;
DELETE FROM guild WHERE name = '신규길드01';

-- -------------------------------------------------------------------
-- 6. 길드 가입
-- id와 guild name을 이용해 새로운 길드에 가입합니다.
-- Procedure, Update, Subquery 활용해주세요.

DROP PROCEDURE IF EXISTS signing_up_guild;

delimiter //
CREATE PROCEDURE signing_up_guild (player_id VARCHAR(30) BINARY, guild_name VARCHAR(30) BINARY)
BEGIN
    UPDATE player
    SET gno = (
        SELECT gno
        FROM guild
        WHERE guild.name = guild_name
    )
    WHERE id = player_id AND gno IS NULL;
    COMMIT;
    SELECT id, gno
    FROM player
    WHERE id = player_id;
END//
delimiter ;


-- -----------------------------------------------------------------
-- 7. 길드 탈퇴
-- 같이 게임하려고 길드를 만들었는데......사람이 너무 안 모입니다. 
-- 현생도 솔로인데 길드에서조차 혼자 있고 싶지 않아요! 탈퇴하고 다른 길드에 들어가야 할 것 같습니다.
-- player id를 이용해 가입 되어 있는 길드에서 탈퇴합니다.
-- Procedure, Update 활용해주세요.
DROP PROCEDURE IF EXISTS leaving_guild;

delimiter //
CREATE PROCEDURE leaving_guild (player_id VARCHAR(30) BINARY)
BEGIN
    UPDATE player
    SET gno = NULL
    WHERE id = player_id AND gno IS NOT NULL;
    COMMIT;
    SELECT id, gno
    FROM player
    WHERE id = player_id;
END//
delimiter ;


-- 친구가 '오직전투'라는 길드에서 활동하고 있다고 합니다. 커뮤니티를 검색해 보니, 평판이 나쁘지 않습니다. 
-- 친구 따라서 '오직전투' 길드에 가입해보죠.
CALL leaving_guild('10점만점');
CALL signing_up_guild('10점만점', '오직전투');

-- ------------------------------------------------------------------
-- 8. 조건에 맞는 신규 길드원 찾기
-- 길드 A는 조건에 맞는 새로운 길드원을 구하고자 합니다.
-- 길드가 원하는 직업과 최소 레벨 조건을 충족하는 길드가 없는 플레이어를 검색합니다.
-- Procedure 활용
DROP PROCEDURE IF EXISTS find_new_member;

delimiter //
CREATE PROCEDURE find_new_member(player_job VARCHAR(10), player_lev SMALLINT)
BEGIN
    SELECT id, job, lev
    FROM player
    WHERE job = player_job 
        AND lev >= player_lev
        AND gno IS NULL;
END//
delimiter ;

CALL find_new_member('전사', 80);


-- --------------------------------------------------------------------
-- 9. 길드 평균 전투력
-- 길드 레이드는 길드원들의 평균 전투력에 따라 도전 가능한 레이드가 다릅니다.
-- 길드에 맞는 레이드를 추천하기 위해 길드원들의 평균 전투력을 검색합니다.
-- Join, Group function, Group By, Order By 활용

SELECT name AS '길드명', AVG(str) AS '길드원 평균 전투력'
FROM player P, guild G
WHERE P.gno = G.gno
GROUP BY P.gno
ORDER BY AVG(str) DESC;


-- --------------------------------------------------------------------
-- 10. 길드원들과 함께 레이드를 돌았지만, 아무래도 버스(무임승차)를 탄 기분만 듭니다. 길드장님께서 초보자 던전에라도 다녀오라고 하시는군요.
-- 초보자용 던전은 100레벨 이하의 플레이어만 입장할 수 있습니다.
-- 던전을 공략하기 위해서는 최소 4명이 있어야 하며, 전사와 성직자는 반드시 포함되어야 합니다.
-- 시간이 많이 없는 당신을 위해 500cash짜리 즉시 매칭권을 판매하고 있습니다. 
-- 즉시 매칭권을 사용하면 현재 접속해 있지 않더라도 조건에 해당하는 캐릭터와 함께 던전에 들어갈 수 있습니다.
-- 최단시간에 공략할 수 있게끔 파티원을 검색해 봅시다! 
​
update player set cash = cash+500 where id =''
select * from player where lev<=100 order by job;
select * from player;

-- 던전 공략에 성공했습니다. level이 5 상승. 앞서 작성한 level_up('id') procedure를 활용해봅시다.
CALL level_up('빅토르');

-- 얼마나 강해졌는지 확인해봅시다.
select * from player where id = '빅토르';


-- PVE 빠른 파티 매칭을 하려고 합니다. 파티 인원수는 총 4명으로 구성되며, 같은 직업은 파티에 들어갈 수 없습니다.
-- 특정 던전 전투력을 기준으로 +1000, -1000 전투력을 가진 유저들을 검색하는 기능을 만들어 보세요.
-- 매칭 시도 때마다 random하게 인원이 결정됩니다. (rand 사용). 
-- rid가 같으면 한 캐릭터만 파티에 들어올 수 있습니다.
DROP PROCEDURE IF EXISTS pve_matching;

delimiter //
CREATE PROCEDURE pve_matching(dun_str int)
BEGIN
	SELECT id, str, job, rid
	FROM (
		SELECT * FROM (
			SELECT * FROM player ORDER BY rand() LIMIT 18446744073709551615
			) -- limit을 넣어야지만 서브쿼리의 내용이 바뀜.
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

-- 정확하게 4인 나오게 하는건 미구현. matching 돌리다가 4인파티가 나오게 됨. -> while문 적용 필요
SELECT rid, count(*) FROM player WHERE str BETWEEN 9000 AND 11000 GROUP BY rid;
CALL pve_matching(10000);


-- --------------------------------------------------------------------
-- 11. 전투력 2배 상승
-- 모든 던전은 3000cash만 결제하면 해당 던전에서 얻은 전투력을 2배로 상승시켜 줍니다. 
-- 결제하고 전투력을 상승시키는 프로시저를 생성해봅시다. 
-- cash는 현재까지 사용한 돈을 의미합니다.

drop procedure IF EXISTS chargestr;

delimiter //
create procedure chargestr (v_id VARCHAR(30), v_str int)
begin
	update player set cash = cash+3000 where id = v_id;
	update player set str = str+(v_str*2) where id = v_id;
end//
delimiter ;

call chargestr('빅토르', 500);
select id, str, cash from player WHERE id = '빅토르';


-- --------------------------------------------------------------------
-- 12. PVP 매칭을 하려고 합니다. 특정 유저의 전투력을 바탕으로 +1000, -1000까지의 매칭을 시도합니다.
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
		ORDER BY rand()
		LIMIT 1;
	
	ELSEIF player_job IN ('궁수', '마법사', '전사', '성직자', '암살자') THEN 
		SELECT id, rid, job, str
		FROM player 
		WHERE str 
			BETWEEN	(SELECT str FROM player WHERE id=player_id) - 1000 
				AND (SELECT str FROM player WHERE id=player_id) + 1000 
			AND rid NOT IN (SELECT rid FROM player WHERE id = player_id)
			AND job != player_job
		ORDER BY rand()
		LIMIT 1;
	END IF;
END //
delimiter ;

SELECT str, job FROM player WHERE rid = '빅토르';
CALL pvp_matching('빅토르', '궁수');


-- -------------------------------------------------------------------
-- 13. PVP 보상으로 전투력을 상승시켜주는 길드 버프를 받았습니다! 
-- 당신이 속한 길드의 길드원들의 전투력이 1.2배 오르도록 select문을 사용하여 예상 전투력을 출력해주세요.
-- (서브 쿼리 사용)
select str*1.2 as '길드버프 활성시 예상전투력', gno, id
from player
where gno = (
select gno from player where id = '빅토르'); 


-- -------------------------------------------------------------------
-- 14. 같이 게임하던 친구가 부캐(추가로 생성한 캐릭터)를 키우러 가겠다며 가버렸습니다. 친구 부캐 이름을 검색해서 찾아내야겠습니다.
-- (대표 아이디(rid)를 사용해서 친구의 모든 id를 검색하는 프로시저를 만들어주세요.)
SELECT DISTINCT rid FROM player;

DROP PROCEDURE IF EXISTS find_friend;

delimiter //
CREATE PROCEDURE find_friend(player_rid varchar(30) BINARY)
BEGIN 
	SELECT id, rid 
	FROM player
	WHERE rid = player_rid;
END //
delimiter ;

CALL find_friend('빅토르'); 

-- -------------------------------------------------------------------
-- 15. 검색하다 보니 눈쌀이 찌푸려지는 이름들이 많습니다. '성기'가 들어간 닉네임에게서 쪽지가 오지 않도록 차단해버려야겠습니다.
-- id에 '성기'가 들어간 유저를 friendtb에서 지워 주세요.

CREATE TABLE friendtb AS SELECT * FROM player;
ALTER TABLE friendtb DROP COLUMN rid;
ALTER TABLE friendtb DROP COLUMN create_date;
ALTER TABLE friendtb DROP COLUMN cash;
select * from friendtb;

delete from friendtb where id like '%성기%';
select * from friendtb;


-- ------------------------------------------------------------------
-- 16. 선물 상자 이벤트
-- 게임사는 결제한 금액에 따라 차등으로 선물 상자를 지급하는 이벤트를 진행하려고 합니다.
-- 선물상자는 대표 플레이어 ID의 총 결제 금액에 따라 지급됩니다.
-- 이벤트 담당자는 이벤트 진행을 위해 유저 별로 지급되는 선물 상자를 검색합니다.
-- Case, Group Function, Group By, Order By 활용
SELECT rid,
	CASE
		WHEN SUM(cash) BETWEEN 0 AND 99000 THEN '평범한 선물상자'
		WHEN SUM(cash) BETWEEN 100000 AND 990000 THEN '동 선물상자'
		WHEN SUM(cash) BETWEEN 1000000 AND 4990000 THEN '은 선물상자'
		WHEN SUM(cash) BETWEEN 5000000 AND 9990000 THEN '금 선물상자'
		WHEN SUM(cash) BETWEEN 10000000 AND 19990000 THEN '플래티넘 선물상자'
		WHEN SUM(cash) >= 20000000 THEN '다이아 선물상자'
	END AS '이벤트 선물상자'
FROM player
GROUP BY rid
ORDER BY SUM(cash) DESC;


-- -------------------------------------------------------------------
-- 17. 복귀 이벤트도 함께 열렸습니다. 혹시 친구가 복귀 이벤트 대상자일지도 모르잖아요? 대상자를 확인해 봅시다.
--  휴면 계정 처리(오늘 날짜에서 마지막 접속일자와의 차가 3달 이상인 경우, 휴면계정으로 처리합니다.)
--  3달 이상 6달 미만인 경우 접속시 복귀 이벤트를 받습니다. 받을 수 있는 player id를 찾아주세요.
--  6달 이상인 경우 접속시 플래티넘 복귀 이벤트를 받습니다. 받을 수 있는 player id를 찾아주세요.
SELECT id, last_date AS '최종 접속일', TIMESTAMPDIFF(MONTH, last_date, curdate()) AS '미접속 기간(month)',
    CASE 
        WHEN TIMESTAMPDIFF(MONTH, last_date, curdate()) BETWEEN 3 AND 5 THEN '복귀 이벤트 대상자    '
        WHEN TIMESTAMPDIFF(MONTH, last_date, curdate()) >= 6 THEN '플래티넘 복귀 이벤트 대상자'
        ELSE 'X'
    END AS '복귀 이벤트 대상 확인'
FROM player 
ORDER BY 3 DESC;

-- -------------------------------------------------------------------
-- 18. 친구가 자꾸 '전사' 유저가 너무 많다며, 레이드 매칭이 잘 되지 않아 실직하게 생겼다고 합니다.
-- 성직자는 여자가 많을 것 같다며 성직자로 직업 변경을 고민하고 있는데요, 
-- 전체 캐릭터 중 직업별, 성별로 차지하는 비율을 구해봅시다. 
SELECT job AS 직업, count(*) AS '직업별 총 인원수',
    count(CASE WHEN sex='M' THEN 1 end) AS '남자 수',
    count(CASE WHEN sex='F' THEN 1 END) AS '여자 수',
    LPAD(concat(round((count(*)/(SELECT count(*) FROM player))*100, 1), '%'), 20, ' ') AS '직업별 비율(%)'
    FROM player 
    GROUP BY job 
    ORDER BY 5 DESC;
