/* Externalise depuis un <script> inline (CSP sans unsafe-inline). Code inchange sauf mention. */
(function () {
  const form = document.getElementById('devisForm');
  const successState = document.getElementById('successState');
  const submitBtn = document.getElementById('submitBtn');

  // Rate limiting simple : 1 soumission par minute
  let lastSubmit = 0;

  function validateField(id, validFn) {
    const field = document.getElementById('field-' + id);
    const input = document.getElementById(id);
    if (!field || !input) return true;
    const ok = validFn(input.value.trim());
    field.classList.toggle('field-error', !ok);
    input.classList.toggle('error', !ok);
    return ok;
  }

  function isEmail(v) { return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v); }

  form.addEventListener('submit', function (e) {
    e.preventDefault();

    // Rate limit côté client
    var now = Date.now();
    if (now - lastSubmit < 60000) {
      alert('Veuillez patienter avant de soumettre à nouveau.');
      return;
    }

    var v1 = validateField('nom', function(v) { return v.length > 0; });
    var v2 = validateField('email', isEmail);
    var v3 = validateField('type', function(v) { return v.length > 0; });
    var v4 = validateField('message', function(v) { return v.length > 10; });
    if (!v1 || !v2 || !v3 || !v4) return;

    submitBtn.disabled = true;
    submitBtn.textContent = 'Envoi en cours…';

    var data = new FormData(form);

    fetch(form.action, {
      method: 'POST',
      body: data,
      headers: { 'Accept': 'application/json' }
    }).then(function (res) {
      if (res.ok) {
        lastSubmit = Date.now();
        window.location.href = './merci.html';
      } else {
        return res.json().then(function (json) {
          var msg = (json.errors && json.errors.map(function(e) { return e.message; }).join(', ')) || 'Erreur inconnue';
          throw new Error(msg);
        });
      }
    }).catch(function (err) {
      submitBtn.disabled = false;
      submitBtn.textContent = 'Envoyer ma demande de devis';
      alert('Erreur lors de l\'envoi : ' + err.message + '\nVous pouvez réessayer ou nous contacter par téléphone.');
    });
  });

  ['nom', 'email', 'type', 'message'].forEach(function (id) {
    var el = document.getElementById(id);
    if (el) el.addEventListener('input', function () {
      var field = document.getElementById('field-' + id);
      if (field) field.classList.remove('field-error');
      el.classList.remove('error');
    });
  });
})();
