unit PlatBlank;

interface

uses
  Windows, Messages, SysUtils, StrUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IniFiles, Printers, ExtCtrls, CustomBlank;

const
  Title = 'Áàíê-Êëèåíò ÇÀÎ "Ñèòè Èíâåñò Áàíê"';
  BIC1 = '044030702';
  Bank1 = 'ÇÀÎ "ÑÈÒÈ ÈÍÂÅÑÒ ÁÀÍÊ"';
  Place1 = 'Ã.ÑÀÍÊÒ-ÏÅÒÅĞÁÓĞÃ';
  KS1 = '30101810600000000702';
  VOP = '01';

  LineFeed = #13#10;

type
  TPlatBlank = class(TCustomBlank)
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
    DocNo: string;
    DocDate: string;
    Sum: string;
    Delivery: string;

    INN: string;
    Name: string;
    LS: string;
    BIC: string;
    Bank: string;
    Place: string;
    KS: string;

    INN2: string;
    Name2: string;
    LS2: string;
    BIC2: string;
    Bank2: string;
    Place2: string;
    KS2: string;

    Prior: string;
    Details: string;
    Sign1: string;
    Sign2: string;

    //since 01.06.2003
    KPP, KPP2: string;
    SS: string;
    NAL1, NAL2, NAL3, NAL4, NAL5, NAL6, NAL7: string;

    procedure DrawPage;
    procedure LoadFromFile(const FileName: string);
    constructor Create; overload; override;
    constructor Create(const FileName: string); overload;
  published
    { Published declarations }
  end;

implementation

uses
  SumFuncs, Russian;

{ TPlatBlank }

constructor TPlatBlank.Create;
begin
  inherited Create;
  TopMargin := 15;
  LeftMargin := 20;
  //Height := 205;

  DocDate := DateToStr(Now);
  BIC := BIC1;
  Bank := Bank1;
  Place := Place1;
  KS := KS1;
end;

constructor TPlatBlank.Create(const FileName: string);
begin
  Create;
  LoadFromFile(FileName);
end;

procedure TPlatBlank.DrawPage;

function NormalizeTax(const S: string): string;
const
  TaxChar = '!';
  LineFeed = #10;
begin
  Result := AnsiReplaceStr(S, ' ' + TaxChar, TaxChar);
  Result := AnsiReplaceStr(Result, TaxChar + ' ', TaxChar);
  Result := AnsiReplaceStr(Result, TaxChar, LineFeed);
end;

begin
  ResetFont('', 9);
  TV(160,   0, 178, 5, '0401060');
  RL(160,   0, 178, 5);
  RL(171,  13, 178, 20);

  TL(  5,   5, 'Ïîñòóï. â áàíê ïëàò.');
  TL( 60,   5, 'Ñïèñàíî ñî ñ÷. ïëàò.');
  TL(  1, -35, 'Ñóììà');
  TL(  1,  35, 'ïğîïèñüş');
  TL(  1, -45, 'ÈÍÍ');
  TL( 51, -45, 'ÊÏÏ');
  TL(  1, -70, 'Ïëàòåëüùèê');
  TL(  1, -85, 'Áàíê ïëàòåëüùèêà');
  TL(  1,-100, 'Áàíê ïîëó÷àòåëÿ');
  TL(  1,-105, 'ÈÍÍ');
  TL( 51,-105, 'ÊÏÏ');
  TL(  1,-130, 'Ïîëó÷àòåëü');
  TL(  1,-165, 'Íàçíà÷åíèå ïëàòåæà');
  TC( 85,  20, 120, 'Äàòà');
  TC(125,  20, 160, 'Âèä ïëàòåæà');
  TL(101, -45, 'Ñóììà');
  TL(101, -60, 'Ñ÷.¹');
  TL(101, -75, 'ÁÈÊ');
  TL(101, -80, 'Ñ÷.¹');
  TL(101, -90, 'ÁÈÊ');
  TL(101, -95, 'Ñ÷.¹');
  TL(101,-105, 'Ñ÷.¹');
  TL(101,-120, 'Âèä îï.');
  TL(101,-125, 'Íàç.ïë.');
  TL(101,-130, 'Êîä');
  TL(136,-120, 'Ñğîê ïëàò.');
  TL(136,-125, 'Î÷åğ.ïëàò.');
  TL(136,-130, 'Ğåç.ïîëå');
  TL( 71,-170, 'Ïîäïèñè');
  TL(141,-170, 'Îòìåòêè áàíêà');
  TL( 11,-185, 'Ì.Ï.');







//    //below obsolete since 01.06.2003
//  ResetFont('', 12);
//    TL( 61, -20, DocNo);
//    TC( 85, -20, 120, DocDate);
//    TC(125, -20, 160, Delivery);
//    TB( 21, -35, 178, 40, RCurrToText(RStrToCurr(Sum)));
//    TL(116, -45, Sum);
//
//    TL( 11, -45, INN);
//    TB(  1, -50, 99, 65, Name);
//    TL(116, -60, LS);
//    // TL(  1, -75, 99, Bank);
//    // TL(  1, -80, 99, Place);
//    TL(116, -75, BIC);
//    TL(116, -80, KS);
//
//    TL( 11,-105, INN2);
//    TB(  1,-110, 99, 125, Name2);
//    TL(116,-105, LS2);
//    // TL(  1, -90, 99, Bank2);
//    // TL(  1, -95, 99, Place2);
//    TL(116, -90, BIC2);
//    TL(116, -95, KS2);
//
//    TL(156,-125, Prior);
//    TB(  1,-140, 178, 160, NormalizeTax(Details));
//    // TL( 51,-175, Sign1);
//    // TL( 51,-190, Sign2);
//    TL(116,-120, VOP);
//
//    ResetFont('', 11);
//    {
//    TL(  1, -75, 99, Bank);
//    TL(  1, -80, 99, Place);
//    TL(  1, -90, 99, Bank2);
//    TL(  1, -95, 99, Place2);
//    }
//    TB(  1, -75, 99, 80, Bank);
//    TL( 30, -85, 99, Place);
//    TB(  1, -90, 99, 95, Bank2);
//    TL( 30,-100, 99, Place2);
//
//    ResetFont('', 11, 'I');
//    TL( 51,-175, Sign1);
//    TL( 51,-190, Sign2);
//    //above obsolete since 01.06.2003



  ResetFont('', 11, '');
  TL(  1, -75, 99, Bank);
  TL(  1, -80, 99, Place);
  TL(  1, -90, 99, Bank2);
  TL(  1, -95, 99, Place2);

  ResetFont('', 12, '');
  TV(171,  13, 178, 20, SS);
  TL( 61, -20, DocNo);
  TC( 85, -20, 120, DocDate);
//  TC(125, -20, 160, Delivery);
  TB( 21, -35, 178, 40, RCurrToText(RStrToCurr(Sum)));
  TL(116, -46, RCurrToStr(RStrToCurr(Sum), '-'));

  TL( 11, -45, INN);
  TL( 61, -45, KPP);
  TB(  1, -50, 99, 65, NormalizeTax(Name));
  TL(116, -60, LS);
  TL(116, -75, BIC);
  TL(116, -80, KS);

  TL( 11,-105, INN2);
  TL( 61,-105, KPP2);
  TB(  1,-110, 99, 125, NormalizeTax(Name2));
  TL(116,-105, LS2);
  TL(116, -90, BIC2);
  TL(116, -95, KS2);

  //TL(156,-120, Srok);
  TL(156,-125, Prior);

  //TV(  0, 130,  45, 135, NAL1);
  TL(  1, -135, NAL1);
  TV( 45, 130,  75, 135, NAL2);
  TV( 75, 130,  85, 135, NAL3);
  TV( 85, 130, 110, 135, NAL4);
  TV(110, 130, 145, 135, NAL5);
  TV(145, 130, 170, 135, NAL6);
  TV(170, 130, 178, 135, NAL7);

  TB(  1,-140, 178, 160, NormalizeTax(Details));
//  TL( 51,-180, Sign1);
//  TL( 51,-195, Sign2);
  TL(116,-120, VOP);





  ResetFont('', 12, '');
  TL(  1, -20, 'ÏËÀÒÅÆÍÎÅ ÏÎĞÓ×ÅÍÈÅ ¹');

  HL(  0,   5,  35);
  HL( 55,   5,  90);
  HL(  0,  40, 178);
  HL(  0,  45, 100);
  HL(  0,  70, 115);
  HL(  0,  85, 178);
  HL(  0, 100, 115);
  HL(  0, 105, 100);
  HL(  0, 130, 178);
  HL(  0, 135, 178);
  HL(  0, 165, 178);
  HL( 85,  20, 120);
  HL(125,  20, 160);
  HL(100,  55, 178);
  HL(100,  75, 115);
  HL(100,  90, 115);
  HL(100, 115, 178);
  HL(100, 120, 115);
  HL(100, 125, 115);
  HL(135, 120, 155);
  HL(135, 125, 155);
  HL( 50, 180, 110);
  HL( 50, 195, 110);

  VL( 20,  25,  40);
  VL( 50,  40,  45);
  VL(100,  40, 130);
  VL( 50, 100, 105);
  VL(115,  40, 130);
  VL(135, 115, 130);
  VL(155, 115, 130);
  VL( 45, 130, 135);
  VL( 75, 130, 135);
  VL( 85, 130, 135);
  VL(110, 130, 135);
  VL(145, 130, 135);
  VL(170, 130, 135);

  //DrawRulers;
end;

procedure TPlatBlank.LoadFromFile(const FileName: string);
var
  PFile: TMemIniFile;
  Is866: Boolean;
  SL: TStringList;
  I: Integer;
  Ver: Integer;
  s: string;

function NormalizeText(const S, S1, S2, S3, S4: string): string;
begin
  if Length(S) > 0 then
    Result := S
  else if Length(S1) > 0 then
  begin
    if S1[1] = '^' then
    begin
      Result := Copy(S1, 2, 53) + Copy(S2, 2, 53) +
        Copy(S3, 2, 53) + Copy(S4, 2, 53);
      if Result[106] = Result[107] then //BUG correction!
        Delete(Result, 106, 1);
    end
    {else if Ver > 7 then //last releases only!
      Result = S1 + ' ' + S2 + ' ' + S3 + ' ' + S4
    }
    else begin
      if Length(S1) = 53 then
        Result := S1 + S2
      else
        Result := S1 + ' ' + S2;

      if Length(S2) = 53 then
      begin
        if (Length(S3) > 1) and (S2[53] = S3[1]) then //BUG correction!
          Delete(Result, Length(Result) - 1, 1);
      end
      else
        Result := Result + ' ';

      if Length(S3) = 53 then
        Result := Result + S3 + S4
      else
        Result := Result + S3 + ' ' + S4;
    end;
  end
  else
    Result := '';
  Result := Trim(Result);
  while Pos('  ', Result) > 0 do
    Delete(Result, Pos('  ', Result), 1);
  if Is866 then
    RDosToWin(Result);
end;

begin
  if ExtractFileDir(FileName) = '' then
    PFile := TMemIniFile.Create('.\' + FileName)
  else
    PFile := TMemIniFile.Create(FileName);
  try
    with PFile do
    begin
      Is866   := ReadString('File', 'CP', '866') = '866';
      Ver     := ReadInteger('File', 'Ver', 0);

      DocNo   := ReadString('Payment', 'No', '1');
      DocDate := RStrToDateStr(ReadString('Payment', 'Date',
                        DateToStr(Date)));
      Sum     := ReadString('Payment', 'Sum', '0-00');
      Prior   := ReadString('Payment', 'Queue', '6');
      Details := NormalizeText(
                   ReadString('Payment', 'Text', ''),
                   ReadString('Payment', 'Text1', ''),
                   ReadString('Payment', 'Text2', ''),
                   ReadString('Payment', 'Text3', ''),
                   ReadString('Payment', 'Text4', ''));

      //Sign1   := ReadString('From', 'Sign1', '');
      //Sign2   := ReadString('From', 'Sign2', '');
      INN     := ReadString('From', 'INN', '');
      Name    := ReadString('From', 'Name', '');
      LS      := ReadString('From', 'LS', '');
      //BIC
      //Bank
      //Place
      //KS
      INN2     := ReadString('To', 'INN2', '');
      Name2    := ReadString('To', 'Name2', '');
      LS2      := ReadString('To', 'LS2', '');
      BIC2     := ReadString('To', 'BIC2', '');
      Bank2    := ReadString('To', 'Bank2', '');
      Place2   := ReadString('To', 'Place2', '');
      KS2      := ReadString('To', 'KS2', '');

      if Is866 then
      begin
        RDosToWin(Sign1);
        RDosToWin(Sign2);
        RDosToWin(INN);
        RDosToWin(Name);
        //Bank
        //Place
        RDosToWin(INN2);
        RDosToWin(Name2);
        RDosToWin(Bank2);
        RDosToWin(Place2);
      end;


      //since 01.06.2003
      if Ver >= 11 then
      begin
        KPP := ReadString('From', 'KPP', '0');
        KPP2 := ReadString('To', 'KPP2', '0');
      end
      else
      begin
        if AnsiLeftStr(Name, 3) = 'ÊÏÏ' then
        begin
          SL := TStringList.Create;
          try
            SL.Text := AnsiReplaceStr(Name, ' ', LineFeed);
            if SL[0] = 'ÊÏÏ' then
            begin
              KPP := SL[1];
              Name := '';
              for I := 2 to SL.Count - 1 do
                Name := Name + SL[I] + ' ';
              Name := Trim(Name);
            end;
          finally
            SL.Free;
          end;
        end;
        if AnsiLeftStr(Name2, 3) = 'ÊÏÏ' then
        begin
          SL := TStringList.Create;
          try
            SL.Text := AnsiReplaceStr(Name2, ' ', LineFeed);
            if SL[0] = 'ÊÏÏ' then
            begin
              KPP2 := SL[1];
              Name2 := '';
              for I := 2 to SL.Count - 1 do
                Name2 := Name2 + SL[I] + ' ';
              Name2 := Trim(Name2);
            end
          finally
            SL.Free;
          end;
        end;
      end;

      if Ver >= 11 then
      begin
        SS := ReadString('To', 'SS', '');
        if Length(SS) = 2 then
        begin
          NAL1 := ReadString('To', 'NAL1', '0');
          NAL2 := ReadString('To', 'NAL2', '0');
          NAL3 := RWin(ReadString('To', 'NAL3', '0'));
          NAL4 := RWin(ReadString('To', 'NAL4', '0'));
          NAL5 := RWin(ReadString('To', 'NAL5', '0'));
          NAL6 := ReadString('To', 'NAL6', '0');
          NAL7 := RWin(ReadString('To', 'NAL7', '0'));
        end;
      end
      else
      begin
        I := Pos(';', Details);
        if (Details[1] = '0') and (I = 3) then
        begin
          SL := TStringList.Create;
          try
            SL.Text := AnsiReplaceStr(Details, ';', LineFeed);
            I := 0;
            SS := SL[I]; Inc(I);
            NAL1 := SL[I]; Inc(I);
            NAL2 := SL[I]; Inc(I);
            NAL3 := SL[I]; Inc(I);
            NAL4 := SL[I]; Inc(I);
            NAL5 := SL[I]; Inc(I);
            NAL6 := SL[I]; Inc(I);
            NAL7 := SL[I]; Inc(I);
            Details := '';
            for I := I to SL.Count - 1 do
              Details := Details + SL[I] + ';';
            I := Length(Details);
            if Details[I] = ';' then
              Delete(Details, I, 1);
          finally
            SL.Free;
          end;
        end
        else if (I > 1) and (I < 20) then
        begin
          SL := TStringList.Create;
          try
            SL.Text := AnsiReplaceStr(Details, ';', LineFeed);
            I := 0;
            SS := '01'; /////////////////////////////////////////
            NAL1 := SL[I]; Inc(I);
            NAL2 := SL[I]; Inc(I);
            NAL3 := SL[I]; Inc(I);
            NAL4 := SL[I]; Inc(I);
            NAL5 := SL[I]; Inc(I);
            NAL6 := SL[I]; Inc(I);
            NAL7 := SL[I]; Inc(I);
            Details := '';
            for I := I to SL.Count - 1 do
              Details := Details + SL[I] + ';';
            I := Length(Details);
            if Details[I] = ';' then
              Delete(Details, I, 1);
          finally
            SL.Free;
          end;
        end;
        if SS = '' then /////////////////////////////////////////
        begin
          NAL1 := '';
          NAL2 := '';
          NAL3 := '';
          NAL4 := '';
          NAL5 := '';
          NAL6 := '';
          NAL7 := '';
        end
        else
        begin
          if NAL1 = '' then NAL1 := '0';
          if NAL2 = '' then NAL2 := '0';
          if NAL3 = '' then NAL3 := '0';
          if NAL4 = '' then NAL4 := '0';
          if NAL5 = '' then NAL5 := '0';
          if NAL6 = '' then NAL6 := '0';
          if NAL7 = '' then NAL7 := '0';
        end;
      end;
    end;

    //1C
    s := INN + '/' + KPP + ' ';
    if AnsiStartsText(s, Name) then
      Name := AnsiMidStr(Name, Length(s) + 1, 160);
    s := INN + '\' + KPP + ' ';
    if AnsiStartsText(s, Name) then
      Name := AnsiMidStr(Name, Length(s) + 1, 160);

    s := INN2 + '/' + KPP2 + ' ';
    if AnsiStartsText(s, Name2) then
      Name2 := AnsiMidStr(Name2, Length(s) + 1, 160);
    s := INN2 + '\' + KPP2 + ' ';
    if AnsiStartsText(s, Name2) then
      Name2 := AnsiMidStr(Name2, Length(s) + 1, 160);

  finally
    PFile.Free;
  end;
end;

end.
