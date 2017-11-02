program UWin;

{$APPTYPE CONSOLE}

uses
  SysUtils;

var
  f1, f2: Text;
  s: string;

begin
  if ParamCount = 0 then
  begin
    Writeln('No source file given to convert!');
    Halt(1);
  end;

  if not FileExists(ParamStr(1)) then
  begin
    Writeln('No such file exists!');
    Halt(2);
  end;

  if ParamCount = 1 then
  begin
    s := ChangeFileExt(ParamStr(1), '.BAK');
    RenameFile(ParamStr(1), s);
    AssignFile(f1, s);
    AssignFile(f2, ParamStr(1));
  end
  else
  begin
    s := ParamStr(2);
    if DirectoryExists(s) then
      s := IncludeTrailingPathDelimiter(s) +
        ExtractFileName(ParamStr(1));
    AssignFile(f1, ParamStr(1));
    AssignFile(f2, s);
  end;

  try
    Reset(f1);
    Rewrite(f2);
    while not Eof(f1) do
    begin
      ReadLn(f1, s);
      WriteLn(f2, RWin(TrimRight(s)));
    end;
  finally
    CloseFile(f1);
    CloseFile(f2);
  end;

  if ParamCount = 1 then
    DeleteFile(ChangeFileExt(ParamStr(1), '.BAK'))
  else
    DeleteFile(ParamStr(1));
  Halt(0);
end.
