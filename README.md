# Arquitetura de Dados - Acompanhamento-Processual
Este repositório contém o modelo relacional (PostgreSQL) desenvolvido para o novo Sistema de Acompanhamento Processual da Pró-Reitoria de Administração e Finanças (PROAD) da Universidade Federal do Tocantins (UFT).

### 🎯 Objetivo
Atuar como a base de dados centralizada e robusta para o Sistema de Acompanhamento Processual, operando em sinergia com o SEI (Sistema Eletrônico de Informações) e a Pró-Reitoria de Administração e Finanças da UFT. A arquitetura foi projetada para garantir integridade referencial, preservação do histórico de movimentações e facilitar a extração de métricas de desempenho (SLA) para a governança institucional.

## 🛠️ Pontos Técnicos da Modelagem

### 1.Separação entre Fato e Dimensão
Organização estrutural dividindo a base de dados entre tabelas de transação (ex: processos, demandas, logs) e tabelas descritivas/cadastrais (ex: setores, modalidades, fases). Esta abordagem normalizada facilita as junções (JOINs) e a construção de vistas analíticas para dashboards.

### 2. Tabela de Logs (Histórico de Tramitação)
Para evitar anomalias de atualização (como sobrescrever datas e perder o rastro do processo), o sistema registra cada movimentação numa tabela dedicada de logs. O cálculo de dias gastos é carimbado estaticamente no momento da transição (Avanço, Retorno, Pausa), preservando a linha do tempo exata.

### 3. Restrições e Tipagem (ENUMs)
A validação de dados começa na camada do banco de dados, não dependendo apenas da aplicação (Backend/Frontend).
- ENUMs: Uso de tipos customizados diretamente no SGBD para impedir o registro de estados inválidos.
```bash
create type tipo_tramitacao as enum('Pausa/Adequação', 'Avanço', 'Retorno');
```
- Integridade (```ON DELETE```): Aplicação de diferentes níveis de proteção de dados órfãos.
  
  - ```CASCADE``` na tabela ```fluxo```: se uma modalidade for excluída, as suas etapas deixam de existir automaticamente.
    
  - ```SET NULL``` nas tabelas de transação: se um utilizador ou setor for desativado, o histórico não é apagado (preservação para auditoria).

### 4. Colunas Calculadas
A tabela ```demandas``` delega cálculos financeiros para o próprio motor do banco de dados, garantindo precisão matemática e aliviando o processamento do servidor aplicacional.
```bash
valor_total numeric(15, 2) generated always as (valor_unitario * quantidade_itens) stored
```
### 💡 Tecnologias e Padrões: 
```PostgreSQL```, ```PL/pgSQL```, ```DDL Padrão ISO```, ```DBeaver```.


<br>
<br>
<div align="center">

Por Ricardo Rocha Alves |  Por RicardoNatiruts <a href="https://github.com/RicardoNatiruts">
  <img src="https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white" align="center" height="25">
</a>
</div>


