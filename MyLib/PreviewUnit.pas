unit PreviewUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Menus;

type
  TPreviewForm = class(TForm)
    ScrollBox: TScrollBox;
    Image: TImage;
    PopupMenu: TPopupMenu;
    Exit: TMenuItem;
    Bevel: TBevel;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure ExitClick(Sender: TObject);
    procedure ScrollBoxMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure ImageMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    PrevX, PrevY: Integer;
  public
    { Public declarations }
  end;

var
  PreviewForm: TPreviewForm;

implementation

{$R *.dfm}

procedure TPreviewForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  case Ord(Key) of
    VK_Space, VK_Escape, VK_Return:
      ExitClick(Sender);
    8, VK_Up:
      Image.Top := Image.Top + 120;
    2, VK_Down:
      Image.Top := Image.Top - 120;
    6, VK_Right:
      Image.Left := Image.Left + 120;
    4, VK_Left:
      Image.Left := Image.Left - 120;
  end;
end;

procedure TPreviewForm.ExitClick(Sender: TObject);
begin
  Close;
end;

procedure TPreviewForm.ScrollBoxMouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
var
  H, W: Integer;
begin
  with Image do
  begin
  H := Height;
  W := Width;
  Stretch := True;
  if ssLeft in Shift then
  begin
    Top := 0;
    Height := Height - WheelDelta;
    Width := MulDiv(Height, W, H);
  end
  else
    if (Top < 0) and (WheelDelta > 0) then
      ScrollBox.ScrollBy(0, WheelDelta);
    if ((Top + Height) > ScrollBox.ClientHeight) and (WheelDelta < 0) then
      ScrollBox.ScrollBy(0, WheelDelta);
  Bevel.SetBounds(Left, Top, Width + 1,Height + 1);
  {
  Caption := Format('%d %d %d %d', [
    WheelDelta,
    Image.Top,
    Image.Top + Image.Height,
    ScrollBox.ClientHeight
    ]);
  }
  end;
  //ScrollBox.ScaleBy(3, 4);
  Handled := True;
end;

procedure TPreviewForm.FormCreate(Sender: TObject);
begin
  //ScrollBox.ScrollInView(Image);
end;

procedure TPreviewForm.ImageMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if ssLeft in Shift then
    with TImage(Sender) do
    begin
      SetBounds(Left + X - PrevX, Top + Y - PrevY, Width, Height);
      Bevel.SetBounds(Left, Top, Width + 1, Height + 1);
    end;
end;

procedure TPreviewForm.ImageMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  PrevX := X;
  PrevY := Y;
end;

end.
