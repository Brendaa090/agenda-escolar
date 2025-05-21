function atualizarDataHora() {
    const elemento = document.getElementById("dataHora");
    const agora = new Date();
    const dataFormatada = agora.toLocaleDateString("pt-BR", {
      day: "2-digit",
      month: "2-digit",
      year: "numeric"
    });
    const horaFormatada = agora.toLocaleTimeString("pt-BR");
    elemento.textContent = `Data: ${dataFormatada} Hora: ${horaFormatada}`;
  }
  
  atualizarDataHora();
  setInterval(atualizarDataHora, 1000);