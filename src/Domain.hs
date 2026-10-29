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
  , loansForUser
  , activeLoansForUser
  , activeLoansCountForBook
  , availableCopies
  , isBookAvailable
  , overdueLoans
  , hasOverdueLoans
  , canUserBorrow
  , totalFinesForUser
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

loansForUser :: UserId -> [Loan] -> [Loan]
loansForUser _ [] = []
loansForUser uid (l:ls)
  | loanUserId l == uid = l : loansForUser uid ls
  | otherwise           = loansForUser uid ls

activeLoansForUser :: UserId -> [Loan] -> [Loan]
activeLoansForUser _ [] = []
activeLoansForUser uid (l:ls)
  | loanUserId l == uid && isLoanActive l = l : activeLoansForUser uid ls
  | otherwise                             = activeLoansForUser uid ls

-- Contagem recursiva com acumulador de exemplares emprestados

activeLoansCountForBook :: BookId -> [Loan] -> Int
activeLoansCountForBook bid loans = aux loans 0
  where
    aux :: [Loan] -> Int -> Int
    aux [] acc = acc
    aux (l:ls) acc
      | loanBookId l == bid && isLoanActive l = aux ls (acc + 1)
      | otherwise                             = aux ls acc

availableCopies :: Book -> [Loan] -> Int
availableCopies book loans
  | remaining > 0 = remaining
  | otherwise     = 0
  where
    remaining = bookTotalCopies book - activeLoansCountForBook (bookId book) loans

isBookAvailable :: Book -> [Loan] -> Bool
isBookAvailable book loans = availableCopies book loans > 0

overdueLoans :: Days -> [Loan] -> [Loan]
overdueLoans _ [] = []
overdueLoans currentDay (l:ls)
  | isLoanOverdue currentDay l = l : overdueLoans currentDay ls
  | otherwise                  = overdueLoans currentDay ls

hasOverdueLoans :: Days -> UserId -> [Loan] -> Bool
hasOverdueLoans _ _ [] = False
hasOverdueLoans currentDay uid (l:ls)
  | loanUserId l == uid && isActiveOverdue = True
  | otherwise                              = hasOverdueLoans currentDay uid ls
  where
    isActiveOverdue =
      case loanStatus currentDay l of
        ActiveOverdue _ -> True
        _               -> False

-- Regra de elegibilidade para novo empréstimo

canUserBorrow :: Days -> User -> Book -> [Loan] -> Bool
canUserBorrow currentDay user book loans =
  isBookAvailable book loans
    && activeCount < maxAllowed
    && not (hasOverdueLoans currentDay (userId user) loans)
  where
    activeCount = length (activeLoansForUser (userId user) loans)
    maxAllowed  = maxLoansForType (userType user)

-- Cálculo recursivo com acumulador do total de coimas de um utente

totalFinesForUser :: Days -> User -> [Loan] -> Double
totalFinesForUser currentDay user loans = aux (loansForUser (userId user) loans) 0.0
  where
    uType = userType user
    aux :: [Loan] -> Double -> Double
    aux [] acc = acc
    aux (l:ls) acc = aux ls (acc + calculateLoanFine currentDay uType l)
