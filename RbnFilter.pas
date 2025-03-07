unit RbnFilter;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  System.Generics.Collections, UMultipliers, Progress;

type
  TRbnRecord = class
    callsign: string;
    de_pfx: string;
    de_cont: string;
    freq: string;
    band: string;
    dx: string;
    dx_pfx: string;
    dx_cont: string;
    mode: string;
    db: string;
    date: string;
    speed: string;
    tx_mode: string;
  end;

  TRbnList = class(TObjectList<TRbnRecord>)
  public
    constructor Create(OwnsObjects: Boolean = True);
    destructor Destroy(); override;
  end;

  TformRbnFilter = class(TForm)
    buttonStart: TButton;
    editInputFileName: TEdit;
    buttonFileRef: TButton;
    OpenDialog1: TOpenDialog;
    GroupBox1: TGroupBox;
    checkDateCompare13: TRadioButton;
    checkDateCompare16: TRadioButton;
    Label1: TLabel;
    GroupBox2: TGroupBox;
    radioDxPfx: TRadioButton;
    radioDxCont: TRadioButton;
    radioDeCont: TRadioButton;
    radioDePfx: TRadioButton;
    Label2: TLabel;
    Label3: TLabel;
    editOutputFileName: TEdit;
    buttonClose: TButton;
    GroupBox3: TGroupBox;
    radioDeQrzCom: TRadioButton;
    radioDeCtyDat: TRadioButton;
    GroupBox4: TGroupBox;
    radioDxQrzCom: TRadioButton;
    radioDxCtyDat: TRadioButton;
    radioDeZone: TRadioButton;
    radioDxZone: TRadioButton;
    GroupBox5: TGroupBox;
    checkDePfxFilter: TCheckBox;
    editDePfxFilter: TEdit;
    checkDxPfxFilter: TCheckBox;
    editDxPfxFilter: TEdit;
    checkDxContFilter: TCheckBox;
    editDxContFilter: TEdit;
    checkDeContFilter: TCheckBox;
    editDeContFilter: TEdit;
    procedure buttonStartClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure buttonFileRefClick(Sender: TObject);
    function GetZone(strCallsign: string; fQrzlookup: Boolean): string;
    procedure FormDestroy(Sender: TObject);
    procedure radioDxDeClick(Sender: TObject);
    procedure buttonCloseClick(Sender: TObject);
    procedure checkDePfxFilterClick(Sender: TObject);
    procedure checkDxPfxFilterClick(Sender: TObject);
    procedure checkDxContFilterClick(Sender: TObject);
    procedure checkDeContFilterClick(Sender: TObject);
  private
    { Private 宣言 }
    FQrzComLookup: TDictionary<string, string>;
    FCountryList : TCountryList;
    FPrefixList : TPrefixList;
    function Load_CTYDAT(): Boolean;
    function GetPrefix(strCallsign: string): TPrefix;
    function GuessCQZone(strCallsign: string): string;
    function GetArea(str: string): integer;
  public
    { Public 宣言 }
  end;

implementation

uses
  Main;

{$R *.dfm}

procedure TformRbnFilter.FormCreate(Sender: TObject);
begin
   FQrzComLookup := TDictionary<string, string>.Create(10000000);
   FCountryList := TCountryList.Create();
   FPrefixList := TPrefixList.Create();
   Load_CTYDAT();
end;

procedure TformRbnFilter.FormDestroy(Sender: TObject);
begin
   FQrzComLookup.Free();
   FPrefixList.Free();
   FCountryList.Free();
end;

procedure TformRbnFilter.buttonCloseClick(Sender: TObject);
begin
   Close();
end;

procedure TformRbnFilter.buttonFileRefClick(Sender: TObject);
var
   strExt: string;
   strFiltered: string;
   slFiles: TStringList;
   filename: string;
begin
   if OpenDialog1.Execute(Self.Handle) <> True then begin
      Exit;
   end;

   editInputFileName.Text := OpenDialog1.Files.CommaText;
   if editInputFileName.Text = '' then begin
      Exit;
   end;

   slFiles := TStringList.Create();
   try
      slFiles.CommaText := editInputFileName.Text;

      filename := slFiles[0];
      strExt := ExtractFileExt(filename);
      strFiltered := ExtractFilePath(filename) + ExtractFileName(filename);
      strFiltered := StringReplace(strFiltered, strExt, '', [rfReplaceAll]);
      strFiltered := strFiltered + '_filtered' + strExt;
      editOutputFileName.Text := strFiltered;
   finally
      slFiles.Free();
   end;
end;

procedure TformRbnFilter.radioDxDeClick(Sender: TObject);
begin
//
end;

procedure TformRbnFilter.buttonStartClick(Sender: TObject);
var
   slFiles: TStringList;
   slFile: TStringList;
   slLine: TStringList;
   slFiltered: TStringList;
   slDePfxFilter: TStringList;
   slDeContFilter: TStringList;
   slDxPfxFilter: TStringList;
   slDxContFilter: TStringList;
   i, j, k: Integer;
   nColumnCount: Integer;
   list: TDictionary<string, string>;
   key: string;
   nDateCompare: Integer;
   nDxCompare: Integer;
   de_zone: string;
   dx_zone: string;
   progress: TformProgress;
   nOK: Integer;
   filename: string;
begin
   slFiles := TStringList.Create();
   slFile := TStringList.Create();
   slLine := TStringList.Create();
   slLine.StrictDelimiter := True;
   slFiltered := TStringList.Create();
   slDePfxFilter := TStringList.Create();
   slDeContFilter := TStringList.Create();
   slDxPfxFilter := TStringList.Create();
   slDxContFilter := TStringList.Create();
   list := TDictionary<string, string>.Create();
   progress := TformProgress.Create(Self);
//   Screen.Cursor := crHourglass;
   try
      if checkDateCompare13.checked = True then begin
         nDateCompare := 13;
      end
      else begin
         nDateCompare := 16;
      end;

      if radioDxPfx.Checked = True then begin
         nDxCompare := 6;
      end
      else if radioDxCont.Checked = True then begin
         nDxCompare := 7;
      end
      else if radioDxZone.Checked = True then begin
         nDxCompare := 14;
      end
      else if radioDePfx.Checked = True then begin
         nDxCompare := 1;
      end
      else if radioDeCont.Checked = True then begin
         nDxCompare := 2;
      end
      else begin
         nDxCompare := 13;    // de_zone
      end;

      slFiles.CommaText := editInputFileName.Text;
      for k := 0 to slFiles.Count - 1 do begin
         filename := slFiles[k];

         slFile.LoadFromFile(filename);

         progress.Title := ExtractFileName(filename);
         progress.Text := '';
         progress.Show();
         Enabled := False;

         slDePfxFilter.CommaText := editDePfxFilter.Text;
         slDeContFilter.CommaText := editDeContFilter.Text;
         slDxPfxFilter.CommaText := editDxPfxFilter.Text;
         slDxContFilter.CommaText := editDxContFilter.Text;

         nColumnCount := 0;
         for i := 0 to slFile.Count - 1 do begin
            slLine.CommaText := Trim(slFile[i]);

            if i = 0 then begin
               nColumnCount := slLine.Count;

               if k = 0 then begin
                  slLine.Add('de_zone');
                  slLine.Add('dx_zone');
                  slFiltered.Add(slLine.CommaText);
               end;
            end
            else begin
               if slLine.Count <> nColumnCount then begin
                  Continue;
               end;

               // DE_PFXフィルター
               if checkDePfxFilter.Checked = True then begin
                  nOK := 0;
                  for j := 0 to slDePfxFilter.Count - 1 do begin
                     if (slLine[1] = slDePfxFilter[j]) then begin
                        Inc(nOK);
                     end;
                  end;

                  if nOK = 0 then begin
                     Continue;
                  end;
               end;

               // DE_CONTフィルター
               if checkDeContFilter.Checked = True then begin
                  nOK := 0;
                  for j := 0 to slDeContFilter.Count - 1 do begin
                     if (slLine[2] = slDeContFilter[j]) then begin
                        Inc(nOK);
                     end;
                  end;

                  if nOK = 0 then begin
                     Continue;
                  end;
               end;

               // DX_PFXフィルター
               if checkDxPfxFilter.Checked = True then begin
                  nOK := 0;
                  for j := 0 to slDxPfxFilter.Count - 1 do begin
                     if (slLine[6] = slDxPfxFilter[j]) then begin
                        Inc(nOK);
                     end;
                  end;

                  if nOK = 0 then begin
                     Continue;
                  end;
               end;

               // DX_CONTフィルター
               if checkDxContFilter.Checked = True then begin
                  nOK := 0;
                  for j := 0 to slDxContFilter.Count - 1 do begin
                     if (slLine[7] = slDxContFilter[j]) then begin
                        Inc(nOK);
                     end;
                  end;

                  if nOK = 0 then begin
                     Continue;
                  end;
               end;

               // ZONE情報を追加する
               de_zone := GetZone(slLine[0], radioDeQrzCom.Checked);
               dx_zone := GetZone(slLine[5], radioDxQrzCom.Checked);
               slLine.Add(de_zone);
               slLine.Add(dx_zone);

               progress.Title := ExtractFileName(filename) + ' DE=' + slLine[0] + ' DX=' + slLine[5];
               progress.Text := IntToStr(i + 1) + '/' + IntToStr(slFile.Count);
               progress.SetProgressData(i + 1, slFile.Count);
               Application.ProcessMessages();

               if progress.Abort = True then begin
                  Break;
               end;

               // 0        1      2       3    4    5  6      7       8    9  10   11    12      13      14
               // callsign,de_pfx,de_cont,freq,band,dx,dx_pfx,dx_cont,mode,db,date,speed,tx_mode,de_zone,dx_zone

               // 1234567890123456
               // 2023-11-25 00:00:00
               key := slLine[5] + slLine[4] + slLine[nDxCompare] + Copy(slLine[10], 1, nDateCompare);

               if list.ContainsKey(key) = False then begin
                  list.Add(key, slLine.CommaText);
                  slFiltered.Add(slLine.CommaText);
               end;
            end;
         end;
      end;

      progress.Hide();
      Enabled := True;

      slFiltered.SaveToFile(editOutputFileName.Text);
   finally
      progress.Release();
//      Screen.Cursor := crDefault;
      slFiles.Free();
      slFile.Free();
      slLine.Free();
      slFiltered.Free();
      slDePfxFilter.Free();
      slDeContFilter.Free();
      slDxPfxFilter.Free();
      slDxContFilter.Free();
      list.Free();
   end;
end;

procedure TformRbnFilter.checkDeContFilterClick(Sender: TObject);
begin
   editDeContFilter.Enabled := checkDeContFilter.Checked;
end;

procedure TformRbnFilter.checkDePfxFilterClick(Sender: TObject);
begin
   editDePfxFilter.Enabled := checkDePfxFilter.Checked;
end;

procedure TformRbnFilter.checkDxContFilterClick(Sender: TObject);
begin
   editDxContFilter.Enabled := checkDxContFilter.Checked;
end;

procedure TformRbnFilter.checkDxPfxFilterClick(Sender: TObject);
begin
   editDxPfxFilter.Enabled := checkDxPfxFilter.Checked;
end;

function TformRbnFilter.GetZone(strCallsign: string; fQrzlookup: Boolean): string;
var
   strCountry, strCQZone, strITUZone, strState: string;
   zone: string;
   Index: Integer;
begin
   // JAは除く
   if IsDomestic(strCallsign) = True then begin
      Result := '25';
      Exit;
   end;

   // -があったらそれ以降を取り除く
   Index := Pos('-', strCallsign);
   if Index > 0 then begin
      strCallsign := Copy(strCallsign, 1, Index - 1);
   end;

   // 既にLookup済みならその値を返す
   if FQrzComLookup.TryGetValue(strCallsign, zone) = True then begin
//      formMain.LogWrite(strCallsign + ' was in cache data');
      Result := zone;
      Exit;
   end
   else begin
      if (fQrzlookup = True) and (formMain.QueryOneStation(strCallsign, strCountry, strCQZone, strITUZone, strState) = True) then begin
         if strCQZone = '' then begin
            strCQZone := GuessCQZone(strCallsign);
         end;
      end
      else begin
         // Lookupできない時はCTY.DATの情報で判定
         strCQZone := GuessCQZone(strCallsign);
      end;

      FQrzComLookup.Add(strCallsign, strCQZone);
      Result := strCQZone;
   end;
end;

function TformRbnFilter.Load_CTYDAT(): Boolean;
var
   i: Integer;
   P: TPrefix;
   strFileName: string;
//   F: TextFile;
begin
   strFileName := ExtractFilePath(Application.ExeName) + 'CTY.DAT';

   // カントリーリストをロード
   FCountryList.LoadFromFile(strFileName);

   if FileExists(strFileName) = True then begin

      // 各カントリーのprefixを展開
      for i := 0 to FCountryList.Count - 1 do begin
         FPrefixList.Parse(FCountryList[i]);
      end;

      // 並び替え（降順）
      FPrefixList.Sort();


//      AssignFile(F, 'cty-zone.txt');
//      ReWrite(F);
//
//      for i := 0 to FPrefixList.Count - 1 do begin
//         WriteLn(F, '"' + FPrefixList.Items[i].Country.FCode +  '","' + FPrefixList.Items[i].Prefix + '","' + FPrefixList.Items[i].Country.CQZone + '","' + FPrefixList.Items[i].OvrCQZone + '"');
//      end;
//
//      CloseFile(F);

      Result := True;
   end
   else begin
      Result := False;
   end;

   // 先頭にUnknown Countryのダミーレコード追加
   P := TPrefix.Create();
   P.Prefix := 'Unknown';
   P.Country := FCountryList[0];
   FPrefixList.Insert(0, P);
end;

function TformRbnFilter.GetPrefix(strCallsign: string): TPrefix;
var
   str: string;
   i: integer;
   P: TPrefix;
   strCallRight: string;
   strCallFirst: string;
begin
   str := strCallSign;
   if str = '' then begin
      Result := FPrefixList[0];
      Exit;
   end;

   if FPrefixList.Count = 0 then begin
      Result := FPrefixList[0];
      Exit;
   end;

   // 最初はコール一致確認
   for i := 0 to FPrefixList.Count - 1 do begin
      P := FPrefixList[i];

      if (P.FullMatch = True) and (P.Prefix = str) then begin
         Result := P;
         Exit;
      end;
   end;

   i := Pos('/', str);
   if i > 0 then begin
      strCallFirst := Copy(str, 1, i - 1);
      strCallRight := Copy(str, i + 1);
   end
   else begin
      strCallFirst := str;
      strCallRight := '';
   end;

   // Marine Mobile
   if strCallRight = 'MM' then begin
      Result := FPrefixList[0];
      Exit;
   end

   // 無視するもの
   else if (strCallRight = 'AA') or (strCallRight = 'AT') or (strCallRight = 'AG') or
      (strCallRight = 'AA') or (strCallRight = 'AE') or (strCallRight = 'M') or
      (strCallRight = 'P') or (strCallRight = 'AM') or (strCallRight = 'QRP') or
      (strCallRight = 'A') or (strCallRight = 'KT') or (strCallRight = 'N') or
      (strCallRight = 'T') or
      (strCallRight = '0') or (strCallRight = '1') or (strCallRight = '2') or
      (strCallRight = '3') or (strCallRight = '4') or (strCallRight = '5') or
      (strCallRight = '6') or (strCallRight = '7') or (strCallRight = '8') or
      (strCallRight = '9') then begin
      str := Copy(str, 1, i - 1);
   end

   // 判別できない
   else if i = 5 then begin
      // まずは左側から前方一致で
      for i := 1 to FPrefixList.Count - 1 do begin
         P := FPrefixList[i];

         if P.FullMatch = False then begin
            if Copy(strCallFirst, 1, Length(P.Prefix)) = P.Prefix then begin
               Result := P;
               Exit;
            end;
         end;
      end;

      // 無ければ右側
      strCallFirst := strCallRight;
   end;

   // 続いて前方一致で
   for i := 1 to FPrefixList.Count - 1 do begin
      P := FPrefixList[i];

      if P.FullMatch = False then begin
         if Copy(strCallFirst, 1, Length(P.Prefix)) = P.Prefix then begin
            Result := P;
            Exit;
         end;
      end;
   end;

   Result := FPrefixList[0];
end;

function TformRbnFilter.GetArea(str: string): integer;
var
   j, k: integer;
begin
   j := pos('/', str);
   if j > 4 then begin
      for k := Length(str) downto 1 do
         if CharInSet(str[k], ['0' .. '9']) = True then
            break;
   end
   else begin
      for k := 1 to Length(str) do
         if CharInSet(str[k], ['0' .. '9']) = True then
            break;
   end;

   if CharInSet(str[k], ['0' .. '9']) = True then
      k := ord(str[k]) - ord('0')
   else
      k := 6;

   Result := k;
end;

function TformRbnFilter.GuessCQZone(strCallsign: string): string;
var
   i, k: integer;
   C: TCountry;
   p: TPrefix;
   str: string;
begin
   p := GetPrefix(strCallsign);
   if p = nil then begin
      Result := '';
      exit;
   end
   else begin
      C := P.Country;
   end;

   str := strCallsign;
   i := StrToIntDef(C.CQZone, 0);

   if (C.Country = 'W') or (C.Country = 'K') then begin
      k := GetArea(str);
      case k of
         1 .. 4:
            i := 5;
         5, 8, 9, 0:
            i := 4;
         6, 7:
            i := 3;
      end;
   end;

   if C.Country = 'VE' then begin
      k := GetArea(str);
      case k of
         1, 2, 9:
            i := 5;
         3 .. 6:
            i := 4;
         7:
            i := 3;
         8:
            i := 1;
         0:
            i := 2;
      end;
   end;

   if C.Country = 'VK' then begin
      k := GetArea(str);
      case k of
         1 .. 5, 7:
            i := 30;
         6, 8:
            i := 29;
         9, 0:
            i := 30; { Should not happen }
      end;
   end;

   if C.Country = 'BY' then begin
      k := GetArea(str);
      case k of
         1 .. 8:
            i := 24;
         9, 0:
            i := 23;
      end;
   end;

   if (C.Country = 'UA') or (C.Country = 'UA0') or (C.Country = 'UA9') then begin
      if (ExPos('U?0', str) > 0) or (pos('R?0', str) > 0) or (pos('R0', str) > 0) then begin
         k := pos('0', str);
         if Length(str) >= k + 1 then
            case str[k + 1] of
               'A', 'B', 'H', 'O', 'P', 'S', 'T', 'U', 'V', 'W':
                  i := 18;
               'Y':
                  i := 23;
               else
                  i := 19;
            end;
      end;

      if (ExPos('U?8', str) > 0) or (ExPos('R?8', str) > 0) then begin
         i := 18;
      end;
      if (ExPos('U?9', str) > 0) or (ExPos('R?9', str) > 0) then begin
         k := pos('9', str);
         if Length(str) >= k + 1 then
            case str[k + 1] of
               'S', 'T', 'W':
                  i := 16;
               'H', 'I', 'O', 'P', 'U', 'V', 'Y', 'Z':
                  i := 18;
               else
                  i := 17;
            end;
      end;
   end;

   if P.OvrCQZone <> '' then begin
      i := StrToIntDef(P.OvrCQZone, 0);
   end;

   if i = 0 then
      Result := ''
   else
      Result := IntToStr(i);
end;

constructor TRbnList.Create(OwnsObjects: Boolean);
begin
   Inherited;
end;

destructor TRbnList.Destroy();
begin
   //
end;

end.
