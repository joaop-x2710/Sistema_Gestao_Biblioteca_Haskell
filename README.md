# Sistema de Gestão de Biblioteca e Empréstimos

Trabalho prático da unidade curricular de Programação Funcional em Haskell (UTAD 2026/2027).

Esta entrega corresponde à Fase 1 (Modelação e núcleo funcional). O projeto modela o catálogo de livros de uma biblioteca, os seus utentes e o registo de empréstimos, aplicando tipos algébricos, records, pattern matching, guards e recursão explícita.

## Problema e objetivos

Uma biblioteca precisa de controlar os exemplares disponíveis de cada obra, os limites de requisição por perfil de leitor (estudante, docente ou utilizador externo), os prazos de devolução e as coimas por atraso.

Na Fase 1, o foco está na definição dos tipos de domínio e nas funções puras que calculam estados de empréstimo, prazos e pesquisas recursivas sobre o catálogo e utentes.

## Estrutura do projeto

```text
Sistema_Gestao_Biblioteca_Haskell/
├── app/
│   └── Main.hs
├── src/
│   ├── Model.hs
│   ├── Domain.hs
│   └── SampleData.hs
├── docs/
│   └── proposta.md
├── cabal.project
├── library-management.cabal
└── README.md
```

No módulo `src/Model.hs` estão os sinónimos de tipo (`BookId`, `UserId`, `LoanId`, `Days`, `Category`), os tipos soma (`UserType`, `LoanStatus`) e os registos (`User`, `Book`, `Loan`, `LoanSummary`).

O módulo `src/Domain.hs` reúne as regras de negócio puras: limites e taxas por perfil, cálculo de dias de atraso e estado de empréstimo, cálculo de coimas e pesquisa/filtragem recursiva de livros, utentes e categorias.

O módulo `src/SampleData.hs` contém os dados de teste usados na demonstração (`app/Main.hs`).

## Compilar e executar com GHC

Na raiz do projeto:

```bash
ghc -Wall -isrc app/Main.hs -o library-manager
./library-manager
```

## Executar com Cabal

```bash
cabal run library-manager
```

## Explorar no GHCi

```bash
ghci -isrc src/Domain.hs src/SampleData.hs
```

Exemplos de expressões no GHCi:

```haskell
findBook 101 sampleBooks
allCategories sampleBooks
loanStatus referenceDay (sampleLoans !! 1)
```
