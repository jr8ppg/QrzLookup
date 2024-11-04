unit UCustomListDlg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls,
  UStationDlg;

type
  TformCustomListDialog = class(TForm)
    Panel2: TPanel;
    ListView1: TListView;
    buttonAdd: TButton;
    buttonEdit: TButton;
    buttonDelete: TButton;
    buttonOK: TButton;
    buttonCancel: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure buttonAddClick(Sender: TObject);
    procedure buttonEditClick(Sender: TObject);
    procedure buttonDeleteClick(Sender: TObject);
    procedure ListView1DblClick(Sender: TObject);
    procedure ListView1SelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure buttonOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListView1ColumnClick(Sender: TObject; Column: TListColumn);
    procedure ListView1Compare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
  private
    { Private 宣言 }
    FPrevSortColumnNo: Integer;
    FSortDirectionAsc: Boolean;
    FCustomListFile: TStringList;
    procedure ListToListView();
    procedure ListViewToList();
  public
    { Public 宣言 }
    property CustomListFile: TStringList read FCustomListFile;
  end;

implementation

{$R *.dfm}

procedure TformCustomListDialog.FormCreate(Sender: TObject);
begin
   FCustomListFile := TStringList.Create();
   FCustomListFile.StrictDelimiter := True;
   FPrevSortColumnNo := -1;
   FSortDirectionAsc := True;
   ListView1.Items.Clear();
end;

procedure TformCustomListDialog.FormShow(Sender: TObject);
begin
   ListView1.Selected := nil;
   buttonEdit.Enabled := False;
   buttonDelete.Enabled := False;
   ListToListView();
end;

procedure TformCustomListDialog.FormDestroy(Sender: TObject);
begin
   FCustomListFile.Free();
end;

procedure TformCustomListDialog.buttonAddClick(Sender: TObject);
var
   dlg: TformStationDialog;
   listitem: TListItem;
begin
   dlg := TformStationDialog.Create(Self);
   dlg.NewRecord := True;
   try
      if dlg.ShowModal() <> mrOK then begin
         Exit;
      end;

      listitem := ListView1.Items.Add();

      listitem.Caption := dlg.Callsign;
      listitem.SubItems.Add(dlg.Country);
      listitem.SubItems.Add(dlg.Continent);
      listitem.SubItems.Add(dlg.CQZone);
      listitem.SubItems.Add(dlg.ITUZone);
      listitem.SubItems.Add(dlg.State);
      listitem.SubItems.Add(dlg.Comment);
   finally
      dlg.Release();
   end;
end;

procedure TformCustomListDialog.buttonDeleteClick(Sender: TObject);
begin
   if ListView1.Selected = nil then begin
      Exit;
   end;

   if MessageBox(Handle, PChar('このステーションを削除します。よろしいですか？'), PChar(Application.Title), MB_YESNO or MB_DEFBUTTON2 or MB_ICONEXCLAMATION) = IDNO then begin
      Exit;
   end;

   ListView1.Selected.Delete();
end;

procedure TformCustomListDialog.buttonEditClick(Sender: TObject);
var
   dlg: TformStationDialog;
   listitem: TListItem;
begin
   dlg := TformStationDialog.Create(Self);
   dlg.NewRecord := False;
   try
      listitem := ListView1.Selected;

      dlg.Callsign := listitem.Caption;
      dlg.Country := listitem.SubItems[0];
      dlg.Continent := listitem.SubItems[1];
      dlg.CQZone := listitem.SubItems[2];
      dlg.ITUZone := listitem.SubItems[3];
      dlg.State := listitem.SubItems[4];
      dlg.Comment := listitem.SubItems[5];

      if dlg.ShowModal() <> mrOK then begin
         Exit;
      end;

      listitem.SubItems[0] := dlg.Country;
      listitem.SubItems[1] := dlg.Continent;
      listitem.SubItems[2] := dlg.CQZone;
      listitem.SubItems[3] := dlg.ITUZone;
      listitem.SubItems[4] := dlg.State;
      listitem.SubItems[5] := dlg.Comment;
   finally
      dlg.Release();
   end;
end;

procedure TformCustomListDialog.ListView1ColumnClick(Sender: TObject; Column: TListColumn);
begin
   if FPrevSortColumnNo = Column.Index then begin
      FSortDirectionAsc := Not FSortDirectionAsc;
   end;

   ListView1.CustomSort(nil, Column.Index);

   FPrevSortColumnNo := Column.Index;
end;

procedure TformCustomListDialog.ListView1Compare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
begin
   if Data = 0 then begin
      Compare := CompareText(Item1.Caption, Item2.Caption);
   end
   else begin
      Compare := CompareText(Item1.SubItems[Data - 1], Item2.SubItems[Data - 1]);
   end;

   if FSortDirectionAsc = False then begin
      Compare := Compare * -1;
   end;
end;

procedure TformCustomListDialog.ListView1DblClick(Sender: TObject);
begin
   buttonEdit.Click();
end;

procedure TformCustomListDialog.ListView1SelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
   buttonEdit.Enabled := Selected;
   buttonDelete.Enabled := Selected;
end;

procedure TformCustomListDialog.buttonOKClick(Sender: TObject);
begin
   ListViewToList();
   ModalResult := mrOK;
end;

procedure TformCustomListDialog.ListToListView();
var
   i: Integer;
   slLine: TStringList;
   listitem: TListItem;
begin
   slLine := TStringList.Create();
   slLine.StrictDelimiter := True;
   ListView1.Items.BeginUpdate();
   try
      for i := 0 to FCustomListFile.Count - 1 do begin
         slLine.CommaText := FCustomListFile[i];

         listitem := ListView1.Items.Add();
         listitem.Caption := slLine[0];
         listitem.SubItems.Add(slLine[1]);   // Country
         listitem.SubItems.Add(slLine[2]);   // Continent
         listitem.SubItems.Add(slLine[3]);   // CQZone
         listitem.SubItems.Add(slLine[4]);   // ITUZone
         listitem.SubItems.Add(slLine[5]);   // State
         listitem.SubItems.Add(slLine[6]);   // Comment
      end;

   finally
      ListView1.Items.EndUpdate();
      slLine.Free();
   end;
end;

procedure TformCustomListDialog.ListViewToList();
var
   i: Integer;
   slLine: TStringList;
   listitem: TListItem;
begin
   slLine := TStringList.Create();
   slLine.StrictDelimiter := True;
   try
      FCustomListFile.Clear();
      for i := 0 to ListView1.Items.Count - 1 do begin
         listitem := ListView1.Items[i];

         slLine.Clear();
         slLine.Add(listitem.Caption);
         slLine.Add(listitem.SubItems[0]);   // Country
         slLine.Add(listitem.SubItems[1]);   // Continent
         slLine.Add(listitem.SubItems[2]);   // CQ
         slLine.Add(listitem.SubItems[3]);   // ITU
         slLine.Add(listitem.SubItems[4]);   // State
         slLine.Add(listitem.SubItems[5]);   // Comment

         FCustomListFile.Add(slLine.CommaText);
      end;
   finally
      slLine.Free();
   end;
end;

end.
