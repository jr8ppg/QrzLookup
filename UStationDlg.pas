unit UStationDlg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  UDxccSelectDlg;

type
  TformStationDialog = class(TForm)
    Panel1: TPanel;
    buttonOK: TButton;
    buttonCancel: TButton;
    Label1: TLabel;
    editCallsign: TEdit;
    Label2: TLabel;
    editCountry: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    editCQZone: TEdit;
    Label5: TLabel;
    editItuZone: TEdit;
    Label6: TLabel;
    comboContinent: TComboBox;
    comboState: TComboBox;
    buttonDxccSelect: TButton;
    editComment: TEdit;
    Label7: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure buttonDxccSelectClick(Sender: TObject);
  private
    { Private êÈåæ }
    FNewRecord: Boolean;
    procedure SetCallsign(v: string);
    function GetCallsign(): string;
    procedure SetCountry(v: string);
    function GetCountry(): string;
    procedure SetContinent(v: string);
    function GetContinent(): string;
    procedure SetCQZone(v: string);
    function GetCQZone(): string;
    procedure SetITUZone(v: string);
    function GetITUZone(): string;
    procedure SetState(v: string);
    function GetState(): string;
    procedure SetComment(v: string);
    function GetComment(): string;
  public
    { Public êÈåæ }
    property NewRecord: Boolean read FNewRecord write FNewRecord;
    property Callsign: string read GetCallsign write SetCallsign;
    property Country: string read GetCountry write SetCountry;
    property Continent: string read GetContinent write SetContinent;
    property CQZone: string read GetCQZone write SetCQZone;
    property ITUZone: string read GetITUZone write SetITUZone;
    property State: string read GetState write SetState;
    property Comment: string read GetComment write SetComment;
  end;

implementation

{$R *.dfm}

procedure TformStationDialog.FormCreate(Sender: TObject);
begin
   FNewRecord := True;
   editCallsign.Text := '';
   editCountry.Text := '';
   comboContinent.Text := '';
   editCQZone.Text := '';
   editITUZone.Text := '';
   comboState.Text := '';
   editComment.Text := '';
end;

procedure TformStationDialog.FormShow(Sender: TObject);
begin
   if FNewRecord = True then begin
      editCallsign.Color := clWindow;
      editCallsign.ReadOnly := False;
      editCallsign.SetFocus();
   end
   else begin
      editCallsign.Color := clBtnFace;
      editCallsign.ReadOnly := True;
      editCountry.SetFocus();
   end;
end;

procedure TformStationDialog.buttonDxccSelectClick(Sender: TObject);
var
   dlg: TformDxccSelectDialog;
begin
   dlg := TformDxccSelectDialog.Create(Self);
   try
      if dlg.ShowModal() <> mrOK then begin
         Exit;
      end;

      editCountry.Text := dlg.SelDxcc.Country;
      comboContinent.Text := dlg.SelDxcc.Continent;
      editCQZone.Text := dlg.SelDxcc.CQZone;
      editITUZone.Text := dlg.SelDxcc.ITUZone;
   finally
      dlg.Release();
   end;
end;

procedure TformStationDialog.SetCallsign(v: string);
begin
   editCallsign.Text := v;
end;

function TformStationDialog.GetCallsign(): string;
begin
   Result := EditCallsign.Text;
end;

procedure TformStationDialog.SetCountry(v: string);
begin
   editCountry.Text := v;
end;

function TformStationDialog.GetCountry(): string;
begin
   Result := editCountry.Text;
end;

procedure TformStationDialog.SetContinent(v: string);
var
   Index: Integer;
begin
   Index := comboContinent.Items.IndexOf(v);
   if Index = -1 then begin
      comboContinent.Text := v;
   end
   else begin
      comboContinent.ItemIndex := Index;
   end;
end;

function TformStationDialog.GetContinent(): string;
begin
   Result := comboContinent.Text;
end;

procedure TformStationDialog.SetCQZone(v: string);
begin
   editCQZone.Text := v;
end;

function TformStationDialog.GetCQZone(): string;
begin
   Result := editCQZone.Text;
end;

procedure TformStationDialog.SetITUZone(v: string);
begin
   editITUZone.Text := v;
end;

function TformStationDialog.GetITUZone(): string;
begin
   Result := editITUZone.Text;
end;

procedure TformStationDialog.SetState(v: string);
var
   Index: Integer;
begin
   Index := comboState.Items.IndexOf(v);
   if Index = -1 then begin
      comboState.Text := v;
   end
   else begin
      comboState.ItemIndex := Index;
   end;
end;

function TformStationDialog.GetState(): string;
begin
   Result := comboState.Text;
end;

procedure TformStationDialog.SetComment(v: string);
begin
   editComment.Text := v;
end;

function TformStationDialog.GetComment(): string;
begin
   Result := editComment.Text;
end;

end.

