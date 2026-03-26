// Smooth scroll — Lenis on desktop only, native scroll on mobile
(function () {
  if (typeof window === 'undefined') return;

  // Mobile: return immediately, CSS scroll-behavior handles everything natively
  var isMobile = window.matchMedia('(max-width: 767px)').matches ||
                 ('ontouchstart' in window && !window.matchMedia('(pointer: fine)').matches);
  if (isMobile) return;

  // Desktop only: init Lenis with duration 1.5
  if (typeof Lenis === 'undefined') return;

  // Override any CSS scroll-behavior to avoid conflicts with Lenis
  var style = document.createElement('style');
  style.textContent = 'html { scroll-behavior: auto !important; }';
  document.head.appendChild(style);

  var lenis = new Lenis({
    duration: 1.5,
    easing: function (t) { return Math.min(1, 1.001 - Math.pow(2, -10 * t)); },
    orientation: 'vertical',
    smoothWheel: true,
    wheelMultiplier: 1,
    touchMultiplier: 2,
  });

  function raf(time) {
    lenis.raf(time);
    requestAnimationFrame(raf);
  }
  requestAnimationFrame(raf);

  // Handle anchor links on desktop
  document.querySelectorAll('a[href^="#"]').forEach(function (anchor) {
    anchor.addEventListener('click', function (e) {
      var target = document.querySelector(this.getAttribute('href'));
      if (target) {
        e.preventDefault();
        var nav = document.querySelector('nav');
        var offset = nav ? -(nav.offsetHeight + 20) : 0;
        lenis.scrollTo(target, { duration: 1.5, offset: offset });
      }
    });
  });
})();
