SHOW DATABASES;

USE playdata;

SHOW tables;

DROP TABLE IF EXISTS player;
DROP TABLE IF EXISTS guild;

-- 길드 테이블 생성
CREATE TABLE guild(
-- column 정의
	gno			INT AUTO_INCREMENT,		-- 길드 번호, pk
	name		VARCHAR(10),			-- 길드명, 10글자까지 가능, NOT NULL
	tend		VARCHAR(10),			-- 길드 성향, 전투/생활/친목
	reg			VARCHAR(10),			-- 길드 활동 지역, 북부/서부/동부/남부/중앙
	lev			SMALLINT,				-- 길드 LEVEL, defluat 1, NOT NULL, 최대 200
	create_date	DATE,					-- 길드 생성 일, NOT NULL
-- pk 정의
	CONSTRAINT pk_gno_guild PRIMARY KEY (gno)
);

-- 플레이어 캐릭터 테이블 생성
CREATE TABLE player(
-- column 정의
	id			VARCHAR(10),	-- 플레이어 캐릭터 id, pk, 대소문자 구분
	gno			INT,			-- 길드 번호, fk, NULL 가능
	job 		VARCHAR(10),	-- 직업, 전사/궁수/마법사/성직자/암살자, NOT NULL
	lev			SMALLINT,		-- LEVEL, DEFAULT 1, NOT NULL, 최대 200
	str			INT,			-- 전투력, DEFAULT 1, NOT NULL 
	sex			VARCHAR(1),		-- 성벌(M, F), NOT NULL
	rid			VARCHAR(10),	-- 대표 플레어이 캐릭터 id, NOT NULL, 한명의 플레이어는 다수의 캐릭터를 생성할 수 있다.
	create_date	DATE,			-- 캐릭터 생성 일, NOT NULL
	last_date	DATE,			-- 최근 접속일, NOT NULL
	cash		int,			-- 누적 결제 금액, DEFAULT 0, NOT NULL
-- pk, fk 정의
	CONSTRAINT pk_id_adventurer PRIMARY KEY (id),
	CONSTRAINT fk_gno_adventurer FOREIGN KEY (gno) REFERENCES guild(gno)
);

-- 테이블 생성 확인
SHOW tables;
DESC guild;
DESC player;

-- guild 테이블 길드 번호 자동 증가 초기값 설정
ALTER TABLE guild AUTO_INCREMENT = 1000;

-- guild 테이블 사용자 입력 데이터 대소문자 구분 설정
-- 길드명
ALTER TABLE guild CHANGE name name VARCHAR(30) BINARY;

-- player 테이블 사용자 입력 데이터 대소문자 구분 설정
-- 플레이어 id, 대표플레이어 id
ALTER TABLE player CHANGE id id VARCHAR(30) BINARY;
ALTER TABLE player CHANGE rid rid VARCHAR(30) BINARY;

-- guild 테이블 not null 설정
-- 길드명, 레벨, 생성일
ALTER TABLE guild MODIFY name VARCHAR(30) BINARY NOT NULL;
ALTER TABLE guild MODIFY lev SMALLINT NOT NULL;
ALTER TABLE guild MODIFY create_date DATE NOT NULL;

DESC guild;

-- player 테이블 not null 설정
-- 직업, 레벨, 전투력, 서버, 성별, 대표 플레이어, 생성일, 최근접속일, 캐쉬
ALTER TABLE player MODIFY job VARCHAR(10) NOT NULL;
ALTER TABLE player MODIFY lev SMALLINT NOT NULL;
ALTER TABLE player MODIFY str INT NOT NULL;
ALTER TABLE player MODIFY sex VARCHAR(1) NOT NULL;
ALTER TABLE player MODIFY rid VARCHAR(30) BINARY NOT NULL;
ALTER TABLE player MODIFY create_date DATE NOT NULL;
ALTER TABLE player MODIFY last_date DATE NOT NULL;
ALTER TABLE player MODIFY cash INT NOT NULL;

DESC player;

-- guild 테이블 default 값 설정
-- 레벨
ALTER TABLE guild ALTER lev SET DEFAULT 1;

DESC guild;

-- player 테이블 default 값 설정
-- 레벨, 전투력, 캐쉬
ALTER TABLE player ALTER lev SET DEFAULT 1;
ALTER TABLE player ALTER str SET DEFAULT 100;
ALTER TABLE player ALTER cash SET DEFAULT 0;

DESC player;

-- guild check 설정
-- 길드명, 성향, 지역, 레벨, 생성일
-- 길드명 : 특수 문자 X
-- 성향 : 전투, 생활, 친목
-- 지역 : 북부, 서부, 남부, 동부, 중앙
-- 레밸 : 1 이상 200 이하
-- 생성일 : 2020-05-30 포함 이후
ALTER TABLE guild ADD CONSTRAINT chk_name_guild CHECK (name NOT REGEXP '!|@|#|&|<|>');
ALTER TABLE guild ADD CONSTRAINT chk_tend_guild CHECK (tend IN ('전투', '생활', '친목'));
ALTER TABLE guild ADD CONSTRAINT chk_reg_guild CHECK (reg IN ('북부', '서부', '남부', '동부', '중앙'));
ALTER TABLE guild ADD CONSTRAINT chk_lev_guild CHECK (lev BETWEEN 1 AND 200);
ALTER TABLE guild ADD CONSTRAINT chk_cdate_guild CHECK (create_date >= '2020-05-30');

-- player check 설정
-- id, 직업, 레벨, 전투력, 성별, rid, 생성일, 최근 접속일, 캐쉬
-- id : 특수 문자 X
-- 직업 : 전사, 마법사, 궁수, 성직자, 암살자
-- 레벨 : 1 이상 200 이하
-- 전투력 : 100 이상
-- 성별 : M 또는 F
-- rid : 특수 문자 X
-- 생성일 : 2020-05-30 포함 이후
-- 최근 접속일 : 생성일 포함 이후
-- 캐쉬 : 0 이상
ALTER TABLE player ADD CONSTRAINT chk_id_player CHECK (id NOT REGEXP '!|@|#|&|<|>');
ALTER TABLE player ADD CONSTRAINT chk_job_player CHECK (job IN ('전사', '마법사', '궁수', '성직자', '암살자'));
ALTER TABLE player ADD CONSTRAINT chk_lev_player CHECK (lev BETWEEN 1 AND 200);
ALTER TABLE player ADD CONSTRAINT chk_str_player CHECK (str >= 100);
ALTER TABLE player ADD CONSTRAINT chk_sex_player CHECK (sex IN('M', 'F'));
ALTER TABLE player ADD CONSTRAINT chk_rid_player CHECK (rid NOT REGEXP '!|@|#|&|<|>');
ALTER TABLE player ADD CONSTRAINT chk_cdate_player CHECK (create_date >= '2020-05-30');
ALTER TABLE player ADD CONSTRAINT chk_ldate_player CHECK (last_date >= create_date);
ALTER TABLE player ADD CONSTRAINT chk_cash_player CHECK (cash >= 0);

-- 제약 조건 확인
SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE TABLE_NAME = 'guild';
SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE TABLE_NAME = 'player';

-- guild 데이터 insert
-- 길드명, 성향, 지역, 레벨(default 1), 생성 일(2020-05-30 이후)
INSERT INTO guild (name, tend, reg, lev, create_date) VALUES ('오직전투', '전투', '서부', 120, '2021-06-11');
INSERT INTO guild (name, tend, reg, lev, create_date) VALUES ('채집제작길드', '생활', '동부', 170, '2020-09-14');
INSERT INTO guild (name, tend, reg, lev, create_date) VALUES ('광부인생', '전투', '북부', 80, '2021-07-30');
INSERT INTO guild (name, tend, reg, lev, create_date) VALUES ('투기장', '전투', '남부', 130, '2021-04-11');
INSERT INTO guild (name, tend, reg, lev, create_date) VALUES ('아메리카노', '친목', '동부', 200, '2020-05-30');
INSERT INTO guild (name, tend, reg, lev, create_date) VALUES ('Asgard', '전투', '중앙', 199, '2020-06-01');

SELECT * FROM guild;

-- player 데이터 insert
-- id, 길드 번호, 직업, 레벨, 전투력, 성별, 대표 id, 생성일, 최근접속일, 캐쉬
INSERT INTO player VALUES ('방패전사', 1000, '전사', 200, 20000, 'M', '전사', '2020-05-30', '2022-05-30', 100000000);
INSERT INTO player VALUES ('헤르미온느', 1000, '마법사', 184, 18400, 'F', '헤르미온느', '2020-07-03', '2022-05-29', 50000000);
INSERT INTO player VALUES ('10점만점', 1000, '궁수', 192, 19200, 'F', '10점만점', '2020-09-05', '2022-05-25', 1200000);
INSERT INTO player VALUES ('귀족힐러', 1000, '성직자', 172, 17200, 'M', '귀족힐러', '2020-10-16', '2022-04-29', 1800000);
INSERT INTO player VALUES ('Sneak', 1000, '암살자', 196, 19600, 'F', 'Sneak', '2020-12-31', '2022-03-15', 900000);
INSERT INTO player VALUES ('Shield', 1001, '전사', 194, 19400, 'F', '헤르미온느', '2021-07-12', '2022-04-15', 4500000);
INSERT INTO player VALUES ('goaway', 1001, '마법사', 145, 14500, 'F', '전사', '2021-09-19', '2022-03-04', 1500000);
INSERT INTO player VALUES ('Leaf', 1001, '궁수', 173, 17300, 'M', 'Leaf', '2021-10-27', '2022-01-18', 10000000);
INSERT INTO player VALUES ('Opera', 1001, '성직자', 94, 9400, 'F', 'Opera', '2022-01-01', '2022-05-09', 400000);
INSERT INTO player VALUES ('Silent', 1001, '암살자', 30, 3000, 'M', 'Opera', '2022-02-01', '2022-04-30', 150000);
INSERT INTO player VALUES ('No1나만도시락', 1002, '마법사', 101, 10100, 'F', 'No1나만도시락', '2020-05-31', '2022-04-23', 192800);
INSERT INTO player VALUES ('No2나만도시락', 1002, '암살자', 97, 9700, 'M', 'No1나만도시락', '2021-08-22', '2022-04-29', 123900);
INSERT INTO player VALUES ('세바스짱', 1002, '궁수', 105, 10500, 'F', '세바스짱', '2020-09-17', '2022-5-30', 180000);
INSERT INTO player VALUES ('트롤인데요', 1002, '궁수', 112, 11200, 'F', '트롤인데요', '2020-10-30', '2022-05-06', 827100);
INSERT INTO player VALUES ('뭐하세요', 1002, '전사', 66, 6600, 'M', '트롤인데요', '2021-08-22', '2022-04-14', 1000000);
INSERT INTO player VALUES ('성기사있으면던짐', 1003, '성직자', 99, 9900, 'M', '성기사있으면던짐', '2021-01-01', '2022-02-11', 162000);
INSERT INTO player VALUES ('투신', 1003, '암살자', 123, 12300, 'F', '투신', '2020-10-18', '2022-01-21', 5000000);
INSERT INTO player VALUES ('빅토르', 1003, '마법사', 100, 10000, 'M', '빅토르', '2021-02-17', '2022-06-01', 1010000);
INSERT INTO player VALUES ('이렐리아', 1003, '전사', 90, 9000, 'F', '빅토르', '2021-09-22', '2022-05-23', 293800);
INSERT INTO player VALUES ('Karina', 1003, '궁수', 103, 10300, 'M', '빅토르', '2020-06-19', '2022-05-31', 562000);
INSERT INTO player VALUES ('Tomas', 1004, '성직자', 164, 16400, 'F', 'Tomas', '2021-02-20', '2022-05-31', 600000);
INSERT INTO player VALUES ('하울의움직이는성', 1004, '성직자', 123, 12300, 'F', 'Tomas', '2021-02-21', '2022-05-31', 160000);
INSERT INTO player VALUES ('카드값줘채리', 1004, '마법사', 131, 13100, 'F', '카드값줘채리', '2022-01-05', '2022-05-31', 150000);
INSERT INTO player VALUES ('티끌모아파산', 1004, '전사', 122, 12200, 'M', '세바스짱', '2020-08-08', '2020-10-31', 200000);
INSERT INTO player VALUES ('친정간금자씨', 1004, '궁수', 150, 15000, 'F', '투신', '2021-11-14', '2022-01-01', 0);
INSERT INTO player VALUES ('명탐정코난', 1005, '전사', 157, 15700, 'M', '명탐정코난', '2021-02-21', '2021-09-08', 5000000);
INSERT INTO player VALUES ('불이야', 1005, '마법사', 192, 19200, 'F', '불이야', '2020-05-30', '2022-05-31', 15000000);
INSERT INTO player VALUES ('Kevin', 1005, '전사', 186, 18600, 'M', 'Sneak', '2021-02-01', '2022-04-29', 6000000);
INSERT INTO player VALUES ('시베리안허스키', 1005, '암살자', 199, 19900, 'F', '시베리안허스키', '2020-07-08', '2022-03-30', 8975200);
INSERT INTO player VALUES ('아뇨뚱인데요', 1005, '성직자', 200, 20000, 'M', 'Leaf', '2020-09-01', '2022-04-25', 3564000);

SELECT * FROM player;

-- commit
COMMIT;