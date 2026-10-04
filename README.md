# Library Management System (Bibliothek)

> Course project — [Course name / module]
> Author: [Your name]
> Date: [Date]

## Table of Contents

1. [Program Description](#1-program-description)
2. [Data Structure](#2-data-structure)
3. [Main Menu Flowchart](#3-main-menu-flowchart)
4. [List of Functions](#4-list-of-functions)
5. [Testing](#5-testing)
6. [Conclusions](#6-conclusions)

---

## 1. Program Description

**Bibliothek** is a console-based library management system written in Object Pascal (Free Pascal, `{$mode objfpc}`). It allows a librarian to manage a book catalog from the command line, with the data persisted between sessions in a plain-text file (`books.txt`).

### Problem it solves

Managing a small library (or a personal book collection) by hand — tracking which books exist, who borrowed what, and when — becomes error-prone and slow as the collection grows. This program automates that bookkeeping: it keeps a structured record of every book and lets the user search, filter, sort, and track lending status without manually editing files or spreadsheets.

### Key features

- Persistent storage: books are loaded from `books.txt` on startup and the file is rewritten whenever the catalog changes (adding, borrowing, returning a book).
- Full catalog view and filtered views (available books only, books by year range, books by a specific author).
- Linear search by exact title.
- Borrowing/returning workflow with validation (a book that is already borrowed cannot be borrowed again; an invalid book number is rejected).
- Three sorting criteria (title, year, author) using Bubble Sort.
- Basic and extended statistics: total books, number available, average page count, oldest/newest book in the catalog.
- Input validation for publication year (must be between 1450 and 2026).

### Technologies used

- **Language:** Object Pascal (Free Pascal Compiler, `objfpc` mode)
- **Data storage:** plain-text file, semicolon-separated fields (`;`)
- **Data structures:** `record` (`TBook`) and a dynamic array (`TBooks = array of TBook`)

---

## 2. Data Structure

### `TBook` record

Each book is represented as a single record with six fields:

```pascal
type
  TBook = record
    title: String;        { book title }
    author: String;       { author name }
    year: Integer;         { publication year }
    pages: Integer;        { number of pages }
    available: Boolean;    { true = can be borrowed, false = currently lent out }
    borrower: String;      { name of the current borrower, empty if available }
  end;

  TBooks = array of TBook; { dynamic array of books }
```

### Why a dynamic array?

Unlike a fixed-size array (`array[1..MAX_BOOKS] of TBook`), a dynamic array (`array of TBook`) does not require a hard-coded maximum capacity. Its size is set at runtime with `SetLength` and grows by one element every time a new book is added (`SetLength(books, Length(books) + 1)`), and `Length(books)` always reflects the current number of books — there is no need for a separate `count` variable.

### File storage format

Each book is stored as one line in `books.txt`, with fields separated by `;`:

```
title;author;year;pages;available;borrower;
```

Example:

```
Kobzar;Taras Shevchenko;1840;248;1;;
```

The helper function `ExtractField` reads one field at a time from the front of a line (up to the next `;`) and removes it from the string, so the loading routine can call it repeatedly to populate all six fields of a `TBook`.

---

## 4. List of Functions

| Name | Parameters | Purpose |
|---|---|---|
| `ExtractField` | `var line: String` | Extracts and removes the first `;`-separated field from a line; used while parsing `books.txt`. |
| `SaveBooksToFile` | `books: TBooks` | Rewrites the entire `books.txt` file from the current in-memory array (called after any data change). |
| `AddBook` | `var TxtFile: TextFile; var books: TBooks` | Prompts the user for book details, validates the year, appends the new book to the file, and adds it to the array. |
| `PrintBook` | `books: TBooks; index: Integer` | Prints all fields of a single book at the given index, including its availability status. |
| `PrintCatalog` | `books: array of TBook` | Prints every book in the catalog, numbered. |
| `PrintAvailable` | `books: TBooks` | Prints only the books currently marked as available. |
| `FindByTitle` | `books: array of TBook; query: String` → `Integer` | Linear search for a book by exact title; returns its index, or `-1` if not found. |
| `SearchByAuthor` | `books: array of TBook; query: String` | Prints every book written by the given author (there can be more than one match). |
| `FilterByYear` | `books: TBooks; fromY, toY: Integer` | Prints every book whose publication year falls strictly between `fromY` and `toY`, after validating the range. |
| `BorrowBook` | `var books: TBooks; index: Integer; borrower: String` | Marks a book as borrowed if it is available and the index is valid; updates the file. |
| `ReturnBook` | `var books: TBooks; index: Integer` | Marks a book as available again and clears the borrower field; updates the file. |
| `SortByTitle` | `var books: TBooks` | Sorts the catalog alphabetically by title using Bubble Sort. |
| `SortByYear` | `var books: TBooks` | Sorts the catalog by publication year using Bubble Sort. |
| `SortByAuthor` | `var books: TBooks` | Sorts the catalog alphabetically by author using Bubble Sort. |
| `AveragePages` | `var books: TBooks` | Computes and prints the average page count across all books. |
| `CountAvailable` | `books: TBooks` → `Integer` | Returns the number of books currently marked as available. |
| `NewestOldestBook` | `var books: TBooks` | Finds and prints the book with the highest and the lowest publication year. |

---

## 5. Testing

| # | Action | Input | Expected Result | Actual Result |
|---|---|---|---|---|
| 1 | Show entire catalog (menu `1`) | — | All books from `books.txt` are printed, numbered | |
| 2 | Show available books (menu `2`) | — | Only books with `available = true` are printed | |
| 3 | Add a book with a valid year (menu `3`) | Title, author, year = `2010`, pages = `300` | Book is appended to `books.txt` and added to the catalog | |
| 4 | Add a book with an invalid year (menu `3`) | Year = `1300` | Error message shown, book is **not** added | |
| 5 | Search by title — book exists (menu `4`) | Exact title of an existing book | That book's full details are printed | |
| 6 | Search by title — book does not exist (menu `4`) | A title not in the catalog | `"Book not found."` message | |
| 7 | Search by author with multiple matches (menu `5`) | An author with 2+ books in the catalog | All matching books are printed | |
| 8 | Search by author with no matches (menu `5`) | An author not in the catalog | `"No books found for this author."` message | |
| 9 | Filter by year range (menu `6`) | `fromY = 1900`, `toY = 2000` | Only books published strictly between 1900 and 2000 are printed | |
| 10 | Filter by invalid year range (menu `6`) | `fromY = 1000` | Validation error, no books printed | |
| 11 | Borrow an available book (menu `7`) | Valid book number, borrower name | Book marked unavailable, borrower name saved, file updated | |
| 12 | Borrow an already-borrowed book (menu `7`) | Number of a book that is already lent out | `"This book is not available"` message, no change made | |
| 13 | Borrow with an out-of-range number (menu `7`) | e.g. `999` | `"Invalid book index."` message, no crash | |
| 14 | Return a borrowed book (menu `8`) | Valid book number | Book marked available again, borrower field cleared | |
| 15 | Sort catalog by title (menu `9a`) | — | Catalog printed afterwards (e.g. via menu `1`) is in alphabetical order by title | |
| 16 | Sort catalog by year (menu `9b`) | — | Catalog is in ascending order by publication year | |
| 17 | Sort catalog by author (menu `9c`) | — | Catalog is in alphabetical order by author | |
| 18 | View statistics (menu `10`) | — | Total books, available count, average pages, oldest/newest book are all printed correctly | |
| 19 | View statistics on an empty catalog | All books removed from `books.txt` | `"No books in catalog."` instead of a crash | |
| 20 | Exit the program (menu `0`) | — | Program terminates without error | |

*(Fill in the "Actual Result" column after running each test manually.)*

---

## 6. Conclusions

[Fill in: what was learned, what was difficult, and ideas for future extensions — e.g. these are suggested talking points:]

- Working with `record` types and dynamic arrays (`array of TBook`) to model structured, growable data instead of separate parallel arrays.
- Reading and writing semicolon-separated data to a text file, and the importance of keeping the field order and separator count consistent between reading (`ExtractField`) and writing (`SaveBooksToFile`).
- Implementing Bubble Sort generically enough that the same algorithm structure works for `String` and `Integer` fields — only the comparison condition changes.
- Handling edge cases (empty catalog, invalid menu input, out-of-range indices) to avoid runtime crashes — this required adding checks that weren't part of the initial design.
- Difficulties encountered: [e.g. mixing `Read`/`ReadLn` causing leftover input in the buffer; operator precedence with `or` in boolean conditions; keeping the in-memory array and the text file in sync after every change].
- Possible extensions: binary search instead of linear search (would require keeping the catalog sorted by the search key); a more robust file format (e.g. CSV with proper escaping, or JSON); a due-date system for borrowed books; a GUI instead of a console interface.

---

## Project Structure

```
bibliothek/
├── bibliothek.pas   # Main program source
├── books.txt        # Persistent book data (semicolon-separated)
└── README.md         # This report
```

## How to Run

```bash
fpc bibliothek.pas
./bibliothek
```
