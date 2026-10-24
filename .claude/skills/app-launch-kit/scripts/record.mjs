// Records store/src/promo.html to a PNG frame sequence by driving headless Chrome
// over CDP. No dependencies — Node 22+ ships a global WebSocket.
// Usage: node record.mjs <promo.html> <out-dir> [fps]
import { spawn } from 'node:child_process';
import { mkdir, writeFile, rm } from 'node:fs/promises';
import { join, resolve } from 'node:path';

const [page, outDir, fpsArg] = process.argv.slice(2);
if (!page || !outDir) { console.error('usage: record.mjs <promo.html> <out-dir> [fps]'); process.exit(1); }
const FPS = Number(fpsArg || 30);
const CHROME = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const PORT = 9222 + (process.pid % 500);

await rm(outDir, { recursive: true, force: true });
await mkdir(outDir, { recursive: true });

const chrome = spawn(CHROME, [
  '--headless=new', '--disable-gpu', '--hide-scrollbars', '--allow-file-access-from-files',
  '--window-size=1080,1920', '--force-device-scale-factor=1',
  `--remote-debugging-port=${PORT}`, '--user-data-dir=' + join(outDir, '.chrome'),
  `file://${resolve(page)}?clean=1`,
], { stdio: 'ignore' });

const sleep = ms => new Promise(r => setTimeout(r, ms));
let target;
for (let i = 0; i < 60 && !target; i++) {
  await sleep(250);
  try {
    const list = await (await fetch(`http://127.0.0.1:${PORT}/json`)).json();
    target = list.find(t => t.type === 'page' && t.webSocketDebuggerUrl);
  } catch {}
}
if (!target) { chrome.kill(); throw new Error('Chrome did not expose a debugging target'); }

const ws = new WebSocket(target.webSocketDebuggerUrl);
await new Promise((ok, bad) => { ws.onopen = ok; ws.onerror = bad; });
let nextId = 1; const pending = new Map();
ws.onmessage = e => {
  const m = JSON.parse(e.data);
  if (m.id && pending.has(m.id)) { pending.get(m.id)(m.result ?? {}); pending.delete(m.id); }
};
const cdp = (method, params = {}) => new Promise(ok => {
  const id = nextId++; pending.set(id, ok); ws.send(JSON.stringify({ id, method, params }));
});
const evaluate = async expr => (await cdp('Runtime.evaluate', { expression: expr, returnByValue: true })).result?.value;

await cdp('Page.enable');
// The headless window is not the viewport — force exact 1080x1920 or the frames
// come out short and libx264 rejects the odd height.
await cdp('Emulation.setDeviceMetricsOverride', { width: 1080, height: 1920, deviceScaleFactor: 1, mobile: false });
// wait for the page's own scenes + screenshots to be in place
for (let i = 0; i < 40; i++) { if (await evaluate('typeof window.seekTo === "function"')) break; await sleep(250); }
await evaluate('document.fonts.ready.then(()=>1)');
await sleep(1200);   // let the <img> screenshots decode before the first frame

const total = await evaluate('window.promoDuration()');
const frames = Math.round(total * FPS);
console.log(`duration ${total.toFixed(2)}s -> ${frames} frames @ ${FPS}fps`);

for (let f = 0; f < frames; f++) {
  await evaluate(`window.seekTo(${(f / FPS).toFixed(4)})`);
  const { data } = await cdp('Page.captureScreenshot', { format: 'png', captureBeyondViewport: false });
  await writeFile(join(outDir, `f${String(f).padStart(5, '0')}.png`), Buffer.from(data, 'base64'));
  if (f % 60 === 0) process.stdout.write(`\r  frame ${f}/${frames}`);
}
console.log(`\rwrote ${frames} frames to ${outDir}`);
ws.close(); chrome.kill();
