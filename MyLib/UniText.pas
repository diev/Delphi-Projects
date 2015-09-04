unit UniText;

interface

uses
  Grids, Classes, SysUtils;

const
  ItemSeparator = '^';
  LineFeed = #10;

procedure ReadUniText(AGrid: TStringGrid; AFileName: string);
procedure ReadUniTextFields(AGrid: TStringGrid; AFileName: string);

implementation

uses
  Russian;

procedure ReadUniText(AGrid: TStringGrid; AFileName: string);
var
  StringList, ItemList: TStringList;
  S: string;
  R, C: Integer;
begin
  StringList := TStringList.Create;
  ItemList := TStringList.Create;
  try
    StringList.LoadFromFile(AFileName);
    AGrid.RowCount := StringList.Count + 1;
    for R := 1 to StringList.Count do
    begin
      S := StringList[R - 1];
      ItemList.Text := StringReplace(S, ItemSeparator, LineFeed, [rfReplaceAll]);
      if (ItemList.Count + 1) > AGrid.ColCount then
        AGrid.ColCount := ItemList.Count + 1;
      for C := 1 to ItemList.Count do
        AGrid.Cells[C, R] := RWin(ItemList[C - 1]);
    end;
  finally
    StringList.Free;
    ItemList.Free;
  end;
end;

procedure ReadUniTextFields(AGrid: TStringGrid; AFileName: string);
var
  StringList, ItemList: TStringList;
  S: string;
  R, C: Integer;
begin
  StringList := TStringList.Create;
  ItemList := TStringList.Create;
  try
    StringList.LoadFromFile(AFileName);
    AGrid.ColCount := StringList.Count + 1;
    for C := 1 to StringList.Count do
    begin
      S := StringList[C - 1];
      ItemList.Text := StringReplace(S, ItemSeparator, LineFeed, [rfReplaceAll]);
      if (ItemList.Count + 1) > AGrid.RowCount then
        AGrid.RowCount := ItemList.Count + 1;
      for R := 1 to ItemList.Count do
        AGrid.Cells[C, R] := RWin(ItemList[R - 1]);
    end;
  finally
    StringList.Free;
    ItemList.Free;
  end;
end;

end.
