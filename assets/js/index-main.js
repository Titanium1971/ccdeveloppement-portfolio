/* Externalise depuis un <script> inline (CSP sans unsafe-inline). Code inchange sauf mention. */
document.documentElement.classList.add('js');
const navLinks = document.getElementById('navLinks');
const navToggle = document.getElementById('navToggle');
const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

if (navToggle && navLinks) {
  navToggle.addEventListener('click', () => {
    const isOpen = navLinks.classList.toggle('open');
    navToggle.setAttribute('aria-expanded', String(isOpen));
  });
}

const observer = new IntersectionObserver((entries) => {
  entries.forEach((entry) => {
    if (entry.isIntersecting) entry.target.classList.add('visible');
  });
}, { threshold: 0.1, rootMargin: '0px 0px -40px 0px' });

document.querySelectorAll('.reveal').forEach((el) => observer.observe(el));

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

const mapIframe = document.querySelector('.map-container iframe[data-src]');
if (mapIframe) {
  const loadMap = () => {
    if (!mapIframe.getAttribute('src')) {
      mapIframe.setAttribute('src', mapIframe.dataset.src);
    }
  };

  if ('IntersectionObserver' in window) {
    const mapObserver = new IntersectionObserver((entries, obs) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          loadMap();
          obs.disconnect();
        }
      });
    }, { rootMargin: '300px 0px' });
    mapObserver.observe(mapIframe);
  } else {
    loadMap();
  }
}
