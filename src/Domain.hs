module Domain
  ( maxLoansForType
  , loanDurationForType
  , dailyFineRate
  , isLoanActive
  , delayDays
  , loanStatus
  , isLoanOverdue
  , calculateLoanFine
  ) where

import Model

-- Regras base por tipo de utente (pattern matching sobre tipo algébrico)

maxLoansForType :: UserType -> Int
maxLoansForType StudentUser  = 3
maxLoansForType TeacherUser  = 6
maxLoansForType ExternalUser = 2

loanDurationForType :: UserType -> Days
loanDurationForType StudentUser  = 15
loanDurationForType TeacherUser  = 30
loanDurationForType ExternalUser = 7

dailyFineRate :: UserType -> Double
dailyFineRate StudentUser  = 0.50
dailyFineRate TeacherUser  = 0.25
dailyFineRate ExternalUser = 1.00

-- Estado e atraso de um empréstimo (pattern matching e guards)

isLoanActive :: Loan -> Bool
isLoanActive loan =
  case loanReturnDay loan of
    Nothing -> True
    Just _  -> False

delayDays :: Days -> Loan -> Days
delayDays currentDay loan =
  case loanReturnDay loan of
    Nothing
      | currentDay > loanDueDay loan -> currentDay - loanDueDay loan
      | otherwise                    -> 0
    Just returnDay
      | returnDay > loanDueDay loan  -> returnDay - loanDueDay loan
      | otherwise                    -> 0

loanStatus :: Days -> Loan -> LoanStatus
loanStatus currentDay loan =
  case loanReturnDay loan of
    Nothing
      | delay > 0 -> ActiveOverdue delay
      | otherwise -> ActiveOnTime
    Just _
      | delay > 0 -> ReturnedLate delay
      | otherwise -> ReturnedOnTime
  where
    delay = delayDays currentDay loan

isLoanOverdue :: Days -> Loan -> Bool
isLoanOverdue currentDay loan =
  case loanStatus currentDay loan of
    ActiveOverdue _ -> True
    ReturnedLate _  -> True
    _               -> False

calculateLoanFine :: Days -> UserType -> Loan -> Double
calculateLoanFine currentDay uType loan =
  fromIntegral (delayDays currentDay loan) * dailyFineRate uType
