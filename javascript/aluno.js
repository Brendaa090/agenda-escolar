function abrirFormulario(nomeAluno) {
    document.getElementById("modalFormulario").style.display = "block";
    document.getElementById("nomeAluno").textContent = nomeAluno;
  }
  
  function fecharFormulario() {
    document.getElementById("modalFormulario").style.display = "none";
  }