unit BankDBF;

interface

uses
  SysUtils, Classes;

type
  TDBFLastUpdate = packed record
    Year: Byte;
    Month: Byte;
    Day: Byte;
  end;

  TDBFHeader = packed record
    VersionNumber: Byte;
    LastUpdate: TDBFLastUpdate;
    RecordCount: LongWord;
    HeaderSize: Word;
    RecordSize: Word;
    Resrv1: Word;
    Transaction: Byte;
    Encrypted: Byte;
    MultiUserEnv: array[0..11] of Byte;
    Indexed: Byte;
    LangDriver: Byte;
    Reserv2: Word;
  end;

  TDBFField = packed record
    FieldName: array[0..10] of AnsiChar;
    FieldType: AnsiChar;
    Addr: LongWord;
    Width: Byte;
    Decimals: Byte;
    Reserv1: Word;
    WorkAreaID: Byte;
    MultiUser: Word;
    SetFields: Byte;
    Reserv2: array[0..6] of Byte;
    MDXIndex: Byte;
  end;

  TBankDBFReader = class
  private
    FRecNo: Integer;
    procedure SetRecNo(const Value: Integer);
  protected
    FStream: TFileStream;
    FDBFHeader: TDBFHeader;
    FDBFFields: array of TDBFField;
    FFields: TStrings;
    FRecBuffer: PChar;
  public
    constructor Create(const FileName: string); overload;
    destructor Destroy; override;
    function LastUpdated: string;
    function RecCount: Integer;
    function RecSize: Integer;
    property RecNo: Integer read FRecNo write SetRecNo;
    function EOF: Boolean;
    procedure GotoNext;
    function FindRec(const Field, FindValue: string): Boolean;
    function FieldCount: Integer;
    function Value(const Field: string): string;
  end;

implementation

uses
  Windows, StrUtils;

{ TBankDBFReader }

constructor TBankDBFReader.Create(const FileName: string);
var
  I, Pos: Integer;
  S: string;
begin
  inherited Create;
  FStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  FFields := TStringList.Create;
  FStream.Read(FDBFHeader, 32);
  SetLength(FDBFFields, FieldCount);
  Pos := 2; //Skip Deleted Byte;
  for I := 0 to FieldCount-1 do
  begin
    FStream.Read(FDBFFields[I], 32);
    with FDBFFields[I] do
    begin
      Addr := Pos;
      Inc(Pos, Width);
      S := AnsiLeftStr(FieldName, StrLen(@FieldName[0]));
      FFields.Append(S);
    end;
  end;
  GetMem(FRecBuffer, RecSize);
  RecNo := 1;
end;

destructor TBankDBFReader.Destroy;
begin
  FStream.Free;
  FFields.Free;
  FreeMem(FRecBuffer);
  inherited;
end;

function TBankDBFReader.EOF: Boolean;
begin
  Result := (RecNo > RecCount);
end;

function TBankDBFReader.FieldCount: Integer;
begin
  Result := FDBFHeader.HeaderSize div 32 - 1;
end;

function TBankDBFReader.FindRec(const Field, FindValue: string): Boolean;
var
  I, FieldSize: Integer;
  FieldBuffer: PChar;
begin
  Result := False;
  I := FFields.IndexOf(Field);
  if I = -1 then
    Exit;
  FieldSize := FDBFFields[I].Width;
  try
    GetMem(FieldBuffer, FieldSize);
    with FStream do
      try
        Position := FDBFHeader.HeaderSize + FDBFFields[I].Addr - 1; /////////-1?
        for I := 1 to RecCount do
        begin
          ReadBuffer(FieldBuffer^, FieldSize);
          //OemToAnsiBuff(FieldBuffer, FieldBuffer, FieldSize);
          if AnsiContainsText(FieldBuffer, FindValue) then
          begin
            Result := True;
            RecNo := I;
            Break;
          end;
          Position := Position + (RecSize - FieldSize);
        end;
      except on EReadError do
        //Result := False;
      end;
  finally
    FreeMem(FieldBuffer);
  end;
end;

procedure TBankDBFReader.GotoNext;
begin
  RecNo := RecNo + 1;
end;

function TBankDBFReader.LastUpdated: string;
begin
  with FDBFHeader.LastUpdate do
    Result := Format('%02d.%02d.%02d', [Day, Month, Year]);
end;

function TBankDBFReader.RecCount: Integer;
begin
  Result := FDBFHeader.RecordCount;
end;

function TBankDBFReader.RecSize: Integer;
begin
  Result := FDBFHeader.RecordSize;
end;

procedure TBankDBFReader.SetRecNo(const Value: Integer);
begin
  if (Value > 0) and (Value <= RecCount) then
  begin
    FRecNo := Value;
    try
      FStream.Position := FDBFHeader.HeaderSize + RecSize * (FRecNo - 1);
      FStream.ReadBuffer(FRecBuffer^, RecSize);
      OemToAnsiBuff(FRecBuffer, FRecBuffer, RecSize);
    except on EReadError do
      Exception.CreateFmt('Ошибка чтения файла DBF, запись #%d!', [FRecNo]);
    end;
  end
  else
  begin
    FRecNo := RecCount + 1;
  end;
end;

function TBankDBFReader.Value(const Field: string): string;
var
  I: Integer;
begin
  I := FFields.IndexOf(Field);
  if I > -1 then
    with FDBFFields[I] do
      Result := Trim(AnsiMidStr(FRecBuffer, Addr, Width))
  else
    Result := '';
end;

end.
