"use strict";

const api = () => (window.pywebview ? window.pywebview.api : null);

/* ── Helpers ──────────────────────────────────────────────────────── */

function formatSize(bytes) {
  if (bytes >= 1073741824) return (bytes / 1073741824).toFixed(2) + " GB";
  if (bytes >= 1048576) return (bytes / 1048576).toFixed(2) + " MB";
  if (bytes >= 1024) return (bytes / 1024).toFixed(2) + " KB";
  return bytes + " B";
}

function esc(s) {
  return String(s || "").replace(/[&<>"']/g, c => (
    c === "&" ? "&amp;" : c === "<" ? "&lt;" : c === ">" ? "&gt;" : c === '"' ? "&quot;" : "&#039;"
  ));
}

function toast(msg, duration) {
  duration = duration || 3000;
  const el = document.getElementById("toast");
  el.textContent = msg;
  el.classList.add("show");
  clearTimeout(el._timer);
  el._timer = setTimeout(() => el.classList.remove("show"), duration);
}

/* ── Tab switching ────────────────────────────────────────────────── */

function activateTab(tabId, updateHash) {
  if (!tabId) return;
  if (tabId === "remote") return;

  const btn = document.querySelector(`.tab-btn[data-tab="${tabId}"]`);
  const panel = document.getElementById(tabId);
  if (!btn || !panel) return;

  document.querySelectorAll(".tab-btn").forEach(b => b.classList.remove("active"));
  document.querySelectorAll(".panel").forEach(p => p.classList.remove("active"));
  btn.classList.add("active");
  panel.classList.add("active");
  if (updateHash) {
    try { window.location.hash = "#" + tabId; } catch (_) {}
  }
}

document.querySelectorAll(".tab-btn").forEach(btn => {
  btn.addEventListener("click", () => {
    activateTab(btn.dataset.tab, true);
  });
});

window.addEventListener("hashchange", () => {
  const h = (window.location.hash || "").replace("#", "").trim().toLowerCase();
  if (h) activateTab(h, false);
});

async function goRemote() {
  const a = api();
  if (!a || !a.navigate_main_to_remote) return;
  await a.navigate_main_to_remote();
  if (a.show_main) await a.show_main();
}

/* ── Downloads ────────────────────────────────────────────────────── */

function renderDownloads(records) {
  const container = document.getElementById("downloads-list");
  const empty = document.getElementById("downloads-empty");

  if (!records || records.length === 0) {
    container.innerHTML = "";
    empty.style.display = "";
    return;
  }
  empty.style.display = "none";

  container.innerHTML = records.map(r => {
    const fname = r.last_seen_filename
      ? r.last_seen_filename
      : (r.path ? r.path.split(/[\\/]/).pop() : "unknown");
    const status = r.status || "Unknown";
    const pct = status === "Completed"
      ? 100
      : (r.total_bytes > 0 ? Math.floor((r.received_bytes || 0) / r.total_bytes * 100) : 0);
    const isZip = fname.toLowerCase().endsWith(".zip");

    let badgeClass = "badge-info";
    if (status === "Completed") badgeClass = "badge-success";
    else if (status === "Failed" || status === "Cancelled") badgeClass = "badge-error";

    let sizeText = "";
    if (status === "Downloading") {
      const got = r.received_bytes ? formatSize(r.received_bytes) : "0 B";
      sizeText = r.total_bytes > 0 ? `${got} / ${formatSize(r.total_bytes)}` : `${got}`;
    } else if (r.total_bytes > 0) {
      sizeText = formatSize(r.total_bytes);
    }

    let buttons = "";
    if (status === "Downloading") {
      buttons = `<button class="btn btn-sm btn-danger" onclick="cancelDl('${r.id}')">Cancel</button>`;
    } else if (status === "Completed") {
      buttons = `<button class="btn btn-sm" onclick="openFile('${esc(r.path)}')">Open</button>
                 <button class="btn btn-sm" onclick="openFolder('${esc(r.path)}')">Folder</button>`;
      if (isZip) {
        buttons += `<button class="btn btn-sm btn-accent" onclick="unzipDl('${esc(r.path)}')">Unzip</button>
                    <button class="btn btn-sm btn-danger" onclick="removeZip('${esc(r.path)}','${r.id}')">Remove ZIP</button>`;
      }
    }
    buttons += `<button class="btn btn-sm" onclick="removeDl('${r.id}')">Remove</button>`;

    const indeterminate = (status === "Downloading" && (!r.total_bytes || r.total_bytes <= 0));
    return `<div class="card" id="dl-${r.id}">
      <div class="card-header">
        <span class="card-title">${esc(fname)}</span>
        <span class="badge ${badgeClass} ${status === "Downloading" ? "badge-pulse" : ""}">${esc(status)}</span>
      </div>
      ${sizeText ? `<div class="card-subtitle">${sizeText}</div>` : ""}
      <div class="progress-outer ${indeterminate ? "progress-indeterminate" : ""}">
        <div class="progress-inner" id="prog-${r.id}" style="width:${pct}%"></div>
      </div>
      <div class="btn-row">${buttons}</div>
    </div>`;
  }).join("");
}

async function loadDownloads() {
  const a = api(); if (!a) return;
  try {
    const raw = await a.get_downloads();
    const records = JSON.parse(raw);
    renderDownloads(records);
  } catch (e) { console.error("loadDownloads", e); }
}

async function cancelDl(id) {
  const a = api(); if (!a) return;
  await a.cancel_download(id);
  toast("Cancel requested");
  loadDownloads();
}

async function removeDl(id) {
  const a = api(); if (!a) return;
  await a.remove_download(id);
  toast("Removed");
  loadDownloads();
}

async function openFile(path) {
  const a = api(); if (!a) return;
  await a.open_file(path);
}

async function openFolder(path) {
  const a = api(); if (!a) return;
  await a.open_folder(path);
}

/* ── ZIP / Install ────────────────────────────────────────────────── */

async function unzipDl(path) {
  const a = api(); if (!a) return;
  const res = JSON.parse(await a.unzip_file(path, ""));
  if (res.ok) toast("Unzip started");
  else toast("Error: " + (res.error || "Unknown"));
}

async function removeZip(path, id) {
  if (!confirm("Remove ZIP file from disk?")) return;
  const a = api(); if (!a) return;
  const res = JSON.parse(await a.remove_zip(path));
  if (res.ok) toast("ZIP removed");
  else toast("Error: " + res.error);
  loadDownloads();
}

window._onUnzipProgress = function (unzipId, pct) {
  toast(`Unzipping ${unzipId}: ${pct}%`, 1200);
};
window._onUnzipFinished = function (unzipId) {
  toast(`Unzip complete: ${unzipId}`);
};
window._onUnzipError = function (_unzipId, msg) {
  toast("Unzip error: " + msg);
};

/* ── Settings ─────────────────────────────────────────────────────── */

async function loadSettings() {
  const a = api(); if (!a) return;
  try {
    const raw = await a.get_settings();
    const s = JSON.parse(raw);
    document.getElementById("s-url").value = s.WEBAPPCORE_URL || "";
    document.getElementById("s-width").value = s.WEBAPPCORE_WINDOW_WIDTH || 1420;
    document.getElementById("s-height").value = s.WEBAPPCORE_WINDOW_HEIGHT || 940;
    document.getElementById("s-download-dir").value = s.WEBAPPCORE_DEFAULT_DOWNLOAD_DIR || "";
    document.getElementById("s-unzip-dir").value = s.WEBAPPCORE_DEFAULT_UNZIP_DIR || "";
    document.getElementById("s-minimized").checked = !!s.WEBAPPCORE_START_MINIMIZED;
    document.getElementById("s-prompt-unzip").checked = !!s.WEBAPPCORE_PROMPT_UNZIP_DIR;
  } catch (e) { console.error("loadSettings", e); }
}

async function openServerSetup() {
  const a = api();
  if (!a || !a.show_server_setup) return;
  await a.show_server_setup();
  if (a.show_main) await a.show_main();
}

async function saveSettings() {
  const a = api(); if (!a) return;
  const data = {
    WEBAPPCORE_URL: document.getElementById("s-url").value,
    WEBAPPCORE_WINDOW_WIDTH: parseInt(document.getElementById("s-width").value) || 1420,
    WEBAPPCORE_WINDOW_HEIGHT: parseInt(document.getElementById("s-height").value) || 940,
    WEBAPPCORE_DEFAULT_DOWNLOAD_DIR: document.getElementById("s-download-dir").value,
    WEBAPPCORE_DEFAULT_UNZIP_DIR: document.getElementById("s-unzip-dir").value,
    WEBAPPCORE_START_MINIMIZED: document.getElementById("s-minimized").checked ? 1 : 0,
    WEBAPPCORE_PROMPT_UNZIP_DIR: document.getElementById("s-prompt-unzip").checked ? 1 : 0,
  };
  const res = JSON.parse(await a.save_settings(JSON.stringify(data)));
  if (res.ok) toast("Settings saved!");
  else toast("Error: " + (res.error || "Unknown"));
}

async function browseDir(inputId) {
  const a = api(); if (!a) return;
  const dir = await a.pick_directory("Select Directory");
  if (dir) document.getElementById(inputId).value = dir;
}

/* ── Init ─────────────────────────────────────────────────────────── */

async function init() {
  const a = api();
  if (!a) { setTimeout(init, 100); return; }

  loadDownloads();
  loadSettings();

  const h = (window.location.hash || "").replace("#", "").trim().toLowerCase();
  if (h) activateTab(h, false);

  setInterval(loadDownloads, 5000);
}

window.addEventListener("pywebviewready", init);
if (window.pywebview) init();
