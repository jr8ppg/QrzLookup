program QrzLookup;

{$R 'resource.res' 'resource.rc'}
{$R *.dres}

uses
  Vcl.Forms,
  Winapi.Windows,
  System.SysUtils,
  Main in 'Main.pas' {formMain},
  WtUtils in 'WtUtils.pas',
  Dxcc in 'Dxcc.pas',
  Check in 'Check.pas' {formCheck},
  SelectZlog in 'SelectZlog.pas' {formSelectZLog},
  RbnFilter in 'RbnFilter.pas' {formRbnFilter},
  UMultipliers in 'UMultipliers.pas',
  Progress in 'Progress.pas' {formProgress},
  UOptions in 'UOptions.pas' {formOptions},
  UCustomListDlg in 'UCustomListDlg.pas' {formCustomListDialog},
  UStationDlg in 'UStationDlg.pas' {formStationDialog},
  Station in 'Station.pas',
  UDxccSelectDlg in 'UDxccSelectDlg.pas' {formDxccSelectDialog};

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
  Application.CreateForm(TformMain, formMain);
  Application.Run;
  ReleaseMutex(hMutex);
end.
