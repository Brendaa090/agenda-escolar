from flask import Flask, render_template, request, redirect, url_for, session, flash
from flask_wtf.csrf import CSRFProtect
import mysql.connector
import os
from config import DB_CONFIG
from functools import wraps

app = Flask(__name__)
app.secret_key = os.urandom(24)  # Chave secreta para sessões
csrf = CSRFProtect(app)  # Proteção CSRF

def get_db_connection():
    return mysql.connector.connect(**DB_CONFIG)

def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'usuario_id' not in session:
            flash('Por favor, faça login para acessar esta página')
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated_function

@app.route('/')
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('matricula')
        senha = request.form.get('senha')
        
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        try:
            cursor.execute("""
                SELECT au.*, dp.is_responsavel 
                FROM auth_user au 
                LEFT JOIN diario_perfilusuario dp ON au.id = dp.user_id 
                WHERE au.username = %s AND au.password = %s AND au.is_active = TRUE
            """, (username, senha))
            usuario = cursor.fetchone()
            
            if usuario:
                session['usuario_id'] = usuario['id']
                session['is_responsavel'] = usuario['is_responsavel']
                flash('Login realizado com sucesso!')
                
                if not usuario['is_responsavel']:
                    return redirect(url_for('telaprof'))
                else:
                    return redirect(url_for('pais'))
            else:
                flash('Usuário ou senha incorretos!')
                
        except Exception as e:
            flash('Erro ao realizar login!')
        finally:
            cursor.close()
            conn.close()
            
    return render_template('login.html')

@app.route('/cadastro_pais', methods=['GET', 'POST'])
def cadastro_pais():
    if request.method == 'POST':
        conn = get_db_connection()
        cursor = conn.cursor()
        
        try:
            # Inserir usuário
            cursor.execute("""
                INSERT INTO auth_user (username, password, first_name, last_name, email, is_active)
                VALUES (%s, %s, %s, %s, %s, TRUE)
            """, (
                request.form['matricula'],
                request.form['senha'],
                request.form['nome_pais'].split()[0],  # primeiro nome
                ' '.join(request.form['nome_pais'].split()[1:]),  # sobrenome
                request.form['email']
            ))
            
            user_id = cursor.lastrowid
            
            # Criar perfil de responsável
            cursor.execute("""
                INSERT INTO diario_perfilusuario (user_id, is_responsavel)
                VALUES (%s, TRUE)
            """, (user_id,))
            
            # Inserir aluno
            cursor.execute("""
                INSERT INTO diario_aluno (nome, data_nascimento, turma_id)
                VALUES (%s, CURDATE(), 1)
            """, (request.form['nome_crianca'],))
            
            aluno_id = cursor.lastrowid
            
            # Relacionar aluno com responsável
            cursor.execute("""
                INSERT INTO diario_aluno_responsaveis (aluno_id, user_id)
                VALUES (%s, %s)
            """, (aluno_id, user_id))
            
            conn.commit()
            flash('Cadastro realizado com sucesso!')
            return redirect(url_for('login'))
            
        except Exception as e:
            conn.rollback()
            flash('Erro ao realizar cadastro!')
        finally:
            cursor.close()
            conn.close()
            
    return render_template('cadpais.html')

@app.route('/aluno')
@login_required
def aluno():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    if session.get('is_responsavel'):
        # Buscar apenas alunos relacionados ao responsável
        cursor.execute("""
            SELECT da.* 
            FROM diario_aluno da
            JOIN diario_aluno_responsaveis dar ON da.id = dar.aluno_id
            WHERE dar.user_id = %s
        """, (session['usuario_id'],))
    else:
        # Professor vê todos os alunos
        cursor.execute("SELECT * FROM diario_aluno")
        
    alunos = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('aluno.html', alunos=alunos)

@app.route('/avisos')
@login_required
def avisos():
    return render_template('avisos.html')

@app.route('/cadpais')
def cadpais():
    return render_template('cadpais.html')

@app.route('/cadprof')
def cadprof():
    return render_template('cadprof.html')

@app.route('/calendario')
@login_required
def calendario():
    return render_template('calendario.html')

@app.route('/faleconosco')
def faleconosco():
    return render_template('faleconosco.html')

@app.route('/pais')
@login_required
def pais():
    return render_template('pais.html')

@app.route('/pastaturma')
@login_required
def pastaturma():
    return render_template('pastaturma.html')

@app.route('/professor')
def professor():
    return render_template('professor.html')

@app.route('/telaprof')
@login_required
def telaprof():
    return render_template('telaprof.html')

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

@app.errorhandler(404)
def pagina_nao_encontrada(e):
    return render_template('404.html'), 404

@app.errorhandler(500)
def erro_servidor(e):
    return render_template('500.html'), 500

if __name__ == '__main__':
    app.run(debug=True)
