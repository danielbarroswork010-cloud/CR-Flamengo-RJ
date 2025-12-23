- PROJETO DE PORTFÓLIO — FLAMENGO MATCH ANALYTICS

Estrutura do Repositório 

flamengo-match-analytics/
│
├── database/
│   ├── 01_create_database.sql
│   ├── 02_tables.sql
│   ├── 03_triggers.sql
│   ├── 04_views.sql
│   ├── 05_procedures.sql
│   ├── 06_indexes.sql
│   └── 07_sample_data.sql
│
├── diagrams/
│   └── DER_flamengo.png
│
└── README.md


01_create_database.sql
CREATE DATABASE flamengo_db;
USE flamengo_db;


02_tables.sql
CREATE TABLE competicao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    tipo ENUM('Nacional','Internacional')
);

CREATE TABLE estadio (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100),
    cidade VARCHAR(100),
    capacidade INT
);

CREATE TABLE temporada (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ano INT NOT NULL
);

CREATE TABLE jogo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    data_jogo DATE NOT NULL,
    adversario VARCHAR(100) NOT NULL,
    mando ENUM('CASA','FORA') NOT NULL,
    gols_flamengo INT NOT NULL,
    gols_adversario INT NOT NULL,
    competicao_id INT,
    estadio_id INT,
    temporada_id INT,
    resultado ENUM('VITORIA','EMPATE','DERROTA'),

    FOREIGN KEY (competicao_id) REFERENCES competicao(id),
    FOREIGN KEY (estadio_id) REFERENCES estadio(id),
    FOREIGN KEY (temporada_id) REFERENCES temporada(id)
);

03_triggers.sql

DELIMITER $$

CREATE TRIGGER trg_define_resultado_insert
BEFORE INSERT ON jogo
FOR EACH ROW
BEGIN
    IF NEW.gols_flamengo > NEW.gols_adversario THEN
        SET NEW.resultado = 'VITORIA';
    ELSEIF NEW.gols_flamengo = NEW.gols_adversario THEN
        SET NEW.resultado = 'EMPATE';
    ELSE
        SET NEW.resultado = 'DERROTA';
    END IF;
END$$

CREATE TRIGGER trg_define_resultado_update
BEFORE UPDATE ON jogo
FOR EACH ROW
BEGIN
    IF NEW.gols_flamengo > NEW.gols_adversario THEN
        SET NEW.resultado = 'VITORIA';
    ELSEIF NEW.gols_flamengo = NEW.gols_adversario THEN
        SET NEW.resultado = 'EMPATE';
    ELSE
        SET NEW.resultado = 'DERROTA';
    END IF;
END$$

DELIMITER ;

04_views.sql

CREATE VIEW vw_resultados_flamengo AS
SELECT 
    j.data_jogo,
    j.adversario,
    j.mando,
    j.gols_flamengo,
    j.gols_adversario,
    j.resultado,
    c.nome AS competicao,
    e.nome AS estadio,
    t.ano AS temporada
FROM jogo j
JOIN competicao c ON j.competicao_id = c.id
JOIN estadio e ON j.estadio_id = e.id
JOIN temporada t ON j.temporada_id = t.id;

05_procedures.sql

DELIMITER $$

CREATE PROCEDURE sp_inserir_jogo (
    IN p_data DATE,
    IN p_adversario VARCHAR(100),
    IN p_mando VARCHAR(10),
    IN p_gols_fla INT,
    IN p_gols_adv INT,
    IN p_competicao INT,
    IN p_estadio INT,
    IN p_temporada INT
)
BEGIN
    INSERT INTO jogo (
        data_jogo, adversario, mando,
        gols_flamengo, gols_adversario,
        competicao_id, estadio_id, temporada_id
    )
    VALUES (
        p_data, p_adversario, p_mando,
        p_gols_fla, p_gols_adv,
        p_competicao, p_estadio, p_temporada
    );
END$$

DELIMITER ;


DELIMITER ;

06_indexes.sql
CREATE INDEX idx_resultado ON jogo(resultado);
CREATE INDEX idx_temporada ON jogo(temporada_id);
CREATE INDEX idx_competicao ON jogo(competicao_id);
CREATE INDEX idx_mando ON jogo(mando);

07_sample_data.sql
INSERT INTO competicao (nome, tipo) VALUES
('Brasileirão','Nacional'),
('Libertadores','Internacional');

INSERT INTO estadio (nome, cidade, capacidade) VALUES
('Maracanã','Rio de Janeiro',78838);

INSERT INTO temporada (ano) VALUES (2024);

CALL sp_inserir_jogo('2024-06-20','Palmeiras','CASA',2,1,1,1,1);
CALL sp_inserir_jogo('2024-06-27','Fluminense','FORA',1,1,1,1,1);
CALL sp_inserir_jogo('2024-07-04','Atlético-MG','FORA',0,2,2,1,1);

