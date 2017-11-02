unit FineReaderFmt;

interface

  function LoadFromDbfFile: Boolean;

implementation
uses
  SysUtils,
  Dialogs,
  BankDBF,
  Russian,
  Rules,
  Bankier,
  Checks,
  Globals,
  BankUtils;

function LoadFromDbfFile: Boolean;
var
  InFile: TBankDBFReader;
  Rep, SOut, SLog: string;
  nOk, nErr, nTotal: Integer;
begin
  with Plat do
  begin
    InFile := TBankDBFReader.Create(InFileName);
    try
      SOut := '';
      SLog := '';
      nOk := 0;
      nErr := 0;

      with InFile do
      begin
        nTotal := RecCount;

        {//2009
        case FieldCount of
          35: begin
                S := '= Платежные поручения =';
                DocType := '01';
              end;
          31:
              begin
                S := '= Платежные требования =';
                DocType := '02';
              end;
          36:
              begin
                S := '= Инкассовые поручения =';
                DocType := '06';
              end;
          29:
              begin
                S := '= Платежные поручения старой версии =';
                DocType := '01';
              end;
          else
              begin
                S := '= НЕПОНЯТНЫЕ ДОКУМЕНТЫ! =';
                DocType := '00';
              end;
        end;
        }

        if YesNoBox('Загрузить %s?'#10'документов: %d', [FileNameExt, nTotal]) then
        begin
          while not EOF do
          begin
            DocNo   := Value('NUMBER');
            DocDate := Value('DATE');
            //Sum     := RStrToCurr(Value('SUM'));
            Sum     := Value('SUM');
            Queue   := Value('PAY_QUEUE');

            Details := Value('PAYMENT_AI');

            //Name    := ReadString('From', 'Name', '');
            INN     := Value('PAYER_INN');
            KPP     := Value('PAYER_KPP');
            LS      := Value('PAYER_ACC');

            Name2   := Value('RECIP');
            INN2    := Value('RECIP_INN');
            KPP2    := Value('RECIP_KPP');
            LS2     := Value('RECIP_ACC');
            BIC2    := Value('RECIP_BIC');
            //Bank2   := '';
            //Place2  := '';
            KS2     := Value('RECIP_KS');

            SS      := Value('TAX_STATUS');
            NAL1    := Value('KBK');
            NAL2    := Value('OKATO');
            NAL3    := Value('TAX_REASON');
            NAL4    := Value('TAX_PERIOD');
            NAL5    := Value('TAX_DOC_N');
            NAL6    := Value('TAX_DATE');
            NAL7    := Value('TAX_TYPE');

            //2009
            OpKind  := Value('OP_KIND');

            //2013
            if OpKind = '02' then
              PaytCondition := Value('PAY_COND');

            try
              VerifyRules;
              SOut := SOut + BankierUniString + #10;
              Inc(nOk);
            except
              on E: Exception do
              begin
                Rep := E.Message;
                SLog := SLog + #13#10 + Format('#%3d: %s', [RecNo, Rep]);
                Inc(nErr);
              end;
            end;
            GotoNext;
          end;
          if Length(SOut) > 0 then
          begin
            CheckMode := Unix;
            AppendMessage(SOut, UNISCAN);
            CheckMode := Dbf;
          end;
          if SLog = '' then
            SLog := Format(' %3d/%3d ok', [nOk, nTotal])
          else
            SLog := Format(' %3d/%3d ok, %3d errors: %s', [nOk, nTotal, nErr, SLog]);
          AppendLogMessage(FileNameExt + SLog, RepFileName);
        end
        //else //Load Canceled by User
      end;
    finally
      InFile.Free;
    end;
  end;
  MessageDlg(Format('Загружено: %d из %d,'#10'пропущено по ошибкам: %d',
    [nOk, nTotal, nErr]), mtInformation, [mbOk], 0);
  Result := True;
end;

end.
