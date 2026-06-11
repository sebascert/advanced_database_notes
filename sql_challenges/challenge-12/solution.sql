---exercise 1

-- 1. What is the business question? How fast does each team complete work over time.
-- 2. What is the exact definition? Completed tasks divided by number of team members (JOIN: teams - users - tasks, where only the status 'completed' counts)
-- 3. What are the edge cases? Team with zero users cause division by zero - Use NULLIF.
-- 4. What is the unit? Completed tasks per person.
-- 5. What would make this metric misleading? A team with many small tasks appears faster and more efficient than one with fewer larger ones.

WITH team_metrics AS (
    SELECT
        t.name AS team_name,
        COUNT(DISTINCT u.id) AS team_members,
        COUNT(CASE WHEN ts.status = 'completed' THEN ts.id END) AS completed_tasks,
        ROUND(
            COUNT(CASE WHEN ts.status = 'completed' THEN ts.id END)
            / NULLIF(COUNT(DISTINCT u.id), 0),
        2) AS velocity
    FROM  teams t
    LEFT  JOIN users u  ON u.team_id     = t.id
    LEFT  JOIN tasks ts ON ts.assigned_to = u.id
    GROUP BY t.id, t.name
)
SELECT
    team_name,
    completed_tasks,
    team_members,
    velocity,
    CASE
        WHEN velocity < (SELECT AVG(velocity) FROM team_metrics)
        THEN 'Below Average'
        ELSE 'Above Average'
    END AS velocity_flag
FROM  team_metrics
ORDER BY velocity DESC;

--exercise 2
-- 1. What is the business question? Are the deadlines meet?
-- 2. What is the exact definition? Percentage of tasks completed one day before the deadline or earlier.
-- 3. What are the edge cases? Task without a due date are excluded
-- 4. What is the unit? Percentage per priority
-- 5. What would make this metric misleading? Teams could artificially extend a deadline.

SELECT
    priority,
    COUNT(*)                                                    AS completed_tasks,
    COUNT(CASE WHEN completed_at <= due_date + 1 THEN 1 END)   AS on_time_tasks,
    ROUND(
        COUNT(CASE WHEN completed_at <= due_date + 1 THEN 1 END)
        * 100.0 / COUNT(*),
    2)                                                          AS on_time_rate_pct,
    ROUND(
        AVG(CASE WHEN completed_at > due_date
            THEN (completed_at - due_date) * 24 END),
    2)                                                          AS avg_lateness_hours
FROM   tasks
WHERE  status    = 'completed'
  AND  due_date  IS NOT NULL
GROUP  BY priority
ORDER  BY CASE priority
    WHEN 'critical' THEN 1 WHEN 'high' THEN 2
    WHEN 'medium'   THEN 3 ELSE 4
END;

--exercise 3
-- 1. What is the business question? Which teams are currently overloaded and which are underutilized.
-- 2. What is the exact definition? Three columns regarding the total tasks, the active tasks, and the completion rate.
-- 3. What are the edge cases? Teams with no tasks still apear.
-- 4. What is the unit? Count (tasks) and percentage of the completion rate.
-- 5. What would make this metric misleading? The original query mixed active and completed tasks.
SELECT
    t.name                                                              AS team_name,
    COUNT(ts.id)                                                        AS total_tasks,
    COUNT(CASE WHEN ts.status IN ('open','in_progress','blocked')
               THEN 1 END)                                              AS active_tasks,
    ROUND(
        COUNT(CASE WHEN ts.status = 'completed' THEN 1 END) * 100.0
        / NULLIF(COUNT(CASE WHEN ts.status != 'cancelled' THEN 1 END), 0),
    2)                                                                  AS completion_rate,
    CASE
        WHEN COUNT(CASE WHEN ts.status IN ('open','in_progress','blocked') THEN 1 END) > 10
            THEN 'Overloaded'
        WHEN COUNT(CASE WHEN ts.status IN ('open','in_progress','blocked') THEN 1 END) >= 5
            THEN 'Healthy'
        ELSE 'Underutilized'
    END                                                                 AS health_score
FROM   teams t
LEFT   JOIN users u  ON u.team_id     = t.id
LEFT   JOIN tasks ts ON ts.assigned_to = u.id
GROUP  BY t.id, t.name
ORDER  BY active_tasks DESC;

--exercise 4
-- 1. What is the business question? Are we resolving tasks fast enough?
-- 2. What is the exact definition? Average median, minimun and maximum horus since a task was created to completed_at.
-- 3. What are the edge cases? Tasks without completed_at are excluded.
-- 4. What is the unit? Hours per priority level
-- 5. What would make this metric misleading? The original averaged all priorities together.

SELECT
    priority,
    COUNT(*)                                                        AS completed_count,
    ROUND(AVG((completed_at - created_at) * 24), 2)                AS avg_resolution_hours,
    ROUND(PERCENTILE_CONT(0.5)
          WITHIN GROUP (ORDER BY (completed_at - created_at) * 24), 2)
                                                                    AS median_hours,
    ROUND(MIN((completed_at - created_at) * 24), 2)                AS fastest_hours,
    ROUND(MAX((completed_at - created_at) * 24), 2)                AS slowest_hours,
    CASE
        WHEN priority = 'critical' AND AVG((completed_at - created_at)*24) <= 24  THEN 'SLA Met'
        WHEN priority = 'high'     AND AVG((completed_at - created_at)*24) <= 72  THEN 'SLA Met'
        WHEN priority = 'medium'   AND AVG((completed_at - created_at)*24) <= 168 THEN 'SLA Met'
        WHEN priority = 'low'      AND AVG((completed_at - created_at)*24) <= 336 THEN 'SLA Met'
        ELSE 'SLA Missed'
    END                                                             AS sla_status
FROM   tasks
WHERE  status = 'completed'
  AND  completed_at IS NOT NULL
GROUP  BY priority
ORDER  BY CASE priority
    WHEN 'critical' THEN 1 WHEN 'high' THEN 2
    WHEN 'medium'   THEN 3 ELSE 4
END;

--exercise 5
-- 1. What is the business question? Which tasks are overdue and how late are they?
-- 2. What is the exact definition? All non-completed and non-cancelled tasks where they have surpassed the due_date.
-- 3. What are the edge cases? Tasks without a due date are excluded.
-- 4. What is the unit? Days overdue.
-- 5. What would make this metric misleading? It only shows a tasks is late, not why or who was responsible about that task.


SELECT
    ts.title,
    u.full_name                          AS assignee,
    t.name                               AS team_name,
    ts.priority,
    ts.due_date,
    TRUNC(SYSDATE - ts.due_date)         AS days_overdue,
    CASE
        WHEN ts.priority = 'critical'                              THEN 'CRITICAL'
        WHEN ts.priority = 'high'   AND SYSDATE-ts.due_date > 2   THEN 'HIGH'
        WHEN ts.priority = 'medium' AND SYSDATE-ts.due_date > 5   THEN 'MEDIUM'
        ELSE                                                            'LOW'
    END                                  AS severity
FROM   tasks ts
LEFT   JOIN users u ON u.id   = ts.assigned_to
LEFT   JOIN teams t ON t.id   = u.team_id
WHERE  ts.due_date < TRUNC(SYSDATE)
  AND  ts.status  NOT IN ('completed', 'cancelled')
  AND  ts.due_date IS NOT NULL
ORDER  BY
    CASE WHEN ts.priority = 'critical' THEN 1
         WHEN ts.priority = 'high'     THEN 2
         WHEN ts.priority = 'medium'   THEN 3
         ELSE 4 END,
    days_overdue DESC;

--exercise 6
-- 1. What is the business question? Which users are delivering the most valuable completed work?
-- 2. What is the exact definition? A sum of priority weights for completed tasks only and divided by active working days.
-- 3. What are the edge cases? Users with no completed tasks return NULL so is handled with NULLIF
-- 4. What is the unit? Weighted tasks per day.
-- 5. What would make this metric misleading? Tasks are measured but not the quality of the output.

SELECT
    u.full_name,
    COUNT(CASE WHEN ts.status = 'completed' THEN 1 END)     AS completed_tasks,
    ROUND(
        SUM(CASE ts.priority
            WHEN 'critical' THEN 4 WHEN 'high'   THEN 3
            WHEN 'medium'   THEN 2 WHEN 'low'    THEN 1
            ELSE 0 END)
        / NULLIF(COUNT(DISTINCT TRUNC(ts.completed_at)), 0),
    2)                                                       AS weighted_score_per_day
FROM   users u
LEFT   JOIN tasks ts ON ts.assigned_to = u.id
WHERE  ts.status = 'completed'
GROUP  BY u.id, u.full_name
ORDER  BY weighted_score_per_day DESC;

--exercise 7
-- 1. What is the business question? What proportion of assigned work does each team finish?
-- 2. What is the exact definition? Completed tasks divided by the total tasks per team.
-- 3. What are the edge cases? Team with zero tasks cause division by zero so it should be handled by NULLIF
-- 4. What is the unit? Percentage.
-- 5. What would make this metric misleading? Is not a performance indicator.

SELECT
    t.name                                                          AS team_name,
    COUNT(ts.id)                                                    AS total_tasks,
    COUNT(CASE WHEN ts.status = 'completed' THEN 1 END)            AS completed_tasks,
    ROUND(
        COUNT(CASE WHEN ts.status = 'completed' THEN 1 END) * 100.0
        / NULLIF(COUNT(ts.id), 0),
    2)                                                              AS efficiency_rate_pct
FROM   teams t
LEFT   JOIN users u  ON u.team_id     = t.id
LEFT   JOIN tasks ts ON ts.assigned_to = u.id
GROUP  BY t.id, t.name
ORDER  BY efficiency_rate_pct DESC;

--exercise 8
-- 1. What is the business question? Which open tasks need more attention based on urgency?
-- 2. What is the exact definition? Numeric priority weight combined with the remaining days before deadline.
-- 3. What are the edge cases? Tasks without due date cannot be scored.
-- 4. What is the unit? Numeric score
-- 5. What would make this metric misleading? The multiplication should be handled in a way that allows to multiply based on the date.

SELECT
    title,
    priority,
    due_date,
    CASE priority
        WHEN 'critical' THEN 4 WHEN 'high'   THEN 3
        WHEN 'medium'   THEN 2 WHEN 'low'    THEN 1
    END
    + CASE
        WHEN due_date < TRUNC(SYSDATE)
        THEN ABS(TRUNC(due_date - SYSDATE)) + 5
        ELSE 5 - TRUNC(due_date - SYSDATE)
    END                                         AS urgency_score
FROM   tasks
WHERE  status NOT IN ('completed', 'cancelled')
ORDER  BY urgency_score DESC;

--exercise part D
-- 1. What is the business question? What's the overall health of the task system?
-- 2. What is the exact definition? One row for the completed, total, active and overdue tasks counts, the completion rate with the average resolution hours (or overdue).
-- 3. What are the edge cases? Cancelled tasks are excluded from the completion rate denominator. Another edge case is if there is a task tied in the priority list.
-- 4. What is the unit? Counts, percentage, hours, days and labels.
-- 5. What would make this metric misleading? A team could have near perfect completion rate on low priority tasks while overlooking the critical ones.
WITH base AS (
    SELECT
        ts.*,
        CASE WHEN ts.status IN ('open','in_progress','blocked') THEN 1 ELSE 0 END AS is_active,
        CASE WHEN ts.due_date < TRUNC(SYSDATE)
              AND ts.status NOT IN ('completed','cancelled')                        THEN 1
             ELSE 0 END                                                             AS is_overdue
    FROM tasks ts
),
priority_rank AS (
    SELECT priority, COUNT(*) AS cnt
    FROM   base WHERE is_active = 1
    GROUP  BY priority
),
team_rank AS (
    SELECT t.name AS team_name, COUNT(*) AS cnt
    FROM   teams t
    JOIN   users u  ON u.team_id     = t.id
    JOIN   tasks ts ON ts.assigned_to = u.id
    WHERE  ts.status IN ('open','in_progress','blocked')
    GROUP  BY t.name
)
SELECT
    COUNT(*)                                                            AS total_tasks,
    COUNT(CASE WHEN status = 'completed'  THEN 1 END)                  AS completed_tasks,
    SUM(is_active)                                                      AS active_tasks,
    SUM(is_overdue)                                                     AS overdue_tasks,
    ROUND(COUNT(CASE WHEN status='completed' THEN 1 END)*100.0/COUNT(*), 2)
                                                                        AS completion_rate_pct,
    ROUND(AVG(CASE WHEN status='completed'
              THEN (completed_at - created_at)*24 END), 2)              AS avg_resolution_hours,
    ROUND(AVG(CASE WHEN is_overdue=1
              THEN TRUNC(SYSDATE - due_date) END), 2)                   AS avg_days_overdue,
    (SELECT priority   FROM priority_rank WHERE cnt=(SELECT MAX(cnt) FROM priority_rank)
     FETCH FIRST 1 ROW ONLY)                                            AS most_common_priority,
    (SELECT team_name  FROM team_rank    WHERE cnt=(SELECT MAX(cnt) FROM team_rank)
     FETCH FIRST 1 ROW ONLY)                                            AS busiest_team
FROM base;
