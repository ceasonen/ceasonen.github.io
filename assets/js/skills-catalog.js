const input = document.getElementById('skill-query');
const status = document.getElementById('skill-count');
const cards = Array.from(document.querySelectorAll('[data-skill]'));
const entries = cards.map(card => ({
  card,
  text: card.textContent.toLowerCase().replaceAll('-', ' ')
}));

function filterSkills() {
  const terms = input.value.toLowerCase().trim().split(/[\s-]+/).filter(Boolean);
  let visible = 0;
  for (const { card, text } of entries) {
    card.hidden = !terms.every(term => text.includes(term));
    visible += Number(!card.hidden);
  }
  status.textContent = visible + ' of ' + cards.length + ' skills';
}

input.addEventListener('input', filterSkills);
filterSkills();
document.getElementById('catalog-controls').hidden = false;
