// Smooth scroll with Lenis — duration 1.5s, synced with requestAnimationFrame
(function () {
  if (typeof window === 'undefined') return;

  // Wait for Lenis to be available (loaded via CDN before this script)
  function initLenis() {
    if (typeof Lenis === 'undefined') {
      console.warn('Lenis not loaded yet, retrying...');
      return;
    }

    const lenis = new Lenis({
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

    // Handle anchor links (smooth scroll to sections)
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

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initLenis);
  } else {
    initLenis();
  }
})();
