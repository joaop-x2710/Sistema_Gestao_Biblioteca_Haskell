# Sistema de Gestão de Biblioteca e Empréstimos

Trabalho prático da unidade curricular de Programação Funcional em Haskell (UTAD 2026/2027).

Esta entrega corresponde à Fase 1 (Modelação e núcleo funcional). O projeto modela o catálogo de livros de uma biblioteca, os seus utentes e o registo de empréstimos, aplicando tipos algébricos, records, pattern matching, guards e recursão explícita.

## Problema e objetivos

Uma biblioteca precisa de controlar os exemplares disponíveis de cada obra, os limites de requisição por perfil de leitor (estudante, docente ou utilizador externo), os prazos de devolução e as coimas por atraso.

Na Fase 1, o foco está na definição dos tipos de domínio e nas funções puras que calculam estados de empréstimo, disponibilidade de exemplares, elegibilidade para novas requisições e coimas acumuladas.

## Estrutura do projeto

```text
Sistema_Gestao_Biblioteca_Haskell/
├── app/
│   └── Main.hs
├── src/
│   ├── Model.hs
│   ├── Domain.hs
│   └── SampleData.hs
├── test/
│   └── TestMain.hs
├── docs/
│   └── proposta.md
├── cabal.project
├── library-management.cabal
└── README.md
```

No módulo `src/Model.hs` estão os sinónimos de tipo (`BookId`, `UserId`, `LoanId`, `Days`, `Category`), os tipos soma (`UserType`, `LoanStatus`) e os registos (`User`, `Book`, `Loan`, `LoanSummary`).

O módulo `src/Domain.hs` reúne as regras de negócio puras: limites e taxas por perfil, cálculo de dias de atraso e estado de empréstimo, pesquisa e filtragem recursiva, contagem com acumulador de exemplares emprestados e de coimas, validação de elegibilidade para requisição e verificação de referências entre entidades.

O módulo `src/SampleData.hs` contém os dados de teste usados na demonstração (`app/Main.hs`) e nos testes automáticos (`test/TestMain.hs`).

## Compilar e executar com GHC

Na raiz do projeto:

```bash
ghc -Wall -isrc app/Main.hs -o library-manager
./library-manager
```

Em Windows:

```powershell
ghc -Wall -isrc app/Main.hs -o library-manager.exe
.\library-manager.exe
```

## Executar com Cabal

```bash
cabal run library-manager
```

## Executar os testes

Com GHC:

```bash
ghc -Wall -isrc test/TestMain.hs -o tests
./tests
```

Ou com Cabal:

```bash
cabal test
```

## Explorar no GHCi

Para testar as funções puras diretamente no interpretador durante a apresentação em aula:

```bash
ghci -isrc src/Domain.hs src/SampleData.hs
```

Exemplos de expressões no GHCi:

```haskell
findBook 101 sampleBooks
allCategories sampleBooks
availableCopies (head sampleBooks) sampleLoans
loanStatus referenceDay (sampleLoans !! 1)
totalFinesForUser referenceDay (head sampleUsers) sampleLoans
validateLoanReferences sampleBooks sampleUsers sampleInvalidLoans
```

## Regras do domínio implementadas na Fase 1

Cada perfil de leitor tem limites e prazos distintos:
- Estudantes (`StudentUser`): até 3 empréstimos ativos em simultâneo, prazo de 15 dias e coima diária de 0.50 EUR.
- Docentes (`TeacherUser`): até 6 empréstimos ativos em simultâneo, prazo de 30 dias e coima diária de 0.25 EUR.
- Externos (`ExternalUser`): até 2 empréstimos ativos em simultâneo, prazo de 7 dias e coima diária de 1.00 EUR.

Um empréstimo sem dia de devolução (`Nothing`) encontra-se ativo (`ActiveOnTime` ou `ActiveOverdue`). Quando tem dia de devolução (`Just d`), passa a concluído (`ReturnedOnTime` ou `ReturnedLate`).

Um leitor pode requisitar um livro quando existem exemplares disponíveis, o seu número de empréstimos ativos é inferior ao limite do seu perfil e não tem empréstimos ativos fora de prazo.
