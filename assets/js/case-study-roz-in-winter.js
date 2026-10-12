/* Externalise depuis un <script> inline (CSP sans unsafe-inline). Code inchange sauf mention. */
document.documentElement.classList.add('js');
const navLinks = document.getElementById('navLinks');
const navToggle = document.getElementById('navToggle');
if (navToggle && navLinks) {
  navToggle.addEventListener('click', () => {
    const isOpen = navLinks.classList.toggle('open');
    navToggle.setAttribute('aria-expanded', String(isOpen));
  });
}
const observer = new IntersectionObserver((entries) => {
  entries.forEach((entry) => { if (entry.isIntersecting) entry.target.classList.add('visible'); });
}, { threshold: 0.1, rootMargin: '0px 0px -40px 0px' });
document.querySelectorAll('.reveal').forEach((el) => observer.observe(el));
