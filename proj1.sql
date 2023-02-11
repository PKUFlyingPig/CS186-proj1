-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;
DROP VIEW IF EXISTS CAcollege;
DROP VIEW IF EXISTS slg;
DROP VIEW IF EXISTS lslg;
DROP VIEW IF EXISTS salary_statistics;
DROP VIEW IF EXISTS maxid;
DROP VIEW IF EXISTS bins_statistics;
DROP VIEW IF EXISTS bins;

-- Question 0
CREATE VIEW q0(era)
AS
  SELECT MAX(era)
  FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
SELECT namefirst, namelast, birthyear FROM people Where weight >300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS

SELECT namefirst, namelast ,birthyear FROM people Where namefirst LIKE '% %' ORDER BY namefirst, namelast;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
 SELECT birthyear,avg(height),Count(*) FROM people GROUP BY birthyear ORDER BY birthyear;


-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS

SELECT birthyear,avg(height),Count(*) FROM people GROUP BY birthyear HAVING avg(height) >70 ORDER BY birthyear;


-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
SELECT namefirst, namelast, H.playerID,yearid FROM people as P,halloffame as H where P.playerID ==H.playerID and H.inducted=='Y' ORDER BY yearid desc ,H.playerID asc;

---- Question 2ii
--CREATE VIEW q2ii(playerid, schoolid)
--AS
--SELECT namefirst, namelast, H.playerID,S.schoolid,yearid FROM people as P,halloffame as H ,collegeplaying as C,schools as S where S.schoolid ==C.schoolid and P.playerID ==C.playerID and P.playerID ==H.playerID and H.inducted=='Y' and schoolState LIKE '%CA%'ORDER BY yearid desc ,S.schoolid,H.playerID asc;
--


CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
SELECT namefirst, namelast, H.playerID,S.schoolid,yearid FROM people as P,halloffame as H ,collegeplaying as C,schools as S where S.schoolid ==C.schoolid and P.playerID ==C.playerID and P.playerID ==H.playerID and H.inducted=='Y' and schoolState LIKE '%CA%'ORDER BY yearid desc ,S.schoolid,H.playerID asc;


-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
SELECT  H.playerID,namefirst, namelast, S.schoolid FROM people as P left outer join collegeplaying as C on P.playerID ==C.playerID left outer join schools as S on S.schoolid=C.schoolid,halloffame as H where    P.playerID ==H.playerID and H.inducted=='Y'  ORDER BY H.playerID desc ,S.schoolid asc;
--and (P.playerID ==C.playerID and S.schoolid ==C.schoolid )

---- Question 3i
CREATE VIEW slg(playerid, AB, yearid,slgval)
AS
select b.playerid,AB,yearid,(H + H2B + 2*H3B + 3*HR + 0.0)/(AB + 0.0)  AS slgval from batting as b ;

CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
select p.playerid, p.namefirst, p.namelast, s.yearid, s.slgval from slg  as s join people as P on s.playerID==p.playerID and s.AB>50 order by slgval desc limit 10
;

-- Question 3ii
CREATE VIEW lslg(playerid, lslgval)
AS
select playerid,  (SUM(H) + SUM(H2B) + 2 * SUM(H3B) + 3 * SUM(HR) + 0.0)/(SUM(AB)  + 0.0) as lslgval from batting as b group by playerID having SUM(AB)>50

;

CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
select p.playerid, p.namefirst, p.namelast,  s.lslgval from lslg  as s join people as P on s.playerID==p.playerID order by s.lslgval desc,p.playerID limit 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
select  p.namefirst, p.namelast,s.lslgval from lslg  as s join people as P on s.playerID==p.playerID where s.lslgval>(select lslgval from lslg where playerID='mayswi01' )

;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
As
 select yearid, min(salary), max(salary), avg(salary) from salaries group by yearid order by yearid;



-- Helper table for 4ii
DROP TABLE IF EXISTS binids;
CREATE TABLE binids(binid);
INSERT INTO binids VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9);

-- Question 4ii
CREATE VIEW bins_statistics(binstart, binend, width)
AS
 select min(salary), max(salary),(-min(salary)+ max(salary)+0.0) /(10+0.0) from salaries where yearid ==2016;

CREATE VIEW bins(binid, binstart, width)
AS
 select binid,(binstart+(width*binid)),width from bins_statistics,binids ;

;

CREATE VIEW q4ii(binid, low, high, count)
AS

select binid,binstart, binstart+width, count(*) from bins ,salaries where yearid==2016 and salary>=binstart and  (salary<binstart+width or (binid ==9 and salary<=binstart+width)) group by binid
;

-- Question 4iii
CREATE VIEW salary_statistics(yearid, minsa, maxsa, avgsa)
AS
 select yearid, min(salary), max(salary), avg(salary) from salaries   group by yearid order by yearid;

;

CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
 select s.yearid,s.minsa-sn.minsa, s.maxsa-sn.maxsa, s.avgsa-sn.avgsa from salary_statistics as s join salary_statistics as sn on s.yearid=sn.yearid+1   order by s.yearid ;

;

-- Question 4iv
CREATE VIEW maxid(playerid, salary, yearid)
AS
SELECT playerid, salary, yearid from salaries where (yearid == 2000 or yearid == 2001)   group by yearid having salary>= max(salary)
;

CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
select maxid.playerid, namefirst, namelast, maxid.salary , maxid.yearid from people,maxid where people.playerID ==maxid.playerID;
-- Question 4v
CREATE VIEW q4v(team, diffAvg)
AS
select allstarfull.teamid,max(salary)-min(salary) from  allstarfull  inner join salaries on allstarfull.playerID== salaries.playerID and salaries.yearid==allstarfull.yearid where salaries.yearid ==2016 group by allstarfull.teamid
;

