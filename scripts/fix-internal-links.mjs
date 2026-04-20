#!/usr/bin/env node
import { readFileSync, writeFileSync, readdirSync, statSync } from "node:fs";
import { resolve, dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = resolve(__dirname, "..");

const SKIP = new Set([
  "index-old.html",
  "index-backup.html",
]);

function walk(dir, acc = []) {
  for (const entry of readdirSync(dir)) {
    const full = join(dir, entry);
    if (entry.startsWith(".") || entry === "node_modules" || entry === "scripts" || entry === "_audit-reports") continue;
    const s = statSync(full);
    if (s.isDirectory()) walk(full, acc);
    else if (entry.endsWith(".html") && !SKIP.has(entry)) acc.push(full);
  }
  return acc;
}

const files = walk(ROOT);
let totalReplaced = 0;
const report = [];

for (const file of files) {
  const src = readFileSync(file, "utf8");
  let out = src;
  let count = 0;

  // 1. href="./page.html#frag" or ../page.html#frag → /page#frag
  //    special case: index.html → /
  out = out.replace(/href="(\.\.?\/)?([a-z0-9-]+)\.html(#[^"]*)?"/gi, (m, rel, name, frag = "") => {
    count++;
    if (name === "index") return `href="/${frag}"`;
    return `href="/${name}${frag}"`;
  });

  // 2. href="blog/article.html" or ./blog/article.html → /blog/article
  out = out.replace(/href="(\.?\/)?blog\/([a-z0-9-]+)\.html(#[^"]*)?"/gi, (m, rel, name, frag = "") => {
    count++;
    if (name === "index") return `href="/blog${frag}"`;
    return `href="/blog/${name}${frag}"`;
  });

  // 3. href="../blog/article.html" → /blog/article
  out = out.replace(/href="\.\.\/blog\/([a-z0-9-]+)\.html(#[^"]*)?"/gi, (m, name, frag = "") => {
    count++;
    if (name === "index") return `href="/blog${frag}"`;
    return `href="/blog/${name}${frag}"`;
  });

  if (count > 0) {
    writeFileSync(file, out);
    totalReplaced += count;
    report.push(`  ${file.replace(ROOT + "/", "")}: ${count}`);
  }
}

console.log(`Total: ${totalReplaced} liens réécrits`);
console.log(report.join("\n"));
