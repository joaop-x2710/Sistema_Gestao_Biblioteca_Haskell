module SampleData
  ( referenceDay
  , sampleBooks
  , sampleUsers
  , sampleLoans
  , sampleInvalidLoans
  ) where

import Model

-- Dia atual de referência para simulação de prazos e atrasos
referenceDay :: Days
referenceDay = 30

sampleBooks :: [Book]
sampleBooks =
  [ Book 101 "Learn You a Haskell for Great Good!" "Miran Lipovaca" "Programação" 2
  , Book 102 "Programming in Haskell" "Graham Hutton" "Programação" 1
  , Book 103 "Introduction to Algorithms" "Cormen et al." "Algoritmos" 3
  , Book 104 "Clean Architecture" "Robert C. Martin" "Engenharia de Software" 2
  ]

sampleUsers :: [User]
sampleUsers =
  [ User 1 "Ana Silva" StudentUser
  , User 2 "Bruno Costa" TeacherUser
  , User 3 "Carla Mendes" ExternalUser
  , User 4 "Diogo Rocha" StudentUser
  ]

sampleLoans :: [Loan]
sampleLoans =
  [ -- Empréstimo ativo dentro do prazo (vence no dia 35)
    Loan 1 101 1 20 35 Nothing
  , -- Empréstimo ativo em atraso (venceu no dia 25; no dia 30 tem 5 dias de atraso)
    Loan 2 102 3 18 25 Nothing
  , -- Empréstimo devolvido dentro do prazo (vencia no dia 20, devolvido no dia 18)
    Loan 3 103 2 1 20 (Just 18)
  , -- Empréstimo devolvido com atraso (vencia no dia 15, devolvido no dia 19 -> 4 dias)
    Loan 4 104 1 1 15 (Just 19)
  , -- Empréstimo ativo dentro do prazo para docente
    Loan 5 103 2 10 40 Nothing
  ]

-- Conjunto auxiliar com referências inválidas para demonstrar a validação
sampleInvalidLoans :: [Loan]
sampleInvalidLoans =
  sampleLoans
    ++ [ Loan 99 999 1 10 25 Nothing
       , Loan 100 101 888 12 27 Nothing
       ]
