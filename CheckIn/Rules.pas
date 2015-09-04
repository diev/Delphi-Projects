unit Rules;

{.$DEFINE DEBUG}

interface

const
  DAYS_AFTER = 10; //разрешено назад
  DAYS_BEFORE = 5; //разрешено вперед

  CUTLENGTH = 30; //Назначение и пр. в "CUT LENGTH..."

resourcestring
  {2009}
  //2009 REGEXP_FILENAME = '[Aa](\d)([1-9ABCabc])(\d{2})(\d{3})\.(\d{3,4})';
  {2009}

  REGEXP_VO       = '^\{VO\d{5}(PS\d{8}/3194/0000/\d/0|)\}';
  REGEXP_VO_SCAN  = '^[\{\[\(]V[OО0]\d{5}([PР]S\d{8}/3194/0000/\d/0|)[\}\]\)]'; //RusLat!
  REGEXP_LS_VO    = '^(30122|30123|30230|30231|40807|40813|40814|40815|40818|40819|40820)';

  REGEXP_INN      = '^(\d{10}|\d{12}|0)$';
  REGEXP_INN10    = '^(\d{10}|0)$';
  REGEXP_INN12    = '^(\d{12}|0)$';
  REGEXP_LS_INN12 = '^(40802|40817)';

  REGEXP_KPP      = '^(\d{9}|0)$';
  REGEXP_BIC      = '^04\d{7}$';
  REGEXP_LS       = '^\d{5}810\d{12}$';
  REGEXP_QUE      = '^[1-5]$'; //с 14.12.2013

  {101}REGEXP_SS       = '^\d{2}$'; {'^0[1-8]$';}
  {104}REGEXP_NAL1     = '^(\d{20})$';
       REGEXP_NAL1T    = '^\d{1,20}$';
  {105}REGEXP_NAL2     = '^\d{1,11}$';
  {106}REGEXP_NAL3     = '^(ТП|ЗД|БФ|ТР|РС|ОТ|РТ|ВУ|ПР|АП|АР)$';
       REGEXP_NAL3T    = '^(ДЕ|ПО|КВ|КТ|ИД|ИП|ТУ|БД|ИН|КП)$'; //таможня с 2010
  {107}REGEXP_NAL4     = '^((Д1|Д2|Д3|МС|КВ|ПЛ|ГД|\d{2})\.\d{2}\.\d{4}|0)$';
       REGEXP_NAL4_Q   = '^(КВ\.01|КВ\.02|КВ\.03|КВ\.04|ПЛ\.01|ПЛ\.02|ГД\.00)';
       REGEXP_NAL4T    = '^.{1,8}$'; //таможня с 2010
  {108}REGEXP_NAL5     = '^.{1,15}$';
  {109}REGEXP_NAL6     = '^(\d{2}\.\d{2}\.\d{4}|0)$'; //дата или 0
  {110}REGEXP_NAL7     = '^(НС|ПЛ|ГП|ВЗ|АВ|ПЕ|ПЦ|СА|АШ|ИШ)$';
       REGEXP_NAL7T    = '^(ШТ|ЗД|ПЕ)$'; //таможня с 2010

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
        if not InputQuery(Format('Уточните N %s на %s', [DocNo, Sum]), Ask, Field) then
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
        Problem(Field, 'короче %d символов', [MinLen]);
    if MaxLen > 0 then
      while Length(Field) > MaxLen do
        Problem(Field, 'длиннее %d символов', [MaxLen]);
    while AnsiContainsStr(Field, '^') do
      Problem(Field, 'содержит ^');
    while AnsiContainsStr(Field, '...') do
      Problem(Field, 'содежит многоточие');
    while Field[1] = '"' do
      Problem(Field, 'кавычка в начале');
    while Field[1] = '-' do
      Problem(Field, 'минус в начале');
  end;

  procedure VerifyINN(var Field: string; const LS: string);
  begin
    ProbEx(Field, REGEXP_INN, 'не 10/12 цифр или 0');
//    if ExecRegExpr(REGEXP_LS_INN12, LS) then
//      ProbEx(Field, REGEXP_INN12, 'не 12 цифр для физ.лица');
    while not ValidINNKey(Field) do
      Problem(Field, 'неправильный');
    while AnsiStartsStr('40', LS) and AnsiSameStr(Field, CIBINN) do
      Problem(Field, 'это ИНН Банка');
  end;

begin
  with Plat do
  begin
    {2009
    if CheckMode = Plt then
    begin
      RepPart := 'ВЕРСИЯ ПРОГРАММЫ';
      if Ver < StrToInt(LastKnownGoodVer) then
        Problem(Version, 'НЕ СООТВЕТСТВУЕТ ФОРМАТУ ЦБ 2003!')
      else
      begin
        testDate := RStrToDate(Version);
        if testDate < RStrToDate(LastKnownGoodVersion) then
          Problem(Version, 'обновите версию');
      end;
    end; //CheckMode = Plt
    2009}

    //---------------------------------------------------------
    RepPart := {3}'Номер док.';
      while NotDigits(DocNo) do
        Problem(DocNo, 'не число');
      {2009
      if CheckMode = Plt then
      begin
        if not AnsiSameStr(BIC2, CIBBIC) then
        begin
          if NotIn(DocNo, 1, 999) then
            Problem(DocNo, 'превышает 999 в другой банк');
          if AnsiEndsStr('000', DocNo) then
            Problem(DocNo, 'на конце 000 в другой банк');
        end;
      end; //CheckMode = Plt
      2009}

    RepPart := {4}'Дата док.';
      if (OpKind = '01') then //Платежное поручение и только
        while NotIn(DocDate, Now - DAYS_AFTER, Now + DAYS_BEFORE) do
          Problem(DocDate, 'не в -%d..+%d дней', [DAYS_AFTER, DAYS_BEFORE]);

    RepPart := {7}'Сумма плат.';
      while NotSum(Sum) do
        Problem(Sum, 'не сумма');

    RepPart := {21}'Очер. плат.';
      if
        {2009
        (CheckMode = Dbf) and
        2009}
        (Length(Queue) > 1) then
        Queue := AnsiRightStr(Queue, 1);
      ProbEx(Queue, REGEXP_QUE, 'не 1..5');

    //---------------------------------------------------------
    RepPart := {60}'ИНН плат.';
      VerifyINN(INN, LS);

    RepPart := {102}'КПП плат.';
      ProbEx(KPP, REGEXP_KPP, 'не 9 цифр или 0');

    RepPart := {9}'Счет плат.';
      ProbEx(LS, REGEXP_LS, 'не 20 цифр');
      {2009
      if CheckMode = Plt then
      begin
        testInt := StrToIntDef(AnsiRightStr(LS, 4), -2);
        if testInt <> StrToIntDef(FileExt, -1) then
          Problem(LS, 'не соответствует файлу доставки');
      end;
      2009}
      while not ValidLSKey(CIBBIC, LS) do
        Problem(LS, 'не соответствует ключу БИК');

    //---------------------------------------------------------
    {2009
    if CheckMode = Plt then
    begin
      RepPart := {8]'Плательщик';
        VerifyText(Name, 3, 160);

      RepPart := 'Файл не соответствует';           /////////////////////////////////
        if not AnsiEndsStr(FileExt, LS) then
          Problem(FileExt, 'иной счет');
        if not AnsiSameStr(AnsiMidStr(FileNameExt, 2, 1), AnsiRightStr(DocDate, 1)) then
          Problem(DocDate, 'иной год');
        if not AnsiSameText(AnsiMidStr(FileNameExt, 3, 1), To36(AnsiMidStr(DocDate, 4, 2))) then
          Problem(DocDate, 'иной месяц');
        if not AnsiSameStr(AnsiMidStr(FileNameExt, 4, 2), AnsiLeftStr(DocDate, 2)) then
          Problem(DocDate, 'иной день');
        testInt := StrToIntDef(AnsiMidStr(FileNameExt, 6, 3), 0);
        if (testInt mod 1000) <> (StrToInt(DocNo) mod 1000) then
          Problem(DocNo, 'иной номер');
    end; //CheckMode = Plt
    2009}

    //---------------------------------------------------------
    RepPart := {16}'Получатель';
      VerifyText(Name2, 3, 160);

    RepPart := {61}'ИНН получ.';
      VerifyINN(INN2, LS2);

    RepPart := {103}'КПП получ.';
      ProbEx(KPP2, REGEXP_KPP, 'не 9 цифр или 0');

    RepPart := {14}'БИК банка получ.';
      ProbEx(BIC2, REGEXP_BIC, 'не 9 цифр');

    RepPart := {17}'Счет получ.';
      ProbEx(LS2, REGEXP_LS, 'не 20 цифр');
      while not ValidLSKey(BIC2, LS2) do
        Problem(LS2, 'не соответствует ключу БИК');

    //---------------------------------------------------------
    {2009
    if CheckBIC then
    begin
      RepPart := {13]'Банк получателя';
      if BnkSeek.FindRec('NEWNUM', BIC2) then
      begin
        //RepPart := {15] 'К/С банка получателя';
        {
        testStr := BnkSeek.Value('KSNP');
        if Length(KS2) > 0 then
          while not AnsiSameStr(KS2, testStr) do
            Problem(KS2, 'не совпадает со Справочником банков')
        else
          KS2 := testStr;
        ]

        testStr := BnkSeek.Value('REAL');
        if Length(testStr) > 0 then
        begin
          if AnsiContainsText('ИЗМР,ЗСЧТ', testStr) and
            (BnkSeek.Value('DATE_CH') < RDateToS(Now)) then
            Problem(BIC2, 'запрещен к расчетам!');
        end;
      end
      else
        Problem(BIC2, 'не найден в Справочнике банков');
    end; //CheckBIC
    2009}

    //---------------------------------------------------------
    RepPart := {101}'Статус налогоплательщика';
      if NotIn(Queue, '15') then
        while Length(SS) = 0 do
          Problem(SS, 'пуст при очер. не 5');
      if AnsiStartsStr('40101', LS2) then
        while Length(SS) = 0 do
          Problem(SS, 'пуст для бюдж. счета 40101');
      if AnsiStartsStr('40314', LS2) then
        while Length(SS) = 0 do
          Problem(SS, 'пуст для тамож. счета 40314');

    if Length(SS) > 0 then
    begin
      ProbEx(SS, REGEXP_SS, 'не 01..20'); //2010

      RepPart := {104}'Код бюдж. классификации';
        if AnsiStartsStr('40101', LS2) then
          ProbEx(NAL1, REGEXP_NAL1, 'не 20 цифр');
        if AnsiStartsStr('40314', LS2) then
          ProbEx(NAL1, REGEXP_NAL1T, 'не цифры');

      RepPart := {105}'Код ОКАТО';
        ProbEx(NAL2, REGEXP_NAL2, 'не цифры');

      RepPart := {106}'Основание платежа';
        //2009 ProbEx(NAL3, REGEXP_NAL3, 'не 2 буквы');
        //2010
        if Length(NAL3) = 0 then
          Problem(NAL3, 'пусто и не 0');
        if NAL3 = '0' then
          TaxMode := Zero
        else if ExecRegExpr(REGEXP_NAL3, NAL3) then
          TaxMode := Budget
        else if ExecRegExpr(REGEXP_NAL3T, NAL3) then
          TaxMode := Customs
        else
          Problem(NAL3, 'не 2 буквы');

      if TaxMode = Budget then
      begin
      RepPart := {107}'Налог. период';
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
        ProbEx(NAL4, REGEXP_NAL4, 'не 2 буквы или дата');
        if NAL4 <> '0' then
        begin
          if Length(NAL4) > 5 then
          begin
            NAL4[3] := '.';
            NAL4[6] := '.';
          end;
          case NAL4[1] of
            'Д', 'М':
              repeat
                testStr := NAL4;
                testStr[1] := '0';
                testStr[2] := '1';
                if TryStrToDate(testStr, testDate) then
                  Break;
                Problem(NAL4, 'не типа Д или МС');
              until False;
            'К', 'П', 'Г':
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
                Problem(NAL4, 'не типа КВ, ПЛ или ГД');
              until False;
            else //date
              repeat
                testStr := NAL4;
                if TryStrToDate(testStr, testDate) then
                  Break;
                Problem(NAL4, 'не дата');
              until False;
          end;
        end;
      end
      else if TaxMode = Customs then
      begin
      RepPart := {107}'Код тамож. органа';
          if Length(NAL4) = 0 then
            Problem(NAL4, 'пуст и не 0');
      end
      else {TaxMode = Zero}
      begin
      RepPart := {107}'Поле 107';
          if Length(NAL4) = 0 then
            Problem(NAL4, 'пусто и не 0');
      end;

      RepPart := {108}'Номер налог. документа';
        VerifyText(NAL5, 1, 15);

      RepPart := {109}'Дата налог. документа';
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
        ProbEx(NAL6, REGEXP_NAL6, 'не 10 знаков');
        if NAL6 <> '0' then
          while not TryStrToDate(NAL6, testDate) do
            Problem(NAL6, 'не дата');

      RepPart := {110}'Тип налог. документа';
        //2009 ProbEx(NAL7, REGEXP_NAL7, 'не 2 буквы');
        //2010
        if Length(NAL7) = 0 then
          Problem(NAL7, 'пуст и не 0');
        if NAL7 = '0' then
          TaxMode := Zero
        else if ExecRegExpr(REGEXP_NAL7, NAL7) then
          TaxMode := Budget
        else if ExecRegExpr(REGEXP_NAL7T, NAL7) then
          TaxMode := Customs
        else
          Problem(NAL7, 'не 2 буквы');
    end;

    //---------------------------------------------------------
    RepPart := {24}'Назначение';
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
        ProbEx(Details, REGEXP_VO, 'нет {VO и т.д.');
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
            raise Exception.Create('Успешно протестирован');

          1: //work
            begin
              {$IFNDEF DEBUG]
              for testInt := 0 to DAYS_AFTER do
              begin
                testStr := Format(MAIL_ARCH, [PathYMD(-testInt)]) + FileNameExt;
                if FileExists(testStr) then
                  if testInt = 0 then
                    raise Exception.Create('ПОВТОРНО (сегодня)')
                  else
                    raise Exception.CreateFmt('ПОВТОРНО (%d %s назад)',
                      [testInt, REndStr(testInt, 'день', 'дня', 'дней')]);
              end;
              {$ENDIF]
            end;

          2: //blocked
            raise Exception.Create('Приостановлен');

          3: //retired
            raise Exception.Create('Искл. из системы');

          else //unused
            raise Exception.Create('Не обслуживается');
        end;
      end;
    end; //CheckMode = Plt
    2009}
  end;
end;

end.
