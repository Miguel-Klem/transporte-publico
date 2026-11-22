# Requisitos e regras de negócio - transporte público

Projeto integrador: banco de dados para uma cidade inteligente
Grupo 03: Gabriel, Miguel, Nicolly e Pedro

## 1 Para quem é o banco e qual problema resolve

A prefeitura precisa saber quais linhas de ônibus atrasam mais, por qual motivo e com quais veículos. Hoje essas informações ficam espalhadas. O banco reúne linhas, veículos, motoristas, viagens e atrasos em um só lugar.

Quem usa o banco
- Administrador (equipe de TI da prefeitura): cria e mantém o banco, e é o único que exclui dados
- Operador (central de controle de tráfego): registra viagens e atrasos e consulta as informações, mas não exclui nada

## 2 Requisitos funcionais (o que o banco deve permitir)

| Código | Requisito | Onde aparece no projeto |
|---|---|---|
| RF01 | Cadastrar linhas, veículos, motoristas e motivos de atraso | Tabelas `linha`, `veiculo`, `motorista` e `motivo_atraso` |
| RF02 | Registrar viagens com horários previstos e reais | Tabela `viagem` |
| RF03 | Registrar o atraso de uma viagem com motivo e minutos | Tabela `atraso` e procedure `sp_registrar_atraso` |
| RF04 | Atualizar dados do dia a dia (tarifa, status do veículo, remarcação de viagem) | Comandos UPDATE da parte 2 do script |
| RF05 | Descobrir quais linhas, motivos e veículos concentram mais atrasos | Consultas 1, 2 e 3 |
| RF06 | Consultar todos os atrasos de uma linha específica | Procedure `sp_atrasos_da_linha` |
| RF07 | Controlar o que cada tipo de usuário pode fazer | Usuário `operador_transporte` com GRANT e REVOKE |

## 3 Requisitos não funcionais (como o banco deve se comportar)

| Código | Requisito | Como é atendido |
|---|---|---|
| RNF01 | Integridade: os dados não podem ficar incoerentes | Mecanismo InnoDB, chaves primárias e estrangeiras |
| RNF02 | Segurança: cada usuário só acessa o necessário | Permissões com GRANT e REVOKE |
| RNF03 | Desempenho: buscas por data devem ser rápidas | Índice `idx_viagem_data`, comprovado com EXPLAIN |
| RNF04 | Confiabilidade: operações em várias tabelas não podem ficar pela metade | Transação com COMMIT e ROLLBACK |
| RNF05 | Manutenção: o código deve ser fácil de entender | Nomes e comentários padronizados no script |
| RNF06 | Privacidade: não usar dados reais de pessoas | Todos os dados são fictícios |
| RNF07 | Compatibilidade: funcionar no ambiente da turma | MySQL 8.0 e MySQL Workbench |

## 4 Regras de negócio

| Código | Regra | Como o banco garante |
|---|---|---|
| RN01 | O número da linha é único e toda linha tem tarifa | `UNIQUE` e `NOT NULL` na tabela `linha` |
| RN02 | A placa do veículo é única | `UNIQUE` na tabela `veiculo` |
| RN03 | A CNH do motorista é única, então ninguém é cadastrado duas vezes | `UNIQUE` na tabela `motorista` |
| RN04 | Toda viagem precisa de linha, veículo e motorista cadastrados, e todo atraso precisa de viagem e motivo cadastrados | Chaves estrangeiras |
| RN05 | Não se exclui linha, veículo, motorista ou motivo que já tenha histórico | `ON DELETE RESTRICT` |
| RN06 | Ao excluir uma viagem, os atrasos dela são excluídos junto | `ON DELETE CASCADE` |
| RN07 | O atraso é registrado em tempo real: só viagem em andamento recebe atraso. Viagem cancelada, programada ou concluída é recusada | Procedure `sp_registrar_atraso` (condição no UPDATE e SIGNAL) |
| RN08 | Cada viagem guarda um atraso principal: viagem que já tem atraso é recusada | Procedure `sp_registrar_atraso` |
| RN09 | Os minutos do atraso precisam ser maiores que zero | Procedure `sp_registrar_atraso` |
| RN10 | Registrar o atraso e marcar a viagem como atrasada acontecem juntos: ou as duas coisas, ou nenhuma | Transação com HANDLER e ROLLBACK |
| RN11 | O operador consulta, insere e atualiza, mas nunca exclui | GRANT de SELECT, INSERT e UPDATE (sem DELETE) |

## 5 Decisão de normalização (pedida no relatório)

Os motivos de atraso (trânsito, chuva, acidente...) ficam na tabela `motivo_atraso`, e cada atraso guarda só o número do motivo. Assim o texto é gravado uma vez só. Se o nome de um motivo mudar, a alteração é feita em um lugar, e não em centenas de atrasos. Isso evita duplicação e inconsistência.

## 6 Observação sobre as colunas `teve_atraso` e `minutos_atraso`

Essas informações poderiam ser calculadas a partir dos horários da viagem. Foram mantidas para facilitar as consultas (filtrar viagens atrasadas sem juntar tabelas) e para guardar o tempo já pronto, junto com o motivo. O custo é manter os dados coerentes, e é por isso que a procedure atualiza a viagem e grava o atraso na mesma transação.
