# Raven Core

> The shared discipline engine powering the Raven platform.
> Built by [Giggso Inc](https://github.com/giggsoinc). MIT License.

---

## What This Is

Raven Core is the shared engine used by all Raven platform implementations.
It is not installed directly — it is used by:

| Repo | Platform |
|---|---|
| [giggsoinc/raven](https://github.com/giggsoinc/raven) | Claude Code |
| [giggsoinc/raven-codex](https://github.com/giggsoinc/raven-codex) | OpenAI Codex |
| [giggsoinc/raven-action](https://github.com/giggsoinc/raven-action) | GitHub Action |

---

## What's in Here

| File | Purpose |
|---|---|
| `cve-check.py` | Three-tier CVE engine — PyPI Safety + GPT deep scan |
| `secret-scan.py` | Secret and credential detection in staged files |
| `audit-log.py` | Encrypted audit log writer — S3 / GCS / Azure / OCI |
| `emit-violation.py` | Violation event emitter — feeds audit log |
| `manifest.schema.json` | Canonical manifest schema — all platforms validate against this |
| `manifest.example.json` | Example manifest for new projects |
| `server.py` | MCP server — 5 tools: status, CVE check, sync libs, debug, violation |

---

## Contributing

Fix the engine here — it fixes every platform at once.

```bash
git clone https://github.com/giggsoinc/raven-core
```

---

## License

MIT — [Giggso Inc](https://github.com/giggsoinc)
