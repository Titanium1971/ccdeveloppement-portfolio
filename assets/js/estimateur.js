/* Externalise depuis un <script> inline (CSP sans unsafe-inline). Code inchange sauf mention. */
/* ============ DATA ============ */
const PRICING = {
  bases: [
    { id:'vitrine', name:'Site vitrine', pages:'5 pages', price:2800, desc:'Avec réservation en ligne', features:['Accueil, présentation, prestations, contact','Réservation en ligne','Référencement local','Pages légales et mise en ligne'] },
    { id:'pme', name:'PME Standard', pages:'10 pages', price:7500, desc:'Le plus demandé', featured:true, features:['Landing page premium','Catalogue multi-catégories','Panier / Commandes','Blog / News avec SEO','Dashboard utilisateur','Admin panel avancé','FAQ / Documentation','Intégrations 3e parties','Analytics page','Page custom spécifique'] },
    { id:'pme-plus', name:'PME+', pages:'15 pages', price:10500, desc:'Croissance & scale', features:['Tout le forfait PME Standard','Marketplace features','Multi-utilisateurs / Rôles','API publique','Synchronisations externes','Performance optimization','Sécurité avancée'] },
    { id:'entreprise', name:'Entreprise', pages:'20+ pages', price:14500, desc:'Plateforme complète', features:['Plateforme complète','White-label possible','Multi-locales','Infrastructure custom','Onboarding entreprise'] }
  ],
  modules: [
    { cat:'Commerce & Transactions', icon:'💰', items:[
      { id:'ecommerce-full', name:'E-commerce Full', desc:'Panier, checkout, paiements Stripe/PayPal', price:1800 },
      { id:'gestion-stocks', name:'Gestion Stocks', desc:'Inventory tracking, alertes, sync multi-canaux', price:1000 },
      { id:'invoicing', name:'Invoicing Automatisé', desc:'Factures auto, PDF, archivage légal', price:800 },
      { id:'payment-plans', name:'Payment Plans', desc:'Paiement échelonné, abonnements', price:1000 },
      { id:'promo-engine', name:'Promo & Discount Engine', desc:'Codes promo, cashback, loyalty points', price:700 },
      { id:'taxes', name:'Taxes & Compliance', desc:'Calcul TVA multi-pays, conformité RGPD', price:900 }
    ]},
    { cat:'Contenu & Personnalisation', icon:'✏️', items:[
      { id:'multi-langue', name:'Multi-Langue', desc:'FR/EN/IT/ES/DE — i18n complet', price:1200 },
      { id:'blog-pro', name:'Blog Professionnel', desc:'SEO-friendly, planification, newsletters', price:600 },
      { id:'ai-content', name:'AI Content Generator', desc:'IA pour descriptions, titres, alt-text', price:1500 },
      { id:'dynamic-content', name:'Dynamic Content', desc:'Templates, variations A/B, personnalisation', price:800 },
      { id:'cms-headless', name:'CMS Headless', desc:'Gestion de contenu flexible + API', price:2000 },
      { id:'media-library', name:'Media Library Pro', desc:'Upload illimité, compression, CDN images', price:600 }
    ]},
    { cat:'Analytics & Intelligence', icon:'📊', items:[
      { id:'dashboard-analytics', name:'Dashboard Analytics Avancé', desc:'Segments, funnels, heatmaps', price:1200 },
      { id:'bi', name:'Business Intelligence', desc:'Rapports custom, export, visualisations', price:1500 },
      { id:'conversion-tracking', name:'Conversion Tracking', desc:'Pixel tracking, attribution, ROI', price:800 },
      { id:'ab-testing', name:'A/B Testing Framework', desc:'Expérimentations statistiques', price:1200 },
      { id:'predictions-ml', name:'Prédictions & Recommandations', desc:'ML pour recommandations produits', price:2500 }
    ]},
    { cat:'Marketing & Engagement', icon:'📣', items:[
      { id:'email-marketing', name:'Email Marketing Pro', desc:'Campagnes, segmentation, automation', price:1000 },
      { id:'sms-push', name:'SMS & Push Notifications', desc:'Alertes, rappels, promotions', price:800 },
      { id:'live-chat', name:'Live Chat & Support', desc:'Chat temps réel, chatbot IA, ticketing', price:1500 },
      { id:'loyalty', name:'Loyalty Program', desc:'Cartes fidélité digitales, rewards', price:1200 },
      { id:'referral', name:'Referral System', desc:'Système de parrainage avec tracking', price:1000 },
      { id:'social-media', name:'Social Media Integration', desc:'Cross-posting, calendrier éditorial', price:600 }
    ]},
    { cat:'Intégrations Externes', icon:'🔗', items:[
      { id:'google-ads', name:'Google Ads & Analytics', desc:'Sync produits, conversion tracking', price:600 },
      { id:'meta-ads', name:'Meta Ads Integration', desc:'Pixel, dynamic ads, catalogue sync', price:600 },
      { id:'booking-sync', name:'Booking / Airbnb / Tripadvisor', desc:'Sync calendrier, avis, réservations', price:1000 },
      { id:'delivery', name:'Delivery Platforms', desc:'Glovo, Uber Eats, Just Eat sync', price:1200 },
      { id:'erp-crm', name:'ERP/CRM Sync', desc:'Sage, Salesforce, HubSpot, Pipedrive', price:2000 },
      { id:'api-custom', name:'API Custom', desc:'Intégration système propriétaire', price:2500 },
      { id:'marketplace-seller', name:'Marketplace Seller', desc:'Vendre sur Amazon, eBay, Etsy, etc.', price:1200 }
    ]},
    { cat:'Performance & Infrastructure', icon:'⚡', items:[
      { id:'cdn-caching', name:'CDN Avancé & Caching', desc:'Distribution mondiale, optimisation cache', price:600 },
      { id:'db-optim', name:'Database Optimization', desc:'Indexation, query optimization, scaling', price:1000 },
      { id:'load-balancing', name:'Load Balancing & Redundancy', desc:'Haute disponibilité, failover auto', price:1500 },
      { id:'security-hardening', name:'Security Hardening', desc:'Firewall, DDoS protection, pentesting', price:2000 },
      { id:'monitoring', name:'Monitoring & Alerts', desc:'Uptime tracking, alertes incidents', price:800 },
      { id:'backup', name:'Backup & Disaster Recovery', desc:'Sauvegarde quotidienne, restore', price:600 }
    ]},
    { cat:'Collaboration & Team', icon:'👥', items:[
      { id:'multi-user', name:'Multi-User Management', desc:'Rôles, permissions, audit trail', price:800 },
      { id:'workflow', name:'Workflow Automation', desc:'N8N intégré, triggers, actions', price:1200 },
      { id:'api-docs', name:'API Documentation Generator', desc:'Docs auto, postman, sandbox', price:600 },
      { id:'version-control', name:'Version Control & Rollback', desc:'Git-like versioning, undo/redo', price:500 },
      { id:'audit-log', name:'Audit Log & Compliance', desc:'Traçabilité complète, export, conformité', price:1000 }
    ]},
    { cat:'Mobile & Cross-Platform', icon:'📱', items:[
      { id:'pwa', name:'Progressive Web App (PWA)', desc:'App web installable, offline mode', price:1500 },
      { id:'native-app', name:'Native Mobile App Wrapper', desc:'Convertir web en iOS/Android app', price:3500 },
      { id:'mobile-features', name:'Mobile-Specific Features', desc:'Géolocalisation, caméra, notifications', price:1000 }
    ]}
  ],
  maintenance: [
    { id:'standard', name:'Essentiel', price:200, annual:2000, desc:'Pour les sites vitrines', features:['Hébergement, SSL et sauvegardes','Surveillance et mises à jour','Petites modifications (1 h/mois)','Support email (48h)'] },
    { id:'premium', name:'Premium', price:350, annual:3500, desc:'Pour les projets avec backoffice', featured:true, features:['Tout le forfait Essentiel','Maintenance + monitoring','Support prioritaire (24h)','Mises à jour régulières','Bug fixes illimités'] },
    { id:'enterprise', name:'Entreprise', price:650, annual:6500, desc:'Pour les plateformes ambitieuses', features:['Tout le forfait Premium','Dédication 8h/mois','Performance optimization','Scaling assistance'] }
  ]
};

/* ============ STATE ============ */
const state = {
  step: 1,
  base: null,
  modules: new Set(),
  maintenance: null
};

// Restore from sessionStorage
try {
  const saved = JSON.parse(sessionStorage.getItem('est_state'));
  if (saved) {
    state.base = saved.base ? PRICING.bases.find(b => b.id === saved.base) : null;
    (saved.modules || []).forEach(m => state.modules.add(m));
    state.maintenance = saved.maintenance ? PRICING.maintenance.find(m => m.id === saved.maintenance) : null;
    state.step = saved.step || 1;
  }
} catch(e) {}

function saveState() {
  sessionStorage.setItem('est_state', JSON.stringify({
    step: state.step,
    base: state.base?.id || null,
    modules: [...state.modules],
    maintenance: state.maintenance?.id || null
  }));
}

/* ============ HELPERS ============ */
function fmt(n) {
  return n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, '\u00a0');
}

function getAllModules() {
  const all = [];
  PRICING.modules.forEach(cat => cat.items.forEach(item => all.push(item)));
  return all;
}

function getSelectedModules() {
  return getAllModules().filter(m => state.modules.has(m.id));
}

function calculate() {
  const basePrice = state.base ? state.base.price : 0;
  const modulesTotal = getSelectedModules().reduce((s, m) => s + m.price, 0);
  const totalHT = basePrice + modulesTotal;
  const totalTTC = Math.round(totalHT * 1.2);
  const maintMonthly = state.maintenance ? state.maintenance.price : 0;
  const maintAnnual = state.maintenance ? state.maintenance.annual : 0;
  return { basePrice, modulesTotal, totalHT, totalTTC, maintMonthly, maintAnnual };
}

/* ============ RENDER ============ */
function renderBaseGrid() {
  const grid = document.getElementById('baseGrid');
  grid.innerHTML = PRICING.bases.map(b => `
    <div class="base-card${b.featured ? ' featured' : ''}${state.base?.id === b.id ? ' selected' : ''}" data-act="selectBase" data-arg="${b.id}">
      <div class="b-name">${b.name}</div>
      <div class="b-desc">${b.desc}</div>
      <div class="b-price">${fmt(b.price)}€ <span>HT</span></div>
      <div class="b-pages">${b.pages} fonctionnelles</div>
      <ul class="b-features">${b.features.map(f => '<li>' + f + '</li>').join('')}</ul>
      <div class="select-indicator">${state.base?.id === b.id ? '✓ Sélectionné' : 'Cliquez pour choisir'}</div>
    </div>
  `).join('');
}

function renderModules() {
  const container = document.getElementById('modulesContainer');
  container.innerHTML = PRICING.modules.map((cat, ci) => {
    const count = cat.items.filter(it => state.modules.has(it.id)).length;
    return `
    <div class="cat-section" data-cat="${ci}">
      <div class="cat-header" aria-expanded="false" data-act="toggleCat">
        <div class="cat-header-left">
          <span class="cat-icon">${cat.icon}</span>
          <span class="cat-name">${cat.cat}</span>
          <span class="cat-count${count ? ' visible' : ''}">${count}</span>
        </div>
        <span class="cat-toggle">▾</span>
      </div>
      <div class="cat-body">
        <div class="cat-body-inner">
          ${cat.items.map(m => `
            <div class="mod-card${state.modules.has(m.id) ? ' selected' : ''}" data-id="${m.id}" data-name="${m.name.toLowerCase()}" data-act="toggleModule" data-arg="${m.id}">
              <div class="mod-check">✓</div>
              <div class="mod-info"><h4>${m.name}</h4><p>${m.desc}</p></div>
              <div class="mod-price">+${fmt(m.price)}€</div>
            </div>
          `).join('')}
        </div>
      </div>
    </div>`;
  }).join('');
}

function renderMaintGrid() {
  const grid = document.getElementById('maintGrid');
  grid.innerHTML = PRICING.maintenance.map(m => `
    <div class="m-card${m.featured ? ' featured' : ''}${state.maintenance?.id === m.id ? ' selected' : ''}" data-act="selectMaintenance" data-arg="${m.id}">
      <div class="m-name">${m.name}</div>
      <div class="m-desc">${m.desc}</div>
      <div class="m-price">${m.price}€ <span>HT/mois</span></div>
      <div class="m-annual">soit ${fmt(m.annual)}€/an (2 mois offerts)</div>
      <ul class="m-features">${m.features.map(f => '<li>' + f + '</li>').join('')}</ul>
    </div>
  `).join('');
}

function renderSummary() {
  const card = document.getElementById('summaryCard');
  const t = calculate();
  const selectedMods = getSelectedModules();

  let html = '';

  // Base
  if (state.base) {
    html += `<div class="summary-section">
      <div class="summary-section-title">Forfait de base</div>
      <div class="summary-row"><span>${state.base.name} — ${state.base.pages}</span><span class="sr-price">${fmt(state.base.price)}€</span></div>
    </div>`;
  }

  // Modules
  if (selectedMods.length) {
    html += `<div class="summary-section">
      <div class="summary-section-title">Modules sélectionnés (${selectedMods.length})</div>
      ${selectedMods.map(m => `<div class="summary-row"><span>${m.name}</span><span class="sr-price">+${fmt(m.price)}€</span></div>`).join('')}
    </div>`;
  }

  // Total
  html += `<div class="summary-divider"></div>
    <div class="summary-total"><span class="st-label">Total HT</span><span class="st-price">${fmt(t.totalHT)}€</span></div>
    <div class="summary-ttc">soit ${fmt(t.totalTTC)}€ TTC</div>`;

  // Maintenance
  if (state.maintenance) {
    html += `<div class="summary-divider"></div>
      <div class="summary-section">
        <div class="summary-section-title">Maintenance récurrente</div>
        <div class="summary-maint"><span>${state.maintenance.name}</span><span class="sm-price">${state.maintenance.price}€ HT/mois · ${fmt(state.maintenance.annual)}€/an</span></div>
      </div>`;
  }

  // Actions
  html += `<div class="summary-actions">
    <a class="btn-primary" href="${buildMailto()}">✉ Demander un devis</a>
    <button class="btn-secondary" data-act="print">⎙ Imprimer</button>
  </div>
  <div class="summary-edit"><a data-act="goToStep" data-arg="1">← Modifier ma sélection</a></div>`;

  card.innerHTML = html;
}

function renderPriceBar() {
  const bar = document.getElementById('priceBar');
  const t = calculate();
  if (state.base) {
    bar.classList.add('visible');
    document.getElementById('pbAmount').textContent = fmt(t.totalHT) + '€ HT';
    const parts = [];
    if (t.modulesTotal) parts.push(getSelectedModules().length + ' module' + (getSelectedModules().length > 1 ? 's' : ''));
    if (state.maintenance) parts.push('+ ' + state.maintenance.price + '€/mois');
    document.getElementById('pbDetail').textContent = parts.join(' · ');
  } else {
    bar.classList.remove('visible');
  }

  const btn = document.getElementById('pbNext');
  if (state.step === 4) {
    btn.textContent = '✉ Demander un devis';
    btn.onclick = function() { window.location.href = buildMailto(); };
  } else {
    btn.textContent = 'Suivant →';
    btn.onclick = goToNextStep;
  }
}

function renderStepBar() {
  document.querySelectorAll('.step-bar-item').forEach(item => {
    const s = parseInt(item.dataset.step);
    item.classList.remove('active', 'completed');
    if (s === state.step) item.classList.add('active');
    else if (s < state.step) item.classList.add('completed');
  });
}

function render() {
  renderStepBar();
  renderPriceBar();
  if (state.step === 4) renderSummary();
}

/* ============ ACTIONS ============ */
function selectBase(id) {
  state.base = PRICING.bases.find(b => b.id === id);
  renderBaseGrid();
  saveState();
  render();
  setTimeout(() => goToStep(2), 350);
}

function toggleModule(id) {
  if (state.modules.has(id)) state.modules.delete(id);
  else state.modules.add(id);

  // Update just the card and count
  const card = document.querySelector(`.mod-card[data-id="${id}"]`);
  if (card) card.classList.toggle('selected');

  // Update category count
  PRICING.modules.forEach((cat, ci) => {
    const count = cat.items.filter(it => state.modules.has(it.id)).length;
    const badge = document.querySelector(`.cat-section[data-cat="${ci}"] .cat-count`);
    if (badge) {
      badge.textContent = count;
      badge.classList.toggle('visible', count > 0);
    }
  });

  saveState();
  render();
}

function selectMaintenance(id) {
  if (id === null) {
    state.maintenance = null;
  } else {
    state.maintenance = PRICING.maintenance.find(m => m.id === id);
  }
  renderMaintGrid();
  saveState();
  render();
  if (id !== null) setTimeout(() => goToStep(4), 350);
}

function toggleCat(header) {
  const expanded = header.getAttribute('aria-expanded') === 'true';
  header.setAttribute('aria-expanded', !expanded);
  const body = header.nextElementSibling;
  body.classList.toggle('open', !expanded);
}

function goToStep(n) {
  if (n > 1 && !state.base) return;
  state.step = n;
  document.querySelectorAll('.est-step').forEach(s => s.classList.remove('active'));
  const target = document.querySelector(`.est-step[data-step="${n}"]`);
  if (target) target.classList.add('active');
  saveState();
  render();
  window.scrollTo({ top: document.querySelector('.step-bar').offsetTop - 60, behavior: 'smooth' });
}

function goToNextStep() {
  if (state.step < 4) goToStep(state.step + 1);
}

function buildMailto() {
  const t = calculate();
  const mods = getSelectedModules();
  let body = 'Bonjour,\n\nJe souhaite un devis pour le projet suivant :\n\n';
  body += '━━ FORFAIT ━━\n';
  body += state.base ? `${state.base.name} (${state.base.pages}) : ${fmt(state.base.price)}€ HT\n` : 'Non sélectionné\n';
  if (mods.length) {
    body += '\n━━ MODULES ━━\n';
    mods.forEach(m => body += `• ${m.name} : +${fmt(m.price)}€\n`);
  }
  if (state.maintenance) {
    body += `\n━━ MAINTENANCE ━━\n${state.maintenance.name} : ${state.maintenance.price}€ HT/mois\n`;
  }
  body += `\n━━ TOTAL ━━\n${fmt(t.totalHT)}€ HT (${fmt(t.totalTTC)}€ TTC)\n`;
  body += '\nMerci de me recontacter pour finaliser le devis.\n\nCordialement';
  return `mailto:canon@ccdeveloppement.eu?subject=${encodeURIComponent('Demande de devis — Estimateur CC Développement')}&body=${encodeURIComponent(body)}`;
}

/* ============ SEARCH ============ */
document.getElementById('moduleSearch').addEventListener('input', function() {
  const q = this.value.toLowerCase().trim();
  document.querySelectorAll('.mod-card').forEach(card => {
    const name = card.dataset.name || '';
    card.classList.toggle('hidden', q && !name.includes(q));
  });
  // Auto-expand categories with matches
  if (q) {
    document.querySelectorAll('.cat-section').forEach(sec => {
      const hasVisible = sec.querySelector('.mod-card:not(.hidden)');
      const header = sec.querySelector('.cat-header');
      const body = sec.querySelector('.cat-body');
      if (hasVisible) {
        header.setAttribute('aria-expanded', 'true');
        body.classList.add('open');
      } else {
        header.setAttribute('aria-expanded', 'false');
        body.classList.remove('open');
      }
    });
  }
});

/* ============ STEP BAR CLICK ============ */
document.querySelectorAll('.step-bar-item').forEach(item => {
  item.addEventListener('click', () => {
    const s = parseInt(item.dataset.step);
    if (item.classList.contains('completed') || s === state.step) goToStep(s);
  });
});

/* ============ ACTIONS DELEGUEES ============ */
/* Remplace les attributs onclick inline (statiques et generes) : CSP sans unsafe-inline. */
const CLICK_ACTIONS = {
  goToStep: (el, arg) => goToStep(parseInt(arg, 10)),
  goToNextStep: () => goToNextStep(),
  selectBase: (el, arg) => selectBase(arg),
  selectMaintenance: (el, arg) => selectMaintenance(arg === undefined ? null : arg),
  toggleModule: (el, arg) => toggleModule(arg),
  toggleCat: (el) => toggleCat(el),
  print: () => window.print()
};
document.addEventListener('click', function (e) {
  const el = e.target.closest('[data-act]');
  if (!el) return;
  const fn = CLICK_ACTIONS[el.dataset.act];
  if (fn) fn(el, el.dataset.arg);
});

/* ============ INIT ============ */
renderBaseGrid();
renderModules();
renderMaintGrid();
// Restore step
if (state.base && state.step > 1) {
  goToStep(state.step);
} else {
  render();
}
