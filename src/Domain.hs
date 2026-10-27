module Domain
  ( maxLoansForType
  , loanDurationForType
  , dailyFineRate
  , isLoanActive
  , delayDays
  , loanStatus
  , isLoanOverdue
  , calculateLoanFine
  , findBook
  , findUser
  , booksByCategory
  , allCategories
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

-- Pesquisa e filtragem recursiva sobre listas

findBook :: BookId -> [Book] -> Maybe Book
findBook _ [] = Nothing
findBook targetId (b:bs)
  | bookId b == targetId = Just b
  | otherwise            = findBook targetId bs

findUser :: UserId -> [User] -> Maybe User
findUser _ [] = Nothing
findUser targetId (u:us)
  | userId u == targetId = Just u
  | otherwise            = findUser targetId us

booksByCategory :: Category -> [Book] -> [Book]
booksByCategory _ [] = []
booksByCategory cat (b:bs)
  | bookCategory b == cat = b : booksByCategory cat bs
  | otherwise             = booksByCategory cat bs

belongsTo :: Eq a => a -> [a] -> Bool
belongsTo _ [] = False
belongsTo val (x:xs)
  | val == x  = True
  | otherwise = belongsTo val xs

allCategories :: [Book] -> [Category]
allCategories books = collectUnique books []
  where
    collectUnique :: [Book] -> [Category] -> [Category]
    collectUnique [] acc = acc
    collectUnique (b:bs) acc
      | belongsTo (bookCategory b) acc = collectUnique bs acc
      | otherwise                      = collectUnique bs (acc ++ [bookCategory b])
