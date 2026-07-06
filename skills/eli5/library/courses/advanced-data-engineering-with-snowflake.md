---
course: Advanced Data Engineering with Snowflake (Course 3 of Snowflake Data Engineering Professional Certificate)
source: https://www.coursera.org/learn/advanced-data-engineering-with-snowflake
date: 2026-06-21
tags: [databases, distributed-systems, data-engineering, cloud]
---

# Advanced Data Engineering with Snowflake — ELI5 Study Guide
*Course 3 of the Snowflake Data Engineering Professional Certificate*

**Modules:**
1. DevOps with Snowflake (~2 hrs)
2. Observability with Snowflake (~2 hrs)

This course assumes you already built pipelines (Course 2). Now you make them **team-safe** (DevOps) and **self-watching** (Observability).

---

## Module 1: DevOps with Snowflake *(weight: high)*

*Analogy:* Imagine 20 chefs editing one recipe book at once. Without rules, they overwrite each other and nobody knows who broke the souffle. DevOps is the system where every edit is tracked, reviewed, and auto-published to the kitchen only after it passes a taste test.

*What it is:* Applying software-engineering discipline — version control, code review, automated deployment — to data pipelines. Instead of clicking changes into the Snowflake UI by hand, you define objects as code in Git and let automation deploy them.

*Key concepts:*
- **Git integration** — Snowflake connects directly to a Git repo; your SQL/object definitions live in version control, not just in the database.
- **GitHub collaboration** — branches, pull requests, reviews. Large teams build pipelines without clobbering each other's work.
- **`CREATE OR ALTER`** — declarative object management. You write the *desired end state* of a table/view; Snowflake figures out the diff. Re-running the same script is safe (idempotent) — no "object already exists" errors.
- **CI/CD with GitHub Actions** — a pipeline that, on every merge, automatically tests and deploys your Snowflake changes across environments (dev → test → prod).
- **Snowflake CLI** — the command-line tool that deployment scripts use to push changes to Snowflake from a CI/CD job.

*Go deeper:* `CREATE OR ALTER` is the linchpin. Old style was `CREATE OR REPLACE`, which *drops and recreates* — destroying data and dependencies. `CREATE OR ALTER` mutates in place to match your declared definition, so it's safe to run repeatedly in automation. That idempotency is what makes declarative CI/CD possible.

*Key takeaways:*
- Objects-as-code in Git = reproducible, reviewable, rollback-able pipelines.
- `CREATE OR ALTER` is declarative and idempotent — safe to re-run; doesn't destroy data like `CREATE OR REPLACE`.
- GitHub Actions + Snowflake CLI = automated deploy across environments on merge.

---

## Module 2: Observability with Snowflake *(weight: high)*

*Analogy:* A pipeline without observability is a car with no dashboard — you only learn the engine died when you're stranded. Observability is the full dashboard: speedometer, warning lights, and a black-box recorder that tells you *exactly* what happened before the failure.

*What it is:* Instrumenting pipelines so you can see their health, trace what happened, and get alerted when something breaks — without manually digging through logs. Snowflake's umbrella feature here is **Snowflake Trail**.

*Key concepts:*
- **Snowflake Trail** — the observability framework bundling logging, tracing, metrics, and alerting.
- **Event tables** — special tables that automatically capture telemetry (logs, traces, metrics) emitted by your pipeline code/procedures.
- **Logging** — recording discrete messages/operational records ("loaded 5000 rows", "validation failed").
- **Traces** — the detailed journey of a single execution across steps; lets you pinpoint *where* in a multi-step pipeline things slowed or failed.
- **Alerts** — objects that watch for a condition (e.g., row count = 0, latency too high) and fire when met.
- **Notifications** — push the alert out to humans (email, webhook) so the team hears about critical issues fast.

*Go deeper:* The distinction the exam loves: **logs vs traces vs alerts**. Logs = individual events ("what happened"). Traces = the connected path of one run ("where in the flow it happened"). Alerts = automated condition-watchers ("tell me when X"). Notifications are the delivery channel, separate from the alert that triggers them. Event tables are the *storage destination* that makes all logging/tracing queryable in SQL.

*Key takeaways:*
- Snowflake Trail = the observability umbrella; Event tables are where the telemetry lands.
- Logs (discrete events) vs Traces (one run's full path) — don't conflate them.
- Alert = detects condition; Notification = delivers the message. Two separate steps.

---

## Cross-Module Exam Traps
- **`CREATE OR ALTER` vs `CREATE OR REPLACE`** — ALTER mutates in place (safe, keeps data); REPLACE drops and recreates (destroys data). Classic trick question.
- **Idempotency** — the whole point of declarative deployment; re-running a script must be a no-op if nothing changed.
- **Logs != Traces** — discrete messages vs connected execution path.
- **Alert != Notification** — the alert is the trigger; the notification is the delivery.
- **Event tables are the sink** — logging/tracing data is queryable *because* it's written to event tables.
- **Snowflake CLI**, not the UI, is what CI/CD jobs use to deploy.
