unit LogUnit;

interface
uses
  Windows, SysUtils, Classes;

  procedure Log(s: AnsiString);

implementation

procedure Log(s: AnsiString);
const
  FileName: AnsiString = 'PingDown.log';
var
  F: TextFile;
begin
  AssignFile(F, FileName);
  if FileExists(FileName) then
    Append(F)
  else
    Rewrite(F);
  Writeln(F, DateTimeToStr(Now) + ' ' + s);
  CloseFile(F);
end;

end.
