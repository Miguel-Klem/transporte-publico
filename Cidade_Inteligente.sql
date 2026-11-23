-- Projeto integrador de Banco de Dados para uma Cidade Inteligente:

-- Tema 03: Transporte Público
-- Grupo 03: Gabriel, Klem, Nicolly e Pedro
-- Escola SENAI A. Jacob Lafer - Santo André/SP
-- Unidade curricular: Banco de dados (BCD)
-- Professor: Paulo Cesar de Camargo
-- SGBD: MySQL 8.0 CE (MySQL Workbench)

-- Como executar na apresenação e para funcionar:
-- Tem que rodar na ordem (1 a 9). Cada parte diz em qual conexão rodar:
-- [ADMIN] = root e [OPERADOR] = conexão do usuário operador_transporte (criada na parte 5 do script)
-- Os comandos que geram erro de propósito estão separados (6, 8 e 9)
-- Se rodar tudo de uma vez, da xabu no Workbench



-- 1 - [ADMIN] Banco, tabelas e dados

-- 1.1 Criando o banco
CREATE DATABASE IF NOT EXISTS transporte_publico;
USE transporte_publico;

-- 1.2 Criando as tabelas
-- Tabelas PK (linha, veiculo, motorista e motivo_atraso)
-- Tabelas dependentes FK (viagem e atraso)

-- Linhas de ônibus (RN01)
CREATE TABLE linha (
  id_linha INT AUTO_INCREMENT PRIMARY KEY,
  numero VARCHAR(10) NOT NULL UNIQUE,   -- Cada linha tem um número só
  nome VARCHAR(80) NOT NULL,
  tarifa DECIMAL(5,2) NOT NULL   -- Valor da passagem
) ENGINE=InnoDB;   -- (ACID) Atomicidade, Consistência, Isolamento e Durabilidade / START TRANSACTION/BEGIN, COMMIT e ROLLBACK

-- Veículos (RN02)
CREATE TABLE veiculo (
  id_veiculo INT AUTO_INCREMENT PRIMARY KEY,
  placa CHAR(7) NOT NULL UNIQUE,   -- Cada ônibus tem uma placa só
  prefixo VARCHAR(10) NOT NULL,   -- Identificação de cada onibus (pode haver prefixos iguais)
  modelo VARCHAR(50) NOT NULL,
  capacidade INT NOT NULL,   -- Quantos passageiros cabem
  status VARCHAR(20) NOT NULL DEFAULT 'ATIVO'   -- ATIVO, MANUTENCAO ou DESATIVADO (ATIVO vem como padrão)
) ENGINE=InnoDB;

-- Motoristas (RN03)
CREATE TABLE motorista (
  id_motorista INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(80) NOT NULL,
  cnh CHAR(11) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- Motivos de Atraso (Ficam em tabela separada para não repetir o mesmo texto em cada atraso)
CREATE TABLE motivo_atraso (
  id_motivo INT AUTO_INCREMENT PRIMARY KEY,
  descricao VARCHAR(60) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- Viagens: cada viagem é feita por uma linha, com um veículo e um motorista (RN04)
CREATE TABLE viagem (
  id_viagem INT AUTO_INCREMENT PRIMARY KEY,
  id_linha INT NOT NULL,
  id_veiculo INT NOT NULL,
  id_motorista INT NOT NULL,
  data_viagem DATE NOT NULL,
  saida_prevista TIME NOT NULL,
  saida_real TIME NULL,
  chegada_prevista TIME NOT NULL,
  chegada_real TIME NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'PROGRAMADA',   -- PROGRAMADA, EM_ANDAMENTO, CONCLUIDA ou CANCELADA (Começa por padrão como PROGRAMADA)
  teve_atraso INT NOT NULL DEFAULT 0,   -- 0 = Não, 1 = Sim
  -- ON DELETE RESTRICT - Impede apagar linha, veículo ou motorista que tenha viagens (RN05)
  FOREIGN KEY (id_linha) REFERENCES linha (id_linha) ON DELETE RESTRICT,
  FOREIGN KEY (id_veiculo) REFERENCES veiculo (id_veiculo) ON DELETE RESTRICT, 
  FOREIGN KEY (id_motorista) REFERENCES motorista (id_motorista) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Atrasos: cada atraso pertence a uma viagem e tem um motivo (RN04)
CREATE TABLE atraso (
  id_atraso INT AUTO_INCREMENT PRIMARY KEY,
  id_viagem INT NOT NULL,
  id_motivo INT NOT NULL,
  minutos_atraso INT NOT NULL,
  observacao VARCHAR(150) NULL,
  -- ON DELETE CASCADE faz o contrário do RESTRICT: se a viagem for apagada, os atrasos dela vão embora junto, porque um atraso sem viagem não faz sentido (RN06)
  FOREIGN KEY (id_viagem) REFERENCES viagem (id_viagem) ON DELETE CASCADE,
  FOREIGN KEY (id_motivo) REFERENCES motivo_atraso (id_motivo) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Checar se está tudo certo (6 tabelas devem aparecer)
SHOW TABLES;

-- 1.3 Insersão dos Dados

INSERT INTO linha (numero, nome, tarifa) VALUES
  ('101', 'Expresso Centro / Bairro Alto', 5.50),
  ('202', 'Terminal Leste / Shopping', 5.50),
  ('303', 'Circular Universitário', 4.00),
  ('404', 'Bairro Industrial / Estação', 5.50);

INSERT INTO veiculo (placa, prefixo, modelo, capacidade, status) VALUES
  ('ABC1234', 'F-101', 'Articulado', 120, 'ATIVO'),
  ('XYZ9876', 'F-102', 'Padrão', 80, 'ATIVO'),
  ('DEF5678', 'F-103', 'Micro-ônibus', 30, 'MANUTENCAO'),
  ('GHI9012', 'F-104', 'Elétrico', 80, 'ATIVO'),
  ('JKL3456', 'F-105', 'Padrão', 80, 'ATIVO');

INSERT INTO motorista (nome, cnh) VALUES
  ('Carlos Silva', '12345678901'),
  ('Ana Oliveira', '98765432100'),
  ('Roberto Santos', '45612378911'),
  ('Mariana Costa', '78945612322'),
  ('Fernando Souza', '32165498733');

INSERT INTO motivo_atraso (descricao) VALUES
  ('Trânsito intenso (Horário de pico)'),
  ('Falha mecânica no motor'),
  ('Acidente na via obstruindo a passagem'),
  ('Condições climáticas (Alagamento/Chuva)'),
  ('Problema na bilhetagem/catraca');

-- Viagens
-- Ordem dos valores: linha, veículo, motorista, data, saída prevista, saída real, chegada prevista, chegada real, status, teve_atraso
INSERT INTO viagem
  (id_linha, id_veiculo, id_motorista, data_viagem, saida_prevista, saida_real, chegada_prevista, chegada_real, status, teve_atraso)
VALUES
  (1, 1, 1, '2026-11-16', '07:00:00', '07:00:00', '07:25:00', '07:24:00', 'CONCLUIDA', 0),   -- Id 1: Nos conformes
  (2, 2, 2, '2026-11-16', '08:00:00', '08:05:00', '08:50:00', '09:10:00', 'CONCLUIDA', 1),   -- Id 2: 20 min de atraso
  (1, 1, 1, '2026-026-11-23', '18:00:00', NULL, '18:15:00', NULL, 'PROGRAMADA', 0),   -- Id 3: Ainda não aconteceu
  (4, 5, 4, '2026-11-16', '12:00:00', '12:00:00', '13:05:00', '13:55:00', 'CONCLUIDA', 1),   -- Id 4: 50 min de atraso
  (1, 1, 1, '2026-11-17', '07:00:00', '07:03:00', '07:25:00', '07:41:00', 'CONCLUIDA', 1),   -- Id 5: 16 min de atraso
  (3, 4, 3, '2-11-17', '17:30:00', '17:30:00', '17:55:00', '17:55:00', 'CONCLUIDA', 0),   -- Id 6: Nos conformes
  (1, 2, 2, '202611-18', '07:00:00', '07:00:00', '07:25:00', '07:50:00', 'CONCLUIDA', 1),   -- Id 7: 25 min de atraso
  (1, 2, 2, '2026-11-19', '07:00:00', '07:10:00', '07:25:00', '07:48:00', 'CONCLUIDA', 1),   -- Id 8: 23 min de atraso
  (1, 1, 1, '2026-11-20', '17:30:00', '17:35:00', '17:55:00', '18:20:00', 'CONCLUIDA', 1),   -- Id 9: 25 min de atraso
  (2, 2, 2, '2026-11-17', '08:00:00', '08:00:00', '08:50:00', '08:50:00', 'CONCLUIDA', 0),   -- Id 10: Nos conformes
  (2, 4, 3, '2026-11-18', '08:00:00', '08:12:00', '08:50:00', '09:15:00', 'CONCLUIDA', 1),   -- Id 11: 25 min de atraso
  (2, 2, 2, '2026-11-19', '18:00:00', '18:00:00', '18:50:00', '19:20:00', 'CONCLUIDA', 1),   -- Id 12: 30 min de atraso
  (3, 4, 3, '2026-11-17', '18:00:00', '18:00:00', '18:15:00', '18:15:00', 'CONCLUIDA', 0),   -- Id 13: Nos conformes
  (3, 5, 4, '2026-11-18', '18:00:00', '18:04:00', '18:15:00', '18:30:00', 'CONCLUIDA', 1),   -- Id 14: 15 min de atraso
  (4, 5, 5, '2026-11-19', '12:00:00', '12:00:00', '13:05:00', '13:05:00', 'CONCLUIDA', 0),   -- Id 15: Nos conformes
  (4, 1, 5, '2026-11-20', '12:00:00', '12:10:00', '13:05:00', '13:40:00', 'CONCLUIDA', 1),   -- Id 16: 35 min de atraso
  (2, 2, 2, '2026-11-20', '08:00:00', NULL, '08:50:00', NULL, 'CANCELADA', 0),   -- Id 17: Viagem cancelada
  (3, 4, 3, '2026-11-21', '18:00:00', '18:02:00', '18:15:00', NULL, 'EM_ANDAMENTO', 0),   -- Id 18: Usada no teste de COMMIT
  (1, 1, 1, '2026-11-21', '17:30:00', '17:32:00', '17:55:00', NULL, 'EM_ANDAMENTO', 0);   -- Id 19: Usada no teste de ROLLBACK

-- Atrasos (o motivo é o número da tabela motivo_atraso)
-- Os minutos são a diferença entre a chegada real e a chegada prevista
INSERT INTO atraso (id_viagem, id_motivo, minutos_atraso, observacao) VALUES
  (2, 1, 20, 'Trânsito parado na avenida principal devido a obras.'),
  (4, 2, 50, 'Veículo superaqueceu e precisou aguardar reboque.'),
  (5, 1, 16, 'Fila de carros na saída do terminal.'),
  (7, 4, 25, 'Chuva forte alagou um trecho da avenida.'),
  (8, 1, 23, 'Trânsito intenso no horário de pico.'),
  (9, 5, 25, 'Catraca com defeito atrasou o embarque.'),
  (11, 3, 25, 'Colisão entre dois carros na via.'),
  (12, 4, 30, 'Chuva forte na região.'),
  (14, 1, 15, 'Trânsito lento perto da escola.'),
  (16, 3, 35, 'Acidente bloqueou uma faixa.');

-- Checagem final: Quantos registros existem em cada tabela
SELECT COUNT(*) AS total_linhas FROM linha;   -- Esperado: 4
SELECT COUNT(*) AS total_veiculos FROM veiculo;   -- Esperado: 5
SELECT COUNT(*) AS total_motoristas FROM motorista;   -- Esperado: 5
SELECT COUNT(*) AS total_motivos FROM motivo_atraso;   -- Esperado: 5
SELECT COUNT(*) AS total_viagens FROM viagem;   -- Esperado: 19
SELECT COUNT(*) AS total_atrasos FROM atraso;   -- Esperado: 10

-- 2 - [ADMIN] Manutenção dos dados (INSERT, UPDATE, DELETE) e consultas

-- 2.1 Manutenção dos dados

-- Insert: Uma nova linhha
INSERT INTO linha (numero, nome, tarifa)
VALUES ('505', 'Terminal Norte / Hospital', 5.50);
SELECT numero, nome, tarifa FROM linha WHERE numero = '505';

-- Update 1: A tarifa da linha nova foi aumentada
UPDATE linha SET tarifa = 6.00 WHERE numero = '505';
SELECT numero, tarifa FROM linha WHERE numero = '505';

-- Update 2: A viagem programada (id 3) foi remarcada para mais tarde
UPDATE viagem
SET saida_prevista = '18:30:00', chegada_prevista = '18:45:00' WHERE id_viagem = 3;
SELECT id_viagem, saida_prevista, chegada_prevista FROM viagem WHERE id_viagem = 3;

-- Delete: a linha 505 foi cancelada antes de ter qualquer viagem
-- Como ela não tem viagens, o MySQL permite a exclusão (RN05)
DELETE FROM linha WHERE numero = '505';
SELECT COUNT(*) AS total_linhas FROM linha;

-- 2.2 Consultas úteis para a prefeitura

-- Consulta 1
-- Quais linhas tiveram mais atrasos na semana de 16 a 22 de novembro?
SELECT l.numero, l.nome, COUNT(a.id_atraso) AS total_atrasos   -- Mostre o número da linha (l), o nome dela (l) e a contagem de quantos atrasos (a) existem, chamando essa coluna de contagem de total_atrasos.
FROM linha l
INNER JOIN viagem v ON v.id_linha = l.id_linha
INNER JOIN atraso a ON a.id_viagem = v.id_viagem
WHERE v.data_viagem >= '2026-11-16' AND v.data_viagem <= '2026-11-22'
GROUP BY l.id_linha, l.numero, l.nome
ORDER BY total_atrasos DESC, l.numero;

-- Consulta 2
-- Quais são os motivos que mais causam atraso?
SELECT m.descricao AS motivo, COUNT(a.id_atraso) AS ocorrencias
FROM motivo_atraso m
INNER JOIN atraso a ON a.id_motivo = m.id_motivo
GROUP BY m.id_motivo, m.descricao
ORDER BY ocorrencias DESC, m.descricao;

-- Consulta 3
-- Quais veículos tiveram mais viagens atrasadas?
SELECT ve.prefixo, ve.placa, COUNT(vi.id_viagem) AS viagens_atrasadas
FROM veiculo ve
INNER JOIN viagem vi ON vi.id_veiculo = ve.id_veiculo
WHERE vi.teve_atraso = 1
GROUP BY ve.id_veiculo, ve.prefixo, ve.placa
ORDER BY viagens_atrasadas DESC, ve.prefixo;


-- PARTE 3 - [ADMIN] Procedures, transação com COMMIT e efeito do CASCADE

-- 3.1 Stored procedures

DELIMITER $$

-- Procedure 1 (Consulta): Mostra todos os atrasos de uma linha específica
DROP PROCEDURE IF EXISTS sp_atrasos_da_linha$$

CREATE PROCEDURE sp_atrasos_da_linha(IN p_numero VARCHAR(10))   -- PROCEDURE - É uma rotina SQL guardada no banco
BEGIN   -- Começo da Procedure
  SELECT v.data_viagem, ve.prefixo, m.descricao AS motivo, a.minutos_atraso, a.observacao
  FROM linha l
  INNER JOIN viagem v ON v.id_linha = l.id_linha
  INNER JOIN veiculo ve ON ve.id_veiculo = v.id_veiculo
  INNER JOIN atraso a ON a.id_viagem = v.id_viagem
  INNER JOIN motivo_atraso m ON m.id_motivo = a.id_motivo
  WHERE l.numero = p_numero
  ORDER BY v.data_viagem, v.saida_prevista;
END$$   -- Fim da Procedure

-- Procedure 2 (Altera duas tabelas em uma transação): Registra um atraso em tempo real
--   Passo 1: Marca a viagem como atrasada (UPDATE na tabela viagem)
--   Passo 2: Grava o atraso (INSERT na tabela atraso)
DROP PROCEDURE IF EXISTS sp_registrar_atraso$$
CREATE PROCEDURE sp_registrar_atraso(
-- IN - É um parâmetro que a rotina recebe
  IN p_id_viagem INT, IN p_id_motivo INT, IN p_minutos INT, IN p_observacao VARCHAR(150)
)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION   -- Caso acontece algum erro nas proximas linhas, o MySQL executa esse bloco
  BEGIN
    ROLLBACK;   -- Desfaz tudo o que estava pendente
    RESIGNAL;   -- Mostra para quem chamou o erro que originou o ROLLBACK
  END;

  START TRANSACTION;   -- Abre um rascunho: Onde as alterações ficam pendentes até confirmarmos com COMMIT ou desfazermos com ROLLBACK

  UPDATE viagem
  SET teve_atraso = 1   -- Dentro da tabela viaggem ele mudará de 0 para 1
  WHERE id_viagem = p_id_viagem   -- Verifica se a viagem existe
    AND status = 'EM_ANDAMENTO'   -- Se está em andamento
    AND teve_atraso = 0   -- Se ainda não tem atraso
    AND p_minutos > 0;  -- Se o seus mintuos são maiores que zero (RN07, RN08 e RN09)

  IF ROW_COUNT() = 0 THEN  -- Se a quantidade de linhas alteradas for igual a zero, significa que a viagem não existe, não está em andamento, já tem atraso ou os minutos são inválidos
    SIGNAL SQLSTATE '45000'  -- O que resulta em um erro
      SET MESSAGE_TEXT = 'Atraso recusado: viagem inválida, fora de andamento, já atrasada ou minutos inválidos'; -- Essa é a mensgem para caso aconteça algum erro quando se chamar a procedure
  END IF; -- Finaliza o IF

  INSERT INTO atraso (id_viagem, id_motivo, minutos_atraso, observacao)
  VALUES (p_id_viagem, p_id_motivo, p_minutos, p_observacao);

  COMMIT;
END$$

DELIMITER ;

-- Executando a procedure 1
CALL sp_atrasos_da_linha('101');   -- Esperado: 4 atrasos (viagens 5, 7, 8 e 9)
CALL sp_atrasos_da_linha('303');   -- Esperado: 1 atraso (viagem 14)
CALL sp_atrasos_da_linha('999');   -- Esperado: nenhuma linha (essa linha não existe)

-- 3.2 Transação de sucesso (COMMIT) na viagem 18, que está em andamento
-- Antes
SELECT id_viagem, status, teve_atraso FROM viagem WHERE id_viagem = 18;    -- Esperado: EM_ANDAMENTO, 0
SELECT COUNT(*) AS atrasos_da_viagem_18 FROM atraso WHERE id_viagem = 18;  -- Esperado: 0

CALL sp_registrar_atraso(18, 1, 12, 'Trânsito parado na avenida principal.');

-- Depois
SELECT id_viagem, status, teve_atraso FROM viagem WHERE id_viagem = 18;    -- Esperado: EM_ANDAMENTO, 1
SELECT COUNT(*) AS atrasos_da_viagem_18 FROM atraso WHERE id_viagem = 18;  -- Esperado: 1

-- 3.3 Efeito do ON DELETE CASCADE (sem erro)
-- O teste fica dentro de uma transação e termina com ROLLBACK
-- para os dados voltarem ao que eram antes
START TRANSACTION;
  SELECT COUNT(*) AS atrasos_da_viagem_2 FROM atraso WHERE id_viagem = 2;   -- Esperado: 1
  DELETE FROM viagem WHERE id_viagem = 2;                                    -- O CASCADE apaga o atraso junto
  SELECT COUNT(*) AS atrasos_da_viagem_2 FROM atraso WHERE id_viagem = 2;   -- Esperado: 0
ROLLBACK;
SELECT COUNT(*) AS atrasos_da_viagem_2 FROM atraso WHERE id_viagem = 2;     -- Esperado: 1 (voltou)
SELECT COUNT(*) AS total_viagens FROM viagem;                                -- Esperado: 19


-- ######################################################################
-- PARTE 4 - [ADMIN] Índice e EXPLAIN
-- ######################################################################
-- Como funciona
--   Índice   é um "catálogo" que ajuda o MySQL a achar os registros sem ler a tabela toda
--   EXPLAIN  mostra o caminho que o MySQL escolheu para executar a consulta
--     type = ALL  o MySQL leu a tabela inteira (sem usar índice)
--     type = ref  o MySQL foi direto aos registros pelo índice
--     key         nome do índice usado (NULL = nenhum)
--     rows        quantidade estimada de linhas que o MySQL precisou examinar
-- Consulta escolhida: viagens de um dia específico (filtro por data_viagem)
-- Com 19 viagens o índice não faria diferença, então vamos aumentar a tabela
-- copiando as viagens que já existem

-- Selecione só o comando abaixo e execute 6 vezes (a cada vez a tabela dobra de tamanho)
INSERT INTO viagem
  (id_linha, id_veiculo, id_motorista, data_viagem,
   saida_prevista, saida_real, chegada_prevista, chegada_real, status, teve_atraso)
SELECT id_linha, id_veiculo, id_motorista, data_viagem,
   saida_prevista, saida_real, chegada_prevista, chegada_real, status, teve_atraso
FROM viagem;

SELECT COUNT(*) AS total_viagens FROM viagem;   -- Esperado depois das 6 execuções: 1216

-- Atualiza as estatísticas que o MySQL usa para escolher o caminho
ANALYZE TABLE viagem;

-- Antes do índice
SHOW INDEX FROM viagem;   -- Aparecem a PRIMARY e as chaves estrangeiras, mas nenhum índice em data_viagem
EXPLAIN SELECT * FROM viagem WHERE data_viagem = '2026-11-23';
-- Esperado: type = ALL, key = NULL, rows em torno de 1200 (leu a tabela inteira)

CREATE INDEX idx_viagem_data ON viagem (data_viagem);
ANALYZE TABLE viagem;

-- Depois do índice
SHOW INDEX FROM viagem;   -- Agora aparece o idx_viagem_data
EXPLAIN SELECT * FROM viagem WHERE data_viagem = '2026-11-23';
-- Esperado: type = ref, key = idx_viagem_data, rows bem menor (em torno de 60)
-- Se o resultado for diferente, anote o que apareceu de verdade e explique no relatório

-- Limpeza: apaga as cópias e deixa só as 19 viagens originais
DELETE FROM viagem WHERE id_viagem > 19;
SELECT COUNT(*) AS total_viagens FROM viagem;   -- Esperado: 19


-- ######################################################################
-- PARTE 5 - [ADMIN] Usuário operacional e GRANT
-- ######################################################################
-- Como funciona
--   CREATE USER  cria um usuário e define a senha
--   GRANT        concede permissões (quem pode fazer o quê)
--   REVOKE       retira permissões
-- O operador consulta, insere e atualiza, mas não exclui (RN11)
CREATE USER 'operador_transporte'@'localhost' IDENTIFIED BY 'Senha@123';

GRANT SELECT, INSERT, UPDATE
ON transporte_publico.*
TO 'operador_transporte'@'localhost';

SHOW GRANTS FOR 'operador_transporte'@'localhost';   -- Esperado: SELECT, INSERT, UPDATE

-- Antes de seguir, crie uma nova conexão no Workbench (botão "+" ao lado de
-- "MySQL Connections") com usuário operador_transporte, senha Senha@123,
-- host 127.0.0.1 e porta 3306. Abra essa conexão em outra aba


-- ######################################################################
-- PARTE 6 - [OPERADOR] Uma operação permitida e uma negada
-- (um comando por vez)
-- ######################################################################
USE transporte_publico;

-- 6.1 Permitida: o operador tem SELECT e UPDATE
SELECT prefixo, status FROM veiculo WHERE placa = 'JKL3456';        -- Esperado: F-105, ATIVO
UPDATE veiculo SET status = 'MANUTENCAO' WHERE placa = 'JKL3456';   -- Esperado: 1 row affected
SELECT prefixo, status FROM veiculo WHERE placa = 'JKL3456';        -- Esperado: F-105, MANUTENCAO

-- 6.2 Negada (gera erro de propósito): o operador não tem DELETE
-- Erro esperado: 1142 - DELETE command denied to user 'operador_transporte'@'localhost' for table 'atraso'
DELETE FROM atraso WHERE id_atraso = 1;


-- ######################################################################
-- PARTE 7 - [ADMIN] REVOKE (retirando a permissão de UPDATE)
-- ######################################################################
REVOKE UPDATE
ON transporte_publico.*
FROM 'operador_transporte'@'localhost';

SHOW GRANTS FOR 'operador_transporte'@'localhost';   -- Esperado: agora só SELECT e INSERT


-- ######################################################################
-- PARTE 8 - [OPERADOR] Testando de novo a permissão retirada
-- ######################################################################
-- Rode o USE abaixo para o MySQL recarregar as permissões nesta conexão
-- Se o UPDATE ainda funcionar, feche e abra a conexão do operador de novo
USE transporte_publico;

-- Gera erro de propósito: o mesmo UPDATE que funcionou na parte 6 agora é negado
-- Erro esperado: 1142 - UPDATE command denied to user 'operador_transporte'@'localhost' for table 'veiculo'
UPDATE veiculo SET status = 'ATIVO' WHERE placa = 'JKL3456';

-- O SELECT continua permitido
SELECT prefixo, status FROM veiculo WHERE placa = 'JKL3456';   -- Esperado: F-105 ainda em MANUTENCAO


-- ######################################################################
-- PARTE 9 - [ADMIN] Testes que geram erro de propósito
-- (um por vez, na conexão do administrador)
-- ######################################################################
USE transporte_publico;

-- Limpeza da parte 6: o administrador devolve o veículo F-105 para ATIVO
UPDATE veiculo SET status = 'ATIVO' WHERE placa = 'JKL3456';

-- 9.1 A chave estrangeira recusa um vínculo inválido: viagem de uma linha que não existe
-- Erro esperado: 1452 - Cannot add or update a child row: a foreign key constraint fails
INSERT INTO viagem (id_linha, id_veiculo, id_motorista, data_viagem, saida_prevista, chegada_prevista)
VALUES (99, 1, 1, '2026-11-24', '06:00:00', '06:40:00');

-- 9.2 Regra de exclusão (RESTRICT): não se apaga uma linha que já tem viagens
-- Erro esperado: 1451 - Cannot delete or update a parent row: a foreign key constraint fails
DELETE FROM linha WHERE id_linha = 1;

-- 9.3 Regra do UNIQUE (RN01): número de linha repetido
-- Erro esperado: 1062 - Duplicate entry '101' for key 'linha.numero'
INSERT INTO linha (numero, nome, tarifa) VALUES ('101', 'Linha repetida', 5.50);

-- 9.4 Transação com falha: ROLLBACK desfaz a primeira alteração (viagem 19)
-- O motivo 99 não existe: o UPDATE (passo 1) funciona, mas o INSERT (passo 2) falha
-- Antes
SELECT id_viagem, status, teve_atraso FROM viagem WHERE id_viagem = 19;    -- Esperado: EM_ANDAMENTO, 0
SELECT COUNT(*) AS atrasos_da_viagem_19 FROM atraso WHERE id_viagem = 19;  -- Esperado: 0

-- Erro esperado: 1452 - Cannot add or update a child row: a foreign key constraint fails
CALL sp_registrar_atraso(19, 99, 15, 'Teste de rollback');

-- Depois: nada mudou, porque o ROLLBACK desfez também o UPDATE
SELECT id_viagem, status, teve_atraso FROM viagem WHERE id_viagem = 19;    -- Esperado: EM_ANDAMENTO, 0
SELECT COUNT(*) AS atrasos_da_viagem_19 FROM atraso WHERE id_viagem = 19;  -- Esperado: 0

-- 9.5 Regras da procedure (RN07, RN08 e RN09): cada chamada abaixo é recusada
-- Erro esperado nas três: 1644 - Atraso recusado: viagem inválida, fora de andamento, já atrasada ou minutos inválidos
CALL sp_registrar_atraso(17, 1, 10, 'Viagem cancelada');   -- Viagem cancelada
CALL sp_registrar_atraso(2, 1, 10, 'Viagem já atrasada');  -- Viagem concluída que já tem atraso
CALL sp_registrar_atraso(19, 1, 0, 'Minutos inválidos');   -- Minutos iguais a zero

-- Conferência final: nada disso entrou no banco
SELECT COUNT(*) AS total_linhas  FROM linha;   -- Esperado: 4
SELECT COUNT(*) AS total_atrasos FROM atraso;  -- Esperado: 11 (os 10 iniciais mais o da viagem 18)

-- ACID neste projeto (para o relatório e a apresentação)
--   Atomicidade   registrar o atraso e marcar a viagem são um bloco só; se um passo
--                 falha, o ROLLBACK desfaz tudo (teste 9.4)
--   Consistência  o banco nunca fica com atraso sem viagem ou sem motivo válido,
--                 porque as chaves estrangeiras barram isso
--   Isolamento    enquanto a transação não é confirmada, outra conexão não enxerga
--                 a alteração pela metade
--   Durabilidade  depois do COMMIT (teste 3.2) o dado fica gravado, mesmo que o
--                 servidor seja reiniciado
-- Fim do script
