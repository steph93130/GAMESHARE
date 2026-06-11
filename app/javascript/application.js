// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "@popperjs/core"
import "bootstrap"

function filterNotifs() {
  const container = document.getElementById('actions_attentes');
  if (!container) return;
  const onBorrow = window.location.pathname === '/borrow';
  container.querySelectorAll('[data-notif-type]').forEach(notif => {
    if (notif.dataset.notifType === 'booking' && onBorrow) {
      notif.style.setProperty('display', 'none', 'important');
    } else {
      notif.style.removeProperty('display');
    }
  });
}

let notifsObserver;

function watchNotifs() {
  notifsObserver?.disconnect();
  notifsObserver = new MutationObserver(mutations => {
    for (const m of mutations) {
      for (const node of m.addedNodes) {
        if (node.nodeType === 1 && node.id === 'actions_attentes') {
          filterNotifs();
          return;
        }
      }
    }
  });
  notifsObserver.observe(document.body, { childList: true });
}

document.addEventListener('turbo:load', () => {
  filterNotifs();
  watchNotifs();
  if (window.location.hash === '#inline_chat_container') {
    const el = document.getElementById('inline_chat_container');
    if (el) el.scrollIntoView({ behavior: 'smooth' });
  }

  const modalAddGame = document.getElementById('modalAddGame');
  if (modalAddGame) {
    modalAddGame.addEventListener('hidden.bs.modal', () => {
      const form = modalAddGame.querySelector('form');
      if (form) form.reset();

      const previewWrapper = modalAddGame.querySelector('[data-ai-generator-target="previewWrapper"]');
      const rulesTextarea = modalAddGame.querySelector('[data-ai-generator-target="rules"]');
      const editButton = modalAddGame.querySelector('[data-ai-generator-target="editButton"]');
      const alert = modalAddGame.querySelector('[data-ai-generator-target="alert"]');

      if (previewWrapper) previewWrapper.classList.add('d-none');
      if (rulesTextarea) rulesTextarea.classList.remove('d-none');
      if (editButton) editButton.classList.add('d-none');
      if (alert) alert.classList.add('d-none');
    });
  }
});
