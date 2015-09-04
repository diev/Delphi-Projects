unit BankUtils;

interface
uses
  DateUtils;

resourcestring
  TABLE36 = '0123456789abcdefghijklmnopqrstuv';

function PathYMD(const UseDate: TDateTime; const Level: Integer = 3): string; overload;
function PathYMD(const IncDays: Integer = 0; const Level: Integer = 3): string; overload;

function To36(const I: Integer): string; overload;
function To36(const S: string): string; overload;
function Ot36(const S: string): Integer;

function AppendMessage(const Msg: string; FileName: string = ''): Boolean;
function AppendLogMessage(const Msg: string; const FileName: string = ''): Boolean; overload;
function AppendLogMessage(const Fmt: string; const Args: array of const; const FileName: string = ''): Boolean; overload;

function YesNoBox(const Fmt: string; const Args: array of const): Boolean;

implementation
uses
  SysUtils, Russian, Controls, Dialogs, Windows;

function PathYMD(const UseDate: TDateTime; const Level: Integer = 3): string;
var
  Y, M, D: Word;
begin
  DecodeDate(UseDate, Y, M, D);
  case Level of
  1:
    Result := Format('%.4d', [Y]);
  2:
    Result := Format('%.4d\%.2d', [Y, M]);
  else
    Result := Format('%.4d\%.2d\%.2d', [Y, M, D]);
  end;
end;

function PathYMD(const IncDays: Integer = 0; const Level: Integer = 3): string;
begin
  Result := PathYMD(IncDay(Now, IncDays), Level);
end;

function To36(const I: Integer): string; //To31 :)
begin
  Result := TABLE36[I + 1];
end;

function To36(const S: string): string; //To31 :)
begin
  Result := To36(StrToIntDef(S, 0));
end;

function Ot36(const S: string): Integer; //Ot31 :)
begin
  Result := AnsiPos(AnsiLowerCase(S), TABLE36) - 1;
end;



function AppendMessage(const Msg: string; FileName: string = ''): Boolean;
var
  TempFileName, Buf, S: string;
  F: TextFile;

  function TryAppend(const Msg, FileName: string; Count: Integer = 1): Boolean;
  var
    F: TextFile;
    I: Integer;
  begin
    I := 0;
    Result := False;
    repeat
      AssignFile(F, FileName);
      try
        if FileExists(FileName) then
          Append(F)
        else
          Rewrite(F);
        Write(F, Msg);
        Result := True;
        Flush(F);
      finally
        CloseFile(F);
      end;
      Inc(I);
      if I = Count then
        //if YesNoBox('Не удается записать в %s'#10'Пытаться ещё?', [FileName]) then
        //  I := 0
        //else
          Exit;
    until Result;
  end;

begin
  if FileName = '' then
    FileName := ChangeFileExt(ParamStr(0), '.log');

  TempFileName := ExtractFilePath(ParamStr(0)) + ExtractFileName(FileName) + '.buf';
  //TempFileName := ChangeFileExt(TempFileName, '.buf');

  if DirectoryExists(ExtractFileDir(FileName)) then
  begin
    if FileExists(TempFileName) then
    begin
      Buf := '';
      AssignFile(F, TempFileName);
      try
        Reset(F);
        while not Eof(F) do
        begin
          Readln(F, S);
          if Length(S) > 0 then
            Buf := Buf + S + #10;
        end;
      finally
        CloseFile(F);
      end;
      if Length(Buf) > 0 then
        DeleteFile(PAnsiChar(TempFileName));
    end;
    Result := TryAppend(Buf + Msg, FileName);
  end
  else
  begin
    Result := TryAppend(Msg, TempFileName);
  end;

  {
  Result := False;
  if FileExists(FileName) then
    F := FileOpen(FileName, fmOpenWrite or fmShareDenyNone)
  else
    F := FileCreate(FileName, fmOpenWrite or fmShareDenyNone);
  if F > -1 then
  begin
    I := FileSeek(F, 0, 2);
    if I > -1 then
    begin
      I := FileWrite(F, Msg, Length(Msg));
      Result := (I = Length(Msg));
    end;
  end;
  FileClose(F);
  }
end;

function AppendLogMessage(const Msg: string; const FileName: string = ''): Boolean;
var
  S: string;
begin
  S := FormatDateTime('dd.mm hh:nn ', Now) +
  {$IFDEF DEBUG}
    'DEBUG ' +
  {$ENDIF}
  RDos(Msg);
  //Writeln(S);
  Result := AppendMessage(S + #13#10, FileName);
end;

function AppendLogMessage(const Fmt: string; const Args: array of const; const FileName: string = ''): Boolean;
begin
  Result := AppendLogMessage(Format(Fmt, Args), FileName);
end;

function YesNoBox(const Fmt: string; const Args: array of const): Boolean;
begin
  Result := IsPositiveResult(MessageDlg(Format(Fmt, Args),
              mtConfirmation, [mbYes, mbNo], 0));
end;

end.
