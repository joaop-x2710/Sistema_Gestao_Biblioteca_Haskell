module Model
  ( BookId
  , UserId
  , LoanId
  , Days
  , Category
  , UserType(..)
  , User(..)
  , Book(..)
  , Loan(..)
  , LoanStatus(..)
  , LoanSummary(..)
  ) where

type BookId   = Int
type UserId   = Int
type LoanId   = Int
type Days     = Int
type Category = String

data UserType
  = StudentUser
  | TeacherUser
  | ExternalUser
  deriving (Eq, Ord, Show)

data User = User
  { userId   :: UserId
  , userName :: String
  , userType :: UserType
  } deriving (Eq, Show)

data Book = Book
  { bookId          :: BookId
  , bookTitle       :: String
  , bookAuthor      :: String
  , bookCategory    :: Category
  , bookTotalCopies :: Int
  } deriving (Eq, Show)

data Loan = Loan
  { loanId        :: LoanId
  , loanBookId    :: BookId
  , loanUserId    :: UserId
  , loanStartDay  :: Days
  , loanDueDay    :: Days
  , loanReturnDay :: Maybe Days
  } deriving (Eq, Show)

data LoanStatus
  = ActiveOnTime
  | ActiveOverdue Days
  | ReturnedOnTime
  | ReturnedLate Days
  deriving (Eq, Ord, Show)

data LoanSummary = LoanSummary
  { summaryLoan      :: Loan
  , summaryBookTitle :: String
  , summaryUserName  :: String
  , summaryStatus    :: LoanStatus
  , summaryFine      :: Double
  } deriving (Eq, Show)
