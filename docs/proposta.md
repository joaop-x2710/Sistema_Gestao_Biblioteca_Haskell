# Proposta inicial do projeto

## Título

Sistema de Gestão de Biblioteca e Empréstimos

## Problema

As bibliotecas académicas e municipais precisam de gerir o catálogo de obras, controlar o número de exemplares disponíveis em cada momento, aplicar regras de empréstimo diferenciadas por tipo de leitor e apurar atrasos e coimas de forma consistente.

## Objetivos

Construir uma aplicação em Haskell que separe o núcleo funcional puro da camada de entrada e saída, permitindo consultar o catálogo, validar requisições e devoluções, calcular coimas e produzir relatórios de utilização e atrasos.

## Utilizadores

Bibliotecários e responsáveis pela gestão do acervo que consultam estados de empréstimos, validam requisições e emitem relatórios de ocupação e coimas.

## Funcionalidades previstas por fase

1. Fase 1 (Modelação e núcleo funcional): definição das entidades (`Book`, `User`, `Loan`, `LoanStatus`, `LoanSummary`), regras por tipo de leitor, cálculo de atrasos e coimas, pesquisa e filtragem recursiva, contagem de disponibilidade e validação de elegibilidade.
2. Fase 2 (Lógica funcional e transformação de dados): estatísticas por categoria e por tipo de utente, rankings de livros mais requisitados e utentes com mais coimas, pipelines com `map`, `filter`, `foldr`/`foldl` e composição funcional, e validações detalhadas com `Maybe` e `Either`.
3. Fase 3 (Aplicação final): leitura e escrita de ficheiros CSV (`livros.csv`, `utentes.csv`, `emprestimos.csv`), parsing seguro, menu interativo no terminal e exportação de relatórios para ficheiro.

## Dados a modelar

- `Book`: identificador, título, autor, categoria e total de exemplares.
- `User`: identificador, nome e perfil (`StudentUser`, `TeacherUser`, `ExternalUser`).
- `Loan`: identificador, livro, utente, dia de início, dia limite e dia de devolução opcional (`Maybe Days`).
- `LoanStatus` e `LoanSummary`: estado calculado do empréstimo e resumo com valor de coima associada.

## Entrada e saída

Na Fase 1 os dados de demonstração residem no módulo `SampleData`. Na Fase 3 a aplicação lerá os dados a partir de ficheiros CSV em `data/`, disponibilizará interação por terminal e gravará relatórios formatados em texto.

## Componente funcional e complexidade

O domínio exige cruzamento entre três entidades relacionadas (`Book`, `User`, `Loan`), estados dependentes do tempo (`Maybe Days` face ao dia de referência), regras parametrizadas por tipos algébricos (`UserType`), agregação de exemplares e coimas por recursão e folds, e validação de integridade referencial.
