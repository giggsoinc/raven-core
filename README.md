<p align="center">
  <img src="./assets/raven-banner.png" alt="Raven — Guardrails before you ship." width="800"/>
</p>

# Raven — Discipline Engine for Claude Code

> AI-native engineering discipline. Guards. Specialists. Session-persistent learning.
> Built by [Giggso / AntiGravity Projects](https://github.com/giggsoinc). MIT License.

*Guardrails before you ship.*

---

## Install as a Claude Code Plugin

```bash
claude plugin install giggsoinc/raven
```

That's it. Raven installs 33 specialist skills, 10 guard agents, 10 slash commands, and an MCP server into your Claude Code session.

Then run the one-time project setup to install hooks, scripts, and your project manifest:

```bash
curl -fsSL https://raw.githubusercontent.com/giggsoinc/raven/main/install.sh | bash
```

---

## What You Get

### Guard Agents (always-on)
| Agent | Purpose |
|---|---|
| `manifest-checker` | Blocks all actions until manifest is loaded |
| `stack-validator` | Blocks code in undeclared stacks |
| `style-enforcer` | Style issues → warn on edit, block on commit |
| `architecture-guard` | No code without an architecture diagram |
| `db-guard` | SQL only in .sql files — hard block on inline SQL |
| `salesforce-guard` | SOQL/DML in loops, hardcoded IDs, fat triggers |
| `odoo-guard` | Hardcoded IDs, raw SQL in ORM, N+1 recordsets |
| `skill-guard` | Skills cannot read secrets or modify hooks |
| `guard-git-watch` | Force push, mass deletion, schema drop detection |

### Specialist Skills (on-demand)
33 curated specialists across every major platform:

`db-specialist` · `postgres-specialist` · `vector-db-specialist` · `salesforce-specialist` · `odoo-specialist` · `aws-specialist` · `azure-specialist` · `gcp-specialist` · `oci-specialist` · `k8s-specialist` · `terraform-specialist` · `devops-specialist` · `security-specialist` · `fastapi-specialist` · `aiml-specialist` · `bigdata-specialist` · `dataeng-specialist` · `kafka-specialist` · `redis-specialist` · `vault-specialist` · `nicegui-specialist` · `tools-landscape` · `dynamic-specialist` · `task-observer` · `andie` · `raven-core` · `raven-expert` · `raven-plan` · `raven-review` · `raven-security` · `raven-refactor` · `raven-test` · `raven-document`

### Slash Commands
| Command | Purpose |
|---|---|
| `/raven-init` | Bootstrap a new project with manifest + architecture |
| `/raven-debug` | Full project health check |
| `/raven-harden` | Promote session observations to permanent rules |
| `/raven-incident` | Declare and manage a production incident |
| `/raven-approve` | Approve a guarded action (deletion, library add) |
| `/raven-scaffold` | Generate boilerplate for your declared stack |
| `/raven-search` | On-demand expert search for platform-specific info |
| `/raven-sync` | Sync Raven engine to latest version |
| `/raven-registry-sync` | Sync all registered projects to current version |
| `/raven-registry-register` | Register a new project with Raven |

### Dynamic Specialist System
No curated skill for your platform? Raven generates one on the fly:
- Reads session history for prior observations
- Assesses confidence (HIGH / MEDIUM / VERIFY)
- Fires targeted search agent only when needed
- Caches the expert profile locally
- Promotes to a curated skill after 3 uses via `/raven-harden`

### Session-Persistent Learning (Task-Observer)
Silently watches every session:
- Logs corrections, vulnerabilities, and patterns to `docs/observations/security_log.md`
- Surfaces open observations at session start
- Weekly hardening reminder when 5+ entries accumulate
- `/raven-harden` turns observations into permanent CLAUDE.md rules

---

## Architecture

View the full architecture diagram:
[raven-architecture.html](https://htmlpreview.github.io/?https://github.com/giggsoinc/raven/blob/main/docs/raven-architecture.html)

---

## Engine Scripts

These scripts are bundled into every Raven project by `bundle.sh`:

| Script | Purpose |
|---|---|
| `cve-check.py` | Three-tier CVE engine — PyPI Safety + GPT deep scan |
| `secret-scan.py` | Secret and credential detection in staged files |
| `audit-log.py` | Encrypted audit log writer — S3 / GCS / Azure / OCI |
| `emit-violation.py` | Violation event emitter — feeds audit log |
| `db-guard.py` | PostEdit hook — blocks inline SQL in non-SQL files |
| `server.py` | MCP server — status, CVE check, sync libs, debug, violation |

---

## Plugin Structure

```
giggsoinc/raven (this repo)
├── .claude-plugin/
│   └── plugin.json          ← plugin metadata
├── .mcp.json                ← MCP server config
├── skills/                  ← 33 specialist SKILL.md files
├── agents/                  ← 10 guard agent .md files
├── commands/                ← 10 slash command .md files
├── cve-check.py             ← engine scripts
├── secret-scan.py
├── db-guard.py
├── server.py
├── bundle.sh                ← syncs plugin content + engine scripts
├── manifest.schema.json     ← project manifest schema
└── manifest.example.json    ← starter manifest
```

---

## MCP Server

The MCP server exposes 5 tools to any MCP-compatible agent:

```bash
# Add to Claude Code manually
claude mcp add raven -- python3 ~/.claude/scripts/server.py
```

Tools: `raven_status` · `raven_cve_check` · `raven_sync_libs` · `raven_debug` · `raven_violation`

---

## Contributing

Fix the engine here — it propagates to all platform repos via `bundle.sh`:

```bash
git clone https://github.com/giggsoinc/raven-core
# make your change
bash bundle.sh --dry-run    # preview what gets copied where
bash bundle.sh              # copy engine scripts + sync plugin content
# commit and push — post-commit hook fires bundle.sh automatically
```

---

## License

MIT — [Giggso / AntiGravity Projects](https://github.com/giggsoinc)
