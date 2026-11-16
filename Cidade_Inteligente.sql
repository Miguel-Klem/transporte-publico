-- 1. Criação do DB

CREATE DATABASE transporte_publico;
USE transporte_publico;

-- 2. Criação das Tabelas

-- Linhas de ônibus
CREATE TABLE linha (
  id_linha INT AUTO_INCREMENT PRIMARY KEY,
  numero   VARCHAR(10)  NOT NULL UNIQUE, -- Não pode ter 2 linhas com o mesmo número
  nome     VARCHAR(80)  NOT NULL,
  tarifa   DECIMAL(5,2) NOT NULL
) ENGINE=InnoDB;

-- Veículos
CREATE TABLE veiculo (
  id_veiculo INT AUTO_INCREMENT PRIMARY KEY,
  placa      CHAR(7)     NOT NULL UNIQUE,
  prefixo    VARCHAR(10) NOT NULL,  -- N° do ônibus (Pode haver prefixos iguais, mas não placas iguais)
  modelo     VARCHAR(50) NOT NULL,
  capacidade INT         NOT NULL,                  -- Quantos passageiros cabem
  status     VARCHAR(20) NOT NULL DEFAULT 'ATIVO'   -- Ativo, Manutenção, Desativado, etc
) ENGINE=InnoDB;

-- Motoristas.
CREATE TABLE motorista (
  id_motorista INT AUTO_INCREMENT PRIMARY KEY,
  nome         VARCHAR(80) NOT NULL,
  cnh          CHAR(11)    NOT NULL UNIQUE
) ENGINE=InnoDB;

-- Motivos de atraso (trânsito, chuva, acidente, etc)
CREATE TABLE motivo_atraso (
  id_motivo INT AUTO_INCREMENT PRIMARY KEY,
  descricao VARCHAR(60) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- Viagens: cada viagem é feita por UMA linha, com UM veículo e UM motorista.
-- As colunas "real" começam vazias (NULL) porque a viagem pode ainda não ter saído ou chegado. O ON DELETE RESTRICT impede apagar uma linha, veículo ou motorista que já tenha viagens, para não perder o histórico.
CREATE TABLE viagem (
  id_viagem        INT AUTO_INCREMENT PRIMARY KEY,
  id_linha         INT  NOT NULL,
  id_veiculo       INT  NOT NULL,
  id_motorista     INT  NOT NULL,
  data_viagem      DATE NOT NULL,
  saida_prevista   TIME NOT NULL,
  saida_real       TIME NULL,
  chegada_prevista TIME NOT NULL,
  chegada_real     TIME NULL,
  status           VARCHAR(20) NOT NULL DEFAULT 'PROGRAMADA',  -- Programada, Em andamento, Concluída, Cancelada
  teve_atraso      INT NOT NULL DEFAULT 0,                     -- 0 = Não, 1 = Sim
  FOREIGN KEY (id_linha)     REFERENCES linha (id_linha)         ON DELETE RESTRICT,
  FOREIGN KEY (id_veiculo)   REFERENCES veiculo (id_veiculo)     ON DELETE RESTRICT,
  FOREIGN KEY (id_motorista) REFERENCES motorista (id_motorista) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Atrasos: cada atraso pertence a uma viagem e tem um motivo.
-- O ON DELETE CASCADE faz o contrário da viagem: se uma viagem for apagada, os atrasos dela vão embora junto (um atraso sem viagem não faz sentido).
CREATE TABLE atraso (
  id_atraso      INT AUTO_INCREMENT PRIMARY KEY,
  id_viagem      INT NOT NULL,
  id_motivo      INT NOT NULL,
  minutos_atraso INT NOT NULL,
  observacao     VARCHAR(150) NULL,
  FOREIGN KEY (id_viagem) REFERENCES viagem (id_viagem)        ON DELETE CASCADE,
  FOREIGN KEY (id_motivo) REFERENCES motivo_atraso (id_motivo) ON DELETE RESTRICT
) ENGINE=InnoDB;