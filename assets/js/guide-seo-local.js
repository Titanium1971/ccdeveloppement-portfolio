/* Externalise depuis un <script> inline (CSP sans unsafe-inline). Code inchange sauf mention. */
(function() {
  const form = document.getElementById('leadForm');
  const successMsg = document.getElementById('formSuccess');
  const errorMsg = document.getElementById('formError');
  if (!form) return;

  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const btn = form.querySelector('.btn-submit');
    const original = btn.textContent;
    btn.textContent = 'Envoi en cours…';
    btn.disabled = true;

    try {
      const formData = new FormData(form);
      // Brevo accepte x-www-form-urlencoded sur le endpoint sibforms
      const body = new URLSearchParams();
      formData.forEach((v, k) => body.append(k, v));

      await fetch(form.action, {
        method: 'POST',
        mode: 'no-cors', // Brevo ne renvoie pas CORS mais enregistre bien le contact
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: body.toString()
      });

      // no-cors ne permet pas de lire le statut : on considère OK après envoi
      form.style.display = 'none';
      successMsg.style.display = 'block';

      // Tracking Plausible (si présent)
      if (window.plausible) {
        window.plausible('Lead Guide SEO', { props: { source: 'guide-seo-local' } });
      }
    } catch (err) {
      btn.textContent = original;
      btn.disabled = false;
      errorMsg.style.display = 'block';
    }
  });
})();
