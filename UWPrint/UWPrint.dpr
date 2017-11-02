program UWPrint;
{version of:
2010-10-05 +no stop on errors - just loging
2010-09-28 +specified Printers, not default only
}

{$APPTYPE CONSOLE}

uses
  Printers,
  Classes,
  SysUtils,
  StrUtils,
  Russian,
  BankUtils;

{$R *.RES}

const
  Ej = '- - - - - - - - ';

var
  FileName: AnsiString;
  F: TextFile;
  S: AnsiString;

  i: Integer;

  TopMargin: Integer = 0;
  LeftMargin: Integer = 0; //8
  FontSize: Integer = 8; //10

function PrintersInfo: AnsiString;
var
  i: Integer;
begin
  Result := 'Программа видит следующие принтеры (* - по умолчанию):'#13#10#13#10;
  for i := 0 to Printer.Printers.Count - 1 do
  begin
    if (i = Printer.PrinterIndex) then
      Result := Result + Format('%3u* "%s"', [i, Printer.Printers[i]]) + #13#10
    else
      Result := Result + Format('%3u  "%s"', [i, Printer.Printers[i]]) + #13#10;
  end;
  RWinToDos(Result);
end;

procedure ExitInfo(s: AnsiString = '');
begin
  Writeln(RDos('Unix-Windows Print - программа графической печати текстов из Банкира'));
  Writeln(RDos('В качестве параметра требует имя файла для печати'));
  Writeln(RDos('Вторым параметром может быть указан принтер (номер или имя в 866!)'));
  Writeln;
  if Length(s) > 0 then
  begin
    Writeln(RDos('ОШИБКА:'));
    Writeln(RDos(s));
    Writeln;
  end;
  Writeln(PrintersInfo);
  Writeln;
  //Writeln(RDos('Нажмите Enter для выхода'));
  //Readln;
  Halt(0);
end;

procedure LinePrint(s: AnsiString = '');
var
  x, y, y1, i: Integer;
begin
  with Printer do
  begin
    x := LeftMargin * Canvas.TextWidth('W');
    y := Canvas.PenPos.Y;
    y1 := Canvas.TextHeight('W');
    i := Pos(#12, s);

    if (y + y1) > PageHeight then
    begin
      NewPage;
      y := TopMargin * y1;
    end;

    if i = 0 then
      Canvas.TextOut(x, y, TrimRight(s))
    else
    begin
      if i > 1 then
        Canvas.TextOut(x, y, TrimRight(AnsiLeftStr(s, i-1)));
      NewPage;
      y := TopMargin * y1;
      if i < Length(s) then
        Canvas.TextOut(x, y, TrimRight(AnsiMidStr(s, i+1, Length(s))));
    end;

    Canvas.PenPos := Point(0, y + y1);
  end;
end;

begin
  if (ParamCount < 1) or
     FindCmdLineSwitch('?') or
     FindCmdLineSwitch('h') then
    ExitInfo();

  if Printer.Printers.Count = 0 then
  begin
    AppendLogMessage('Нет установленных принтеров!');
    Halt(1);
  end;

  FileName := ParamStr(1);
  if not FileExists(FileName) then
  begin
    AppendLogMessage('Нет такого файла %s', [FileName]);
    Halt(2);
  end;

  if (ParamCount = 2) then
  begin
    //Printer.SetPrinter(ParamStr(2));
    S := ParamStr(2);
    if TryStrToInt(S, i) then
    begin
      if (i > -1) and (i < Printer.Printers.Count) then
        Printer.PrinterIndex := i
      else
      begin
        AppendLogMessage('Нет принтера с номером %s', [S]);
        Halt(3);
      end;
    end
    else
    begin
      i := Printer.Printers.IndexOf(S);
      if i = -1 then
      begin
        AppendLogMessage('Нет принтера с именем (в 866) "%s"', [S]);
        Halt(4);
      end;
      Printer.PrinterIndex := i;
    end;
  end;

  AssignFile(F, FileName);
  //SetLineBreakStyle(F, tlbsLF);
  Reset(F);
  //Readln(F, S);
  {if AnsiEndsStr(#13, S) then
  begin
    CloseFile(F);
    SetLineBreakStyle(F, tlbsCRLF);
    Reset(F);
  end;}

  with Printer do
  begin
    //Orientation := poLandscape;
    Orientation := poPortrait;
    Title := 'UWPrint - ' + FileName;
    BeginDoc;

    Canvas.Font.Name := 'Courier New';
    Canvas.Font.Charset := 204; //RUSSIAN_CHARSET;
    Canvas.Font.Size := FontSize;

    while not EOF(F) do
    begin
      Readln(F, S);
      S := AnsiReplaceStr(S, '$$', #12);
      if AnsiStartsStr(Ej, s) then
        S := #12
      else if AnsiStartsStr(#27'M', S) then
        S := AnsiMidStr(S, 2, Length(S));
      LinePrint(RWin(S));
    end;
    EndDoc;
  end;
  CloseFile(F);
end.

