#!/usr/bin/env node
import { writeFileSync, statSync, existsSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = resolve(__dirname, "..");
const SITE_URL = "https://ccdeveloppement.eu";

const PAGES = [
  { file: "index.html",                                            url: "/",                                                            priority: 1.0,  changefreq: "weekly"  },
  { file: "tarifs.html",                                           url: "/tarifs",                                                      priority: 0.95, changefreq: "monthly" },
  { file: "devis.html",                                            url: "/devis",                                                       priority: 0.9,  changefreq: "monthly" },
  { file: "creation-site-web-agde.html",                           url: "/creation-site-web-agde",                                      priority: 0.9,  changefreq: "monthly" },
  { file: "seo-local-herault.html",                                url: "/seo-local-herault",                                           priority: 0.9,  changefreq: "monthly" },
  { file: "blog/index.html",                                       url: "/blog",                                                        priority: 0.85, changefreq: "weekly"  },
  { file: "guide-seo-local.html",                                  url: "/guide-seo-local",                                             priority: 0.8,  changefreq: "monthly" },
  { file: "estimateur.html",                                       url: "/estimateur",                                                  priority: 0.8,  changefreq: "monthly" },
  { file: "blog/creation-site-internet-agde-guide-complet-2026.html", url: "/blog/creation-site-internet-agde-guide-complet-2026",      priority: 0.75, changefreq: "monthly" },
  { file: "blog/seo-local-herault-restaurants-artisans.html",      url: "/blog/seo-local-herault-restaurants-artisans",                 priority: 0.75, changefreq: "monthly" },
  { file: "blog/combien-coute-site-vitrine-tpe-2026.html",         url: "/blog/combien-coute-site-vitrine-tpe-2026",                    priority: 0.75, changefreq: "monthly" },
  { file: "comparatif-tarifs.html",                                url: "/comparatif-tarifs",                                           priority: 0.7,  changefreq: "monthly" },
  { file: "guide-tarifs.html",                                     url: "/guide-tarifs",                                                priority: 0.7,  changefreq: "monthly" },
  { file: "mentions-legales.html",                                 url: "/mentions-legales",                                            priority: 0.3,  changefreq: "yearly"  },
  { file: "rgpd-confidentialite.html",                             url: "/rgpd-confidentialite",                                        priority: 0.3,  changefreq: "yearly"  },
];

function lastmod(filePath) {
  const abs = resolve(ROOT, filePath);
  if (!existsSync(abs)) return null;
  return statSync(abs).mtime.toISOString().split(".")[0] + "+00:00";
}

const today = new Date().toISOString().split("T")[0];
const missing = [];

const urls = PAGES
  .map((p) => {
    const mod = lastmod(p.file);
    if (!mod) { missing.push(p.file); return null; }
    return `  <url>
    <loc>${SITE_URL}${p.url}</loc>
    <lastmod>${mod}</lastmod>
    <changefreq>${p.changefreq}</changefreq>
    <priority>${p.priority.toFixed(2)}</priority>
  </url>`;
  })
  .filter(Boolean)
  .join("\n");

const sitemap = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${urls}
</urlset>
`;

const sitemapIndex = `<?xml version="1.0" encoding="UTF-8"?>
<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <sitemap>
    <loc>${SITE_URL}/sitemap.xml</loc>
    <lastmod>${today}</lastmod>
  </sitemap>
</sitemapindex>
`;

writeFileSync(resolve(ROOT, "sitemap.xml"), sitemap);
writeFileSync(resolve(ROOT, "sitemap_index.xml"), sitemapIndex);

console.log(`Sitemap généré : ${PAGES.length - missing.length} URL(s)`);
if (missing.length) console.warn(`Pages manquantes (skippées) :`, missing);
