unit CBR;

interface

type
  TIntDate = Integer;
  TIntCurrency = Integer;

  TAccDoc = record
    AccDocNo: Integer;
    AccDocDate: TIntDate;
  end;

  TPayerPayeeBank = record
    BIC: Integer;
    CorrespAcc: string;
  end;

  TPayerPayee = record
    PersonalAcc: string;
    INN: string;
    KPP: string;
    Name: string;
    Bank: TPayerPayeeBank;
  end;

  TDepartmentalInfo = record
    DrawerStatus: Integer;
    CBC: string;
    OKATO: string;
    PaytReason: string;
    TaxPeriod: string;
    DocNo: string;
    DocDate: string;
    TaxPaytKind: string;
  end;

  TInitialED = record
    EDNo: Integer;
    EDDate: TIntDate;
    EDAuthor: Integer;
  end;

  TED101 = record
    EDNo: Integer;
    EDDate: TIntDate;
    EDAuthor: Integer;
    InitialED: TInitialED;
    TransKind: Integer;
    Priority: Integer;
    ReceiptDate : TIntDate;
    FileDate: TIntDate;
    ChargeOffDate: TIntDate;
    PayKind: Integer;
    Sum: TIntCurrency;
    SystemCode: Integer;
    TurnoverKind: Integer;
    Purpose: string;
    AccDoc: TAccDoc;
    Payer, Payee: TPayerPayee;
    DeptInfo: TDepartmentalInfo;
  end;

implementation

end.
