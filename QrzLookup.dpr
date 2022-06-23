program QrzLookup;

{$R 'resource.res' 'resource.rc'}
{$R *.dres}

uses
  Vcl.Forms,
  Winapi.Windows,
  System.SysUtils,
  Main in 'Main.pas' {Form1},
  WtUtils in 'WtUtils.pas',
  Dxcc in 'Dxcc.pas',
  Check in 'Check.pas' {formCheck},
  SelectZlog in 'SelectZlog.pas' {formSelectZLog};

{$R *.res}

var
   hMutex: THANDLE;
   MutexName: string;
   ExeName: string;

begin
   ExeName := ExtractFileName(Application.ExeName);
   MutexName := ExeName + '_started';

   hMutex := OpenMutex(MUTEX_ALL_ACCESS, False, PChar(MutexName));
   if hMutex <> 0 then begin
      CloseHandle(hMutex);
      MessageBox(0, PChar(ExeName + ' は既に起動しています。タスクマネージャで確認して下さい.'), PChar(Application.Title), MB_OK or MB_ICONEXCLAMATION);
      Exit;
   end;
   hMutex := CreateMutex(nil, False, PChar(MutexName));

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
  ReleaseMutex(hMutex);
end.
