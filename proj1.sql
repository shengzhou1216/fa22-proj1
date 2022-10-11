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
  SELECT MAX(era)
  FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst,namelast,birthyear FROM people WHERE weight > 300 ORDER BY namefirst,namelast;
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst,namelast,birthyear from people 
  where namefirst like '% %' 
  order by namefirst,namelast;
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear,avg(height),count(*) from people 
  group by birthyear 
  having count(*) > 0
  order by birthyear;
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear,avg(height),count(*) from people 
  group by birthyear 
  having count(*) > 0 and avg(height) > 70
  order by birthyear;
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT p.namefirst,p.namelast,hf.playerid,hf.yearid 
  from (
    select yearid,playerid 
    from HallofFame 
    where inducted = 'Y'
    group by playerid 
    order by yearid desc,playerid asc
  ) hf 
  join people p on hf.playerid = p.playerid
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT p.namefirst,p.namelast,hf.playerid,s.schoolid,hf.yearid from HallofFame hf
  join people p on hf.playerid = p.playerid and hf.inducted = 'Y'
  join CollegePlaying cp on hf.playerid = cp.playerid
  join Schools s on s.schoolid = cp.schoolid and s.schoolState = 'CA'
  order by hf.yearid desc, s.schoolid asc, hf.playerid asc;
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT hf.playerid,p.namefirst,p.namelast,s.schoolid from HallofFame hf
  join people p on hf.playerid = p.playerid and hf.inducted = 'Y'
  left join CollegePlaying cp on hf.playerid = cp.playerid
  left join Schools s on s.schoolid = cp.schoolid
  order by hf.playerid desc, s.schoolid asc;
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT t.playerid,p.namefirst,p.namelast,t.yearid,t.slg from
  (
    select (1.0 * (h - h2b - h3b - hr  + 2 * h2b + 3 * h3b + 4 * hr) / ab) as slg,playerid,yearid 
    from batting  where ab > 50  order by slg desc limit 10
  ) t
  join people p on t.playerid = p.playerid
  order by t.slg desc,t.yearid asc,t.playerid asc;
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT t.playerid,p.namefirst,p.namelast,t.lslg from
  (
    select (1.0 * (sum(h) - sum(h2b) - sum(h3b) - sum(hr)  + 2 * sum(h2b) + 3 * sum(h3b) + 4 * sum(hr)) / sum(ab)) as lslg,playerid,yearid 
    from batting group by playerid having sum(ab) > 50  order by lslg desc limit 10
  ) t
  join people p on t.playerid = p.playerid
  order by t.lslg desc, t.playerid asc;
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT p.namefirst,p.namelast,t.lslg from
  (
    select (1.0 * (sum(h) - sum(h2b) - sum(h3b) - sum(hr)  + 2 * sum(h2b) + 3 * sum(h3b) + 4 * sum(hr)) / sum(ab)) as lslg,playerid 
    from batting 
    group by playerid having sum(ab) > 50  and lslg > (
      select (1.0 * (sum(h) - sum(h2b) - sum(h3b) - sum(hr)  + 2 * sum(h2b) + 3 * sum(h3b) + 4 * sum(hr)) / sum(ab)) as lslg 
      from batting where playerid = 'mayswi01'
    )
  ) t
  join people p on t.playerid = p.playerid;
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT yearid,min(salary),max(salary),avg(salary) from salaries group by yearid order by yearid;
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
-- low: 507500.0, high: 33000000.0, step: 3249250.0
  SELECT 
    t1.binid,low,high,count from
    (
      select binid,(507500.0 + binid * 3249250.0) as low,(507500.0 + (binid  + 1) * 3249250.0) as high
      from binids
    ) t1
    join 
    (
      select  case
        when salary >= 507500.0 and salary < (507500.0 + 3249250.0 * 1) then 0
        when salary >= 507500.0 + 3249250.0 * 1 and salary < (507500.0 + 3249250.0 * 2) then 1
        when salary >= 507500.0 + 3249250.0 * 2 and salary < (507500.0 + 3249250.0 * 3) then 2
        when salary >= 507500.0 + 3249250.0 * 3 and salary < (507500.0 + 3249250.0 * 4) then 3
        when salary >= 507500.0 + 3249250.0 * 4 and salary < (507500.0 + 3249250.0 * 5) then 4
        when salary >= 507500.0 + 3249250.0 * 5 and salary < (507500.0 + 3249250.0 * 6) then 5
        when salary >= 507500.0 + 3249250.0 * 6 and salary < (507500.0 + 3249250.0 * 7) then 6
        when salary >= 507500.0 + 3249250.0 * 7 and salary < (507500.0 + 3249250.0 * 8) then 7
        when salary >= 507500.0 + 3249250.0 * 8 and salary < (507500.0 + 3249250.0 * 9) then 8
        else 9
      end as binid, count(*) as count
      from salaries where yearid = '2016'
      group by binid
    ) t2 
    on t1.binid = t2.binid
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  SELECT t1.yearid,(t2.low - t1.low) as mindff,(t2.high - t1.high) as maxdiff,(t2.mean - t1.mean) as avgdiff from
    (
      select min(salary) as low,max(salary) as high, avg(salary) as mean,(yearid + 1) as yearid from salaries group by yearid order by yearid 
    ) t1
    join 
    (
      select min(salary) as low,max(salary) as high, avg(salary) as mean,yearid from salaries group by yearid order by yearid
    ) t2
    on t1.yearid = t2.yearid
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  SELECT p.playerid,namefirst,namelast,salary,s.yearid from
  (
    select max(salary) as max_salary from salaries where yearid = '2000'
  ) t1
  join salaries s on s.yearid = '2000' and s.salary = t1.max_salary
  join people p on s.playerid = p.playerid
  union
  SELECT p.playerid,namefirst,namelast,salary,s.yearid from
  (
    select max(salary) as max_salary from salaries where yearid = '2001'
  ) t1
  join salaries s on s.yearid = '2001' and s.salary = t1.max_salary
  join people p on s.playerid = p.playerid
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  SELECT 
    t1.teamid,(max(s.salary) - min(s.salary) ) as diffAvg from
    (
      select playerid,teamid from allstarfull where yearid = '2016'
    ) t1
    join salaries s on t1.playerid = s.playerid and s.yearid = '2016'
    group by t1.teamid
;

