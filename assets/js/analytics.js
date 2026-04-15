/**
 * CC Developpement — Tracking & Analytics
 * GA4 (gtag.js) + Consent Mode v2 + Microsoft Clarity
 *
 * Remplacer les placeholders avant mise en production :
 *   - G-NZ2MQMB67H  → ex. G-XXXXXXXXXX
 *   - wbyffo03d6 → ex. abcdef1234
 */

(function () {
  'use strict';

  var GA_ID = 'G-NZ2MQMB67H';
  var CLARITY_ID = 'wbyffo03d6';
  var CONSENT_KEY = 'cc_cookie_consent';

  // ─── 1. Consent Mode v2 — denied by default ───────────────────────
  window.dataLayer = window.dataLayer || [];
  function gtag() { dataLayer.push(arguments); }
  window.gtag = gtag;

  gtag('consent', 'default', {
    analytics_storage: 'denied',
    ad_storage: 'denied',
    ad_user_data: 'denied',
    ad_personalization: 'denied',
    wait_for_update: 500
  });

  // ─── 2. Load gtag.js ──────────────────────────────────────────────
  gtag('js', new Date());
  gtag('config', GA_ID, { send_page_view: true });

  var gtagScript = document.createElement('script');
  gtagScript.async = true;
  gtagScript.src = 'https://www.googletagmanager.com/gtag/js?id=' + GA_ID;
  document.head.appendChild(gtagScript);

  // ─── 3. Load Microsoft Clarity ─────────────────────────────────────
  (function (c, l, a, r, i, t, y) {
    c[a] = c[a] || function () { (c[a].q = c[a].q || []).push(arguments); };
    t = l.createElement(r); t.async = 1; t.src = 'https://www.clarity.ms/tag/' + i;
    y = l.getElementsByTagName(r)[0]; y.parentNode.insertBefore(t, y);
  })(window, document, 'clarity', 'script', CLARITY_ID);

  // ─── 4. Cookie consent banner ──────────────────────────────────────
  function injectBannerStyles() {
    var css = document.createElement('style');
    css.textContent =
      '#cc-cookie-banner{position:fixed;bottom:0;left:0;right:0;z-index:99999;' +
      'background:#111;color:#fff;font-family:system-ui,sans-serif;font-size:14px;' +
      'padding:16px 24px;display:flex;align-items:center;justify-content:center;' +
      'gap:16px;flex-wrap:wrap;box-shadow:0 -2px 12px rgba(0,0,0,.3)}' +
      '#cc-cookie-banner p{margin:0;line-height:1.5;max-width:680px}' +
      '#cc-cookie-banner a{color:#60a5fa;text-decoration:underline}' +
      '#cc-cookie-banner button{border:none;border-radius:6px;padding:8px 20px;' +
      'font-size:14px;font-weight:600;cursor:pointer;white-space:nowrap}' +
      '#cc-cookie-accept{background:#25D366;color:#fff}' +
      '#cc-cookie-accept:hover{background:#1DA851}' +
      '#cc-cookie-refuse{background:transparent;color:#aaa;border:1px solid #555!important}' +
      '#cc-cookie-refuse:hover{color:#fff;border-color:#999!important}';
    document.head.appendChild(css);
  }

  function showBanner() {
    injectBannerStyles();
    var banner = document.createElement('div');
    banner.id = 'cc-cookie-banner';
    banner.setAttribute('role', 'dialog');
    banner.setAttribute('aria-label', 'Consentement cookies');
    banner.innerHTML =
      '<p>Ce site utilise des cookies d\u2019analyse pour am\u00e9liorer votre exp\u00e9rience. ' +
      '<a href="/rgpd-confidentialite.html">Politique de confidentialit\u00e9</a></p>' +
      '<button id="cc-cookie-accept">Accepter</button>' +
      '<button id="cc-cookie-refuse">Refuser</button>';
    document.body.appendChild(banner);

    document.getElementById('cc-cookie-accept').addEventListener('click', function () {
      acceptConsent();
      banner.remove();
    });
    document.getElementById('cc-cookie-refuse').addEventListener('click', function () {
      refuseConsent();
      banner.remove();
    });
  }

  function acceptConsent() {
    localStorage.setItem(CONSENT_KEY, 'granted');
    gtag('consent', 'update', {
      analytics_storage: 'granted'
    });
  }

  function refuseConsent() {
    localStorage.setItem(CONSENT_KEY, 'denied');
  }

  // Check stored consent
  var stored = localStorage.getItem(CONSENT_KEY);
  if (stored === 'granted') {
    acceptConsent();
  } else if (!stored) {
    // No choice yet — show banner after DOM ready
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', showBanner);
    } else {
      showBanner();
    }
  }
  // If 'denied', do nothing — consent stays denied, no banner

  // ─── 5. Conversion events ─────────────────────────────────────────

  function ready(fn) {
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', fn);
    } else {
      fn();
    }
  }

  ready(function () {

    // --- 5a. form_start — first focus on devis form fields ---
    var formFields = document.querySelectorAll(
      '.form-card input, .form-card select, .form-card textarea'
    );
    var formStartFired = false;
    formFields.forEach(function (field) {
      field.addEventListener('focus', function () {
        if (!formStartFired) {
          formStartFired = true;
          gtag('event', 'form_start', {
            event_category: 'engagement',
            form_name: 'devis'
          });
        }
      }, { once: true });
    });

    // --- 5b. form_submit — successful form submission ---
    var devisForm = document.querySelector('.form-card form');
    if (devisForm) {
      devisForm.addEventListener('submit', function () {
        gtag('event', 'form_submit', {
          event_category: 'conversion',
          form_name: 'devis'
        });
      });
    }
    // Also fire on merci.html load (confirmation page)
    if (window.location.pathname.indexOf('merci') !== -1) {
      gtag('event', 'form_submit', {
        event_category: 'conversion',
        form_name: 'devis',
        method: 'confirmation_page'
      });
    }

    // --- 5c. cta_click — WhatsApp, phone, email, Cal.com ---
    document.addEventListener('click', function (e) {
      var link = e.target.closest('a[href]');
      if (!link) return;
      var href = link.href || '';

      var ctaType = null;
      if (href.indexOf('wa.me') !== -1 || href.indexOf('whatsapp') !== -1) {
        ctaType = 'whatsapp';
      } else if (href.indexOf('tel:') === 0) {
        ctaType = 'telephone';
      } else if (href.indexOf('mailto:') === 0) {
        ctaType = 'email';
      } else if (href.indexOf('cal.com') !== -1) {
        ctaType = 'cal_com';
      }

      if (ctaType) {
        gtag('event', 'cta_click', {
          event_category: 'engagement',
          cta_type: ctaType,
          cta_url: href
        });
      }
    });

    // --- 5d. scroll_depth — 25%, 50%, 75%, 100% ---
    var scrollMarks = { 25: false, 50: false, 75: false, 100: false };
    function checkScroll() {
      var scrollTop = window.pageYOffset || document.documentElement.scrollTop;
      var docHeight = document.documentElement.scrollHeight - document.documentElement.clientHeight;
      if (docHeight <= 0) return;
      var pct = Math.round((scrollTop / docHeight) * 100);

      [25, 50, 75, 100].forEach(function (mark) {
        if (pct >= mark && !scrollMarks[mark]) {
          scrollMarks[mark] = true;
          gtag('event', 'scroll_depth', {
            event_category: 'engagement',
            depth: mark + '%'
          });
        }
      });
    }
    var scrollTimer;
    window.addEventListener('scroll', function () {
      clearTimeout(scrollTimer);
      scrollTimer = setTimeout(checkScroll, 150);
    }, { passive: true });

    // --- 5e. outbound_click — LinkedIn, portfolio externe ---
    document.addEventListener('click', function (e) {
      var link = e.target.closest('a[href]');
      if (!link) return;
      var href = link.href || '';
      if (href.indexOf('linkedin.com') !== -1 ||
          (href.indexOf('http') === 0 && href.indexOf(window.location.hostname) === -1)) {
        gtag('event', 'outbound_click', {
          event_category: 'engagement',
          outbound_url: href,
          link_text: (link.textContent || '').trim().substring(0, 50)
        });
      }
    });

  }); // end ready

})();
