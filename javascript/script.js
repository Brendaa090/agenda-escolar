document.addEventListener('DOMContentLoaded', () => {
    const turmas = {
      1: { nome: "Turma 1", alunos: ["João", "Maria", "Pedro"], responsavel: ["Prof.Ana"] },
      2: { nome: "Turma 2", alunos: ["Ana", "Carlos", "Luiza"] },
      3: { nome: "Turma 3", alunos: ["Paulo", "Fernanda", "Ricardo"] },
      4: { nome: "Turma 4", alunos: ["Lucas", "Juliana", "Marcos"] },
      5: { nome: "Turma 5", alunos: ["Beatriz", "Rafael", "Camila"] },
      6: { nome: "Turma 6", alunos: ["Gustavo", "Isabela", "Thiago"] }
    };
  
    const turmaBoxes = document.querySelectorAll('.turma-box');
    const dynamicContent = document.getElementById('dynamic-content');
    const grid = document.getElementById('turmas-grid');
  
    turmaBoxes.forEach(box => {
      box.addEventListener('click', () => {
        const turmaId = box.getAttribute('data-turma');
        carregarTurma(turmaId);
      });
    });
  
    function carregarTurma(turmaId) {
      const turma = turmas[turmaId];
  
      if (!turma) {
        dynamicContent.innerHTML = `<p>Turma não encontrada</p>`;
        return;
      }
  
      dynamicContent.innerHTML = `
        <button onclick="voltarParaTurmas()" class="voltar-btn">← Voltar</button>
        <h2>${turma.nome}</h2>
        <div class="alunos-container">
          ${turma.alunos.map(aluno => `
            <div class="turma-box" onclick="redirecionarParaFormulario('${aluno}')">
              <img src="imgs/aluno.png" alt="Imagem do Aluno">
              <h2>${aluno}</h2>
            </div>
          `).join('')}
        </div>
      `;
  
      grid.style.display = 'none';
      dynamicContent.style.display = 'block';
    }
  
    window.voltarParaTurmas = function() {
      grid.style.display = 'grid';
      dynamicContent.style.display = 'none';
    };
  
    window.redirecionarParaFormulario = function(alunoNome) {
      localStorage.setItem('alunoSelecionado', alunoNome);
      window.location.href = 'html/aluno.html';
    };
  });
