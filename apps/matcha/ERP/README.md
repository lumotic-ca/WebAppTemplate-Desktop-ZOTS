# Matcha ERP

Native web wrappers for **self-hosted ERPNext** instances.

Users connect to their own ERPNext server URL (e.g. `https://erp.company.com`). The app remembers the server across sessions and opens it in a native WebView shell.

## Implementations

| Folder | Stack | Status |
|---|---|---|
| [flutter/](flutter/) | Flutter | Not started |
| [tauri/](tauri/) | Tauri v2 | Ready |

## Tauri (desktop)

Minimal single-window wrapper — see [tauri/README.md](tauri/README.md).

```bash
cd tauri
npm install
npm run tauri dev
```

## ERPNext notes

- ERPNext is served over **HTTPS** on a user-provided host
- Typical entry path: site root or `/app` depending on the instance
- Self-hosted instances may use custom domains, internal IPs, or `.local` hosts
