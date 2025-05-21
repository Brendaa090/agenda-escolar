
document.querySelectorAll("button").forEach(button => {
    button.addEventListener("click", () => {
      alert(`Você clicou no botão: ${button.textContent}`);
    });
  });
