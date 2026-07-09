import { readFileSync, readdirSync, statSync } from "node:fs";
import { join } from "node:path";

const root = new URL(".", import.meta.url).pathname;
const blocked = [
  /https?:\/\//i,
  /@import/i,
  /url\((['"]?)https?:/i,
  /analytics/i,
  /upload/i,
  /fetch\(/i,
  /XMLHttpRequest/i,
  /navigator\.sendBeacon/i,
  /<form/i,
  /type=['"]file/i
];

function files(dir) {
  return readdirSync(dir).flatMap((entry) => {
    const path = join(dir, entry);
    const stat = statSync(path);
    return stat.isDirectory() ? files(path) : [path];
  });
}

let failed = false;
for (const path of files(root)) {
  if (!/\.(html|css|js|mjs|md)$/.test(path)) continue;
  if (path.endsWith("offline-check.mjs")) continue;
  const text = readFileSync(path, "utf8");
  for (const pattern of blocked) {
    if (pattern.test(text)) {
      console.error(`offline policy violation: ${path} matches ${pattern}`);
      failed = true;
    }
  }
}

if (failed) {
  process.exit(1);
}

console.log("offline policy scan passed");
