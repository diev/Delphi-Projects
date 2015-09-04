program CheckIn10;

{$APPTYPE CONSOLE}

//Don't forget to switch {.$DEFINE DEBUG} in Globals!!!


uses
  SysUtils,
  StrUtils,
  Globals,
  Russian,
  {Pgp2dll,}
  {2009
  Clients,
  BClientFmt,
  2009}
  Checks,
  Rules,
  Bankier,
  FineReaderFmt,
  BankUtils;

var
  SearchRec: TSearchRec;
  FileAttrs: Integer;
  S: string;

begin
  try
    {2009
    if (ParamCount = 3) and (ParamStr(3) = '/1') then
    with Plat do
    begin
      CheckMode := Plt;
      FilePath := ExtractFilePath(ParamStr(1));
      FileNameExt := ExtractFileName(ParamStr(1));
      FileExt := ExtractFileExt(FileNameExt);
      Delete(FileExt, 1, 1);
      InFileName := FilePath + FileNameExt;
      RepFileName := ParamStr(2);
      LoadFromFile;
      VerifyRules;

      CheckMode := Unix;
      AppendMessage(BankierUniString + #10, UNITEXT);
      //AppendLogMessage('%s добавлен в Банкир', [FileNameExt]);
      S := Format('%-13s', [FileNameExt]);
      AppendLogMessage(S);
      AppendLogMessage(S, RepFileName);
      Halt(0);
    end;

    if (ParamCount = 2) and (ParamStr(2) = '/2') then
    with Plat do
    begin
      CheckMode := Plt;
      FilePath := ExtractFilePath(ParamStr(1));
      FileNameExt := ExtractFileName(ParamStr(1));
      FileExt := ExtractFileExt(FileNameExt);
      Delete(FileExt, 1, 1);
      InFileName := FilePath + FileNameExt;
      //RepFileName := ParamStr(2);
      LoadFromFile;
      //VerifyRules;

      CheckMode := Unix;
      AppendMessage(BankierUniString + #10, UNITEXT);
      //AppendLogMessage('%s добавлен в Банкир', [FileNameExt]);
      S := Format('%-13s догружен', [FileNameExt]);
      AppendLogMessage(S);
      //AppendLogMessage(S, RepFileName);
      Halt(0);
    end;
    2009}

    if ParamCount <> 2 then
      raise Exception.Create('Нет 2 параметров: файл/маска и log!');

//    if AnsiContainsText(InFile, '*') or
//       AnsiContainsText(InFile, '?') then
//    begin

    with Plat do
    begin
      RepFileName := ParamStr(2);

      FilePath := ExtractFilePath(ParamStr(1));
      //if not AnsiEndsStr('\', FilePath) then
        //FilePath := FilePath + '\';

      FileAttrs := faArchive;
      if FindFirst(ParamStr(1), FileAttrs, SearchRec) = 0 then
      try
        repeat
          FileNameExt := SearchRec.Name;
          //2009
          //FileExt := ExtractFileExt(FileNameExt);
          //Delete(FileExt, 1, 1);
          InFileName := FilePath + FileNameExt;

          //2009
          //if AnsiEndsText('dbf', FileExt) then
          //begin
            CheckMode := Dbf;
            if LoadFromDbfFile then
            begin
              S := FilePath + 'BAK\' + PathYMD(Now);
              ForceDirectories(S);
              S := S + '\' + FormatDateTime('hhnn', Now) + FileNameExt;
              if not RenameFile(InFileName, S) then
              begin
                if not DeleteFile(InFileName) then
                  Exception.CreateFmt('Не удалить загруженный файл %s', [InFileName]);
              end
              else
                Exception.CreateFmt('Не вынести загруженный файл %s в %s', [InFileName, S]);
            end;
          //2009
          //end;
          {2009
          else if NotDigits(FileExt) then
            //skip .log, .exe, etc...
          else
            try
              CheckMode := Plt;
              LoadFromFile;
              VerifyRules;
              CheckMode := Unix;
              AppendMessage(BankierUniString + #10, UNITEXT);
              S := Format('%-13s', [FileNameExt]);
              AppendLogMessage(S);
              AppendLogMessage(S, RepFileName);

              if RenameFile(InFileName, FilePath + 'BAK\o' + Copy(FileNameExt, 2, 255)) then
              begin
                //if not DeleteFile(InFileName) then
                  //Exception.CreateFmt('Не удалить загруженный файл %s', [InFileName]);
              end
              else
                Exception.CreateFmt('Не вынести в BAK загруженный файл %s', [InFileName]);
            except
              on E: Exception do
              begin
                S := Format('%-13s %s', [FileNameExt, E.Message]);
                AppendLogMessage(S);
                AppendLogMessage(S, RepFileName);

                RenameFile(InFileName, FilePath + 'BAK\e' + Copy(FileNameExt, 2, 255));
                //Halt(1);
              end;
            end;
          2009}

        until FindNext(SearchRec) <> 0;
      finally
        FindClose(SearchRec);
      end
      else //if not FileExists(InFileName) then
        raise Exception.CreateFmt('Нет исходных файлов - %s', [ParamStr(1)]);
    end;

  {
  if CheckPgp then
    InFileName := PGPOutPath + InFileName
  else
    raise Exception.Create('Файл не имеет подписи!');
  }

  except
    on E: Exception do
    with Plat do
    begin
      case CheckMode of

      {2009
      Plt:
        begin
          S := Format('%-13s %s', [FileNameExt, E.Message]);
          AppendLogMessage(S);
          AppendLogMessage(S, RepFileName);
          Halt(1);
        end;
      2009}

      Unix:
        begin
          AppendLogMessage('%-13s НЕ добавлен в Банкир!', [FileNameExt]);
          Halt(0);
        end;

      else

      end;
    end;
  end;

  Halt(0);

end.
