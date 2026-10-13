/* Externalise depuis un <script> inline (CSP sans unsafe-inline). Code inchange sauf mention. */
// WhatsApp Demo Animation
(function() {
  const chatBody = document.getElementById('waChatBody');
  if (!chatBody) return;

  const messages = chatBody.querySelectorAll('.wa-msg');
  const typing1 = document.getElementById('waTyping1');
  const typing2 = document.getElementById('waTyping2');
  const replayBtn = document.getElementById('waReplay');
  let animated = false;
  let animationTimeout = [];

  function resetChat() {
    animationTimeout.forEach(t => clearTimeout(t));
    animationTimeout = [];
    messages.forEach(m => { m.classList.remove('visible'); m.style.display = 'none'; });
    if (typing1) { typing1.classList.remove('visible'); typing1.style.display = 'none'; }
    if (typing2) { typing2.classList.remove('visible'); typing2.style.display = 'none'; }
    if (replayBtn) { replayBtn.classList.remove('visible'); }
    animated = false;
  }

  function playChat() {
    resetChat();
    animated = true;

    // Message 1: Client asks (0.4s)
    animationTimeout.push(setTimeout(() => {
      messages[0].style.display = 'block';
      requestAnimationFrame(() => messages[0].classList.add('visible'));
    }, 400));

    // Typing indicator 1 (1.2s)
    animationTimeout.push(setTimeout(() => {
      if (typing1) { typing1.style.display = 'flex'; typing1.classList.add('visible'); }
      chatBody.scrollTop = chatBody.scrollHeight;
    }, 1200));

    // Hide typing, show response (2.8s)
    animationTimeout.push(setTimeout(() => {
      if (typing1) { typing1.classList.remove('visible'); typing1.style.display = 'none'; }
      messages[1].style.display = 'block';
      requestAnimationFrame(() => messages[1].classList.add('visible'));
      chatBody.scrollTop = chatBody.scrollHeight;
    }, 2800));

    // Message 3: Client confirms (4.8s)
    animationTimeout.push(setTimeout(() => {
      messages[2].style.display = 'block';
      requestAnimationFrame(() => messages[2].classList.add('visible'));
      chatBody.scrollTop = chatBody.scrollHeight;
    }, 4800));

    // Typing indicator 2 (5.6s)
    animationTimeout.push(setTimeout(() => {
      if (typing2) { typing2.style.display = 'flex'; typing2.classList.add('visible'); }
      chatBody.scrollTop = chatBody.scrollHeight;
    }, 5600));

    // Message 4: Confirmation with recap (7.2s)
    animationTimeout.push(setTimeout(() => {
      if (typing2) { typing2.classList.remove('visible'); typing2.style.display = 'none'; }
      messages[3].style.display = 'block';
      requestAnimationFrame(() => messages[3].classList.add('visible'));
      chatBody.scrollTop = chatBody.scrollHeight;
    }, 7200));

    // Show replay button (8.5s)
    animationTimeout.push(setTimeout(() => {
      if (replayBtn) { replayBtn.classList.add('visible'); }
      chatBody.scrollTop = chatBody.scrollHeight;
    }, 8500));
  }

  // Trigger on scroll into view
  const chatObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting && !animated) {
        playChat();
      }
    });
  }, { threshold: 0.3 });

  chatObserver.observe(chatBody);

  // Replay button
  if (replayBtn) {
    replayBtn.addEventListener('click', () => {
      playChat();
    });
  }
})();
