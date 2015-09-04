unit Checks;

interface

{2009
resourcestring
  PGPSignature = '-----BEGIN PGP MESSAGE-----';

function NotPGP(const File1, File2: string): Boolean;
2009}
function NotIn(const S: string; const Arr: array of string): Boolean; overload;
function NotIn(const S: string; const N1, N2: Integer): Boolean; overload;
function NotIn(const S: string; const D1, D2: TDateTime): Boolean; overload;
function NotIn(const S, Allowed: string): Boolean; overload;
function NotDigits(const S: string): Boolean;
function NotSum(const S: string): Boolean;
function NotMask(const S, Mask: string): Boolean;

implementation
uses
  Classes,
  SysUtils,
  StrUtils,
  Dialogs,
  Controls,
  {2009
  Pgp2dll,
  2009}
  Globals,
  Russian;

{2009
function NotPGP(const File1, File2: string): Boolean;
var
  F: TextFile;
  s: string;
  Pubr: string;
begin
  AssignFile(F, File1);
  Reset(F);
  Readln(F, s);
  CloseFile(F);
  if s <> PGPSignature then
    raise Exception.Create('Файл не имеет заголовка PGP!');
  Result := PGPDecodeFile(File1, File2, Pubr, SECRKEY_PGP, SECRPASS)
end;
2009}

function NotIn(const S: string; const Arr: array of string): Boolean;
var
  I: Integer;
begin
  for I := Low(Arr) to High(Arr) do
    if S = Arr[I] then
    begin
      Result := False;
      Exit;
    end;
  Result := True;
end;

function NotIn(const S: string; const N1, N2: Integer): Boolean; overload;
var
  I: Integer;
begin
  I := StrToIntDef(S, N1-1);
  Result := (I < N1) or (I > N2);
end;

function NotIn(const S: string; const D1, D2: TDateTime): Boolean; overload;
var
  D: TDateTime;
begin
  if TryStrToDate(S, D) then
    Result := (D < D1) or (D > D2)
  else
    Result := True;
end;

function NotIn(const S, Allowed: string): Boolean;
var
  I: Integer;
begin
  for I := 1 to Length(S) do
    if not AnsiContainsStr(Allowed, S[I]) then
    begin
      Result := True;
      Exit;
    end;
  Result := False;
end;

function NotDigits(const S: string): Boolean;
{var
  I: Integer;
begin
  for I := 1 to Length(S) do
    //if not TryStrToInt(S[I], SI) then
    if not AnsiContainsStr('0123456789', S[I]) then
    begin
      Result := True;
      Exit;
    end;
  Result := False;
}
begin
  Result := NotIn(S, '0123456789');
end;

function NotSum(const S: string): Boolean;
var
  I: Integer;
  T: string;
begin
  Result := True;
  T := S;
  I := Length(T);
  if I = 0 then //нет
    Exit;
  if T[1] = '0' then
    if (I <> 4) or NotIn(T[2], '.,-') then
      Exit;
  if T[1] = '-' then //отрицательная
    Exit;
  if T[I] = '-' then //без копеек
    Exit;
  if T[I] = '=' then //что-то лишнее?
  begin
    Delete(T, I, 1);
    Result := NotDigits(T);
    Exit;
  end;
  if I < 4 then //без рублей (и без =)
    Exit;
  if NotIn(T[I-2], '.,-') then //неправильный разделитель
    Exit;
  T[I-2] := '0'; //подмена разделителя
  Result := NotDigits(T);
end;

function NotMask(const S, Mask: string): Boolean;
var
  I: Integer;
begin
  Result := True;
  if Length(S) < Length(Mask) then
    Exit;
  for I := 1 to Length(Mask) do
  begin
    if Mask[I] = 'X' then
    begin
      if NotDigits(S[I]) then
        Exit;
    end
    else if S[I] <> Mask[I] then
      Exit;
  end;
  Result := False;
end;

end.
