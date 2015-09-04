unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Dialogs,
  ExtCtrls,
  PingUnit, ShutdownUnit, LogUnit;

type
  TPingDownService = class(TService)
    Timer1: TTimer;
    procedure ServiceExecute(Sender: TService);
    procedure Timer1Timer(Sender: TObject);
    procedure ServicePause(Sender: TService; var Paused: Boolean);
    procedure ServiceContinue(Sender: TService; var Continued: Boolean);
    procedure ServiceAfterInstall(Sender: TService);
    procedure ServiceAfterUninstall(Sender: TService);
    procedure ServiceCreate(Sender: TObject);
    procedure ServiceDestroy(Sender: TObject);
    procedure ServiceShutdown(Sender: TService);
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServiceBeforeInstall(Sender: TService);
  private
    { Private declarations }
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  PingDownService: TPingDownService;
//resourcestring
  LOG_PING:AnsiString = 'LOG[Y]';
  LogIt: Boolean = true;
                 //[123.567.901.345]
  IP_PING1: AnsiString = 'PING1[wins3          ]';
  IP_PING2: AnsiString = 'PING2[sql3           ]';
  IP_PING3: AnsiString = 'PING3[bankier        ]';
  IP_PING4: AnsiString = 'PING4[wins0          ]';
  IP_PING5: AnsiString = 'PING5[wins5          ]';
  IP_PING6: AnsiString = 'PING6[goblin         ]';
  IP_PING7: AnsiString = 'PING7[               ]';
  IP_PING8: AnsiString = 'PING8[               ]';
  IP_PING9: AnsiString = 'PING9[               ]';

implementation

{$R *.DFM}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  PingDownService.Controller(CtrlCode);
end;

function TPingDownService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TPingDownService.ServiceAfterInstall(Sender: TService);
begin
  if LogIt then Log('Install');
end;

procedure TPingDownService.ServiceAfterUninstall(Sender: TService);
begin
  if LogIt then Log('Uninstall');
end;

procedure TPingDownService.ServiceBeforeInstall(Sender: TService);
begin
  //
end;

procedure TPingDownService.ServiceContinue(Sender: TService;
  var Continued: Boolean);
begin
  if LogIt then Log('Continue');
  Timer1.Enabled := True;
end;

procedure TPingDownService.ServiceCreate(Sender: TObject);
begin
  if LogIt then Log('Create');
end;

procedure TPingDownService.ServiceDestroy(Sender: TObject);
begin
  if LogIt then Log('Exit');
end;

procedure TPingDownService.ServiceExecute(Sender: TService);
begin
  if LogIt then Log('Execute');
  //Timer1.Enabled := True;
  while not Terminated do
    ServiceThread.ProcessRequests(True); //wait for termination
  //Timer1.Enabled := False;
end;

procedure TPingDownService.ServicePause(Sender: TService; var Paused: Boolean);
begin
  if LogIt then Log('Pause');
  Timer1.Enabled := False;
end;

procedure TPingDownService.ServiceShutdown(Sender: TService);
begin
  if LogIt then Log('Shutdown');
end;

procedure TPingDownService.ServiceStart(Sender: TService; var Started: Boolean);
begin
  if LogIt then Log('Start');
  Timer1.Enabled := True;
end;

procedure TPingDownService.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  if LogIt then Log('Stop');
  Timer1.Enabled := False;
end;

procedure TPingDownService.Timer1Timer(Sender: TObject);
var
  IP1, IP2, IP3, IP4, IP5, IP6, IP7, IP8, IP9: AnsiString;
begin
  IP1 := Trim(Copy(IP_PING1, 7, 15));
  IP2 := Trim(Copy(IP_PING2, 7, 15));
  IP3 := Trim(Copy(IP_PING3, 7, 15));
  IP4 := Trim(Copy(IP_PING4, 7, 15));
  IP5 := Trim(Copy(IP_PING5, 7, 15));
  IP6 := Trim(Copy(IP_PING6, 7, 15));
  IP7 := Trim(Copy(IP_PING7, 7, 15));
  IP8 := Trim(Copy(IP_PING8, 7, 15));
  IP9 := Trim(Copy(IP_PING9, 7, 15));

  //LogIt := (Copy(LOG_PING, 5, 1) = 'Y');
  if LogIt then
  begin
    Log('Ping1 ' + IP1);
    if Ping(IP1) then
      Log('Ping1 ' + IP1 + ' ok');
    Log('Ping2 ' + IP2);
    if Ping(IP2) then
      Log('Ping2 ' + IP2 + ' ok');
    Log('Ping3 ' + IP3);
    if Ping(IP3) then
      Log('Ping3 ' + IP3 + ' ok');
    Log('Ping4 ' + IP4);
    if Ping(IP4) then
      Log('Ping4 ' + IP4 + ' ok');
    Log('Ping5 ' + IP5);
    if Ping(IP5) then
      Log('Ping5 ' + IP5 + ' ok');
    Log('Ping6 ' + IP6);
    if Ping(IP6) then
      Log('Ping6 ' + IP6 + ' ok');
    Log('Ping7 ' + IP7);
    if Ping(IP7) then
      Log('Ping7 ' + IP7 + ' ok');
    Log('Ping8 ' + IP8);
    if Ping(IP8) then
      Log('Ping8 ' + IP8 + ' ok');
    Log('Ping9 ' + IP9);
    if Ping(IP9) then
      Log('Ping9 ' + IP9 + ' ok');
{
    else if Ping(IP2) then
      Log('Ping ' + IP2)
    else if Ping(IP3) then
      Log('Ping ' + IP3)
    else if Ping(IP4) then
      Log('Ping ' + IP4)
    else if Ping(IP5) then
      Log('Ping ' + IP5)
    else if Ping(IP6) then
      Log('Ping ' + IP6)
    else if Ping(IP7) then
      Log('Ping ' + IP7)
    else if Ping(IP8) then
      Log('Ping ' + IP8)
    else if Ping(IP9) then
      Log('Ping ' + IP9)
    else
    begin
      Log('WAR!');
      ShowMessage(DateTimeToStr(Now) + ' WAR!');
    end
}
  end
  else
  begin
    if Ping(IP1) then
    else if Ping(IP2) then
    else if Ping(IP3) then
    else if Ping(IP4) then
    else if Ping(IP5) then
    else if Ping(IP6) then
    else if Ping(IP7) then
    else if Ping(IP8) then
    else if Ping(IP9) then
    else
      MyExitWindows(EWX_SHUTDOWN or EWX_FORCE or EWX_POWEROFF);
  end;
end;

end.
