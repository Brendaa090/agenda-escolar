SQL
-- Cria o banco de dados se ele não existir
CREATE DATABASE IF NOT EXISTS agenda_escolar;

-- Seleciona o banco de dados
USE agenda_escolar;

-- Tabela para Turmas
CREATE TABLE IF NOT EXISTS diario_turma (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);

-- Tabela para Alunos
CREATE TABLE IF NOT EXISTS diario_aluno (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(200) NOT NULL,
    data_nascimento DATE NOT NULL,
    turma_id INT NOT NULL,
    FOREIGN KEY (turma_id) REFERENCES diario_turma(id)
);

-- Tabela para Usuários (baseada no modelo User do Django)
-- Adapte conforme a sua configuração de usuário (padrão Django ou personalizado)
CREATE TABLE IF NOT EXISTS auth_user (
    id INT AUTO_INCREMENT PRIMARY KEY,
    password VARCHAR(128) NOT NULL,
    last_login DATETIME(6),
    is_superuser BOOLEAN NOT NULL,
    username VARCHAR(150) UNIQUE NOT NULL,
    first_name VARCHAR(150) NOT NULL,
    last_name VARCHAR(150) NOT NULL,
    email VARCHAR(254) NOT NULL,
    is_staff BOOLEAN NOT NULL,
    is_active BOOLEAN NOT NULL,
    date_joined DATETIME(6) NOT NULL
);

-- Tabela para Registros Diários
CREATE TABLE IF NOT EXISTS diario_registrodiario (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    professor_id INT NOT NULL,
    aluno_id BIGINT NOT NULL,
    data DATE NOT NULL,
    descricao LONGTEXT NOT NULL,
    video VARCHAR(100),
    FOREIGN KEY (professor_id) REFERENCES auth_user(id),
    FOREIGN KEY (aluno_id) REFERENCES diario_aluno(id)
);

-- Tabela para Interações
CREATE TABLE IF NOT EXISTS diario_interacao (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    registro_id BIGINT NOT NULL,
    usuario_id INT NOT NULL,
    mensagem LONGTEXT NOT NULL,
    data_hora DATETIME(6) NOT NULL,
    FOREIGN KEY (registro_id) REFERENCES diario_registrodiario(id),
    FOREIGN KEY (usuario_id) REFERENCES auth_user(id)
);

-- Tabela para Grupos de Usuários (se você optar por usar grupos)
CREATE TABLE IF NOT EXISTS auth_group (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) UNIQUE NOT NULL
);

-- Tabela de relacionamento entre Usuários e Grupos (se você optar por usar grupos)
CREATE TABLE IF NOT EXISTS auth_user_groups (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    group_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES auth_user(id),
    FOREIGN KEY (group_id) REFERENCES auth_group(id),
    UNIQUE KEY auth_user_groups_user_id_group_id_uniq (user_id, group_id)
);

-- Tabela de relacionamento entre Grupos e Permissões (se você optar por usar grupos e permissões)
CREATE TABLE IF NOT EXISTS auth_permission (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    content_type_id INT NOT NULL,
    codename VARCHAR(100) NOT NULL,
    UNIQUE KEY auth_permission_content_type_id_codename_uniq (content_type_id, codename)
);

CREATE TABLE IF NOT EXISTS auth_group_permissions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    group_id INT NOT NULL,
    permission_id INT NOT NULL,
    FOREIGN KEY (group_id) REFERENCES auth_group(id),
    FOREIGN KEY (permission_id) REFERENCES auth_permission(id),
    UNIQUE KEY auth_group_permissions_group_id_permission_id_uniq (group_id, permission_id)
);

-- Tabela para o modelo de perfil de usuário (se você optar por um perfil)
-- Adapte os campos conforme a sua definição
CREATE TABLE IF NOT EXISTS diario_perfilusuario (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNIQUE NOT NULL,
    is_responsavel BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES auth_user(id)
);

-- Tabela para o relacionamento entre Alunos e Responsáveis (se você optar por essa abordagem)
CREATE TABLE IF NOT EXISTS diario_aluno_responsaveis (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    aluno_id BIGINT NOT NULL,
    user_id INT NOT NULL,
    FOREIGN KEY (aluno_id) REFERENCES diario_aluno(id),
    FOREIGN KEY (user_id) REFERENCES auth_user(id),
    UNIQUE KEY diario_aluno_responsaveis_aluno_id_user_id_uniq (aluno_id, user_id)
);