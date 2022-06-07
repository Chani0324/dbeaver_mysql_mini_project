# playdata-mysql-db

## 설명
이 프로젝트는 MMORPG의 db를 작게 구현하여 그 안에 필요한 테이블과 기능들을 MySQL을 활용해 구현해보는 프로젝트입니다.

## 목표
* MySQL의 DDL을 활용해 필요한 table을 생성합니다.
* MySQL의 DML, TCL을 활용해 필요한 기능들을 구현합니다.
* MySQL의 function, procedure, trigger를 활용해 필요한 기능들을 구현합니다


## Tech Stack
<img src="https://img.shields.io/badge/mysql-4479A1?style=for-the-badge&logo=mysql&logoColor=white">
<img src="https://img.shields.io/badge/dbeaver-003B57?style=for-the-badge&logo=dbeaver&logoColor=white">

## Project Configuration
```bash
📦 Databases
└─ playdata
   ├─ Tables
   │  ├─ guild
   │  └─ player
   ├─ Procedures
   │  ├─ auto_charge
   │  ├─ create_guild
   │  ├─ find_friend
   │  ├─ find_new_member
   │  ├─ leaving_guild
   │  ├─ level_up
   │  ├─ chargestr
   │  ├─ pvp_matching
   │  ├─ pve_matching
   │  └─ signing_up_guild
   └─ Trigger
      └─ player.new_player_event
```
©generated by [Project Tree Generator](https://woochanleee.github.io/project-tree-generator)

## Files
* tables_mysql.sql
* scenario.sql

### tables_mysql.sql
guild table과 player table을 생성하며, data를 삽입하는 insert문을 작성한 mysql script file 입니다. 아래는 guild table과 player table의 예시입니다.

* guild table
```sql
-- 길드 테이블 생성
CREATE TABLE guild(
-- column 정의
	gno		INT AUTO_INCREMENT,	-- 길드 번호, PK
	name		VARCHAR(10),		-- 길드명
	tend		VARCHAR(10),		-- 성향, 전투/생활/친목
	reg		VARCHAR(10),		-- 활동 지역, 북부/서부/동부/남부/중앙
	lev		SMALLINT,		-- LEVEL
	create_date	DATE,			-- 생성 일
-- pk 정의
	CONSTRAINT pk_gno_guild PRIMARY KEY (gno)
);
```

* player table
```sql
-- 플레이어 테이블 생성
CREATE TABLE player(
-- column 정의
	id		VARCHAR(10),	-- 플레이어 캐릭터 id, PK
	gno		INT,		-- 길드 번호, FK
	job 		VARCHAR(10),	-- 직업, 전사/궁수/마법사/성직자/암살자
	lev		SMALLINT,	-- LEVEL
	str		INT,		-- 전투력
	sex		VARCHAR(1),	-- 성벌(M, F)
	rid		VARCHAR(10),	-- 대표 플레어이 캐릭터 id
	create_date	DATE,		-- 캐릭터 생성 일
	last_date	DATE,		-- 최근 접속일
	cash		int,		-- 누적 결제 금액
-- pk, fk 정의
	CONSTRAINT pk_id_adventurer PRIMARY KEY (id),
	CONSTRAINT fk_gno_adventurer FOREIGN KEY (gno) REFERENCES guild(gno)
);
```

### scenarios_mysql.sql
guild table과 player table을 활용해 구현한 기능들을 작성한 mysql script file입니다. 아래는 구현한 기능들의 예시입니다.

* 길드 생성
```sql
DROP PROCEDURE IF EXISTS create_guild;

-- 길드 생성 Procedure 생성
CREATE PROCEDURE create_guild(guild_name VARCHAR(30) BINARY)
BEGIN
	INSERT INTO guild (name, create_date)
	VALUES (guild_name, CURDATE());
	SELECT *
	FROM guild
	WHERE name = guild_name;
END;
```

```sql
-- 길드 생성 Procedure 실행
CALL create_guild('신규길드01');
```

실행 결과
|gno|name|tend|reg|lev|create_date|
|---|---|---|---|---|---|
|1006|신규길드01|NULL|NULL|1|2022-06-07|

* 길드 가입
```sql
DROP PROCEDURE IF EXISTS signing_up_guild;

-- 길드 가입 Procedure 생성
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
END;
```

```sql
-- 길드 가입 Procedure 실행
CALL signing_up_guild('신규플레이어01', '신규길드01');
```

실행 결과
|id|gno|
|---|---|
|신규플레이어01|1006|

## Contributors
* 박재민
* 윤홍찬
* 유예지
