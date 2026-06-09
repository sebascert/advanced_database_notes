--Step 1 Source Tables (OLTP)
--Tickets table
CREATE TABLE tickets (
    ticket_id    NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title        VARCHAR2(200) NOT NULL,
    status       VARCHAR2(20)  DEFAULT 'open' NOT NULL,
    priority     VARCHAR2(10)  DEFAULT 'medium' NOT NULL,
    assigned_to  NUMBER        REFERENCES agents(agent_id),
    created_at   TIMESTAMP     DEFAULT SYSTIMESTAMP,
    resolved_at  TIMESTAMP,
    CONSTRAINT chk_ticket_status CHECK (
        status IN ('open', 'in_progress', 'resolved', 'cancelled')
    ),
    CONSTRAINT chk_ticket_priority CHECK (
        priority IN ('low', 'medium', 'high', 'critical')
    )
);
--Ticket assignments table
CREATE TABLE ticket_assignments (
    assignment_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ticket_id     NUMBER     NOT NULL REFERENCES tickets(ticket_id),
    assigned_to   NUMBER     NOT NULL REFERENCES agents(agent_id),
    assigned_by   NUMBER     REFERENCES agents(agent_id),
    valid_from    TIMESTAMP  NOT NULL,
    valid_to      TIMESTAMP
);
--Step 2 Sample Data
INSERT INTO tickets (title, status, priority, assigned_to, created_at, resolved_at)
VALUES ('Test1', 'resolved', 'high', 1,
        TIMESTAMP '2026-04-01 12:00:00', TIMESTAMP '2026-04-03 11:00:00');
INSERT INTO tickets (title, status, priority, assigned_to, created_at, resolved_at)
VALUES ('Test2', 'resolved', 'medium', 2,
        TIMESTAMP '2026-04-01 12:00:00', TIMESTAMP '2026-04-03 11:00:00');
INSERT INTO tickets (title, status, priority, assigned_to, created_at, resolved_at)
VALUES ('Test3', 'resolved', 'critical', 3,
        TIMESTAMP '2026-04-01 12:00:00', TIMESTAMP '2026-04-03 11:00:00');
INSERT INTO tickets (title, status, priority, assigned_to, created_at, resolved_at)
VALUES ('Test4', 'in_progress', 'medium', 2,
        TIMESTAMP '2026-04-01 12:00:00', NULL);
INSERT INTO tickets (title, status, priority, assigned_to, created_at, resolved_at)
VALUES ('Test5', 'open', 'low', 1,
        TIMESTAMP '2026-04-01 12:00:00', NULL);
--Step 3 Trigger
CREATE OR REPLACE TRIGGER trg_ticket_assignment_log
    AFTER INSERT OR UPDATE OF assigned_to ON tickets
    FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO ticket_assignments
            (ticket_id, assigned_to, assigned_by, valid_from)
        VALUES
            (:NEW.ticket_id, :NEW.assigned_to, NULL, :NEW.created_at);
    ELSIF UPDATING THEN
        --Close previous assignment
        UPDATE ticket_assignments
           SET valid_to = SYSTIMESTAMP
         WHERE ticket_id = :OLD.ticket_id
           AND valid_to IS NULL;
        --Open new assignment
        INSERT INTO ticket_assignments
            (ticket_id, assigned_to, assigned_by, valid_from)
        VALUES
            (:NEW.ticket_id, :NEW.assigned_to, NULL, SYSTIMESTAMP);
    END IF;
END;
/
--Step 4 Data Warehouse Tables (Star schema)
CREATE TABLE dim_agent (
    agent_key   NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    agent_id    NUMBER        NOT NULL,
    agent_name  VARCHAR2(100) NOT NULL,
    team        VARCHAR2(50)  NOT NULL,
    CONSTRAINT uq_dim_agent UNIQUE (agent_id)
);
CREATE TABLE fact_ticket_daily (
    fact_key          NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    date_key          NUMBER       NOT NULL,
    agent_key         NUMBER       NOT NULL REFERENCES dim_agent(agent_key),
    status            VARCHAR2(20) NOT NULL,
    priority          VARCHAR2(10) NOT NULL,
    tickets_created   NUMBER       DEFAULT 0,
    tickets_resolved  NUMBER       DEFAULT 0,
    CONSTRAINT uq_fact_ticket UNIQUE (date_key, agent_key, status, priority)
);
--Step 5 Populate dim_agent
--structure of the agents table
CREATE TABLE agents (
    agent_id    NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    agent_name  VARCHAR2(100) NOT NULL,
    team        VARCHAR2(50)  NOT NULL
);
INSERT INTO agents (agent_name, team) VALUES ('Yael',   'DataBases');
INSERT INTO agents (agent_name, team) VALUES ('Varela',    'DataBases');
INSERT INTO agents (agent_name, team) VALUES ('Yoyo',  'DataBases');
INSERT INTO agents (agent_name, team) VALUES ('Messi',   'DataBases');
COMMIT;
INSERT INTO dim_agent (agent_id, agent_name, team)
SELECT agent_id, agent_name, team FROM agents;
COMMIT;
--Step 6 ETL Logic
from sqlalchemy import create_engine, text
import pandas as pd
USERNAME = ""
PASSWORD = ""
DSN      = "tcps://db.freesql.com:2484/23ai_34ui2"
engine = create_engine(
    "oracle+oracledb://:@",
    connect_args={"user": USERNAME, "password": PASSWORD, "dsn": DSN}
)
--Extract
tickets     = pd.read_sql("SELECT * FROM tickets",            engine)
assignments = pd.read_sql("SELECT * FROM ticket_assignments", engine)
dim_agent   = pd.read_sql("SELECT * FROM dim_agent",          engine)
for col in ["created_at", "resolved_at"]:
    tickets[col] = pd.to_datetime(tickets[col])
for col in ["valid_from", "valid_to"]:
    assignments[col] = pd.to_datetime(assignments[col])
-- Who was asigned
def agent_at(ticket_id, moment, asgn):
    if pd.isna(moment):
        return None
    mask = (
        (asgn["ticket_id"] == ticket_id) &
        (asgn["valid_from"] <= moment) &
        (asgn["valid_to"].isna() | (asgn["valid_to"] > moment))
    )
    rows = asgn[mask]
    return rows.iloc[0]["assigned_to"] if not rows.empty else None
tickets["agent_created"]  = tickets.apply(
    lambda r: agent_at(r["ticket_id"], r["created_at"],  assignments), axis=1)
tickets["agent_resolved"] = tickets.apply(
    lambda r: agent_at(r["ticket_id"], r["resolved_at"], assignments), axis=1)
-- Group by date, agent, status, priority
created = tickets[tickets["agent_created"].notna()].copy()
created["date_key"] = created["created_at"].dt.strftime("%Y%m%d").astype(int)
created["agent_id"] = created["agent_created"].astype(int)
created["tickets_created"]  = 1
created["tickets_resolved"] = 0
resolved = tickets[tickets["agent_resolved"].notna()].copy()
resolved["date_key"] = resolved["resolved_at"].dt.strftime("%Y%m%d").astype(int)
resolved["agent_id"] = resolved["agent_resolved"].astype(int)
resolved["tickets_created"]  = 0
resolved["tickets_resolved"] = 1
cols = ["date_key","agent_id","status","priority","tickets_created","tickets_resolved"]
grouped = (pd.concat([created[cols], resolved[cols]])
    .groupby(["date_key","agent_id","status","priority"])
    .sum()
    .reset_index()
    .merge(dim_agent[["agent_id","agent_key"]], on="agent_id")
)
-- Insert into : fact_ticket_daily
merge_sql = """
    MERGE INTO fact_ticket_daily f
    USING (SELECT 1 FROM dual) d
    ON (    f.date_key  = :date_key
        AND f.agent_key = :agent_key
        AND f.status    = :status
        AND f.priority  = :priority)
    WHEN MATCHED THEN
        UPDATE SET
            tickets_created  = tickets_created  + :tickets_created,
            tickets_resolved = tickets_resolved + :tickets_resolved
    WHEN NOT MATCHED THEN
        INSERT (date_key, agent_key, status, priority, tickets_created, tickets_resolved)
        VALUES (:date_key, :agent_key, :status, :priority, :tickets_created, :tickets_resolved)
"""
with engine.begin() as conn:
    for _, row in grouped.iterrows():
        conn.execute(text(merge_sql), {
            "date_key":         int(row["date_key"]),
            "agent_key":        int(row["agent_key"]),
            "status":           row["status"],
            "priority":         row["priority"],
            "tickets_created":  int(row["tickets_created"]),
            "tickets_resolved": int(row["tickets_resolved"])
        })
--Step 7
SELECT
    f.date_key,
    a.agent_name,
    a.team,
    f.status,
    f.priority,
    f.tickets_created,
    f.tickets_resolved
FROM fact_ticket_daily f
JOIN dim_agent a ON a.agent_key = f.agent_key
ORDER BY f.date_key, a.agent_name;
‎.gitignore‎
+1Lines changed: 1 addition & 0 deletions
Original file line number	Diff line number	Diff line change
