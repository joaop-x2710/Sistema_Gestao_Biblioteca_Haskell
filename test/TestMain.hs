module Main where

import Domain
import GHC.IO.Encoding (setLocaleEncoding, utf8)
import Model
import SampleData
import System.IO (hSetEncoding, stderr, stdout)

main :: IO ()
main = do
  configureEncoding
  putStrLn "Testes da Fase 1 - Sistema de Gestão de Biblioteca e Empréstimos"
  testLookupFunctions
  testAvailability
  testLoanStatusAndFines
  testBorrowEligibility
  testReferenceValidation
  putStrLn "Todos os testes passaram."

configureEncoding :: IO ()
configureEncoding = do
  setLocaleEncoding utf8
  hSetEncoding stdout utf8
  hSetEncoding stderr utf8

testLookupFunctions :: IO ()
testLookupFunctions = do
  assertEqual "pesquisa de livro existente"
    (Just "Programming in Haskell")
    (fmap bookTitle (findBook 102 sampleBooks))
  assertEqual "pesquisa de livro inexistente"
    Nothing
    (findBook 999 sampleBooks)
  assertEqual "categorias únicas"
    ["Programação", "Algoritmos", "Engenharia de Software"]
    (allCategories sampleBooks)

testAvailability :: IO ()
testAvailability = do
  case (findBook 101 sampleBooks, findBook 102 sampleBooks) of
    (Just b101, Just b102) -> do
      assertEqual "exemplares disponíveis do livro 101" 1 (availableCopies b101 sampleLoans)
      assertEqual "exemplares disponíveis do livro 102 (esgotado)" 0 (availableCopies b102 sampleLoans)
      assertEqual "livro 102 indisponível" False (isBookAvailable b102 sampleLoans)
    _ -> error "Livros de teste em falta"

testLoanStatusAndFines :: IO ()
testLoanStatusAndFines = do
  let loanOnTime  = Loan 1 101 1 20 35 Nothing
  let loanOverdue = Loan 2 102 3 18 25 Nothing
  let loanLateRet = Loan 4 104 1 1 15 (Just 19)
  assertEqual "estado ativo dentro do prazo" ActiveOnTime (loanStatus referenceDay loanOnTime)
  assertEqual "estado ativo em atraso (5 dias)" (ActiveOverdue 5) (loanStatus referenceDay loanOverdue)
  assertEqual "estado devolvido com atraso (4 dias)" (ReturnedLate 4) (loanStatus referenceDay loanLateRet)
  assertEqual "coima de utente externo (5 dias * 1.00)" 5.0 (calculateLoanFine referenceDay ExternalUser loanOverdue)
  assertEqual "coima de estudante (4 dias * 0.50)" 2.0 (calculateLoanFine referenceDay StudentUser loanLateRet)

testBorrowEligibility :: IO ()
testBorrowEligibility = do
  case (findBook 101 sampleBooks, findBook 102 sampleBooks, findUser 1 sampleUsers, findUser 3 sampleUsers) of
    (Just b101, Just b102, Just ana, Just carla) -> do
      assertEqual "Ana pode requisitar livro disponível"
        True
        (canUserBorrow referenceDay ana b101 sampleLoans)
      assertEqual "Ana não pode requisitar livro sem exemplares"
        False
        (canUserBorrow referenceDay ana b102 sampleLoans)
      assertEqual "Carla não pode requisitar por ter empréstimo ativo em atraso"
        False
        (canUserBorrow referenceDay carla b101 sampleLoans)
    _ -> error "Dados de teste em falta"

testReferenceValidation :: IO ()
testReferenceValidation = do
  assertEqual "dados válidos sem erros de referência"
    []
    (validateLoanReferences sampleBooks sampleUsers sampleLoans)
  assertEqual "deteção de 2 referências inválidas"
    2
    (length (validateLoanReferences sampleBooks sampleUsers sampleInvalidLoans))

assertEqual :: (Eq a, Show a) => String -> a -> a -> IO ()
assertEqual label expected actual
  | expected == actual = putStrLn ("[OK] " ++ label)
  | otherwise = error $ "[FALHOU] " ++ label
      ++ " | esperado=" ++ show expected
      ++ " | obtido=" ++ show actual
