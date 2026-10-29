module Main where

import Data.List (intercalate)
import Domain
import GHC.IO.Encoding (setLocaleEncoding, utf8)
import Model
import SampleData
import System.IO (hSetEncoding, stderr, stdout)
import Text.Printf (printf)

main :: IO ()
main = do
  configureEncoding
  putStrLn "========================================================================"
  putStrLn "  SISTEMA DE GESTÃO DE BIBLIOTECA E EMPRÉSTIMOS (Fase 1 - Demonstração)"
  putStrLn $ "  Dia de referência: " ++ show referenceDay
  putStrLn "========================================================================"

  putStrLn "\n1. CATÁLOGO DE LIVROS E DISPONIBILIDADE"
  putStrLn "------------------------------------------------------------------------"
  mapM_ (putStrLn . formatBookLine sampleLoans) sampleBooks
  putStrLn $ "Categorias registadas: " ++ intercalate ", " (allCategories sampleBooks)

  putStrLn "\n2. UTENTES REGISTADOS E RESUMO DE EMPRÉSTIMOS / COIMAS"
  putStrLn "------------------------------------------------------------------------"
  mapM_ (putStrLn . formatUserLine referenceDay sampleLoans) sampleUsers

  putStrLn "\n3. RESUMO DOS EMPRÉSTIMOS"
  putStrLn "------------------------------------------------------------------------"
  let summaries = buildAllSummaries referenceDay sampleBooks sampleUsers sampleLoans
  mapM_ (putStrLn . formatSummaryLine) summaries

  putStrLn "\n4. VERIFICAÇÃO DE ELEGIBILIDADE PARA NOVO EMPRÉSTIMO (Livro 101)"
  putStrLn "------------------------------------------------------------------------"
  case findBook 101 sampleBooks of
    Nothing -> putStrLn "Livro 101 não encontrado."
    Just book ->
      mapM_ (putStrLn . formatEligibility referenceDay book sampleLoans) sampleUsers

  putStrLn "\n5. VALIDAÇÃO DE REFERÊNCIAS (Demonstração com dados inválidos)"
  putStrLn "------------------------------------------------------------------------"
  mapM_ putStrLn (validateLoanReferences sampleBooks sampleUsers sampleInvalidLoans)

configureEncoding :: IO ()
configureEncoding = do
  setLocaleEncoding utf8
  hSetEncoding stdout utf8
  hSetEncoding stderr utf8

formatBookLine :: [Loan] -> Book -> String
formatBookLine loans book =
  show (bookId book)
    ++ " | " ++ bookTitle book
    ++ " (" ++ bookAuthor book ++ ")"
    ++ " | Cat: " ++ bookCategory book
    ++ " | Disponíveis: " ++ show (availableCopies book loans)
    ++ "/" ++ show (bookTotalCopies book)

formatUserLine :: Days -> [Loan] -> User -> String
formatUserLine currentDay loans user =
  show (userId user)
    ++ " | " ++ userName user
    ++ " (" ++ formatUserType (userType user) ++ ")"
    ++ " | Ativos: " ++ show activeCount ++ "/" ++ show maxAllowed
    ++ " | Coimas acumuladas: " ++ formatCurrency totalFine
  where
    activeCount = length (activeLoansForUser (userId user) loans)
    maxAllowed  = maxLoansForType (userType user)
    totalFine   = totalFinesForUser currentDay user loans

formatSummaryLine :: LoanSummary -> String
formatSummaryLine summary =
  "#" ++ show (loanId (summaryLoan summary))
    ++ " | " ++ summaryBookTitle summary
    ++ " | " ++ summaryUserName summary
    ++ " | " ++ formatStatus (summaryStatus summary)
    ++ " | Coima: " ++ formatCurrency (summaryFine summary)

formatEligibility :: Days -> Book -> [Loan] -> User -> String
formatEligibility currentDay book loans user =
  userName user ++ " -> " ++ statusText
  where
    statusText
      | canUserBorrow currentDay user book loans = "PODE requisitar \"" ++ bookTitle book ++ "\""
      | otherwise                                = "IMPEDIDO de requisitar \"" ++ bookTitle book ++ "\""

formatUserType :: UserType -> String
formatUserType StudentUser  = "Estudante"
formatUserType TeacherUser  = "Docente"
formatUserType ExternalUser = "Externo"

formatStatus :: LoanStatus -> String
formatStatus ActiveOnTime        = "Ativo (dentro do prazo)"
formatStatus (ActiveOverdue d)   = "Ativo (EM ATRASO: " ++ show d ++ " dias)"
formatStatus ReturnedOnTime      = "Devolvido (a tempo)"
formatStatus (ReturnedLate d)    = "Devolvido (com atraso: " ++ show d ++ " dias)"

formatCurrency :: Double -> String
formatCurrency val = printf "%.2f EUR" val
