// Smooth scroll — Lenis on desktop, native CSS scroll-behavior on mobile
(function () {
  if (typeof window === 'undefined') return;

  function isMobile() {
    return window.matchMedia('(max-width: 767px)').matches ||
           ('ontouchstart' in window && !window.matchMedia('(pointer: fine)').matches);
  }

  function initMobileScroll() {
    // Inject scroll-behavior: smooth for pages that don't already have it
    var style = document.createElement('style');
    style.textContent = 'html { scroll-behavior: smooth !important; }';
    document.head.appendChild(style);
  }

  function initLenis() {
    if (typeof Lenis === 'undefined') {
      console.warn('Lenis not loaded');
      return;
    }

    // Lenis requires scroll-behavior: auto on html to avoid conflicts
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

    // Sync Lenis with requestAnimationFrame
    function raf(time) {
      lenis.raf(time);
      requestAnimationFrame(raf);
    }
    requestAnimationFrame(raf);

    // Handle anchor links
    document.querySelectorAll('a[href^="#"]').forEach(function (anchor) {
      anchor.addEventListener('click', function (e) {
        var target = document.querySelector(this.getAttribute('href'));
        if (target) {
          e.preventDefault();
          lenis.scrollTo(target, { duration: 1.5 });
        }
      });
    });
  }

  function init() {
    if (isMobile()) {
      initMobileScroll();
    } else {
      initLenis();
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
