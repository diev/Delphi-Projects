unit CustomBlank;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Printers, ExtCtrls;

type
  TCustomBlank = class
  private
    { Private declarations }
    FMetaFile: TMetaFile;
    FMetafileCanvas: TMetafileCanvas;
    FPixelsPerInchX: Integer;
    FPixelsPerInchY: Integer;
    FTopMargin: Integer;
    FLeftMargin: Integer;
    FHeight: Integer;
    FWidth: Integer;
    function GetFont: TFont;
    procedure SetFont(const Value: TFont);
  protected
    { Protected declarations }
    function GetCanvas: TCanvas;
  public
    { Public declarations }
    function xm(x: Integer): Integer;
    function ym(y: Integer): Integer;
    procedure ResetFont(Name: string = ''; Size: Integer = 0;
      Style: string = '');
    procedure FL(x, y, x2, y2: Integer);
    procedure RL(x, y, x2, y2: Integer);
    procedure HL(x, y, x2: Integer);
    procedure VL(x, y, y2: Integer);
    procedure TL(x, y: Integer; S: string); overload;
    procedure TL(x, y, x2: Integer; S: string); overload;
    procedure TC(x, y, x2: Integer; S: string);
    procedure TB(x, y, x2, y2: Integer; S: string);
    procedure TV(x, y, x2, y2: Integer; S: string);
    procedure BeginScreenDoc;
    procedure BeginPrinterDoc;
    procedure EndDoc;
    procedure DrawPrinterPage;
    procedure Preview;
    procedure Print(NumCopies: Integer = 1; const DocTitle: string = 'Бланк');
    procedure DrawRulers;
    procedure SaveImage(const FileName: string);
    constructor Create; virtual;
    destructor Destroy; override;
    property Canvas: TCanvas read GetCanvas;
    property Font: TFont read GetFont write SetFont;
    property TopMargin: Integer read FTopMargin write FTopMargin;
    property LeftMargin: Integer read FLeftMargin write FLeftMargin;
    property Width: Integer read FWidth write FWidth;
    property Height: Integer read FHeight write FHeight;
  published
    { Published declarations }
  end;

implementation

uses
  PreviewUnit, Math;

{ TCustomBlank }

constructor TCustomBlank.Create;
begin
  FPixelsPerInchX := Screen.PixelsPerInch;
  FPixelsPerInchY := Screen.PixelsPerInch;

  //A4(mm)
  FLeftMargin := 20;
  FTopMargin := 15;
  FWidth := 210;
  FHeight := 297;
end;

destructor TCustomBlank.Destroy;
begin
  FMetafileCanvas.Free;
  FMetaFile.Free;
  inherited Destroy;
end;

procedure TCustomBlank.BeginScreenDoc;
begin
  FPixelsPerInchX := Screen.PixelsPerInch;
  FPixelsPerInchY := Screen.PixelsPerInch;

  FMetaFile.Free;
  FMetaFile := TMetaFile.Create;
  with FMetaFile do
  begin
    Height := MulDiv(FHeight, FPixelsPerInchX * 10, 254);
    Width := MulDiv(FWidth, FPixelsPerInchY * 10, 254);
  end;

  FMetafileCanvas.Free;
  FMetafileCanvas := TMetafileCanvas.Create(FMetaFile, 0);
  with FMetafileCanvas do
  begin
    Font.Name := 'Times New Roman';
    Font.Size := 8;
    Font.Charset := RUSSIAN_CHARSET;
    Pen.Width := 1;
  end;
end;

procedure TCustomBlank.BeginPrinterDoc;
begin
  FPixelsPerInchX := GetDeviceCaps(Printer.Handle, LOGPIXELSX);
  FPixelsPerInchY := GetDeviceCaps(Printer.Handle, LOGPIXELSY);

  FMetaFile.Free;
  FMetaFile := TMetaFile.Create;
  with FMetaFile do
  begin
    Height := MulDiv(FHeight, FPixelsPerInchX * 10, 254);
    Width := MulDiv(FWidth, FPixelsPerInchY * 10, 254);
  end;

  FMetafileCanvas.Free;
  FMetafileCanvas := TMetafileCanvas.Create(FMetaFile, Printer.Handle);
  with FMetafileCanvas do
  begin
    Font.Name := 'Times New Roman';
    Font.Size := 8;
    Font.Charset := RUSSIAN_CHARSET;
    if FPixelsPerInchY <> Screen.PixelsPerInch then
      Font.Size := Round(Font.Size * FPixelsPerInchY / Screen.PixelsPerInch);
    Pen.Width := 1 + FPixelsPerInchY div 300;
  end;
end;

procedure TCustomBlank.EndDoc;
begin
  FMetafileCanvas.Free;
  FMetafileCanvas := nil;
end;

function TCustomBlank.xm(x: Integer): Integer;
begin
  Result := MulDiv(x, FPixelsPerInchX * 10, 254);
end;

function TCustomBlank.ym(y: Integer): Integer;
begin
  if y < 0 then
  begin
    y := -y;
    Result := MulDiv(y, FPixelsPerInchY * 10, 254) -
      FMetafileCanvas.TextHeight('W');
  end
  else
    Result := MulDiv(y, FPixelsPerInchY * 10, 254);
end;

procedure TCustomBlank.HL(x, y, x2: Integer);
begin
  with FMetafileCanvas do
  begin
    y := ym(y);
    MoveTo(xm(x), y);
    LineTo(xm(x2), y);
  end;
end;

procedure TCustomBlank.RL(x, y, x2, y2: Integer);
begin
  with FMetafileCanvas do
  begin
    //Rectangle(xm(x), ym(y), xm(x2), ym(y2));
    x := xm(x); x2 := xm(x2);
    y := ym(y); y2 := ym(y2);
    MoveTo(x, y);
    LineTo(x2,y);
    LineTo(x2,y2);
    LineTo(x, y2);
    LineTo(x, y);
  end;
end;

procedure TCustomBlank.TB(x, y, x2, y2: Integer; S: string);
var
  R: TRect;
begin
  R := Rect(xm(x), ym(y), xm(x2), ym(y2));
  DrawText(FMetafileCanvas.Handle, PChar(S), Length(S), R,
    DT_LEFT or DT_NOPREFIX or DT_WORDBREAK);
end;

procedure TCustomBlank.TV(x, y, x2, y2: Integer; S: string);
var
  R: TRect;
begin
  R := Rect(xm(x), ym(y), xm(x2), ym(y2));
  DrawText(FMetafileCanvas.Handle, PChar(S), Length(S), R,
    DT_CENTER or DT_VCENTER or DT_NOPREFIX or DT_SINGLELINE);
end;

procedure TCustomBlank.TL(x, y: Integer; S: string);
begin
  FMetafileCanvas.TextOut(xm(x), ym(y), S);
end;

procedure TCustomBlank.TL(x, y, x2: Integer; S: string);
var
  R: TRect;
begin
  with FMetafileCanvas do
  begin
    R.Top := ym(y);
    R.Left := xm(x);
    R.Bottom := R.Top + TextHeight(S);
    R.Right := xm(x2);
    TextRect(R, R.Left, R.Top, S);
  end;
end;

procedure TCustomBlank.TC(x, y, x2: Integer; S: string);
begin
  with FMetafileCanvas do
  begin
    x := xm(x);
    Inc(x, (xm(x2) - x - TextWidth(S)) div 2);
    TextOut(x, ym(y), S);
  end;
end;

procedure TCustomBlank.VL(x, y, y2: Integer);
begin
  with FMetafileCanvas do
  begin
    x := xm(x);
    MoveTo(x, ym(y));
    LineTo(x, ym(y2));
  end;
end;

procedure TCustomBlank.FL(x, y, x2, y2: Integer);
begin
  with FMetafileCanvas do
  begin
    MoveTo(xm(x), ym(y));
    LineTo(xm(x2), ym(y2));
  end;
end;

procedure TCustomBlank.Preview;
var
  Form: TPreviewForm;
begin
  Form := TPreviewForm.Create(Application);
  try
    Form.ScrollBox.DisableAutoRange;
    with Form.Image do
    begin
      SetBounds(2, 2, FMetaFile.Width, FMetaFile.Height);
      Form.Bevel.SetBounds(Left, Top, Width + 2, Height + 2);
      Canvas.Draw(xm(LeftMargin), ym(TopMargin), FMetaFile);
      //Form.ScrollBox.VertScrollBar.Range := Form.Image.Height;
    end;
    Form.ScrollBox.EnableAutoRange;
    with Form do
    begin
      Height := Min(Form.Image.Height + 40, Screen.Height - 40);
      Width := Min(Form.Image.Width + 40, Screen.Width - 40);
      //Left := (Screen.Width - Width - 40) div 2;
      //Top := (Screen.Height - Height - 40) div 2;
      ShowModal;
    end;
  finally
    Form.Free;
  end;
end;

procedure TCustomBlank.Print(NumCopies: Integer = 1; const DocTitle: string = 'Бланк');
begin
  Printer.Title := DocTitle;
  Printer.BeginDoc;
  while NumCopies > 0 do
  begin
    DrawPrinterPage;
    Dec(NumCopies);
    if NumCopies > 0 then
      Printer.NewPage;
  end;
  Printer.EndDoc;
end;

procedure TCustomBlank.DrawRulers;
var
  I: Integer;
begin
  with FMetafileCanvas do
  begin
    HL(0, 0, FWidth);
    VL(0, 0, FHeight);
    for I := 1 to (FWidth div 10) do
    begin
      VL(I * 10 - 5, 0, 1);
      VL(I * 10, 0, 3);
      TL(I * 10, 3, IntToStr(I));
    end;
    for I := 1 to (FHeight div 10) do
    begin
      HL(0, I * 10 - 5, 1);
      HL(0, I * 10, 3);
      TL(3, I * 10, IntToStr(I));
    end;
  end;
end;

function TCustomBlank.GetCanvas: TCanvas;
begin
  Result := FMetafileCanvas;
end;

procedure TCustomBlank.DrawPrinterPage;
var
  X, Y: Integer;
begin
  X := xm(FLeftMargin);
  Y := ym(FTopMargin);
  Dec(X, GetDeviceCaps(Printer.Handle, PHYSICALOFFSETX));
  Dec(Y, GetDeviceCaps(Printer.Handle, PHYSICALOFFSETY));
  Printer.Canvas.Draw(X, Y, FMetaFile);
end;

function TCustomBlank.GetFont: TFont;
var
  Font: TFont;
begin
  Font := TFont.Create;
  try
    Font.Assign(FMetafileCanvas.Font);
    if FPixelsPerInchY <> Screen.PixelsPerInch then
      Font.Size := Round(Result.Size * Screen.PixelsPerInch / FPixelsPerInchY);
    Result.Assign(Font);
  finally
    Font.Free;
  end;
end;

procedure TCustomBlank.SetFont(const Value: TFont);
begin
  with FMetafileCanvas.Font do
  begin
    Assign(Value);
    if FPixelsPerInchY <> Screen.PixelsPerInch then
      Size := Round(Size * FPixelsPerInchY / Screen.PixelsPerInch);
  end;
end;

procedure TCustomBlank.ResetFont(Name: string = ''; Size: Integer = 0;
  Style: string = '');
begin
  with FMetafileCanvas do
  begin
    if Name <> '' then
      try
        Font.Name := Name;
      except
        ;
      end;

    if Size > 0 then
    begin
      Font.Size := Size;
      if FPixelsPerInchY <> Screen.PixelsPerInch then
        Font.Size := Round(Font.Size * FPixelsPerInchY / Screen.PixelsPerInch);
    end;

    if Style <> '' then
    begin
      if Pos('N', Style) > 0 then
        Font.Style := [];
      if Pos('B', Style) > 0 then
        Font.Style := Font.Style + [fsBold];
      if Pos('I', Style) > 0 then
        Font.Style := Font.Style + [fsItalic];
      if Pos('U', Style) > 0 then
        Font.Style := Font.Style + [fsUnderline];
    end;
    Font.Charset := RUSSIAN_CHARSET;
  end;
end;

procedure TCustomBlank.SaveImage(const FileName: string);
var
  Img: TBitmap;
begin
  Img := TBitmap.Create;
  try
    Img.PixelFormat := pf1bit;
    Img.Height := FMetaFile.Height;
    Img.Width := FMetaFile.Width;
    Img.Canvas.Draw(xm(FLeftMargin),ym(FTopMargin),FMetaFile);
    Img.SaveToFile(FileName + '.bmp');
//    FMetaFile.Height :=
//    FMetaFile.Width :=
    FMetaFile.SaveToFile(FileName + '.emf');
  finally
    Img.Free;
  end;
end;

end.
