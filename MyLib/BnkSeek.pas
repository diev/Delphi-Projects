unit BnkSeek;

interface

uses
  SysUtils, Classes;

const
  CIBBIC = '044030702';
  VER2FIELDS = 5;

type
  TDBFHeader = packed record
    VersionNumber: Byte;
    LastUpdateYear: Byte;
    LastUpdateMonth: Byte;
    LastUpdateDay: Byte;
    NumberOfRecords: LongWord;
    BytesInHeader: Word;
    BytesInRecord: Word;
    Reserved: array[1..20] of Byte;
  end;

  TBnkSeekRec = packed record
    Deleted: Byte;
    VKEY: array[1..8] of AnsiChar;
    REAL: array[1..4] of AnsiChar;
    PZN: array[1..2] of AnsiChar;
    UER: AnsiChar;
    RGN: array[1..2] of AnsiChar;
    IND: array[1..6] of AnsiChar;
    TNP: AnsiChar;
    NNP: array[1..25] of AnsiChar;
    ADR: array[1..30] of AnsiChar;
    RKC: array[1..9] of AnsiChar;
    NAMEP: array[1..45] of AnsiChar;
    NAMEN: array[1..18] of AnsiChar;
    NEWNUM: array[1..9] of AnsiChar;
    NEWKS: array[1..9] of AnsiChar;
    PERMFO: array[1..6] of AnsiChar;
    SROK: array[1..2] of AnsiChar;
    AT1: array[1..7] of AnsiChar;
    AT2: array[1..7] of AnsiChar;
    TELEF: array[1..25] of AnsiChar;
    REGN: array[1..9] of AnsiChar;
    OKPO: array[1..8] of AnsiChar;
    DT_IZM: array[1..8] of AnsiChar;
//  P: AnsiChar;
    CKS: array[1..6] of AnsiChar;
    KSNP: array[1..20] of AnsiChar;
    DATE_IN: array[1..8] of AnsiChar;
    DATE_CH: array[1..8] of AnsiChar;
    VKEYDEL: array[1..8] of AnsiChar;
  end;

  TBnkSeek2Rec = packed record
    Deleted: Byte;
    BIC: array[1..9] of AnsiChar;
    BANK: array[1..45] of AnsiChar;
    PLACE: array[1..31] of AnsiChar;
    KS: array[1..20] of AnsiChar;
    POST: AnsiChar;
  end;

  TBnkSeek = class
  private
    FBIC: string;
    FFileName: string;
    FHeader: TDBFHeader;
    FBuffer: TBnkSeekRec;
    FBuffer2: TBnkSeek2Rec;
    FFound: Boolean;
    FFound2: Boolean;
    procedure SetBIC(const Value: string);
    procedure SetFileName(const Value: string);
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
    function Found: Boolean;
    function FileUpdated: string;
    function Bank: string;
    function RKC: Boolean;
    function Place: string;
    function KS: string;
    function Post: string;
    function Delivery: string;
  published
    { Published declarations }
    property FileName: string read FFileName write SetFileName;
    property BIC: string read FBIC write SetBIC;
  end;

implementation

uses
  Russian;

{ TBnkSeek }

function TBnkSeek.Delivery: string;
begin
  if FFound then
    if Copy(CIBBIC, 1, 4) = Copy(FBIC, 1, 4) then
      Result := '' //A,B
    else if (FBuffer.UER = '1') or (FBuffer.UER = '3') then
      Result := 'Ýëåêòðîííî' //C
    else
      Result := 'Ïî÷òîé' //P
  else if FFound2 then
    if FBuffer2.POST = 'P' then
      Result := 'Ïî÷òîé'
    else if FBuffer2.POST = 'C' then
      Result := 'Ýëåêòðîííî'
    else //A,B
      Result := ''
  else //not found
    Result := '';
end;

function TBnkSeek.FileUpdated: string;
begin
  Result := Format('%02d.%02d.%02d', [FHeader.LastUpdateDay,
    FHeader.LastUpdateMonth, FHeader.LastUpdateYear]);
end;

function TBnkSeek.Found: Boolean;
begin
  Result := FFound or FFound2;
end;

function TBnkSeek.Bank: string;
begin
  if FFound then
  begin
    {
    if FBuffer.P = '+' then
      Result := ''
    else
      case StrToIntDef(FBuffer.PZN, -1) of
        0: Result := 'ÃÐÊÖ ';
        10: Result := 'ÐÊÖ ';
        20: Result := 'Á ';
        21: Result := 'ÊÁ ';
        22: Result := 'ÑÁ ';
        23: Result := 'ÀÊÁ ';
        24: Result := '×ÊÁ ';
        25: Result := 'ÊÎÏÁ ';
        26: Result := 'ÀÏÁ ';
        30: Result := 'ÔÁ ';
        31: Result := 'ÔÊÁ ';
        32: Result := 'Îòä.';
        33: Result := 'ÔÀÊÁ ';
        34: Result := 'Ô×ÊÁ ';
        35: Result := 'ÔÊÎÁ ';
        36: Result := 'Îòä.';
        40: Result := 'ÖÓ ';
        50: Result := 'ÖÕ ';
        70: Result := 'ÊÓ ';
        71: Result := 'ÊË ';
        72: Result := 'ÎÐÖÁ ';
        90: Result := 'ËÈÊÂ ';
        98: Result := 'ÈÑÊË ';
        99: Result := 'ÎÒÇÂ ';
      else
        Result := '';
      end;
    Result := Result + RWin(Trim(FBuffer.NAMEP));
    }
    Result := RWin(Trim(FBuffer.NAMEP));
  end
  else if FFound2 then
    Result := RWin(Trim(FBuffer2.BANK))
  else
    Result := '';
end;

function TBnkSeek.KS: string;
begin
  if FFound then
    Result := Trim(FBuffer.KSNP)
  else if FFound2 then
    Result := Trim(FBuffer2.KS)
  else
    Result := '';
end;

function TBnkSeek.Place: string;
begin
  if FFound then
  begin
    case StrToIntDef(FBuffer.TNP, -1) of
      1: Result := 'Ã.';
      2: Result := 'Ï.';
      3: Result := 'Ñ.';
      4: Result := 'ÏÃÒ ';
      5: Result := 'ÑÒ-ÖÀ ';
      6: Result := 'ÀÓË ';
      7: Result := 'ÐÏ ';
    else
      Result := '';
    end;
    Result := Result + RWin(Trim(FBuffer.NNP));
  end
  else if FFound2 then
    Result := RWin(Trim(FBuffer2.PLACE))
  else
    Result := '';
end;

function TBnkSeek.Post: string;
begin
  if FFound then
    if Copy(CIBBIC, 1, 6) = Copy(FBIC, 1, 6) then
      Result := 'A'
    else if Copy(CIBBIC, 1, 4) = Copy(FBIC, 1, 4) then
      Result := 'B'
    else if (FBuffer.UER = '1') or (FBuffer.UER = '3') then
      Result := 'C'
    else
      Result := 'P'
  else if FFound2 then
    Result := FBuffer2.POST
  else
    Result := 'P';
end;

function TBnkSeek.RKC: Boolean;
begin
  Result := KS = '';
end;

procedure TBnkSeek.SetBIC(const Value: string);
var
  S: TFileStream;
  I, N: Integer;
begin
  FBIC := CIBBIC;
  N := Length(CIBBIC);
  for I := Length(Value) downto 1 do
  begin
    FBIC[N] := Value[I];
    Dec(N);
  end;
  FFound := False;
  FFound2 := False;
  try
    S := TFileStream.Create(FFileName, fmOpenRead or fmShareDenyNone);
    try
      S.Read(FHeader, SizeOf(FHeader));
      S.Position := FHeader.BytesInHeader;
      I := 0;
      if (FHeader.BytesInHeader div 32 - 1) > VER2FIELDS then
        repeat
          Inc(I);
          S.Read(FBuffer, FHeader.BytesInRecord);
          FFound := FBuffer.NEWNUM = FBIC;
        until FFound or (I = FHeader.NumberOfRecords)
      else
        repeat
          Inc(I);
          S.Read(FBuffer2, FHeader.BytesInRecord);
          FFound2 := FBuffer2.BIC = FBIC;
        until FFound2 or (I = FHeader.NumberOfRecords);
    finally
      S.Free;
    end;
  except
    //File not found, etc.
  end;
end;

procedure TBnkSeek.SetFileName(const Value: string);
begin
  FFileName := Value;
  FFound := False;
  FFound2 := False;
end;

end.
