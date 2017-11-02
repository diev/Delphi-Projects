unit Globals;

{.$DEFINE DEBUG}
//Don't forget to switch {.$DEFINE DEBUG} here!!!
{.$DEFINE DEBUG}

interface
{2009
uses
  BankDBF, Clients;
2009}

resourcestring
{$IFDEF DEBUG}
  {2009
  INTEST = 'in\';
  UNITEXT = 'out\uni-test.txt';
  2009}
  UNISCAN = 'out\uni-scan.txt';
{$ELSE}
  {2009
  INTEST = 'i:\cibank\mail\intest\';
  UNITEXT = 'u:\mail\in\uni-test.txt';
  2009}
  UNISCAN = 'u:\mail\in\uni-scan.txt';
{$ENDIF}

  {2009
  MAILBOX_R = 'i:\cibank\smail\mailbox\%s\r\';
  MAILBOX_S = 'i:\cibank\smail\mailbox\%s\s\';

  MAIL_ARCH = 'i:\cibank\mail\in\%s\';

  BNKSEEK_DBF1 = 'g:\cibank\util\bnkseek.dbf';
  BNKSEEK_DBF2 = 'i:\util\bnkseek.dbf';
  BCLIENTS_TXT = 'i:\cibank\bclients.txt';

  PUBRKEY_PGP = 'i:\cibank\pgp\keys\pubr%s.pgp';
  SECRKEY_PGP = 'i:\cibank\pgp\keys\secrbank.pgp';
  SECRPASS = '***';

  LastKnownGoodVersion = '06.01.2004';
  LastKnownGoodVer = '11';
  InitVersion = '04.08.1999';
  2009}
  CIBBIC = '044030702';
  CIBKS  = '30102810500000000702';
  CIBINN = '7831001422';

type
  TCheckMode = ({2009 Init, Plt, 2009} Dbf, Unix);
  TTaxMode   = (Zero, Budget, Customs); //2010

  TPlat = record
    FilePath,
    FileNameExt,
    FileExt,
    InFileName,
    RepFileName: string;

    //[File]
    {2009
    Created: TDateTime;
    Is866: Boolean;
    Ver: Integer;
    Version: string;
    HomePath: string;
    2009}

    //[Payment]
    DocNo: string; //Integer;
    DocDate: string; //TDateTime;
    Sum: string; //Currency;
    Queue: string;
    Details: string;

    //[From]
    Name: string;
    INN: string;
    KPP: string;
    LS: string;

    //[To]
    Name2: string;
    INN2: string;
    KPP2: string;
    LS2: string;
    BIC2: string;
    //Bank2: string;
    //Place2: string;
    KS2: string;

    SS: string;
    NAL1: string;
    NAL2: string;
    NAL3: string;
    NAL4: string;
    NAL5: string;
    NAL6: string;
    NAL7: string;

    CheckMode: TCheckMode;
    TaxMode:   TTaxMode; //2010
    {2009
    CheckBIC: Boolean;
    CheckBCl: Boolean;
    2009}

    //2009
    OpKind: string; //Вид операции

    //2013
    PaytCondition: string; //Условие оплаты ПТ (1 или 2)
  end;

var
  Plat: TPlat;
  {2009
  BnkSeek: TBankDBFReader;
  BClients: TClientsList;
  2009}

implementation
{2009
uses
  SysUtils, Dialogs, Checks, BankUtils;

initialization

  with Plat do try
    CheckMode := Init;

    if FileExists(BNKSEEK_DBF1) then
    begin
      BnkSeek := TBankDBFReader.Create(BNKSEEK_DBF1);
      CheckBIC := BnkSeek.FindRec('NEWNUM', CIBBIC);
    end
    else if FileExists(BNKSEEK_DBF2) then
    begin
      BnkSeek := TBankDBFReader.Create(BNKSEEK_DBF2);
      CheckBIC := BnkSeek.FindRec('NEWNUM', CIBBIC);
    end
    else
    begin
      MessageDlg('Справочник банков подключить не удалось!', mtWarning, [mbOk], 0);
      CheckBIC := False;
    end;

    if FileExists(BCLIENTS_TXT) then
    begin
      BClients := TClientsList.Create(BCLIENTS_TXT);
      CheckBCl := BClients.Count > 0;
    end
    else
      CheckBCl := False;
  except
    on E: Exception do
    begin
      AppendLogMessage(E.Message);
      Halt(2);
    end;
  end;

finalization

  BnkSeek.Free;
  BClients.Free;
2009}

end.
