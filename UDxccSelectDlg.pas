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
    procedure ListView1ColumnClick(Sender: TObject; Column: TListColumn);
    procedure ListView1Compare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
  private
    { Private êÈåæ }
    FPrevSortColumnNo: Integer;
    FSortDirectionAsc: Boolean;
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
   FPrevSortColumnNo := -1;
   FSortDirectionAsc := True;
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

procedure TformDxccSelectDialog.ListView1ColumnClick(Sender: TObject; Column: TListColumn);
begin
   if FPrevSortColumnNo = Column.Index then begin
      FSortDirectionAsc := Not FSortDirectionAsc;
   end;

   ListView1.CustomSort(nil, Column.Index);

   FPrevSortColumnNo := Column.Index;
end;

procedure TformDxccSelectDialog.ListView1Compare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
begin
   if Data = 0 then begin
      Compare := StrToIntDef(Item1.Caption, 0) - StrToIntDef(Item2.Caption, 0);
   end
   else begin
      Compare := CompareText(Item1.SubItems[Data - 1], Item2.SubItems[Data - 1]);
   end;

   if FSortDirectionAsc = False then begin
      Compare := Compare * -1;
   end;
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
