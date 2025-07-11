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

-- Question 0
CREATE VIEW q0(era)
AS
  SELECT MAX(era) FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE weight > 300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE namefirst LIKE '% %'
  ORDER BY namefirst, namelast ASC
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height) as avgheight, COUNT(*) as count
  FROM people 
  GROUP BY birthyear
  ORDER BY birthyear ASC
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height) as avgheight, COUNT(*) as count
  FROM people 
  GROUP BY birthyear
  HAVING AVG(height) > 70
  ORDER BY birthyear ASC
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT namefirst, namelast, hf.playerID, hf.yearid
  FROM HallofFame hf
  JOIN people pp ON hf.playerID = pp.playerID
  WHERE hf.inducted = 'Y'
  ORDER BY hf.yearid DESC, hf.playerID ASC
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT pp.namefirst, pp.namelast, pp.playerID, s.schoolID, hf.yearID 
  FROM people pp
  JOIN halloffame hf ON pp.playerID = hf.playerID AND hf.inducted = 'Y'
  JOIN collegeplaying cp ON cp.playerid = pp.playerID
  JOIN schools s ON cp.schoolID = s.schoolID AND s.schoolState = 'CA'
  ORDER BY hf.yearID DESC, s.schoolID ASC, pp.playerID ASC
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT pp.playerID, pp.namefirst, pp.namelast,  cp.schoolID
  FROM people pp
  JOIN halloffame hf ON pp.playerID = hf.playerID AND hf.inducted = 'Y'
  LEFT JOIN collegeplaying cp ON cp.playerid = pp.playerID
  ORDER BY pp.playerID DESC, cp.schoolID ASC
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT b.playerID, pp.namefirst, pp.namelast, b.yearID, (((b.H - b.H2B - b.H3B - b.HR) + 2 * b.H2B + 3 * b.H3B + 4 * b.HR) * 1.0 / b.AB) as slg
  FROM batting b
  JOIN people pp ON b.playerID = pp.playerID
  WHERE b.AB > 50
  ORDER BY slg DESC, b.yearID ASC, b.playerID ASC 
  LIMIT 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT b.playerID, pp.namefirst, pp.namelast, (((SUM(b.H) - SUM(b.H2B) - SUM(b.H3B) - SUM(b.HR)) + 2 * SUM(b.H2B) + 3 * SUM(b.H3B) + 4 * SUM(b.HR)) * 1.0 / SUM(b.AB)) as lslg
  FROM batting b
  JOIN people pp ON b.playerID = pp.playerID
  GROUP BY b.playerID, pp.namefirst, pp.namelast
  HAVING SUM(b.AB) > 50
  ORDER BY lslg DESC, b.playerID ASC 
  LIMIT 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT pp.namefirst, pp.namelast, (((SUM(b.H) - SUM(b.H2B) - SUM(b.H3B) - SUM(b.HR)) + 2 * SUM(b.H2B) + 3 * SUM(b.H3B) + 4 * SUM(b.HR)) * 1.0 / SUM(b.AB)) as lslg
  FROM batting b
  JOIN people pp ON b.playerID = pp.playerID
  GROUP BY b.playerID, pp.namefirst, pp.namelast
  HAVING SUM(b.AB) > 50 AND lslg > (
    SELECT (((SUM(b.H) - SUM(b.H2B) - SUM(b.H3B) - SUM(b.HR)) + 2 * SUM(b.H2B) + 3 * SUM(b.H3B) + 4 * SUM(b.HR)) * 1.0 / SUM(b.AB))
    FROM batting b
    WHERE b.playerID = 'mayswi01'
    GROUP BY b.playerID
  )
  ORDER BY lslg DESC, b.playerID ASC 
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT yearID, MIN(salary), MAX(salary), AVG(salary)
  FROM salaries
  GROUP BY yearID
  ORDER BY yearID ASC
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  WITH minmax AS (
    SELECT MIN(salary) as min_salary, MAX(salary) as max_salary
    FROM salaries
    WHERE yearID = 2016
  ),
  buckets as (
    SELECT binid, 
    (min_salary + ((max_salary - min_salary) / 10) * binid) as min_range,
    (min_salary + (max_salary - min_salary) / 10 * (binid + 1)) as max_range
    FROM binids b, minmax
  )
  SELECT binid, min_range, max_range, COUNT(salary)
  FROM buckets
  JOIN salaries ON (salaries.yearID=2016 AND (salary = max_range OR (salary >= min_range AND salary < max_range)))
  GROUP BY binid
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  WITH year1 AS (
    SELECT yearid, min(salary) as min_sal, max(salary) as max_sal, avg(salary) as avg_sal
    FROM salaries
    GROUP BY yearid
  )
  SELECT y2.yearid, (y2.min_sal - y1.min_sal), (y2.max_sal - y1.max_sal), y2.avg_sal - y1.avg_sal
  FROM year1 y1
  INNER JOIN year1 y2 ON (y1.yearid = y2.yearid - 1)
  ORDER BY y1.yearid
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  WITH max_salary AS (
    SELECT MAX(salary) as max_sal, yearid
    FROM salaries
    WHERE yearid = 2000 OR yearid = 2001
    GROUP BY yearid
  )
  SELECT s.playerid, p.namefirst, p.namelast, s.salary, s.yearid
  FROM salaries s
  INNER JOIN max_salary m ON (m.max_sal = s.salary AND s.yearid = m.yearid)
  JOIN people p ON (s.playerid = p.playerid)

;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  SELECT a.teamid , max(salary)  - min(salary)
  FROM allstarfull a
  JOIN salaries s ON (a.playerid = s.playerid AND s.yearid = 2016 AND a.yearid = 2016) 
  GROUP BY a.teamid
  -- SELECT playerid, team_ID
  -- FROM allstarfull a
  -- WHERE a.yearid = 2016
;

