unit RbnFilter;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.Generics.Collections;

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
    procedure buttonStartClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure buttonFileRefClick(Sender: TObject);
    procedure editInputFileNameChange(Sender: TObject);
    function GetZone(strCallsign: string): string;
    procedure FormDestroy(Sender: TObject);
  private
    { Private êÈåæ }
    FQrzComLookup: TDictionary<string, string>;
  public
    { Public êÈåæ }
  end;

var
  formRbnFilter: TformRbnFilter;

implementation

uses
  Main;

{$R *.dfm}

procedure TformRbnFilter.FormCreate(Sender: TObject);
begin
   FQrzComLookup := TDictionary<string, string>.Create(10000000);
end;

procedure TformRbnFilter.FormDestroy(Sender: TObject);
begin
   FQrzComLookup.Free();
end;

procedure TformRbnFilter.buttonFileRefClick(Sender: TObject);
begin
   if OpenDialog1.Execute(Self.Handle) <> True then begin
      Exit;
   end;

   editInputFileName.Text := OpenDialog1.FileName;
end;

procedure TformRbnFilter.buttonStartClick(Sender: TObject);
var
   slFile: TStringList;
   slLine: TStringList;
   slFiltered: TStringList;
   i: Integer;
   nColumnCount: Integer;
   list: TDictionary<string, string>;
   key: string;
   strFiltered: string;
   strExt: string;
   nDateCompare: Integer;
   nDxCompare: Integer;
   de_zone: string;
   dx_zone: string;
begin
   slFile := TStringList.Create();
   slLine := TStringList.Create();
   slLine.StrictDelimiter := True;
   slFiltered := TStringList.Create();
   list := TDictionary<string, string>.Create();
   Screen.Cursor := crHourglass;
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
      else if radioDePfx.Checked = True then begin
         nDxCompare := 1;
      end
      else if radioDeCont.Checked = True then begin
         nDxCompare := 2;
      end
      else begin
         nDxCompare := 6;
      end;

      strExt := ExtractFileExt(editInputFileName.Text);
      strFiltered := ExtractFilePath(editInputFileName.Text) + ExtractFileName(editInputFileName.Text);
      strFiltered := StringReplace(strFiltered, strExt, '', [rfReplaceAll]);
      strFiltered := strFiltered + '_filtered' + strExt;

      slFile.LoadFromFile(editInputFileName.Text);

      nColumnCount := 0;
      for i := 0 to slFile.Count - 1 do begin
         slLine.CommaText := Trim(slFile[i]);

         if i = 0 then begin
            nColumnCount := slLine.Count;

            slLine.Add('de_zone');
            slLine.Add('dx_zone');
            slFiltered.Add(slLine.CommaText);
         end
         else begin
            if slLine.Count <> nColumnCount then begin
               Continue;
            end;

            // 0        1      2       3    4    5  6      7       8    9  10   11    12
            // callsign,de_pfx,de_cont,freq,band,dx,dx_pfx,dx_cont,mode,db,date,speed,tx_mode

            // 1234567890123456
            // 2023-11-25 00:00:00
            key := slLine[5] + slLine[4] + slLine[nDxCompare] + Copy(slLine[10], 1, nDateCompare);

            if list.ContainsKey(key) = False then begin

               list.Add(key, slLine.CommaText);

               de_zone := GetZone(slLine[0]);
               dx_zone := GetZone(slLine[5]);
               slLine.Add(de_zone);
               slLine.Add(dx_zone);
               slFiltered.Add(slLine.CommaText);
            end;
         end;
      end;

      slFiltered.SaveToFile(editOutputFileName.Text);
   finally
      Screen.Cursor := crDefault;
      slFile.Free();
      slLine.Free();
      slFiltered.Free();
      list.Free();
   end;
end;

procedure TformRbnFilter.editInputFileNameChange(Sender: TObject);
var
   strExt: string;
   strFiltered: string;
begin
   if editInputFileName.Text = '' then begin
      Exit;
   end;

   strExt := ExtractFileExt(editInputFileName.Text);
   strFiltered := ExtractFilePath(editInputFileName.Text) + ExtractFileName(editInputFileName.Text);
   strFiltered := StringReplace(strFiltered, strExt, '', [rfReplaceAll]);
   strFiltered := strFiltered + '_filtered' + strExt;
   editOutputFileName.Text := strFiltered;
end;

function TformRbnFilter.GetZone(strCallsign: string): string;
var
   strCountry, strCQZone, strITUZone, strState: string;
   zone: string;
begin
   if FQrzComLookup.TryGetValue(strCallsign, zone) = True then begin
      Result := zone;
      Exit;
   end
   else begin
      if formMain.QueryOneStation(strCallsign, strCountry, strCQZone, strITUZone, strState) = True then begin
         Result := strCQZone;
         FQrzComLookup.Add(strCallsign, strCQZone);
      end
      else begin
         Result := '';
      end;
   end;
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
