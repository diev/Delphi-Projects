unit FullScreen;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls;

type
  TFullScreenForm = class(TForm)
    Image: TImage;
    procedure FormCreate(Sender: TObject);
    procedure ImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

//function FullScreenPreview(Bitmap: TBitmap): Integer;
var
  FullScreenForm: TFullScreenForm;

implementation

{$R *.DFM}

{function FullScreenPreview(Bitmap: TBitmap): Integer;
var
  FullScreenForm: TFullScreenForm;
begin
  FullScreenForm := TFullScreenForm.Create(Application);
  try
    FullScreenForm.Image.Picture.Bitmap.Assign(Bitmap);
    Result := FullScreenForm.ShowModal;
  finally
    FullScreenForm.Free;
  end;
end;
}

procedure TFullScreenForm.FormCreate(Sender: TObject);
begin
  SetBounds(0, 0, Screen.Width, Screen.Height);
end;

procedure TFullScreenForm.ImageMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
    Close;
end;

procedure TFullScreenForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then
    Close;
end;

end.
