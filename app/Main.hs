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
  putStrLn "  SISTEMA DE GESTÃO DE BIBLIOTECA E EMPRÉSTIMOS (Fase 1 - Base)"
  putStrLn $ "  Dia de referência: " ++ show referenceDay
  putStrLn "========================================================================"

  putStrLn "\n1. CATÁLOGO DE LIVROS"
  putStrLn "------------------------------------------------------------------------"
  mapM_ (putStrLn . formatBookLine) sampleBooks
  putStrLn $ "Categorias registadas: " ++ intercalate ", " (allCategories sampleBooks)

  putStrLn "\n2. UTENTES REGISTADOS E REGRAS POR PERFIL"
  putStrLn "------------------------------------------------------------------------"
  mapM_ (putStrLn . formatUserLine) sampleUsers

  putStrLn "\n3. ESTADO DOS EMPRÉSTIMOS REGISTADOS"
  putStrLn "------------------------------------------------------------------------"
  mapM_ (putStrLn . formatLoanLine referenceDay sampleBooks sampleUsers) sampleLoans

configureEncoding :: IO ()
configureEncoding = do
  setLocaleEncoding utf8
  hSetEncoding stdout utf8
  hSetEncoding stderr utf8

formatBookLine :: Book -> String
formatBookLine book =
  show (bookId book)
    ++ " | " ++ bookTitle book
    ++ " (" ++ bookAuthor book ++ ")"
    ++ " | Cat: " ++ bookCategory book
    ++ " | Exemplares: " ++ show (bookTotalCopies book)

formatUserLine :: User -> String
formatUserLine user =
  show (userId user)
    ++ " | " ++ userName user
    ++ " (" ++ formatUserType uType ++ ")"
    ++ " | Limite: " ++ show (maxLoansForType uType)
    ++ " | Prazo: " ++ show (loanDurationForType uType) ++ " dias"
    ++ " | Taxa diária: " ++ formatCurrency (dailyFineRate uType)
  where
    uType = userType user

formatLoanLine :: Days -> [Book] -> [User] -> Loan -> String
formatLoanLine currentDay books users loan =
  "#" ++ show (loanId loan)
    ++ " | " ++ bTitle
    ++ " | " ++ uName
    ++ " | " ++ formatStatus (loanStatus currentDay loan)
    ++ " | Coima: " ++ formatCurrency fine
  where
    bTitle = maybe "Livro desconhecido" bookTitle (findBook (loanBookId loan) books)
    mUser  = findUser (loanUserId loan) users
    uName  = maybe "Utente desconhecido" userName mUser
    fine   = maybe 0.0 (\u -> calculateLoanFine currentDay (userType u) loan) mUser

formatUserType :: UserType -> String
formatUserType StudentUser  = "Estudante"
formatUserType TeacherUser  = "Docente"
formatUserType ExternalUser = "Externo"

formatStatus :: LoanStatus -> String
formatStatus ActiveOnTime      = "Ativo (dentro do prazo)"
formatStatus (ActiveOverdue d) = "Ativo (EM ATRASO: " ++ show d ++ " dias)"
formatStatus ReturnedOnTime    = "Devolvido (a tempo)"
formatStatus (ReturnedLate d)  = "Devolvido (com atraso: " ++ show d ++ " dias)"

formatCurrency :: Double -> String
formatCurrency val = printf "%.2f EUR" val
