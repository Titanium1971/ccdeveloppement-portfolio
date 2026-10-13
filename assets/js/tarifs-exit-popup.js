/* Externalise depuis un <script> inline (CSP sans unsafe-inline). Code inchange sauf mention. */
(function(){
  var shown = false;
  function showExitPopup(){
    if(shown || sessionStorage.getItem('exitPopupDismissed')) return;
    shown = true;
    document.getElementById('exitPopup').style.display = 'flex';
  }
  window.closeExitPopup = function(){
    document.getElementById('exitPopup').style.display = 'none';
    sessionStorage.setItem('exitPopupDismissed','1');
  };
  document.addEventListener('mouseout', function(e){
    if(e.clientY < 5 && e.relatedTarget == null) showExitPopup();
  });
  if('ontouchstart' in window){
    setTimeout(function(){ showExitPopup(); }, 45000);
  }
  // Bouton de fermeture (remplace l'attribut onclick inline)
  var closeBtn = document.querySelector('#exitPopup [data-exit-close]');
  if (closeBtn) closeBtn.addEventListener('click', function(){ window.closeExitPopup(); });
  document.getElementById('exitPopup').addEventListener('click', function(e){
    if(e.target === this) window.closeExitPopup();
  });
})();
