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
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE weight > 300;
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE namefirst LIKE '% %'
  ORDER BY namefirst, namelast;
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), COUNT(*)
  FROM people
  GROUP BY birthyear
  ORDER BY birthyear;
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), COUNT(*)
  FROM people
  GROUP BY birthyear
  HAVING AVG(height) > 70
  ORDER BY birthyear;
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT namefirst, namelast, playerid, yearid
  FROM people NATURAL JOIN halloffame 
  WHERE halloffame.inducted = 'Y'
  ORDER BY yearid DESC, playerid
;

-- Question 2ii
CREATE VIEW CAcollege(playerid, schoolid)
AS 
  SELECT c.playerid, c.schoolid 
  FROM collegeplaying c INNER JOIN schools s
  ON c.schoolid = s.schoolid
  WHERE s.schoolState = 'CA';

CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT namefirst, namelast, q.playerid, schoolid, yearid
  FROM q2i q INNER JOIN CAcollege c
  ON q.playerid = c.playerid
  ORDER BY yearid DESC, schoolid, q.playerid;
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT q.playerid, namefirst, namelast, schoolid
  FROM q2i q LEFT OUTER JOIN collegeplaying c
  ON q.playerid = c.playerid
  ORDER BY q.playerid DESC, schoolid;
;

-- Question 3i
CREATE VIEW slg(playerid, yearid, AB, slgval)
AS 
  SELECT playerid, yearid, AB, (H + H2B + 2*H3B + 3*HR + 0.0)/(AB + 0.0)
  FROM batting
;

CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT p.playerid, p.namefirst, p.namelast, s.yearid, s.slgval
  FROM people p INNER JOIN slg s
  ON p.playerid = s.playerid
  WHERE s.AB > 50
  ORDER BY s.slgval DESC, s.yearid, p.playerid
  LIMIT 10
;

-- Question 3ii
CREATE VIEW lslg(playerid, lslgval)
AS 
  SELECT playerid, (SUM(H) + SUM(H2B) + 2 * SUM(H3B) + 3 * SUM(HR) + 0.0)/(SUM(AB) + 0.0)
  FROM batting
  GROUP BY playerid
  HAVING SUM(AB) > 50
;

CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT p.playerid, p.namefirst, p.namelast, l.lslgval
  FROM people p INNER JOIN lslg l
  ON p.playerid = l.playerid
  ORDER BY l.lslgval DESC, p.playerid
  LIMIT 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT p.namefirst, p.namelast, l.lslgval
  FROM people p INNER JOIN lslg l
  ON p.playerid = l.playerid
  WHERE l.lslgval >
    (
      SELECT lslgval 
      FROM lslg 
      WHERE playerid = 'mayswi01'
    )
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT yearid, MIN(salary), MAX(salary), AVG(salary)
  FROM salaries
  GROUP BY yearid
  ORDER BY yearid
;


-- Helper table for 4ii
DROP TABLE IF EXISTS binids;
CREATE TABLE binids(binid);
INSERT INTO binids VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9);

-- Question 4ii
CREATE VIEW bins_statistics(binstart, binend, width)
AS 
  SELECT MIN(salary), MAX(salary), CAST (((MAX(salary) - MIN(salary))/10) AS INT)
  FROM salaries
;

CREATE VIEW bins(binid, binstart, width)
AS 
  SELECT CAST ((salary/width) AS INT), binstart, width
  FROM salaries, bins_statistics
  WHERE yearid = 2016
;

CREATE VIEW q4ii(binid, low, high, count)
AS
  SELECT binid, 507500.0+binid*3249250,3756750.0+binid*3249250, count(*)
  from binids,salaries
  where (salary between 507500.0+binid*3249250 and 3756750.0+binid*3249250 )and yearID='2016'
  group by binid
;

-- Question 4iii
CREATE VIEW salary_statistics(yearid, minsa, maxsa, avgsa)
AS 
  SELECT yearid, MIN(salary), MAX(salary), AVG(salary)
  FROM salaries
  GROUP BY yearid
;

CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  SELECT s1.yearid, s1.minsa - s2.minsa, s1.maxsa - s2.maxsa, s1.avgsa - s2.avgsa
  FROM salary_statistics s1
  INNER JOIN salary_statistics s2
  ON s1.yearid - 1 = s2.yearid
  ORDER BY s1.yearid
;

-- Question 4iv
CREATE VIEW maxid(playerid, salary, yearid)
AS
  SELECT playerid, salary, yearid
    FROM salaries 
    WHERE (yearid = 2000 AND salary = 
          (SELECT MAX(salary)
          FROM salaries s1
          WHERE s1.yearid = 2000)
          )
          OR 
          (yearid = 2001 AND salary =
          (SELECT MAX(salary)
          FROM salaries s2
          WHERE s2.yearid = 2001)
          )
;

CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  SELECT p.playerid, p.namefirst, p.namelast, m.salary, m.yearid
  FROM people p INNER JOIN maxid m
  ON p.playerid = m.playerid
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  SELECT a.teamid, MAX(s.salary) - MIN(s.salary)
  FROM allstarfull a INNER JOIN salaries s 
  ON a.playerid = s.playerid AND a.yearid = s.yearid
  WHERE s.yearid = 2016
  GROUP BY a.teamid
;

