#!/usr/bin/env node
'use strict';
// scenarios.js — the one reader of a target's state registry
// (design/generated/<target>/images/index.md), the one owner of the deep-link
// formula, and the renderer behind the scenario preview server and the
// published site. Wrapped by preview-scenarios.sh, publish-scenarios.sh,
// build-images.sh, open-deeplink.sh and check-variants.sh; not run directly.
//
// Usage: node scenarios.js <command> --project <dir> --target <name> [options]
//   meta                      appId and scheme, one "key<TAB>value" per line
//   registry                  one entry per line, fields separated by 0x1f (unit separator —
//                             a tab would collapse empty fields under bash `read`):
//                             id route variant file capture(1|0) link deps(comma-separated)
//   link  --route R [--variant V] [--locale L] [--params k=v]...   print link 0x1f appId 0x1f scheme
//   link  --id ID | --file F                                        link of a registry entry
//   serve --port N [--host H] [--device ID] --open-script <path>    preview server
//   build --out <dir>                                               static site
//
// Needs the `yaml` package (all commands) and `marked` (serve/build). Run it as
//   npx --yes -p marked -p yaml node scenarios.js …
// and both are found on PATH (see req()).

const fs = require('fs');
const path = require('path');
const http = require('http');
const { execFile } = require('child_process');

const US = '\x1f'; // field separator for machine-facing output (see header)

function fail(msg, code = 1) { process.stderr.write(`Error: ${msg}\n`); process.exit(code); }

// Resolve a package installed by `npx -p`: its bin dir is on PATH, and the
// package itself sits one level up from that.
function req(name) {
  try { return require(name); } catch (_) { /* not on the default path */ }
  for (const dir of (process.env.PATH || '').split(path.delimiter)) {
    if (!/node_modules[\\/]\.bin$/.test(dir)) continue;
    try { return require(path.join(dir, '..', name)); } catch (_) { /* next dir */ }
  }
  fail(`package '${name}' not found; run via: npx --yes -p marked -p yaml node ${path.basename(__filename)} …`);
}

// ---------- arguments ----------

function parseArgs(argv) {
  const a = { params: [] };
  for (let i = 0; i < argv.length; i++) {
    const k = argv[i];
    if (!k.startsWith('--')) { a.command = a.command || k; continue; }
    const key = k.slice(2);
    if (key === 'params') { a.params.push(argv[++i]); continue; }
    a[key] = argv[++i];
  }
  return a;
}

// ---------- registry ----------

// The frontmatter block: everything between the first `---` line and the next.
function frontmatterBlock(text) {
  const lines = text.split(/\r?\n/);
  let start = -1;
  for (let i = 0; i < lines.length; i++) {
    if (lines[i].trim() !== '---') continue;
    if (start < 0) start = i; else return lines.slice(start + 1, i).join('\n');
  }
  return null;
}

// Percent-encode a link component unless the author already did.
const enc = (s) => (/%[0-9a-f]{2}/i.test(s) ? s : encodeURIComponent(s));

// The deep-link formula. Route may carry path segments (`TallyView/tally%3Aid`).
function buildLink(scheme, route, variant, locale, params) {
  const q = [];
  if (variant) q.push('variant=' + enc(variant));
  if (locale && locale !== 'en') q.push('locale=' + enc(locale));
  for (const [k, v] of Object.entries(params || {})) q.push(enc(k) + '=' + enc(v));
  return `${scheme}://screen/${route}` + (q.length ? '?' + q.join('&') : '');
}

function slug(...parts) {
  return parts.filter(Boolean).join('-').toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
}

function loadRegistry(genDir) {
  const file = path.join(genDir, 'images', 'index.md');
  const reg = { file, appId: '', scheme: '', entries: [] };
  if (!fs.existsSync(file)) return reg;
  const block = frontmatterBlock(fs.readFileSync(file, 'utf8'));
  const doc = (block && req('yaml').parse(block)) || {};
  reg.appId = doc.appId == null ? '' : String(doc.appId);
  reg.scheme = doc.scheme == null ? '' : String(doc.scheme);
  const list = Array.isArray(doc.screenshots) ? doc.screenshots : [];
  reg.entries = list.map((e, i) => {
    const route = String(e.route || '').trim();
    const variant = e.variant == null ? '' : String(e.variant);
    const locale = e.locale == null ? '' : String(e.locale);
    const params = {};
    if (e.params && typeof e.params === 'object') {
      for (const [k, v] of Object.entries(e.params)) params[k] = v == null ? '' : String(v);
    }
    const fileName = e.file ? String(e.file) : '';
    let capture = e.capture !== false;
    if (capture && !fileName) {
      process.stderr.write(`Warning: ${path.relative(process.cwd(), file)} entry ${i + 1} (${route}) has no file; treating as capture: false\n`);
      capture = false;
    }
    const paramSlug = Object.values(params).join('-');
    const id = e.id ? String(e.id) : fileName ? fileName.replace(/\.[^.]+$/, '') : slug(route, variant, paramSlug);
    return {
      id, route, variant, locale, params, file: fileName, capture,
      note: e.note == null ? '' : String(e.note),
      deps: Array.isArray(e.deps) ? e.deps.map(String) : [],
      link: buildLink(reg.scheme, route, variant, locale, params),
    };
  });
  return reg;
}

// ---------- rendering ----------

function esc(s) {
  return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

function loadTemplate(file) {
  return fs.readFileSync(file, 'utf8');
}

function fillTemplate(tpl, fields) {
  return tpl.replace(/\{\{(\w+)\}\}/g, (_, k) => (fields[k] == null ? '' : fields[k]));
}

// A bare `![alt](../images/f.png)` is linked to the registry entry that owns f.png.
// An explicit `[![alt](img)](link)` is left exactly as written.
function autoLinkImages(md, reg) {
  const byFile = new Map(reg.entries.filter((e) => e.file).map((e) => [e.file, e]));
  return md.replace(/(^|[^[])(!\[[^\]]*\]\(([^)\s]+)\))/g, (m, before, img, src) => {
    const entry = byFile.get(path.basename(src));
    return entry ? `${before}[${img}](${entry.link})` : m;
  });
}

// Compare the explicit links in a doc with the registry's link for the same image.
function linkDrift(md, reg) {
  const byFile = new Map(reg.entries.filter((e) => e.file).map((e) => [e.file, e]));
  const out = [];
  const re = /\[!\[[^\]]*\]\(([^)\s]+)\)\]\(([^)\s]+)\)/g;
  let m;
  while ((m = re.exec(md))) {
    const entry = byFile.get(path.basename(m[1]));
    if (!entry) out.push({ image: m[1], problem: 'not in registry' });
    else if (entry.link !== m[2]) out.push({ image: m[1], problem: `links to ${m[2]}, registry says ${entry.link}` });
  }
  return out;
}

function renderMarkdown(md) {
  const m = req('marked');
  const marked = m.marked || m;
  return marked.parse(md);
}

// mode: 'serve' (links stay .md, live-link script injected) | 'build' (.md → .html, no script)
function renderDoc(mdText, { reg, mode, root, template, title, nav, extra }) {
  let md = mdText;
  if (md.startsWith('---')) {
    const block = frontmatterBlock(md);
    if (block != null) md = md.slice(md.indexOf('---', 3 + block.length) + 3);
  }
  md = autoLinkImages(md, reg);
  const heading = /^#\s+(.+)$/m.exec(md);
  let html = renderMarkdown(md);
  if (mode === 'build') html = html.replace(/href="([^"/]+)\.md"/g, 'href="$1.html"');
  return fillTemplate(template, {
    title: title || (heading ? heading[1].trim() : 'Scenario'),
    content: html,
    nav: nav || '',
    extra: extra || '',
    root: root || '',
  });
}

// In serve mode the header states where links go; the server, not the page, owns that.
function navHtml(root, mode, device) {
  const ext = mode === 'build' ? '.html' : '.md';
  const states = mode === 'build' ? 'states.html' : 'states';
  const where = mode === 'serve' ? `<span class="appeus-device">links open on: <code>${esc(device || 'auto')}</code></span>` : '';
  return `<nav class="appeus-nav"><a href="${root}scenarios/index${ext}">Scenarios</a> · <a href="${root}${states}">States</a>${where}</nav>`;
}

function statesHtml(reg, genDir, mode) {
  const ext = mode === 'build' ? '.html' : '.md';
  const rows = reg.entries.map((e) => {
    const imgPath = e.file ? path.join(genDir, 'images', e.file) : '';
    const has = imgPath && fs.existsSync(imgPath);
    const thumb = has
      ? `<a href="${esc(e.link)}"><img class="thumb" src="images/${esc(e.file)}" alt="${esc(e.id)}"></a>`
      : `<span class="muted">${e.capture ? 'not captured yet' : 'no screenshot'}</span>`;
    const variant = e.variant || '<span class="muted">default</span>';
    const params = Object.entries(e.params).map(([k, v]) => `${esc(k)}=${esc(v)}`).join(' ');
    return `<tr><td>${thumb}</td><td><code>${esc(e.route)}</code>${params ? `<br><small>${params}</small>` : ''}</td>` +
      `<td>${variant}</td><td>${esc(e.note)}</td><td><a href="${esc(e.link)}">open</a><br><small><code>${esc(e.link)}</code></small></td></tr>`;
  });
  const body = reg.entries.length
    ? `<table class="states"><thead><tr><th></th><th>Screen</th><th>Variant</th><th>Note</th><th>Link</th></tr></thead><tbody>${rows.join('\n')}</tbody></table>`
    : `<p>No states registered. Add entries under <code>screenshots:</code> in <code>images/index.md</code>.</p>`;
  const intro = `<h1>States</h1><p>Every reviewable state registered for this target (${reg.entries.length}). ` +
    (mode === 'serve' ? 'Click a screenshot or <em>open</em> to launch it on the preview\'s device.' : 'Open a link on a device that has the app installed.') +
    ` Scenarios: <a href="scenarios/index${ext}">index</a>.</p>`;
  return intro + body;
}

// The client side of live links: the page says which state, the server knows which
// device. On a phone's own browser the OS resolves the scheme, so the script stands aside.
function liveScript(scheme) {
  return `<div id="appeus-toast" class="appeus-toast" hidden></div>
<script>
(function () {
  var scheme = ${JSON.stringify(scheme)};
  if (/Android|iPhone|iPad/i.test(navigator.userAgent)) return;
  var toast = document.getElementById('appeus-toast');
  function say(msg, ok) {
    toast.textContent = msg; toast.className = 'appeus-toast ' + (ok ? 'ok' : 'err'); toast.hidden = false;
    clearTimeout(say.t); say.t = setTimeout(function () { toast.hidden = true; }, ok ? 2500 : 10000);
  }
  document.addEventListener('click', function (e) {
    var a = e.target.closest ? e.target.closest('a[href]') : null;
    if (!a) return;
    var href = a.getAttribute('href') || '';
    if (!scheme || href.indexOf(scheme + '://') !== 0) return;
    e.preventDefault();
    say('Opening…', true);
    fetch('/open?link=' + encodeURIComponent(href))
      .then(function (r) { return r.json(); })
      .then(function (j) { say(j.message, j.ok); })
      .catch(function (err) { say('preview server unreachable: ' + err, false); });
  });
})();
</script>`;
}

// ---------- serve ----------

const MIME = {
  '.png': 'image/png', '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg', '.gif': 'image/gif', '.svg': 'image/svg+xml',
  '.css': 'text/css', '.js': 'text/javascript', '.json': 'application/json', '.html': 'text/html; charset=utf-8',
  '.md': 'text/plain; charset=utf-8', '.txt': 'text/plain; charset=utf-8',
};

function runScript(script, args, env, cb) {
  execFile(script, args, { env: { ...process.env, ...env }, timeout: 30000 }, (err, stdout, stderr) => {
    cb(err ? (err.code == null ? 1 : err.code) : 0, String(stdout), String(stderr));
  });
}

function serve(opts) {
  const { genDir, project, target, port, host, openScript, template, device } = opts;
  const scenDir = path.join(genDir, 'scenarios');
  const env = { APPEUS_PROJECT_DIR: project };
  const send = (res, code, type, body) => { res.writeHead(code, { 'Content-Type': type, 'Cache-Control': 'no-store' }); res.end(body); };
  const json = (res, code, obj) => send(res, code, 'application/json', JSON.stringify(obj));

  const server = http.createServer((req, res) => {
    const u = new URL(req.url, 'http://x');
    const p = decodeURIComponent(u.pathname);
    const reg = loadRegistry(genDir); // re-read per request: the registry is edited while previewing

    if (p === '/' || p === '/index.html') {
      const to = fs.existsSync(path.join(scenDir, 'index.md')) ? '/scenarios/index.md' : '/states';
      res.writeHead(302, { Location: to }); return res.end();
    }
    if (p === '/open') {
      const link = u.searchParams.get('link') || '';
      if (!reg.scheme || !link.startsWith(reg.scheme + '://')) {
        return json(res, 400, { ok: false, message: `refusing to open '${link}': not a ${reg.scheme || '<scheme>'}:// link` });
      }
      const args = ['--target', target, '--link', link];
      if (reg.appId) args.push('--app-id', reg.appId);
      if (device) args.push('--device', device);
      return runScript(openScript, args, env, (code, out, err) => {
        if (code === 0) return json(res, 200, { ok: true, message: out.trim() || `opened ${link}` });
        let message = (err.trim() || out.trim() || `open-deeplink exited ${code}`).split('\n')[0];
        if (code === 3) message = 'Several devices connected; restart the preview with --device <id> (or set APPEUS_DEVICE)';
        json(res, 200, { ok: false, message });
      });
    }
    if (p === '/states' || p === '/states.html') {
      const page = fillTemplate(template, { title: 'States', content: statesHtml(reg, genDir, 'serve'), nav: navHtml('', 'serve', device), extra: liveScript(reg.scheme), root: '' });
      return send(res, 200, MIME['.html'], page);
    }
    const mdMatch = /^\/scenarios\/([^/]+)\.(md|html)$/.exec(p);
    if (mdMatch) {
      const file = path.join(scenDir, mdMatch[1] + '.md');
      if (!fs.existsSync(file)) return send(res, 404, 'text/plain', `not found: ${p}`);
      const page = renderDoc(fs.readFileSync(file, 'utf8'), { reg, mode: 'serve', root: '../', template, nav: navHtml('../', 'serve', device), extra: liveScript(reg.scheme) });
      return send(res, 200, MIME['.html'], page);
    }
    // Static files under the generated dir only.
    const file = path.normalize(path.join(genDir, p));
    if (!file.startsWith(genDir + path.sep) || !fs.existsSync(file) || fs.statSync(file).isDirectory()) {
      return send(res, 404, 'text/plain', `not found: ${p}`);
    }
    send(res, 200, MIME[path.extname(file).toLowerCase()] || 'application/octet-stream', fs.readFileSync(file));
  });

  // One preview per project means collisions are ordinary; say so plainly.
  server.on('error', (err) => {
    if (err.code === 'EADDRINUSE') {
      process.stderr.write(`Error: port ${port} is already in use (another preview server?).\n` +
        `  Choose another with --port <n>, or set APPEUS_PORT for this project.\n`);
      process.exit(4);
    }
    if (err.code === 'EACCES') {
      process.stderr.write(`Error: not allowed to listen on port ${port}; use --port with a value above 1023.\n`);
      process.exit(4);
    }
    throw err;
  });

  server.listen(port, host, () => {
    process.stdout.write(`Previewing ${path.relative(process.cwd(), genDir) || genDir} at http://${host === '0.0.0.0' ? 'localhost' : host}:${port}/\n`);
    if (host === '0.0.0.0') process.stdout.write('Bound to all interfaces: open the same URL with this machine\'s LAN address on a phone that has the app installed.\n');
    // Say now, not on the first click, where links will go.
    if (device) return process.stdout.write(`Links open on: ${device}\n`);
    runScript(openScript, ['--list'], env, (_c, out) => {
      const rows = out.split('\n').filter(Boolean);
      if (rows.length === 1) process.stdout.write(`Links open on: ${rows[0].split('\t')[1]} (the only connected device)\n`);
      else if (rows.length === 0) process.stdout.write('No device connected; links will fail until one is (or restart with --device <id>).\n');
      else process.stdout.write(`${rows.length} devices connected; links will fail until you restart with --device <id> or set APPEUS_DEVICE:\n` + rows.map((r) => '  ' + r.replace(/\t/g, '  ')).join('\n') + '\n');
    });
  });
}

// ---------- build ----------

function build(opts) {
  const { genDir, out, template } = opts;
  const reg = loadRegistry(genDir);
  const scenDir = path.join(genDir, 'scenarios');
  const imgDir = path.join(genDir, 'images');
  fs.mkdirSync(path.join(out, 'scenarios'), { recursive: true });
  fs.mkdirSync(path.join(out, 'images'), { recursive: true });
  if (fs.existsSync(imgDir)) {
    for (const f of fs.readdirSync(imgDir)) {
      if (/\.(png|jpe?g|gif|svg)$/i.test(f)) fs.copyFileSync(path.join(imgDir, f), path.join(out, 'images', f));
    }
  }
  let count = 0;
  const drift = [];
  if (fs.existsSync(scenDir)) {
    for (const f of fs.readdirSync(scenDir)) {
      if (!f.endsWith('.md')) continue;
      const md = fs.readFileSync(path.join(scenDir, f), 'utf8');
      for (const d of linkDrift(md, reg)) drift.push(`${f}: ${d.image} ${d.problem}`);
      const page = renderDoc(md, { reg, mode: 'build', root: '../', template, nav: navHtml('../', 'build') });
      fs.writeFileSync(path.join(out, 'scenarios', f.replace(/\.md$/, '.html')), page);
      count++;
    }
  }
  fs.writeFileSync(path.join(out, 'states.html'), fillTemplate(template, { title: 'States', content: statesHtml(reg, genDir, 'build'), nav: navHtml('', 'build'), extra: '', root: '' }));
  const home = fs.existsSync(path.join(out, 'scenarios', 'index.html')) ? 'scenarios/index.html' : 'states.html';
  fs.writeFileSync(path.join(out, 'index.html'), `<!doctype html><meta charset="utf-8"><meta http-equiv="refresh" content="0; url=${home}">`);
  process.stdout.write(`Rendered ${count} scenario page(s) + states.html to ${out}\n`);
  for (const d of drift) process.stdout.write(`Note: ${d}\n`);
}

// ---------- main ----------

function main() {
  const a = parseArgs(process.argv.slice(2));
  if (!a.command) fail('missing command (meta | registry | link | serve | build)');
  if (!a.project || !a.target) fail('--project and --target are required');
  const project = path.resolve(a.project);
  const genDir = path.join(project, 'design', 'generated', a.target);
  const template = loadTemplate(a.template || path.join(__dirname, '..', '..', 'templates', 'scenarios', 'page.html'));

  switch (a.command) {
    case 'meta': {
      const reg = loadRegistry(genDir);
      process.stdout.write(`appId\t${reg.appId}\nscheme\t${reg.scheme}\n`);
      break;
    }
    case 'registry': {
      const reg = loadRegistry(genDir);
      for (const e of reg.entries) {
        process.stdout.write([e.id, e.route, e.variant, e.file, e.capture ? '1' : '0', e.link, e.deps.join(',')].join(US) + '\n');
      }
      break;
    }
    case 'link': {
      const reg = loadRegistry(genDir);
      let link;
      if (a.id || a.file) {
        const e = reg.entries.find((x) => x.id === a.id || (a.file && x.file === a.file));
        if (!e) fail(`no registry entry ${a.id ? `with id '${a.id}'` : `for file '${a.file}'`} in ${reg.file}`);
        link = e.link;
      } else {
        if (!a.route) fail('link needs --route, --id or --file');
        if (!reg.scheme) fail(`no scheme in ${reg.file}; set the frontmatter 'scheme:' first`);
        const params = {};
        for (const kv of a.params) { const i = kv.indexOf('='); if (i < 0) fail(`--params expects k=v, got '${kv}'`); params[kv.slice(0, i)] = kv.slice(i + 1); }
        link = buildLink(reg.scheme, a.route, a.variant || '', a.locale || '', params);
      }
      process.stdout.write([link, reg.appId, reg.scheme].join(US) + '\n');
      break;
    }
    case 'serve':
      if (!a['open-script']) fail('serve needs --open-script <path to open-deeplink.sh>');
      serve({ genDir, project, target: a.target, port: Number(a.port || 8080), host: a.host || '127.0.0.1', openScript: a['open-script'], template, device: a.device || '' });
      break;
    case 'build':
      if (!a.out) fail('build needs --out <dir>');
      build({ genDir, out: path.resolve(a.out), template });
      break;
    default:
      fail(`unknown command '${a.command}'`);
  }
}

main();
