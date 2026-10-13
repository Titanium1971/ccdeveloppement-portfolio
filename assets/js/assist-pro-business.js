/* Externalise depuis un <script> inline (CSP sans unsafe-inline). Code inchange sauf mention. */
document.documentElement.classList.add('js');

/* Bandeau pré-lancement : fermeture mémorisée 30 jours */
(function () {
  var banner = document.getElementById('prelaunchBanner');
  var closeBtn = document.getElementById('prelaunchBannerClose');
  if (!banner || !closeBtn) return;
  var KEY = 'ccdev_prelaunch_banner_dismissed_v1';
  var TTL_MS = 30 * 24 * 60 * 60 * 1000;
  try {
    var raw = localStorage.getItem(KEY);
    if (raw) {
      var ts = parseInt(raw, 10);
      if (!isNaN(ts) && Date.now() - ts < TTL_MS) {
        banner.classList.add('is-hidden');
      }
    }
  } catch (_) {}
  closeBtn.addEventListener('click', function () {
    banner.classList.add('is-hidden');
    try { localStorage.setItem(KEY, String(Date.now())); } catch (_) {}
  });
})();

const navLinks = document.getElementById('navLinks');
const navToggle = document.getElementById('navToggle');
const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

if (navToggle && navLinks) {
  navToggle.addEventListener('click', () => {
    const isOpen = navLinks.classList.toggle('open');
    navToggle.setAttribute('aria-expanded', String(isOpen));
  });
}

const mainNav = document.querySelector('nav');

document.querySelectorAll('a[href^="#"]').forEach((a) => {
  a.addEventListener('click', (e) => {
    const href = a.getAttribute('href');
    if (!href || href === '#') return;
    const target = document.querySelector(href);
    if (!target) return;

    e.preventDefault();
    const navHeight = mainNav ? mainNav.offsetHeight : 0;
    const top = target.getBoundingClientRect().top + window.scrollY - navHeight - 20;
    window.scrollTo({ top, behavior: prefersReducedMotion ? 'auto' : 'smooth' });

    if (navLinks) navLinks.classList.remove('open');
    if (navToggle) navToggle.setAttribute('aria-expanded', 'false');
  });
});

// Empêche le clic sur le DPA placeholder (LOT 4 le branchera)
document.querySelectorAll('[data-dpa-disabled]').forEach((el) => {
  el.addEventListener('click', (e) => {
    e.preventDefault();
  });
});
