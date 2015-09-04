unit Plat;

interface
uses
  SysUtils, Classes;

type
  TPlat = class
    //[File]
    Created: TDateTime;
    Is866: Boolean;
    Ver: Integer;
    Version: string;
    HomePath: string;

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
  end;

  TPlatFile = class(TPlat)
    FilePath: string;
    FileNameExt: string;
    FileExt: string;
    InFileName: string;
    RepFileName: string;
  end;

implementation

end.
