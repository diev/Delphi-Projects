unit Bankier;

interface

  function BankierUniString: string;

implementation
uses
  SysUtils,
  StrUtils,
  Globals,
  Russian;

function BankierUniString: string;
var
  //T: string;
  local: Boolean;
  //b790, b791: Boolean;
begin
  with Plat do
  begin
    local := (BIC2 = CIBBIC);
    //b790 := False; //(BIC2 = '044030790');
    //b791 := False; //(BIC2 = '044030791');

    {01} Result := RDateToS(DocDate) + '^';
    {02} Result := Result + DocNo + '^';
    {03} Result := Result + OpKind + '^'; //01 - ПП, 02 - ПТ, 06 - ИП
    {04} {if local then
           Result := Result + 'C^'
         else}
           Result := Result + 'A^';
    {05} Result := Result + '^';
    {06} Result := Result + '^';
    {07} Result := Result + '^';
    {08} Result := Result + '^';
    {09} if local then
           Result := Result + '801^'
         else
           Result := Result + '802^';
    {10} Result := Result + '4^';
         {if OpKind = '02' then //2009 - ПТ
           Result := Result + '1^'
         else
           Result := Result + '4^';}
    {11} Result := Result + '810^';
    {12} Result := Result + Sum + '^';
    {13} Result := Result + Sum + '^';
    {14} Result := Result + '^';
    {15} Result := Result + Queue + '^';
    {16} Result := Result + '^';
    {17} Result := Result + '^';
    {18} Result := Result + '^';
    {19} Result := Result + LS + '^';
    {20} Result := Result + '^';
    {21} Result := Result + '^';
    {22} Result := Result + '^';
    {23} Result := Result + CIBBIC + '^';
    {24} Result := Result + '^';
    {25} Result := Result + LS2 + '^';
    {26} Result := Result + {BIC2 +} '^';
    {27} {if b790 then
         begin
           T := AnsiMidStr(LS2, 10, 2);
           if (T = '14') or (T = '00') then
             Result := Result + KS2 + '^'
           else
             Result := Result + '30101810900000000790-' + T + '^';
         end
         else if b791 then
         begin
           T := AnsiMidStr(LS2, 10, 2);
           if (T = '14') or (T = '00') then
             Result := Result + KS2 + '^'
           else
             Result := Result + '30101810200000000791-' + T + '^';
         end
         else}
         Result := Result + KS2 + '^';
    {28} Result := Result + '^';
    {29} {if b790 or b791 then
           Result := Result + T + '^'
         else}
         Result := Result + BIC2 + '^';
    {30} Result := Result + '^';
    {31} Result := Result + RDos(Details) + '^'; //AnsiReplaceStr(Details, '!', ' ') + '^';
    {32} Result := Result + '^';
    {33} Result := Result + '^';
    {34} Result := Result + '^';
    {35} Result := Result + RDos(Name2) + '^'; //AnsiReplaceStr(Name2, '!', ' ') + '^';
    {36} Result := Result + '^';
    {37} Result := Result + '^';
    {38} Result := Result + '^';
    {39} Result := Result + '^';
    {40} Result := Result + '^';
    {41} Result := Result + '^';
    {42} Result := Result + '^';
    {43} Result := Result + '^';
    {44} Result := Result + '^';
    {45} Result := Result + '^';
    {46} Result := Result + '^';
    {47} Result := Result + '^';
    {48} Result := Result + 'e^';
    {49} Result := Result + LS + '^';
    {50} Result := Result + '^';
    {51} {2009
         if AnsiStartsStr('044030', BIC2) then  //A
           T := 'SM1'
         else if AnsiStartsStr('0440', BIC2) then //B
           T := 'SM2'
         else //C
           T := 'Э';
           {
               use (cWorkDir + 'bnkseek') shared read alias 'bnkseek' new
               //set index to bnkseek
               set index to (cWorkDir + 'bnkseek')
               seek (bic2)
               if found()
                   if bnkseek->UER = "1" //C
                      t = 'Э'
                   elseif bnkseek->UER = "3"
                      t = 'Э'
                   else
                      t = ' ' //P
                   endif
               else
                   t = 'Э'
                   alert('Банк '+bic2+' не найден!')
               endif
               close bnkseek
           ]
         Result := Result + T + '^';
         2009}
         if local then //2009
           Result := Result + '^'
         else
           Result := Result + 'SM1^';
    {52} Result := Result + '^';
    {53} {2009
         if CheckMode = Dbf then
           Result := Result + '26^'
         else
           Result := Result + '555^';
         2009}
         if OpKind = '01' then //2009 - ПП
           Result := Result + '26^'
         else
           Result := Result + '5^';
    {54} Result := Result + 'e^';
    {55} if local then
           Result := Result + LS2 + '^'
         else
           Result := Result + CIBKS + '^';
    {56} Result := Result + '^';
    {57} Result := Result + '^'; // dtos(ctod(cfg('action'))) + '^' // not used now
    {58} Result := Result + '^';
    {59} Result := Result + '^';
    {60} Result := Result + '^';
    {61} Result := Result + '^';
    {62} Result := Result + '^';
    {63} Result := Result + '^';
    {64} Result := Result + '^';
    {65} Result := Result + '^';
    {66} Result := Result + '^';
    {67} Result := Result + '^';
    {68} if OpKind = '02' then //2013 - ПТ
           Result := Result + AnsiChar(222) + 'PaytCondition:' + PaytCondition + '^'
         else
           Result := Result + '^';
    {69} Result := Result + '^';
    {70} Result := Result + '^';
    {71} Result := Result + '^';
    {72} Result := Result + '^';
    {73} {2009
         if CheckMode = Dbf then
           Result := Result + '243^'
         else
           Result := Result + '245^';
         2009}
         Result := Result + '243^'; //2009
    {74} Result := Result + '^';
    {75} Result := Result + INN + '^';
    {76} Result := Result + INN2 + '^';
    {77} Result := Result + '^';
    {78} Result := Result + '^';
    {79} Result := Result + '^';
    {80} Result := Result + '^';
    {81} Result := Result + '^';
    {82} Result := Result + '^';
    {83} Result := Result + '^';
    {84} Result := Result + '^';
    {85} Result := Result + '^';
    {86} Result := Result + '^';
    {87} Result := Result + '^';
    {88} Result := Result + '^';
    {89} Result := Result + '^';
    {90} Result := Result + '^';
    {91} Result := Result + '^';
    {92} Result := Result + KPP + '^';
    {93} Result := Result + KPP2 + '^';
    {94} Result := Result + SS + '^';
    {95} Result := Result + RDos(NAL1) + '^';
    {96} Result := Result + RDos(NAL2) + '^';
    {97} Result := Result + RDos(NAL3) + '^';
    {98} Result := Result + RDos(NAL4) + '^';
    {99} Result := Result + RDos(NAL5) + '^';
   {100} Result := Result + RDos(NAL6) + '^';
   {101} Result := Result + RDos(NAL7) + '^';
   {102} Result := Result + RDateToS(Now) + '^';

     //RWinToDos(Result);
   end;
end;

end.
