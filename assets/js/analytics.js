/**
 * CC Developpement — Tracking & Analytics (RGPD Option B)
 * ============================================================
 * Version : 2.0.0
 * Date    : 2026-05-03
 *
 * Comportement :
 *   - AUCUN appel reseau vers GA4 / Clarity avant consentement explicite.
 *   - AUCUN appel reseau apres refus (et revocation + suppression cookies).
 *   - Bandeau de choix [Tout refuser] [Personnaliser] [Tout accepter]
 *     a meme niveau hierarchique (pas de bouton refuser cache).
 *   - Modale "Personnaliser" avec cases pre-decochees au premier passage.
 *   - Lien permanent "Gerer mes preferences" via [data-cookie-preferences].
 *
 * Contraintes RGPD (CNIL 2026) :
 *   - Consentement libre, eclaire, specifique, univoque.
 *   - Refuser doit etre aussi facile qu'accepter.
 *   - Possibilite de retirer son consentement a tout moment.
 *   - Aucune lecture/ecriture de cookie ou pixel avant choix utilisateur.
 *
 * Services controles :
 *   - Google Analytics 4 (G-NZ2MQMB67H) — mesure d'audience
 *   - Microsoft Clarity (wbyffo03d6) — heatmaps + session recording
 *
 * Vanilla JS pur, sans dependance externe.
 */

(function () {
  'use strict';

  // ---------------------------------------------------------------------------
  // Constantes
  // ---------------------------------------------------------------------------
  var GA_ID = 'G-NZ2MQMB67H';
  var CLARITY_ID = 'wbyffo03d6';
  var CONSENT_KEY = 'ccdev_cookie_consent_v1';
  var CONSENT_VERSION = 1;

  // Flag interne : bloque les events si user a retire son consentement
  // apres avoir branche les listeners dans la session courante.
  var trackingActive = false;

  // ---------------------------------------------------------------------------
  // Stockage du consentement
  // ---------------------------------------------------------------------------
  function getConsent() {
    try {
      var raw = localStorage.getItem(CONSENT_KEY);
      if (!raw) return null;
      var parsed = JSON.parse(raw);
      if (!parsed || parsed.version !== CONSENT_VERSION) return null;
      return parsed;
    } catch (e) {
      return null;
    }
  }

  function saveConsent(consent) {
    try {
      var payload = {
        version: CONSENT_VERSION,
        analytics: !!consent.analytics,
        clarity: !!consent.clarity,
        timestamp: new Date().toISOString()
      };
      localStorage.setItem(CONSENT_KEY, JSON.stringify(payload));
      return payload;
    } catch (e) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // CSS (injecte une seule fois)
  // ---------------------------------------------------------------------------
  var stylesInjected = false;
  function injectStyles() {
    if (stylesInjected) return;
    stylesInjected = true;
    var css = [
      /* Reset minimal — charte CC Développement (dark + vert néon #39FF14) */
      '.ccdev-cookie-banner *,.ccdev-cookie-modal *{box-sizing:border-box;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Helvetica,Arial,sans-serif;-webkit-font-smoothing:antialiased}',

      /* Bandeau */
      '.ccdev-cookie-banner{position:fixed;left:0;right:0;bottom:0;z-index:2147483646;background:#111113;color:#D4D4D8;border-top:1px solid rgba(57,255,20,0.18);box-shadow:0 -12px 32px rgba(0,0,0,.55),0 0 60px rgba(57,255,20,0.04);padding:20px 24px;backdrop-filter:saturate(140%) blur(6px)}',
      '.ccdev-cookie-banner__inner{max-width:1200px;margin:0 auto;display:flex;align-items:center;justify-content:space-between;gap:24px;flex-wrap:wrap}',
      '.ccdev-cookie-banner__text{flex:1 1 420px;font-size:13.5px;line-height:1.6;color:#B6B6C0;margin:0;letter-spacing:.01em}',
      '.ccdev-cookie-banner__text a{color:#39FF14;text-decoration:underline;text-decoration-color:rgba(57,255,20,0.4);text-underline-offset:3px;transition:text-decoration-color .15s ease}',
      '.ccdev-cookie-banner__text a:hover{text-decoration-color:#39FF14}',
      '.ccdev-cookie-banner__actions{display:flex;flex-direction:row;gap:10px;flex-wrap:wrap}',
      '.ccdev-cookie-btn{display:inline-flex;align-items:center;justify-content:center;border:1px solid transparent;border-radius:10px;padding:12px 20px;font-size:13.5px;font-weight:600;cursor:pointer;line-height:1.2;letter-spacing:.02em;transition:background .18s ease,border-color .18s ease,color .18s ease,box-shadow .18s ease,transform .12s ease;min-width:140px}',
      '.ccdev-cookie-btn:active{transform:translateY(1px)}',
      '.ccdev-cookie-btn:focus-visible{outline:2px solid #39FF14;outline-offset:2px}',
      /* Refuser : sombre, bordure visible (même poids que Accepter) */
      '.ccdev-cookie-btn--refuse{background:#27272A;color:#FFFFFF;border-color:#3F3F46}',
      '.ccdev-cookie-btn--refuse:hover{background:#3F3F46;border-color:#52525B}',
      /* Personnaliser : transparent + bordure verte */
      '.ccdev-cookie-btn--custom{background:transparent;color:#39FF14;border-color:rgba(57,255,20,0.5)}',
      '.ccdev-cookie-btn--custom:hover{background:rgba(57,255,20,0.08);border-color:#39FF14}',
      /* Accepter : vert néon, texte noir, glow */
      '.ccdev-cookie-btn--accept{background:#39FF14;color:#09090B;border-color:#39FF14;box-shadow:0 0 0 0 rgba(57,255,20,0)}',
      '.ccdev-cookie-btn--accept:hover{background:#5BFF3A;border-color:#5BFF3A;box-shadow:0 0 24px rgba(57,255,20,0.45)}',

      /* Modale */
      '.ccdev-cookie-modal{position:fixed;inset:0;z-index:2147483647;display:flex;align-items:center;justify-content:center;padding:20px}',
      '.ccdev-cookie-modal__backdrop{position:absolute;inset:0;background:rgba(9,9,11,.72);backdrop-filter:blur(4px)}',
      '.ccdev-cookie-modal__panel{position:relative;background:#111113;color:#D4D4D8;border:1px solid rgba(57,255,20,0.22);border-radius:16px;box-shadow:0 24px 80px rgba(0,0,0,.65),0 0 80px rgba(57,255,20,0.06);max-width:540px;width:100%;max-height:90vh;overflow-y:auto;padding:32px 32px 28px}',
      '.ccdev-cookie-modal__close{position:absolute;top:14px;right:14px;background:transparent;border:1px solid transparent;color:#B6B6C0;font-size:22px;line-height:1;cursor:pointer;padding:6px 10px;border-radius:8px;transition:background .15s ease,color .15s ease,border-color .15s ease}',
      '.ccdev-cookie-modal__close:hover{background:#27272A;color:#FFFFFF;border-color:#3F3F46}',
      '.ccdev-cookie-modal__title{margin:0 0 10px;font-size:19px;font-weight:700;color:#FFFFFF;letter-spacing:.01em}',
      '.ccdev-cookie-modal__intro{margin:0 0 22px;font-size:13.5px;line-height:1.6;color:#B6B6C0}',
      '.ccdev-cookie-modal__option{display:flex;align-items:flex-start;gap:12px;padding:16px;background:#18181B;border:1px solid #27272A;border-radius:12px;margin-bottom:12px;cursor:pointer;transition:border-color .15s ease,background .15s ease}',
      '.ccdev-cookie-modal__option:hover{background:#1F1F23;border-color:rgba(57,255,20,0.35)}',
      '.ccdev-cookie-modal__option input[type=checkbox]{margin-top:2px;width:18px;height:18px;accent-color:#39FF14;cursor:pointer;flex-shrink:0}',
      '.ccdev-cookie-modal__option-label{font-weight:600;font-size:14px;color:#FFFFFF;display:block;margin-bottom:4px}',
      '.ccdev-cookie-modal__option-desc{font-size:13px;line-height:1.55;color:#B6B6C0;margin:0}',
      '.ccdev-cookie-modal__actions{display:flex;flex-direction:row;gap:10px;flex-wrap:wrap;margin-top:24px;justify-content:flex-end}',

      /* Mobile */
      '@media (max-width:640px){',
      '  .ccdev-cookie-banner{padding:16px}',
      '  .ccdev-cookie-banner__inner{flex-direction:column;align-items:stretch}',
      '  .ccdev-cookie-banner__actions{flex-direction:column;width:100%}',
      '  .ccdev-cookie-btn{width:100%;min-width:0}',
      '  .ccdev-cookie-modal{padding:0}',
      '  .ccdev-cookie-modal__panel{max-width:100%;max-height:100vh;height:100vh;border-radius:0}',
      '  .ccdev-cookie-modal__actions{flex-direction:column}',
      '  .ccdev-cookie-modal__actions .ccdev-cookie-btn{width:100%}',
      '}'
    ].join('');

    var style = document.createElement('style');
    style.id = 'ccdev-cookie-styles';
    style.textContent = css;
    document.head.appendChild(style);
  }

  // ---------------------------------------------------------------------------
  // Bandeau
  // ---------------------------------------------------------------------------
  var bannerEl = null;

  function showConsentBanner() {
    injectStyles();
    if (bannerEl) return;

    var banner = document.createElement('div');
    banner.className = 'ccdev-cookie-banner';
    banner.setAttribute('role', 'dialog');
    banner.setAttribute('aria-label', 'Consentement aux cookies');
    banner.setAttribute('aria-live', 'polite');

    banner.innerHTML =
      '<div class="ccdev-cookie-banner__inner">' +
        '<p class="ccdev-cookie-banner__text">' +
          'Nous utilisons des cookies de mesure d’audience et d’analyse comportementale ' +
          'afin de comprendre l’utilisation du site et d’améliorer nos pages. ' +
          'Vous pouvez accepter, refuser ou personnaliser votre choix. Vous pourrez le modifier à tout moment. ' +
          '<a href="/rgpd-confidentialite.html">En savoir plus</a>.' +
        '</p>' +
        '<div class="ccdev-cookie-banner__actions">' +
          '<button type="button" class="ccdev-cookie-btn ccdev-cookie-btn--refuse" data-action="refuse-all">Tout refuser</button>' +
          '<button type="button" class="ccdev-cookie-btn ccdev-cookie-btn--custom" data-action="customize">Personnaliser</button>' +
          '<button type="button" class="ccdev-cookie-btn ccdev-cookie-btn--accept" data-action="accept-all">Tout accepter</button>' +
        '</div>' +
      '</div>';

    document.body.appendChild(banner);
    bannerEl = banner;

    banner.querySelector('[data-action="refuse-all"]').addEventListener('click', handleRefuseAllFromBanner);
    banner.querySelector('[data-action="customize"]').addEventListener('click', function () {
      closeBanner();
      showPreferencesPanel();
    });
    banner.querySelector('[data-action="accept-all"]').addEventListener('click', handleAcceptAllFromBanner);
  }

  function closeBanner() {
    if (bannerEl && bannerEl.parentNode) {
      bannerEl.parentNode.removeChild(bannerEl);
    }
    bannerEl = null;
  }

  // ---------------------------------------------------------------------------
  // Modale de preferences
  // ---------------------------------------------------------------------------
  var modalEl = null;
  var lastFocusedBeforeModal = null;

  function showPreferencesPanel() {
    injectStyles();
    if (modalEl) return;

    lastFocusedBeforeModal = document.activeElement;

    var existing = getConsent();
    var initialAnalytics = existing ? !!existing.analytics : false;
    var initialClarity = existing ? !!existing.clarity : false;

    var modal = document.createElement('div');
    modal.className = 'ccdev-cookie-modal';
    modal.setAttribute('role', 'dialog');
    modal.setAttribute('aria-modal', 'true');
    modal.setAttribute('aria-label', 'Préférences cookies');

    modal.innerHTML =
      '<div class="ccdev-cookie-modal__backdrop" data-action="close-modal"></div>' +
      '<div class="ccdev-cookie-modal__panel">' +
        '<button type="button" class="ccdev-cookie-modal__close" aria-label="Fermer" data-action="close-modal">×</button>' +
        '<h2 class="ccdev-cookie-modal__title">Préférences cookies</h2>' +
        '<p class="ccdev-cookie-modal__intro">' +
          'Choisissez les cookies que vous souhaitez activer. Vous pourrez modifier votre choix à tout moment ' +
          'depuis le lien "Gérer mes préférences cookies" en pied de page.' +
        '</p>' +
        '<label class="ccdev-cookie-modal__option">' +
          '<input type="checkbox" data-pref="analytics"' + (initialAnalytics ? ' checked' : '') + '>' +
          '<span>' +
            '<span class="ccdev-cookie-modal__option-label">Google Analytics 4</span>' +
            '<span class="ccdev-cookie-modal__option-desc">Mesure d’audience et événements de conversion</span>' +
          '</span>' +
        '</label>' +
        '<label class="ccdev-cookie-modal__option">' +
          '<input type="checkbox" data-pref="clarity"' + (initialClarity ? ' checked' : '') + '>' +
          '<span>' +
            '<span class="ccdev-cookie-modal__option-label">Microsoft Clarity</span>' +
            '<span class="ccdev-cookie-modal__option-desc">Cartes de chaleur et enregistrements de session</span>' +
          '</span>' +
        '</label>' +
        '<div class="ccdev-cookie-modal__actions">' +
          '<button type="button" class="ccdev-cookie-btn ccdev-cookie-btn--refuse" data-action="modal-refuse-all">Tout refuser</button>' +
          '<button type="button" class="ccdev-cookie-btn ccdev-cookie-btn--custom" data-action="modal-save">Enregistrer mes choix</button>' +
          '<button type="button" class="ccdev-cookie-btn ccdev-cookie-btn--accept" data-action="modal-accept-all">Tout accepter</button>' +
        '</div>' +
      '</div>';

    document.body.appendChild(modal);
    modalEl = modal;

    // Listeners
    modal.addEventListener('click', function (e) {
      var t = e.target;
      var action = t && t.getAttribute && t.getAttribute('data-action');
      if (action === 'close-modal') {
        closeModal();
        // Si pas de consentement enregistre, reafficher le bandeau
        if (!getConsent()) showConsentBanner();
      } else if (action === 'modal-save') {
        var aCheck = modal.querySelector('input[data-pref="analytics"]');
        var cCheck = modal.querySelector('input[data-pref="clarity"]');
        handleSaveFromModal(!!aCheck.checked, !!cCheck.checked);
      } else if (action === 'modal-accept-all') {
        handleAcceptAllFromModal();
      } else if (action === 'modal-refuse-all') {
        handleRefuseAllFromModal();
      }
    });

    // Escape pour fermer
    modal.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' || e.keyCode === 27) {
        closeModal();
        if (!getConsent()) showConsentBanner();
      }
    });

    // Focus initial : premier bouton de fermeture (focus trap basique)
    var firstFocusable = modal.querySelector('.ccdev-cookie-modal__close');
    if (firstFocusable && typeof firstFocusable.focus === 'function') {
      try { firstFocusable.focus(); } catch (e) { /* noop */ }
    }
  }

  function closeModal() {
    if (modalEl && modalEl.parentNode) {
      modalEl.parentNode.removeChild(modalEl);
    }
    modalEl = null;
    if (lastFocusedBeforeModal && typeof lastFocusedBeforeModal.focus === 'function') {
      try { lastFocusedBeforeModal.focus(); } catch (e) { /* noop */ }
    }
    lastFocusedBeforeModal = null;
  }

  // ---------------------------------------------------------------------------
  // Chargement / revocation des trackers
  // ---------------------------------------------------------------------------
  var gaLoaded = false;
  var clarityLoaded = false;
  var trackingListenersBound = false;

  function loadGoogleAnalytics() {
    if (gaLoaded) {
      // deja charge : on s'assure simplement que le consent est granted
      try {
        if (typeof window.gtag === 'function') {
          window.gtag('consent', 'update', {
            analytics_storage: 'granted',
            ad_storage: 'denied',
            ad_user_data: 'denied',
            ad_personalization: 'denied'
          });
        }
      } catch (e) { /* noop */ }
      return;
    }
    try {
      window.dataLayer = window.dataLayer || [];
      function gtag() { window.dataLayer.push(arguments); }
      window.gtag = gtag;

      // Default : analytics granted (par decision utilisateur), pub denied
      gtag('consent', 'default', {
        analytics_storage: 'granted',
        ad_storage: 'denied',
        ad_user_data: 'denied',
        ad_personalization: 'denied'
      });
      gtag('js', new Date());
      gtag('config', GA_ID, {
        send_page_view: true,
        anonymize_ip: true
      });

      var s = document.createElement('script');
      s.async = true;
      s.src = 'https://www.googletagmanager.com/gtag/js?id=' + encodeURIComponent(GA_ID);
      s.onerror = function () { /* echec reseau silencieux */ };
      document.head.appendChild(s);

      gaLoaded = true;
    } catch (e) {
      // ne casse pas le site
    }
  }

  function loadMicrosoftClarity() {
    if (clarityLoaded) {
      try {
        if (typeof window.clarity === 'function') {
          window.clarity('consentv2', { ad_Storage: 'denied', analytics_Storage: 'granted' });
        }
      } catch (e) { /* noop */ }
      return;
    }
    try {
      (function (c, l, a, r, i) {
        c[a] = c[a] || function () { (c[a].q = c[a].q || []).push(arguments); };
        var t = l.createElement(r);
        t.async = 1;
        t.src = 'https://www.clarity.ms/tag/' + encodeURIComponent(i);
        t.onerror = function () { /* echec reseau silencieux */ };
        var y = l.getElementsByTagName(r)[0];
        if (y && y.parentNode) {
          y.parentNode.insertBefore(t, y);
        } else {
          l.head.appendChild(t);
        }
      })(window, document, 'clarity', 'script', CLARITY_ID);

      // Consent API v2 (apres queue stub disponible)
      try {
        window.clarity('consentv2', { ad_Storage: 'denied', analytics_Storage: 'granted' });
      } catch (e) { /* noop */ }

      clarityLoaded = true;
    } catch (e) {
      // ne casse pas le site
    }
  }

  function revokeGoogleAnalytics() {
    try {
      if (typeof window.gtag === 'function') {
        window.gtag('consent', 'update', {
          analytics_storage: 'denied',
          ad_storage: 'denied',
          ad_user_data: 'denied',
          ad_personalization: 'denied'
        });
      }
    } catch (e) { /* noop */ }
  }

  function revokeMicrosoftClarity() {
    try {
      if (typeof window.clarity === 'function') {
        try { window.clarity('consentv2', { ad_Storage: 'denied', analytics_Storage: 'denied' }); } catch (e) { /* noop */ }
        try { window.clarity('consent', false); } catch (e) { /* noop */ }
      }
    } catch (e) { /* noop */ }
  }

  // ---------------------------------------------------------------------------
  // Suppression des cookies analytics
  // ---------------------------------------------------------------------------
  function deleteAnalyticsCookies() {
    var names = ['_ga', '_gid', '_gat', '_clck', '_clsk', 'CLID', 'ANONCHK', 'MR', 'MUID', 'SM'];
    var expired = 'Thu, 01 Jan 1970 00:00:00 GMT';
    var hostname = window.location.hostname || '';

    // Domaines sur lesquels tenter la suppression
    var domains = ['', hostname, '.' + hostname, '.ccdeveloppement.eu', 'ccdeveloppement.eu'];

    // Cookies fixes
    names.forEach(function (name) {
      domains.forEach(function (d) {
        if (d) {
          document.cookie = name + '=; expires=' + expired + '; path=/; domain=' + d;
        } else {
          document.cookie = name + '=; expires=' + expired + '; path=/';
        }
      });
    });

    // _ga_* (variante par stream GA4)
    try {
      var all = document.cookie ? document.cookie.split(';') : [];
      for (var i = 0; i < all.length; i++) {
        var cName = all[i].split('=')[0].trim();
        if (cName.indexOf('_ga_') === 0) {
          domains.forEach(function (d) {
            if (d) {
              document.cookie = cName + '=; expires=' + expired + '; path=/; domain=' + d;
            } else {
              document.cookie = cName + '=; expires=' + expired + '; path=/';
            }
          });
        }
      }
    } catch (e) { /* noop */ }
  }

  // ---------------------------------------------------------------------------
  // Tracking events (branches uniquement si analytics accepte)
  // ---------------------------------------------------------------------------
  function safeGtag() {
    if (!trackingActive) return;
    if (typeof window.gtag !== 'function') return;
    try { window.gtag.apply(null, arguments); } catch (e) { /* noop */ }
  }

  function bindFormStart() {
    var form = document.getElementById('devisForm');
    if (!form) return;
    var fields = form.querySelectorAll('input, select, textarea');
    var fired = false;
    fields.forEach(function (field) {
      field.addEventListener('focus', function () {
        if (fired) return;
        fired = true;
        safeGtag('event', 'form_start', { event_category: 'engagement', form_name: 'devis' });
      }, { once: true });
    });
  }

  function bindFormSubmit() {
    var form = document.getElementById('devisForm');
    if (form) {
      form.addEventListener('submit', function () {
        safeGtag('event', 'form_submit', { event_category: 'conversion', form_name: 'devis' });
      });
    }
    if (window.location.pathname.indexOf('merci') !== -1) {
      safeGtag('event', 'form_submit', {
        event_category: 'conversion',
        form_name: 'devis',
        method: 'confirmation_page'
      });
    }
  }

  function classifyCta(href) {
    if (!href) return null;
    if (href.indexOf('wa.me') !== -1) return 'wa';
    if (href.indexOf('cal.com') !== -1) return 'cal';
    if (href.indexOf('tel:') === 0) return 'tel';
    if (href.indexOf('mailto:') === 0) return 'email';
    return null;
  }

  function bindCtaClicks() {
    document.addEventListener('click', function (e) {
      var link = e.target.closest && e.target.closest('a[href]');
      if (!link) return;
      var href = link.getAttribute('href') || link.href || '';
      var channel = classifyCta(href);
      if (!channel) return;
      safeGtag('event', 'cta_click', {
        event_category: 'engagement',
        channel: channel,
        destination: href
      });
    });
  }

  function bindScrollDepth() {
    var marks = { 25: false, 50: false, 75: false, 100: false };
    var timer = null;
    function check() {
      var scrollTop = window.pageYOffset || document.documentElement.scrollTop;
      var docHeight = document.documentElement.scrollHeight - document.documentElement.clientHeight;
      if (docHeight <= 0) return;
      var pct = Math.round((scrollTop / docHeight) * 100);
      [25, 50, 75, 100].forEach(function (m) {
        if (pct >= m && !marks[m]) {
          marks[m] = true;
          safeGtag('event', 'scroll_depth', { event_category: 'engagement', percent: m });
        }
      });
    }
    window.addEventListener('scroll', function () {
      if (timer) clearTimeout(timer);
      timer = setTimeout(check, 150);
    }, { passive: true });
  }

  function bindOutboundClicks() {
    document.addEventListener('click', function (e) {
      var link = e.target.closest && e.target.closest('a[href]');
      if (!link) return;
      var href = link.getAttribute('href') || link.href || '';
      if (href.indexOf('http') !== 0) return;
      if (href.indexOf('ccdeveloppement.eu') !== -1) return;
      // Eviter double-comptage avec cta_click (wa.me, cal.com)
      if (classifyCta(href)) return;
      safeGtag('event', 'outbound_click', {
        event_category: 'engagement',
        destination: href
      });
    });
  }

  function initConsentControlledTracking() {
    trackingActive = true;
    if (trackingListenersBound) return;
    trackingListenersBound = true;
    ready(function () {
      bindFormStart();
      bindFormSubmit();
      bindCtaClicks();
      bindScrollDepth();
      bindOutboundClicks();
    });
  }

  function ready(fn) {
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', fn);
    } else {
      fn();
    }
  }

  // ---------------------------------------------------------------------------
  // Handlers
  // ---------------------------------------------------------------------------
  function handleAcceptAllFromBanner() {
    saveConsent({ analytics: true, clarity: true });
    loadGoogleAnalytics();
    loadMicrosoftClarity();
    initConsentControlledTracking();
    closeBanner();
  }

  function handleRefuseAllFromBanner() {
    saveConsent({ analytics: false, clarity: false });
    deleteAnalyticsCookies();
    closeBanner();
  }

  function handleAcceptAllFromModal() {
    var prev = getConsent();
    var prevA = prev ? !!prev.analytics : false;
    var prevC = prev ? !!prev.clarity : false;

    saveConsent({ analytics: true, clarity: true });
    if (!prevA) loadGoogleAnalytics(); else loadGoogleAnalytics(); // idempotent
    if (!prevC) loadMicrosoftClarity(); else loadMicrosoftClarity();
    initConsentControlledTracking();
    closeModal();
  }

  function handleRefuseAllFromModal() {
    var prev = getConsent();
    var prevA = prev ? !!prev.analytics : false;
    var prevC = prev ? !!prev.clarity : false;

    if (prevA) revokeGoogleAnalytics();
    if (prevC) revokeMicrosoftClarity();
    trackingActive = false;
    saveConsent({ analytics: false, clarity: false });
    deleteAnalyticsCookies();
    closeModal();
  }

  function handleSaveFromModal(wantAnalytics, wantClarity) {
    var prev = getConsent();
    var prevA = prev ? !!prev.analytics : false;
    var prevC = prev ? !!prev.clarity : false;

    // Analytics
    if (prevA && !wantAnalytics) {
      revokeGoogleAnalytics();
      trackingActive = false;
    } else if (!prevA && wantAnalytics) {
      loadGoogleAnalytics();
      initConsentControlledTracking();
    } else if (prevA && wantAnalytics) {
      // garde l'etat actif
      trackingActive = true;
    }

    // Clarity
    if (prevC && !wantClarity) {
      revokeMicrosoftClarity();
    } else if (!prevC && wantClarity) {
      loadMicrosoftClarity();
    }

    saveConsent({ analytics: wantAnalytics, clarity: wantClarity });

    // Si l'un des deux passe a false, nettoyer les cookies tiers
    if ((prevA && !wantAnalytics) || (prevC && !wantClarity)) {
      deleteAnalyticsCookies();
    }

    closeModal();
  }

  // ---------------------------------------------------------------------------
  // API publique : openPreferences (pour lien permanent footer)
  // ---------------------------------------------------------------------------
  function openPreferences() {
    closeBanner();
    showPreferencesPanel();
  }
  window.openPreferences = openPreferences;
  window.ccdevCookieConsent = {
    openPreferences: openPreferences,
    getConsent: getConsent
  };

  function bindPreferenceLinks() {
    ready(function () {
      var links = document.querySelectorAll('[data-cookie-preferences]');
      for (var i = 0; i < links.length; i++) {
        links[i].addEventListener('click', function (e) {
          e.preventDefault();
          openPreferences();
        });
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Init
  // ---------------------------------------------------------------------------
  function init() {
    bindPreferenceLinks();

    var c = getConsent();
    if (c === null) {
      ready(showConsentBanner);
      return;
    }
    if (c.analytics) {
      loadGoogleAnalytics();
      initConsentControlledTracking();
    }
    if (c.clarity) {
      loadMicrosoftClarity();
    }
  }

  init();

})();
