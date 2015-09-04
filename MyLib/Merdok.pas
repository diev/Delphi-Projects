unit Merdok;

interface

uses
  BankDBF;

type
  TMerdokRec = packed record
    Deleted : AnsiChar;
    DVV     : TDBFDate;
    DD      : TDBFDate;
    ND      : array[1..3] of AnsiChar;
    DV      : TDBFDate;
    DAV     : TDBFDate;
    DK      : AnsiChar;
    ELNUM   : array[1..16] of AnsiChar;
    VO      : array[1..2] of AnsiChar;
    MFKB    : array[1..9] of AnsiChar;
    LSKL    : array[1..20] of AnsiChar;
    NAMKL   : array[1..160] of AnsiChar;
    MF      : array[1..9] of AnsiChar;
    LSKOR   : array[1..20] of AnsiChar;
    NAMKOR  : array[1..160] of AnsiChar;
    SU      : TDBFSum;
    NKOR1   : array[1..53] of AnsiChar;
    NKOR2   : array[1..53] of AnsiChar;
    NKOR3   : array[1..53] of AnsiChar;
    NKOR4   : array[1..51] of AnsiChar;
    PAROL   : array[1..10] of AnsiChar;
    SS      : array[1..4] of AnsiChar;
    KRKB    : array[1..20] of AnsiChar;
    INNMFKB : array[1..12] of AnsiChar;
    MFKBFIL : array[1..9] of AnsiChar;
    KR      : array[1..20] of AnsiChar;
    INNMF   : array[1..12] of AnsiChar;
    MFFIL   : array[1..9] of AnsiChar;
    DFA     : array[1..4] of AnsiChar;
    NA      : array[1..3] of AnsiChar;
    T_CLOCK : array[1..5] of AnsiChar;
    PR_DOC  : AnsiChar;
    PRIOR   : AnsiChar;
    DPLAT   : TDBFDate;
    SUB_ID  : array[1..10] of AnsiChar;
    PR_NUM  : array[1..6] of AnsiChar;
    ELNUMS  : array[1..16] of AnsiChar;
    KPPA    : array[1..9] of AnsiChar;
    KPPB    : array[1..9] of AnsiChar;
    DPPL    : TDBFDate;
    DKART   : TDBFDate;
    DSPL    : TDBFDate;
    D_OTMET : TDBFDate;
    SSTATUS : array[1..2] of AnsiChar;
    CODBCLAS: array[1..19] of AnsiChar;
    CODOKATO: array[1..11] of AnsiChar;
    NALPLAT : array[1..2] of AnsiChar;
    NALPER  : array[1..10] of AnsiChar;
    NDNAL   : array[1..15] of AnsiChar;
    DDNAL   : array[1..10] of AnsiChar;
    TYPNAL  : array[1..2] of AnsiChar;
    SU_OST  : TDBFSum;
    N_CH_PL : array[1..8] of AnsiChar;
    D_PL    : TDBFDate;
    SHIFR   : array[1..2] of AnsiChar;
    N_PLDOK : array[1..3] of AnsiChar;
    LS_ERR  : array[1..10] of AnsiChar;
  end;

implementation

end.
