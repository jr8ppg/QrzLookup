unit UOptions;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Samples.Spin;

type
  TformOptions = class(TForm)
    Panel1: TPanel;
    buttonOK: TButton;
    buttonCancel: TButton;
    groupSelectSite: TGroupBox;
    radioSelectQRZ: TRadioButton;
    radioSelectQRZCQ: TRadioButton;
    groupLinkLogger: TGroupBox;
    radioLinkLogger0: TRadioButton;
    radioLinkLogger1: TRadioButton;
    radioLinkLogger2: TRadioButton;
    radioLinkLogger3: TRadioButton;
    spinScanInterval: TSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    spinKeepAliveIntervalMin: TSpinEdit;
    Label4: TLabel;
    groupQRZInfo: TGroupBox;
    editQRZUserID: TEdit;
    editQRZPassword: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    groupQRZCQInfo: TGroupBox;
    Label7: TLabel;
    Label8: TLabel;
    editQRZCQUserid: TEdit;
    editQRZCQPassword: TEdit;
    radioLinkLogger4: TRadioButton;
    Label9: TLabel;
    editUdpPort: TEdit;
    GroupBox1: TGroupBox;
    radioQueryOption1: TRadioButton;
    radioQueryOption2: TRadioButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private êÈåæ }
    procedure SetSite(v: Integer);
    function GetSite(): Integer;
    procedure SetKeepAliveMin(v: Integer);
    function GetKeepAliveMin(): Integer;
    procedure SetUserId(Index: Integer; v: string);
    function GetUserId(Index: Integer): string;
    procedure SetPassword(Index: Integer; v: string);
    function GetPassword(Index: Integer): string;
    procedure SetLinkLogger(v: Integer);
    function GetLinkLogger(): Integer;
    procedure SetScanInterval(v: Integer);
    function GetScanInterval(): Integer;
    procedure SetUdpPort(v: Integer);
    function GetUdpPort(): Integer;
    procedure SetQueryOption(v: Integer);
    function GetQueryOption(): Integer;
  public
    { Public êÈåæ }
    property Site: Integer read GetSite write SetSite;
    property KeepAliveMin: Integer read GetKeepAliveMin write SetKeepAliveMin;
    property UserId[Index: Integer]: string read GetUserId write SetUserId;
    property Password[Index: Integer]: string read GetPassword write SetPassword;
    property LinkLogger: Integer read GetLinkLogger write SetLinkLogger;
    property ScanInterval: Integer read GetScanInterval write SetScanInterval;
    property UdpPort: Integer read GetUdpPort write SetUdpPort;
    property QueryOption: Integer read GetQueryOption write SetQueryOption;
  end;

implementation

{$R *.dfm}

procedure TformOptions.FormCreate(Sender: TObject);
begin
   radioSelectQRZ.Checked := True;
   radioLinkLogger0.Checked := True;
   editQRZUserId.Text := '';
   editQRZPassword.Text := '';
   editQRZCQUserId.Text := '';
   editQRZCQPassword.Text := '';
end;

procedure TformOptions.FormDestroy(Sender: TObject);
begin
//
end;

procedure TformOptions.FormShow(Sender: TObject);
begin
//
end;

procedure TformOptions.SetSite(v: Integer);
begin
   case v of
      0: radioSelectQRZ.Checked := True;
      1: radioSelectQRZCQ.Checked := True;
   end;
end;

function TformOptions.GetSite(): Integer;
begin
   if radioSelectQRZ.Checked = True then begin
      Result := 0;
   end
   else begin
      Result := 1;
   end;
end;

procedure TformOptions.SetKeepAliveMin(v: Integer);
begin
   spinKeepAliveIntervalMin.Value := v;
end;

function TformOptions.GetKeepAliveMin(): Integer;
begin
   Result := spinKeepAliveIntervalMin.Value;
end;

procedure TformOptions.SetUserId(Index: Integer; v: string);
begin
   case Index of
      0: editQRZUserId.Text := v;
      1: editQRZCQUserId.Text := v;
   end;
end;

function TformOptions.GetUserId(Index: Integer): string;
begin
   case Index of
      0: Result := editQRZUserId.Text;
      1: Result := editQRZCQUserId.Text;
   end;
end;

procedure TformOptions.SetPassword(Index: Integer; v: string);
begin
   case Index of
      0: editQRZPassword.Text := v;
      1: editQRZCQPassword.Text := v;
   end;
end;

function TformOptions.GetPassword(Index: Integer): string;
begin
   case Index of
      0: Result := editQRZPassword.Text;
      1: Result := editQRZCQPassword.Text;
   end;
end;

procedure TformOptions.SetLinkLogger(v: Integer);
begin
   case v of
      0: radioLinkLogger0.Checked := True;
      1: radioLinkLogger1.Checked := True;
      2: radioLinkLogger2.Checked := True;
      3: radioLinkLogger3.Checked := True;
      4: radioLinkLogger4.Checked := True;
   end;
end;

function TformOptions.GetLinkLogger(): Integer;
begin
   if radioLinkLogger0.Checked = True then begin
      Result := 0;
   end
   else if radioLinkLogger1.Checked = True then begin
      Result := 1;
   end
   else if radioLinkLogger2.Checked = True then begin
      Result := 2;
   end
   else if radioLinkLogger3.Checked = True then begin
      Result := 3;
   end
   else if radioLinkLogger4.Checked = True then begin
      Result := 4;
   end;
end;

procedure TformOptions.SetScanInterval(v: Integer);
begin
   spinScanInterval.Value := v;
end;

function TformOptions.GetScanInterval(): Integer;
begin
   Result := spinScanInterval.Value;
end;

procedure TformOptions.SetUdpPort(v: Integer);
begin
   editUdpPort.Text := IntToStr(v);
end;

function TformOptions.GetUdpPort(): Integer;
begin
   Result := StrToIntDef(editUdpPort.Text, 12060);
end;

procedure TformOptions.SetQueryOption(v: Integer);
begin
   if v = 0 then begin
      radioQueryOption1.Checked := True;
   end
   else begin
      radioQueryOption2.Checked := True;
   end;
end;

function TformOptions.GetQueryOption(): Integer;
begin
   if radioQueryOption1.Checked = True then begin
      Result := 0;
   end
   else begin
      Result := 1;
   end;
end;

end.
