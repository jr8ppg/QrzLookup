unit UDxccSelectDlg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  Dxcc;

type
  TformDxccSelectDialog = class(TForm)
    Panel1: TPanel;
    buttonOK: TButton;
    buttonCancel: TButton;
    ListView1: TListView;
    procedure FormShow(Sender: TObject);
    procedure ListView1SelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure ListView1DblClick(Sender: TObject);
  private
    { Private êÈåæ }
    FSelDxcc: TDxccObject;
  public
    { Public êÈåæ }
    property SelDxcc: TDxccObject read FSelDxcc;
  end;

implementation

uses
  Main;

{$R *.dfm}

procedure TformDxccSelectDialog.FormCreate(Sender: TObject);
begin
   FSelDxcc := nil;
end;

procedure TformDxccSelectDialog.FormShow(Sender: TObject);
var
   i: Integer;
   listitem: TListItem;
   dxcc: TDxccObject;
begin
   for i := 0 to formMain.DxccList.Count - 1 do begin
      dxcc := formMain.DxccList[i];
      listitem := ListView1.Items.Add();

      listitem.Caption := IntToStr(dxcc.Number);
      listitem.SubItems.Add(dxcc.Country);
      listitem.SubItems.Add(dxcc.Continent);
      listitem.SubItems.Add(dxcc.CQZone);
      listitem.SubItems.Add(dxcc.ITUZone);
      listitem.Data := dxcc;
   end;

   ListView1.Selected := nil;
   buttonOK.Enabled := False;
end;

procedure TformDxccSelectDialog.ListView1DblClick(Sender: TObject);
begin
   if ListView1.Selected <> nil then begin
      buttonOK.Click();
   end;
end;

procedure TformDxccSelectDialog.ListView1SelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
   if Selected = True then begin
      FSelDxcc := TDxccObject(Item.Data);
   end
   else begin
      FSelDxcc := nil;
   end;

   buttonOK.Enabled := Selected;
end;

end.
