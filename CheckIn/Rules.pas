unit Rules;

{.$DEFINE DEBUG}

interface

const
  DAYS_AFTER = 10; //��������� �����
  DAYS_BEFORE = 5; //��������� ������

  CUTLENGTH = 30; //���������� � ��. � "CUT LENGTH..."

resourcestring
  {2009}
  //2009 REGEXP_FILENAME = '[Aa](\d)([1-9ABCabc])(\d{2})(\d{3})\.(\d{3,4})';
  {2009}

  REGEXP_VO       = '^\{VO\d{5}(PS\d{8}/3194/0000/\d/0|)\}';
  REGEXP_VO_SCAN  = '^[\{\[\(]V[O�0]\d{5}([P�]S\d{8}/3194/0000/\d/0|)[\}\]\)]'; //RusLat!
  REGEXP_LS_VO    = '^(30122|30123|30230|30231|40807|40813|40814|40815|40818|40819|40820)';

  REGEXP_INN      = '^(\d{10}|\d{12}|0)$';
  REGEXP_INN10    = '^(\d{10}|0)$';
  REGEXP_INN12    = '^(\d{12}|0)$';
  REGEXP_LS_INN12 = '^(40802|40817)';

  REGEXP_KPP      = '^(\d{9}|0)$';
  REGEXP_BIC      = '^04\d{7}$';
  REGEXP_LS       = '^\d{5}810\d{12}$';
  REGEXP_QUE      = '^[1-5]$'; //� 14.12.2013

  {101}REGEXP_SS       = '^\d{2}$'; {'^0[1-8]$';}
  {104}REGEXP_NAL1     = '^(\d{20})$';
       REGEXP_NAL1T    = '^\d{1,20}$';
  {105}REGEXP_NAL2     = '^\d{1,11}$';
  {106}REGEXP_NAL3     = '^(��|��|��|��|��|��|��|��|��|��|��)$';
       REGEXP_NAL3T    = '^(��|��|��|��|��|��|��|��|��|��)$'; //������� � 2010
  {107}REGEXP_NAL4     = '^((�1|�2|�3|��|��|��|��|\d{2})\.\d{2}\.\d{4}|0)$';
       REGEXP_NAL4_Q   = '^(��\.01|��\.02|��\.03|��\.04|��\.01|��\.02|��\.00)';
       REGEXP_NAL4T    = '^.{1,8}$'; //������� � 2010
  {108}REGEXP_NAL5     = '^.{1,15}$';
  {109}REGEXP_NAL6     = '^(\d{2}\.\d{2}\.\d{4}|0)$'; //���� ��� 0
  {110}REGEXP_NAL7     = '^(��|��|��|��|��|��|��|��|��|��)$';
       REGEXP_NAL7T    = '^(��|��|��)$'; //������� � 2010

  procedure VerifyRules;

implementation
uses
  SysUtils,
  StrUtils,
  DateUtils,
  Dialogs,
  Windows,
  Globals,
  Russian,
  Checks,
  BICLSKey,
  INNKey,
  RegExpr,
  BankUtils;

procedure VerifyRules;
var
  RepPart: string;
  {2009
  testInt: Integer;
  2009}
  testDate: TDateTime;
  testStr: string;

  procedure Problem(var Field: string; const S: string); overload;
  var
    Ask, Log, ShortField: string;
  begin
    with Plat do
    begin
      if Length(Field) > CUTLENGTH then
        ShortField := AnsiLeftStr(Field, CUTLENGTH) + '...'
      else
        ShortField := Field;
      Ask := Format('%s -'#10'%s'#10'%s', [RepPart, ShortField, S]);
      Log := Format('%s "%s" - %s', [RepPart, ShortField, S]);

      {2009
      if CheckMode = Plt then
        raise Exception.Create(Log);

      if CheckMode = Dbf then
      2009}
        if not InputQuery(Format('�������� N %s �� %s', [DocNo, Sum]), Ask, Field) then
          raise Exception.Create(Log);
    end;
  end;

  procedure Problem(var Field: string; const S: string; const Values: array of const); overload;
  begin
    Problem(Field, Format(S, Values));
  end;

  procedure ProbEx(var Field: string; const REGEXP, S: string);
  begin
    while not ExecRegExpr(REGEXP, Field) do
      Problem(Field, S);
  end;

  procedure VerifyText(var Field: string; const MinLen: Integer = 0; const MaxLen: Integer = 0);
  begin
    if MinLen > 0 then
      while Length(Field) < MinLen do
        Problem(Field, '������ %d ��������', [MinLen]);
    if MaxLen > 0 then
      while Length(Field) > MaxLen do
        Problem(Field, '������� %d ��������', [MaxLen]);
    while AnsiContainsStr(Field, '^') do
      Problem(Field, '�������� ^');
    while AnsiContainsStr(Field, '...') do
      Problem(Field, '������� ����������');
    while Field[1] = '"' do
      Problem(Field, '������� � ������');
    while Field[1] = '-' do
      Problem(Field, '����� � ������');
  end;

  procedure VerifyINN(var Field: string; const LS: string);
  begin
    ProbEx(Field, REGEXP_INN, '�� 10/12 ���� ��� 0');
//    if ExecRegExpr(REGEXP_LS_INN12, LS) then
//      ProbEx(Field, REGEXP_INN12, '�� 12 ���� ��� ���.����');
    while not ValidINNKey(Field) do
      Problem(Field, '������������');
    while AnsiStartsStr('40', LS) and AnsiSameStr(Field, CIBINN) do
      Problem(Field, '��� ��� �����');
  end;

begin
  with Plat do
  begin
    {2009
    if CheckMode = Plt then
    begin
      RepPart := '������ ���������';
      if Ver < StrToInt(LastKnownGoodVer) then
        Problem(Version, '�� ������������� ������� �� 2003!')
      else
      begin
        testDate := RStrToDate(Version);
        if testDate < RStrToDate(LastKnownGoodVersion) then
          Problem(Version, '�������� ������');
      end;
    end; //CheckMode = Plt
    2009}

    //---------------------------------------------------------
    RepPart := {3}'����� ���.';
      while NotDigits(DocNo) do
        Problem(DocNo, '�� �����');
      {2009
      if CheckMode = Plt then
      begin
        if not AnsiSameStr(BIC2, CIBBIC) then
        begin
          if NotIn(DocNo, 1, 999) then
            Problem(DocNo, '��������� 999 � ������ ����');
          if AnsiEndsStr('000', DocNo) then
            Problem(DocNo, '�� ����� 000 � ������ ����');
        end;
      end; //CheckMode = Plt
      2009}

    RepPart := {4}'���� ���.';
      if (OpKind = '01') then //��������� ��������� � ������
        while NotIn(DocDate, Now - DAYS_AFTER, Now + DAYS_BEFORE) do
          Problem(DocDate, '�� � -%d..+%d ����', [DAYS_AFTER, DAYS_BEFORE]);

    RepPart := {7}'����� ����.';
      while NotSum(Sum) do
        Problem(Sum, '�� �����');

    RepPart := {21}'����. ����.';
      if
        {2009
        (CheckMode = Dbf) and
        2009}
        (Length(Queue) > 1) then
        Queue := AnsiRightStr(Queue, 1);
      ProbEx(Queue, REGEXP_QUE, '�� 1..5');

    //---------------------------------------------------------
    RepPart := {60}'��� ����.';
      VerifyINN(INN, LS);

    RepPart := {102}'��� ����.';
      ProbEx(KPP, REGEXP_KPP, '�� 9 ���� ��� 0');

    RepPart := {9}'���� ����.';
      ProbEx(LS, REGEXP_LS, '�� 20 ����');
      {2009
      if CheckMode = Plt then
      begin
        testInt := StrToIntDef(AnsiRightStr(LS, 4), -2);
        if testInt <> StrToIntDef(FileExt, -1) then
          Problem(LS, '�� ������������� ����� ��������');
      end;
      2009}
      while not ValidLSKey(CIBBIC, LS) do
        Problem(LS, '�� ������������� ����� ���');

    //---------------------------------------------------------
    {2009
    if CheckMode = Plt then
    begin
      RepPart := {8]'����������';
        VerifyText(Name, 3, 160);

      RepPart := '���� �� �������������';           /////////////////////////////////
        if not AnsiEndsStr(FileExt, LS) then
          Problem(FileExt, '���� ����');
        if not AnsiSameStr(AnsiMidStr(FileNameExt, 2, 1), AnsiRightStr(DocDate, 1)) then
          Problem(DocDate, '���� ���');
        if not AnsiSameText(AnsiMidStr(FileNameExt, 3, 1), To36(AnsiMidStr(DocDate, 4, 2))) then
          Problem(DocDate, '���� �����');
        if not AnsiSameStr(AnsiMidStr(FileNameExt, 4, 2), AnsiLeftStr(DocDate, 2)) then
          Problem(DocDate, '���� ����');
        testInt := StrToIntDef(AnsiMidStr(FileNameExt, 6, 3), 0);
        if (testInt mod 1000) <> (StrToInt(DocNo) mod 1000) then
          Problem(DocNo, '���� �����');
    end; //CheckMode = Plt
    2009}

    //---------------------------------------------------------
    RepPart := {16}'����������';
      VerifyText(Name2, 3, 160);

    RepPart := {61}'��� �����.';
      VerifyINN(INN2, LS2);

    RepPart := {103}'��� �����.';
      ProbEx(KPP2, REGEXP_KPP, '�� 9 ���� ��� 0');

    RepPart := {14}'��� ����� �����.';
      ProbEx(BIC2, REGEXP_BIC, '�� 9 ����');

    RepPart := {17}'���� �����.';
      ProbEx(LS2, REGEXP_LS, '�� 20 ����');
      while not ValidLSKey(BIC2, LS2) do
        Problem(LS2, '�� ������������� ����� ���');

    //---------------------------------------------------------
    {2009
    if CheckBIC then
    begin
      RepPart := {13]'���� ����������';
      if BnkSeek.FindRec('NEWNUM', BIC2) then
      begin
        //RepPart := {15] '�/� ����� ����������';
        {
        testStr := BnkSeek.Value('KSNP');
        if Length(KS2) > 0 then
          while not AnsiSameStr(KS2, testStr) do
            Problem(KS2, '�� ��������� �� ������������ ������')
        else
          KS2 := testStr;
        ]

        testStr := BnkSeek.Value('REAL');
        if Length(testStr) > 0 then
        begin
          if AnsiContainsText('����,����', testStr) and
            (BnkSeek.Value('DATE_CH') < RDateToS(Now)) then
            Problem(BIC2, '�������� � ��������!');
        end;
      end
      else
        Problem(BIC2, '�� ������ � ����������� ������');
    end; //CheckBIC
    2009}

    //---------------------------------------------------------
    RepPart := {101}'������ �����������������';
      if NotIn(Queue, '15') then
        while Length(SS) = 0 do
          Problem(SS, '���� ��� ����. �� 5');
      if AnsiStartsStr('40101', LS2) then
        while Length(SS) = 0 do
          Problem(SS, '���� ��� ����. ����� 40101');
      if AnsiStartsStr('40314', LS2) then
        while Length(SS) = 0 do
          Problem(SS, '���� ��� �����. ����� 40314');

    if Length(SS) > 0 then
    begin
      ProbEx(SS, REGEXP_SS, '�� 01..20'); //2010

      RepPart := {104}'��� ����. �������������';
        if AnsiStartsStr('40101', LS2) then
          ProbEx(NAL1, REGEXP_NAL1, '�� 20 ����');
        if AnsiStartsStr('40314', LS2) then
          ProbEx(NAL1, REGEXP_NAL1T, '�� �����');

      RepPart := {105}'��� �����';
        ProbEx(NAL2, REGEXP_NAL2, '�� �����');

      RepPart := {106}'��������� �������';
        //2009 ProbEx(NAL3, REGEXP_NAL3, '�� 2 �����');
        //2010
        if Length(NAL3) = 0 then
          Problem(NAL3, '����� � �� 0');
        if NAL3 = '0' then
          TaxMode := Zero
        else if ExecRegExpr(REGEXP_NAL3, NAL3) then
          TaxMode := Budget
        else if ExecRegExpr(REGEXP_NAL3T, NAL3) then
          TaxMode := Customs
        else
          Problem(NAL3, '�� 2 �����');

      if TaxMode = Budget then
      begin
      RepPart := {107}'�����. ������';
        {2009
        if CheckMode = Dbf then
        begin
        2009}
          {2010
          if Length(NAL4) > 5 then
          begin
            NAL4[3] := '.';
            NAL4[6] := '.';
          end;
          2010}
          if AnsiContainsStr(NAL4, '00.00.00') then
            NAL4 := '0';
        {2009
        end;
        2009}
        ProbEx(NAL4, REGEXP_NAL4, '�� 2 ����� ��� ����');
        if NAL4 <> '0' then
        begin
          if Length(NAL4) > 5 then
          begin
            NAL4[3] := '.';
            NAL4[6] := '.';
          end;
          case NAL4[1] of
            '�', '�':
              repeat
                testStr := NAL4;
                testStr[1] := '0';
                testStr[2] := '1';
                if TryStrToDate(testStr, testDate) then
                  Break;
                Problem(NAL4, '�� ���� � ��� ��');
              until False;
            '�', '�', '�':
              repeat
                if ExecRegExpr(REGEXP_NAL4_Q, NAL4) then
                begin
                  testStr := NAL4;
                  testStr[1] := '0';
                  testStr[2] := '1';
                  testStr[4] := '0';
                  testStr[5] := '1';
                  if TryStrToDate(testStr, testDate) then
                    Break;
                end;
                Problem(NAL4, '�� ���� ��, �� ��� ��');
              until False;
            else //date
              repeat
                testStr := NAL4;
                if TryStrToDate(testStr, testDate) then
                  Break;
                Problem(NAL4, '�� ����');
              until False;
          end;
        end;
      end
      else if TaxMode = Customs then
      begin
      RepPart := {107}'��� �����. ������';
          if Length(NAL4) = 0 then
            Problem(NAL4, '���� � �� 0');
      end
      else {TaxMode = Zero}
      begin
      RepPart := {107}'���� 107';
          if Length(NAL4) = 0 then
            Problem(NAL4, '����� � �� 0');
      end;

      RepPart := {108}'����� �����. ���������';
        VerifyText(NAL5, 1, 15);

      RepPart := {109}'���� �����. ���������';
        {2009
        if CheckMode = Dbf then
        begin
        2009}
          if Length(NAL6) > 5 then
          begin
            NAL6[3] := '.';
            NAL6[6] := '.';
          end;
          if AnsiContainsStr(NAL6, '00.00.00') then
            NAL6 := '0';
        {2009
        end;
        2009}
        ProbEx(NAL6, REGEXP_NAL6, '�� 10 ������');
        if NAL6 <> '0' then
          while not TryStrToDate(NAL6, testDate) do
            Problem(NAL6, '�� ����');

      RepPart := {110}'��� �����. ���������';
        //2009 ProbEx(NAL7, REGEXP_NAL7, '�� 2 �����');
        //2010
        if Length(NAL7) = 0 then
          Problem(NAL7, '���� � �� 0');
        if NAL7 = '0' then
          TaxMode := Zero
        else if ExecRegExpr(REGEXP_NAL7, NAL7) then
          TaxMode := Budget
        else if ExecRegExpr(REGEXP_NAL7T, NAL7) then
          TaxMode := Customs
        else
          Problem(NAL7, '�� 2 �����');
    end;

    //---------------------------------------------------------
    RepPart := {24}'����������';
      VerifyText(Details, 3, 210);
      if ExecRegExpr(REGEXP_LS_VO, LS2) or
        ExecRegExpr(REGEXP_LS_VO, LS) then
      begin
        //         1         2         3
        //123456789012345678901234567890123456
        //{VOXXXXXPSXXXXXXXX/3194/0000/X/0}

        {2009
        if CheckMode = Dbf then
        begin
        2009}
          if ExecRegExpr(REGEXP_VO_SCAN, Details) then
          begin
            Details[1] := '{';
            Details[3] := 'O'; //RusLat scan bug VO
            if Details[10] = 'S' then
            begin
              Details[9] := 'P'; //RusLat scan bug PS
              Details[33] := '}';
            end
            else
              Details[9] := '}';
          end;
        {2009
        end;
        2009}
        ProbEx(Details, REGEXP_VO, '��� {VO � �.�.');
      end;

    //---------------------------------------------------------
    {2009
    if CheckMode = Plt then
    begin
      testStr := LS;
      with BClients do
      begin
        testInt := IndexOf(testStr);
        case WRK[testInt] of
          0: //test
            raise Exception.Create('������� �������������');

          1: //work
            begin
              {$IFNDEF DEBUG]
              for testInt := 0 to DAYS_AFTER do
              begin
                testStr := Format(MAIL_ARCH, [PathYMD(-testInt)]) + FileNameExt;
                if FileExists(testStr) then
                  if testInt = 0 then
                    raise Exception.Create('�������� (�������)')
                  else
                    raise Exception.CreateFmt('�������� (%d %s �����)',
                      [testInt, REndStr(testInt, '����', '���', '����')]);
              end;
              {$ENDIF]
            end;

          2: //blocked
            raise Exception.Create('�������������');

          3: //retired
            raise Exception.Create('����. �� �������');

          else //unused
            raise Exception.Create('�� �������������');
        end;
      end;
    end; //CheckMode = Plt
    2009}
  end;
end;

end.
