program Bibliothek;
{$mode objfpc}

Uses sysutils;

type
  TBook = record       
    title: String;        
    author: String;      
    year: Integer;       
    pages: Integer;    
    available: Boolean; 
    borrower: String;   
    
  end;
    TBooks = array of TBook;  

var
    title: String;
    line: String;
    books: array of TBook;
    bookInfo: TextFile;
    menu, yearBookFrom, yearBookTo: Integer;
    index: Integer;
    borrower: String;

function ExtractField(var line: String): String; {read line from books.txt and give it to books array}
var
semiColPosition: Integer;
begin
    semiColPosition := Pos(';', line); {read position where is ; in line}
    ExtractField := Copy(line, 1, semiColPosition - 1); {copy word from 1 letter to semi colon position}
    Delete(line, 1, semiColPosition); {delete this word}
end;

procedure SaveBooksToFile(books: TBooks);
var 
  availStr: String;
  i: Integer;
begin
for i := 0 to Length(books) - 1 do
      begin
        if books[i].available then
        availStr := '1'
        else
        availStr := '0';

        WriteLn(bookInfo, books[i].title, ';', books[i].author, ';', books[i].year, ';', books[i].pages, ';', availStr, ';', books[i].borrower,';');
      end;
end;

{ Введення даних }
procedure AddBook(var TxtFile: TextFile; var books: TBooks);
var 
title, author: String;
year, pages: Integer;
begin
  WriteLn('Please write the title of the book: ');  
  ReadLn(title);
  WriteLn('Please write the author of the book: ');  
  ReadLn(author);
  WriteLn('Please write the year of the book: ');  
  ReadLn(year);
  if (year < 1450) or (year > 2026) then
    begin
      WriteLn('The year of the book must be between 1450 and 2026. Please try again.');
      Exit;
    end;
  WriteLn('Please write how many pages of the book: ');  
  ReadLn(pages);  

  Append(TxtFile);
  WriteLn(TxtFile, title, ';', author, ';', year, ';', pages, ';1;;');
  CloseFile(TxtFile);

  SetLength(books, (Length(books) + 1));
    books[Length(books) - 1].title := title; 
    books[Length(books) - 1].author := author;
    books[Length(books) - 1].year := year;
    books[Length(books) - 1].pages := pages;
    books[Length(books) - 1].available := true;
    books[Length(books) - 1].borrower := '';
end;

procedure PrintBook(books: TBooks; index: Integer);
begin
      WriteLn;
      WriteLn('The title of the book: ', books[index].title);
      WriteLn('The author of the book: ', books[index].author);
      WriteLn('The year of the book: ', books[index].year);
      WriteLn('The pages of the book: ', books[index].pages);

      if not books[index].available then
        begin
          WriteLn('Sorry! We don''t have this book, it was taken by: ', books[index].borrower);
        end
      else
        begin
          WriteLn('This book is avaible!');
        end;
      WriteLn;
end;

procedure PrintCatalog(books: array of TBook); {for showing array}
var i: Integer;
begin
  for i := 0 to Length(books) - 1 do
    begin
      WriteLn;
      Write(i + 1, ': ');
      WriteLn('The title of the book: ', books[i].title);
      WriteLn('The author of the book: ', books[i].author);
      WriteLn('The year of the book: ', books[i].year);
      WriteLn('The pages of the book: ', books[i].pages);

      if not books[i].available then
        begin
          WriteLn('Sorry! We don''t have this book, it was taken by: ', books[i].borrower);
        end
      else
        begin
          WriteLn('This book is avaible!');
        end;
      WriteLn;
    end;
end;

procedure PrintAvailable(books: TBooks);
var i: Integer;
begin
  for i := 0 to Length(books) - 1 do
    begin
      if books[i].available then 
        PrintBook(books, i);
    end;
end;

function FindByTitle(books: array of TBook; query: String): Integer;
var i: Integer;
begin
  for i := 0 to Length(books) - 1 do
    begin
      if books[i].title = query then
        begin
          FindByTitle := i;
          Exit;
        end
      else
        begin
          FindByTitle := -1;
        end;
    end;
end;

procedure SearchByAuthor(books: array of TBook; query: String);
var i: Integer;
    found: Boolean;
begin
  found := false;
  for i := 0 to Length(books) - 1 do
    if books[i].author = query then
      begin
        PrintBook(books, i);
        found := true;
      end;
  if not found then
    WriteLn('No books found for this author.');
end;

procedure FilterByYear(books: TBooks; fromY, toY: Integer);
var i: Integer;
begin
  if (fromY < 1450) or (toY > 2026) then
    begin
      WriteLn('The year of the book must be between 1450 and 2026. Please try again.');
      Exit;
    end;
  for i := 0 to Length(books) - 1 do
    if (books[i].year > fromY) and (books[i].year < toY) then
      PrintBook(books, i);
end;

procedure BorrowBook(var books: TBooks; index: Integer; borrower: String);
begin
if (index < 0) or (index >= Length(books)) then
  begin
    WriteLn('Invalid book index.');
    Exit;
  end;
if books[index].available then 
  begin
    books[index].available := false;
    books[index].borrower := borrower;
    WriteLn('You have successfully borrowed the book: ', books[index].title);
  end
  else
    begin
      WriteLn('Sorry! This book is not available. It was taken by: ', books[index].borrower);
      Exit;
    end;

  Rewrite(bookInfo);
  SaveBooksToFile(books);
  CloseFile(bookInfo);
end;

procedure ReturnBook(var books: TBooks; index: Integer);
begin
  if (index < 0) or (index >= Length(books)) then
    begin
      WriteLn('Invalid book index.');
      Exit;
    end;
  books[index].available := true;
  books[index].borrower := '';

  Rewrite(bookInfo);
  SaveBooksToFile(books);
  CloseFile(bookInfo);
end;

procedure SortByTitle(var books: TBooks);
var
  i, j: Integer;
  temp: TBook;
begin
  for i := 0 to Length(books) - 2 do
    for j := i + 1 to Length(books) - 1 do
      if books[i].title > books[j].title then
      begin
        temp := books[i];
        books[i] := books[j];
        books[j] := temp;
      end;
end; 

procedure SortByYear(var books: TBooks);
var
  i, j: Integer;
  temp: TBook;
begin
  for i := 0 to Length(books) - 2 do
    for j := i + 1 to Length(books) - 1 do
      if books[i].year > books[j].year then
      begin
        temp := books[i];
        books[i] := books[j];
        books[j] := temp;
      end;
end; 

procedure SortByAuthor(var books: TBooks);
var
  i, j: Integer;
  temp: TBook;
begin
  for i := 0 to Length(books) - 2 do
    for j := i + 1 to Length(books) - 1 do
      if books[i].author > books[j].author then
      begin
        temp := books[i];
        books[i] := books[j];
        books[j] := temp;
      end;
end; 

procedure AveragePages(var books: TBooks);
var
  i: Integer;
  totalPages: Integer;
begin
  totalPages := 0;
  if Length(books) = 0 then 
    WriteLn('No books in catalog.') 
  else
  begin
    for i := 0 to Length(books) - 1 do
      totalPages := totalPages + books[i].pages; 

      totalPages := totalPages div Length(books);
      WriteLn('Average number of pages per book: ', totalPages);
  end;
end;

function CountAvailable(books: TBooks): Integer;
var
  i: Integer;
  count: Integer;
begin
  count := 0;
  for i := 0 to Length(books) - 1 do
    if books[i].available then
      count := count + 1;
  CountAvailable := count;
end;

procedure NewestOldestBook(var books: TBooks);
var
  i: Integer;
  newest, oldest: Integer;
begin
  if Length(books) = 0 then
    WriteLn('No books in catalog.')
  else
    begin
      newest := 0;
      oldest := 0;
      for i := 1 to Length(books) - 1 do
        begin
          if books[i].year > books[newest].year then
            newest := i;
          if books[i].year < books[oldest].year then
            oldest := i;
        end;

      WriteLn('The newest book in the catalog:');
      PrintBook(books, newest);
      WriteLn('The oldest book in the catalog:');
      PrintBook(books, oldest);
    end;
end;

{========================================}

begin
    SetLength(books, 0);
    Assign(bookInfo, 'books.txt');
    Reset(bookInfo);
    While not Eof(bookInfo) do {read the books.txt and write it ti array}
    begin
      SetLength(books, (Length(books) + 1));
      ReadLn(bookInfo, line); 
      books[Length(books) - 1].title := ExtractField(line); 
      books[Length(books) - 1].author := ExtractField(line);
      books[Length(books) - 1].year := StrToInt(ExtractField(line));
      books[Length(books) - 1].pages := StrToInt(ExtractField(line));
      books[Length(books) - 1].available := (ExtractField(line) = '1');
      books[Length(books) - 1].borrower := ExtractField(line);
    end;
    CloseFile(bookInfo);

    repeat
      WriteLn;
      WriteLn('======================================');
      WriteLn('        Library System  v1.0          ');
      WriteLn('======================================');
      WriteLn;
      WriteLn('1. Show the entire catalog');
      WriteLn('2. Show available books');
      WriteLn('3. Add a book');
      WriteLn('4. Search by title');
      WriteLn('5. Search by author');
      WriteLn('6. Filter by year');
      WriteLn('7. Check out a book to a reader');
      WriteLn('8. Accept a return');
      WriteLn('9. Sort the catalog');
      WriteLn('   a. By title');
      WriteLn('   b. By year');
      WriteLn('   c. By author');
  
      WriteLn('0. Log out');
      WriteLn;
      WriteLn('Selection: ');
      ReadLn(menu);

      Case menu of
      1: PrintCatalog(books);
      2:  begin
            WriteLn('There is all of the books available!');
            PrintAvailable(books);
          end;
      3: AddBook(bookInfo, books);
      4:  begin
            WriteLn('Pleate enter the title:');
            ReadLn(title);
            index := FindByTitle(books, title);
            if index = -1 then
              WriteLn('Book not found.')
            else
              PrintBook(books, index);
            end;
      5: begin
            WriteLn('Pleate enter the author:');
            ReadLn(title);
            SearchByAuthor(books, title);
          end;
      6:  begin
            WriteLn(' Please enter the start publication years : ');
            Read(yearBookFrom);
            WriteLn(' Please enter the end publication years : ');
            Read(yearBookTo);
            FilterByYear(books, yearBookFrom, yearBookTo);
          end;
      7:  begin
            PrintAvailable(books);
            WriteLn('Please enter the number of the book you want to borrow:');
            ReadLn(index);
            WriteLn('Please enter your name:');
            ReadLn(borrower);
            BorrowBook(books, index - 1, borrower);
          end;
      8: begin
            WriteLn('Please enter the number of the book you want to return:');
            Read(index);
            ReturnBook(books, index - 1);
          end;
      9:  begin
            WriteLn('Please choose how to sort the catalog:');
            WriteLn('a. By title');
            WriteLn('b. By year');
            WriteLn('c. By author');
            ReadLn(title);
            if title = 'a' then
              SortByTitle(books)
            else if title = 'b' then
              SortByYear(books)
            else if title = 'c' then
              SortByAuthor(books)
            else
              WriteLn('Invalid option.');
          end;

      10: begin
            WriteLn('Statistics:');
            WriteLn('Total number of books: ', Length(books));
            WriteLn('Total number of available books: ', CountAvailable(books));
            WriteLn;
            AveragePages(books);
            NewestOldestBook(books);
          end;
      0:;
      end;

    until false;
end.