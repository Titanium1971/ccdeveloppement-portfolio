/* Externalise depuis un <script> inline (CSP sans unsafe-inline). Code inchange sauf mention. */
// Barre de progression de lecture
(function() {
  const bar = document.getElementById('readProgress');
  if (!bar) return;
  function update() {
    const h = document.documentElement;
    const total = h.scrollHeight - h.clientHeight;
    const progress = total > 0 ? (h.scrollTop / total) * 100 : 0;
    bar.style.width = progress + '%';
  }
  window.addEventListener('scroll', update, { passive: true });
  window.addEventListener('resize', update);
  update();
})();
