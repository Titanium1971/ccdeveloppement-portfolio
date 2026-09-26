// Bloque l'accès public aux fichiers internes versionnés dans le repo
// (rapports d'audit, notes, scripts, config locale). Réponse 404.
const BLOCKED = [
  /^\/_audit-reports(\/|$)/i,
  /^\/\.claude(\/|$)/i,
  /^\/\.git/i,
  /^\/scripts(\/|$)/i,
  /^\/content(\/|$)/i,
  /^\/functions(\/|$)/i,
  /^\/strix_runs(\/|$)/i,
  /^\/pagespeed[^/]*\.pdf$/i,
  /\.(md|sh|mjs)$/i,
];

export async function onRequest(context) {
  let path;
  try {
    path = decodeURIComponent(new URL(context.request.url).pathname);
  } catch {
    return new Response('Not found', { status: 404 });
  }

  if (!BLOCKED.some((re) => re.test(path))) {
    return context.next();
  }

  const notFound = await context.env.ASSETS.fetch(new URL('/404', context.request.url));
  if (notFound.ok) {
    return new Response(notFound.body, { status: 404, headers: notFound.headers });
  }
  return new Response('Not found', { status: 404 });
}
