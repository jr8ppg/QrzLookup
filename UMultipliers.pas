unit UMultipliers;

interface

uses
  SysUtils, Windows, Classes, Dialogs, Forms, UITypes,
  Generics.Collections, Generics.Defaults;

type
  TCountry = class(TObject)
    FName: string;            // Japan, Hawaii, etc
    FCQZone: string;          // CQ Zone
    FITUZone: string;         // ITU Zone
    FContinent: string;       // 大陸
    FLatitude: string;        // 緯度
    FLongitude: string;       // 経度
    FUTCOffset: Integer;      // UTCに対する時差
    FCode: string;            // JA, KH6 etc
    FPrefixes: string;        // 代表プリフィックス
    FIndex: Integer;
  public
    constructor Create(); overload;
    constructor Create(strText: string); overload;

    procedure Parse(strText: string);
    property CountryName: string read FName write FName;
    property CQZone: string read FCQZone write FCQZone;
    property ITUZone: string read FITUZone write FITUZone;
    property Continent: string read FContinent write FContinent;
    property Latitude: string read FLatitude write FLatitude;
    property Longitude: string read FLongitude write FLongitude;
    property UTCOffset: Integer read FUTCOffset write FUTCOffset;
    property Country: string read FCode write FCode;
    property Prefixes: string read FPrefixes write FPrefixes;
    property Index: Integer read FIndex write FIndex;
  end;

  TCountryList = class(TObjectList<TCountry>)
  private
  public
    constructor Create(OwnsObjects: Boolean = True);
    procedure LoadFromFile(strFileName: string);
  end;

  TPrefix = class(TObject)
    FPrefix: string;
    FOvrCQZone: string;         // override zone
    FOvrITUZone: string;
    FOvrContinent: string;  // override continent
    FCountry: TCountry;
    FFullMatch: Boolean;
  public
    constructor Create();
    property Prefix: string read FPrefix write FPrefix;
    property OvrCQZone: string read FOvrCQZone write FOvrCQZone;
    property OvrITUZone: string read FOvrITUZone write FOvrITUZone;
    property OvrContinent: string read FOvrContinent write FOvrContinent;
    property Country: TCountry read FCountry write FCountry;
    property FullMatch: Boolean read FFullMatch write FFullMatch;
  end;

  TPrefixComparer = class(TComparer<TPrefix>)
  public
    function Compare(const Left, Right: TPrefix): Integer; override;
  end;

  TPrefixList = class(TObjectList<TPrefix>)
  private
    FPrefixComparer: TPrefixComparer;
  public
    constructor Create(OwnsObjects: Boolean = True);
    destructor Destroy(); override;
    procedure Parse(cty: TCountry);
    procedure Sort(); overload;
  end;

  TCity = class
    CityNumber : string;
    CityName : string;
    PrefNumber : string;
    PrefName : string;
    Index: Integer;
    constructor Create;
    function Abbrev : string;
  end;

  TCityList = class
  private
    FList: TList;
    FSortedMultiList: TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    function GetCity(Name : string): TCity;
    procedure LoadFromFile(filename: string);
    function AddAndSort(C : TCity): integer; // returns the index inserted
    property List: TList read FList;
    property SortedMultiList: TStringList read FSortedMultiList;
  end;

  TState = class
    StateName : string;
    StateAbbrev : string;
    AltAbbrev : string;
    Index: Integer;
    constructor Create;
  end;

  TStateList = class
  private
    FList: TList;
  public
    constructor Create;
    procedure LoadFromFile(filename: string);
    destructor Destroy; override;
    property List: TList read FList;
  end;

  TIsland = class
    RefNumber : string;
    Name : string;
    constructor Create;
  end;

  TIslandList = class
  private
    FList : TList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromFile(filename : string);
//    procedure SaveToFile(filename : string);
    property List: TList read FList;
  end;

function Less(x, y: integer): integer;
function StrMore(A, B: string): Boolean; { true if a>b }
function ExPos(substr, str: string): Integer;

implementation

constructor TCountryList.Create(OwnsObjects: Boolean);
begin
   Inherited Create(OwnsObjects);
end;

procedure TCountryList.LoadFromFile(strFileName: string);
var
   mem: TMemoryStream;
   i: Integer;
   ch: AnsiChar;
   buf: Byte;
   strLine: string;
   C: TCountry;
begin
   mem := TMemoryStream.Create();
   try
      C := TCountry.Create();
      C.CountryName := 'Unknown';
      Add(C);

      if FileExists(strFileName) = False then begin
         Exit;
      end;

      mem.LoadFromFile(strFileName);
      mem.Position := 0;

      strLine := '';
      for i := 0 to mem.Size - 1 do begin
         mem.Read(buf, 1);
         ch := AnsiChar(buf);

         if ch = AnsiChar($0d) then begin
            Continue;
         end;
         if ch = AnsiChar($0a) then begin
            Continue;
         end;

         if ch = ';' then begin
            C := TCountry.Create(strLine);
            C.Index := Count;
            Add(C);
            strLine := '';
         end
         else begin
            strLine := strLine + Char(ch);
         end;
      end;

   finally
      mem.Free();
   end;
end;

constructor TCountry.Create();
begin
   Inherited;

   FName := '';
   FCQZone := '';
   FITUZone := '';
   FContinent := '';
   FLatitude := '';
   FLongitude := '';
   FUTCOffset := 0;
   FCode := '';
   FPrefixes := '';

   FIndex := -1;
end;

constructor TCountry.Create(strText: string);
begin
   Inherited Create();
   Parse(strText);
end;

procedure TCountry.Parse(strText: string);
var
   slLine: TStringList;
   i: Integer;
begin
   slLine := TStringList.Create();
   slLine.StrictDelimiter := True;
   slLine.Delimiter := ':';
   try
      slLine.DelimitedText := strText;

      for i := 0 to slLine.Count - 1 do begin
         slLine[i] := Trim(slLine[i]);
      end;

      FName       := slLine[0];
      FCQZone     := slLine[1];
      FITUZone    := slLine[2];
      FContinent  := slLine[3];
      FLatitude   := slLine[4];
      FLongitude  := slLine[5];
      FUTCOffset  := StrToIntDef(slLine[6], 0);
      FCode       := slLine[7];
      FPrefixes   := slLine[8];

   finally
      slLine.Free();
   end;
end;

constructor TPrefix.Create();
begin
   Inherited;
   FPrefix := '';
   FOvrCQZone := '';
   FOvrITUZone := '';
   FOvrContinent := '';
   FCountry := nil;
   FFullMatch := False;
end;

constructor TPrefixList.Create(OwnsObjects: Boolean);
begin
   Inherited Create(OwnsObjects);
   FPrefixComparer := TPrefixComparer.Create();
end;

destructor TPrefixList.Destroy();
begin
   Inherited;
   FPrefixComparer.Free();
end;

procedure TPrefixList.Parse(cty: TCountry);
var
   i: Integer;
   slText: TStringList;
   P: TPrefix;
   strPrefix: string;
   strOvrCQZone: string;
   strOvrITUZone: string;
   strOvrContinent: string;
   strUnused: string;
   fFullMatch: Boolean;

   function ExtractNumber(var strPrefix: string; strBegin, strEnd: string): string;
   var
      p1, p2: Integer;
   begin
      p1 := Pos(strBegin, strPrefix);
      if p1 <= 0 then begin
         Result := '';
         Exit;
      end;

      p2 := Pos(strEnd, strPrefix, p1 + 1);
      if p2 <= 0 then begin
         p2 := Length(strPrefix);
      end;

      Result := Copy(strPrefix, p1 + 1, p2 - p1 - 1);
      System.Delete(strPrefix, p1, p2 - p1 + 1);
   end;
begin
   slText := TStringList.Create();
   slText.StrictDelimiter := True;
   try
      slText.CommaText := cty.Prefixes;

      for i := 0 to slText.Count - 1 do begin
         strPrefix := Trim(slText[i]);

         // =で始まる物は完全一致コール
         if strPrefix[1] = '=' then begin
            strPrefix := Copy(strPrefix, 2);
            fFullMatch := True;
         end
         else begin
            fFullMatch := False;
         end;

         // ()はOverride CQ Zone
         strOvrCQZone := ExtractNumber(strPrefix, '(', ')');

         // []はOverride ITU Zone
         strOvrITUZone := ExtractNumber(strPrefix, '[', ']');

         // {}はOverride Continent
         strOvrContinent := ExtractNumber(strPrefix, '{', '}');

         // <#/#>はOverride latitude/longitude
         strUnused := ExtractNumber(strPrefix, '<', '>');

         // ~#~はOverride UTCOffset
         strUnused := ExtractNumber(strPrefix, '~', '~');

         P := TPrefix.Create();
         P.Prefix := strPrefix;
         P.Country := cty;
         P.OvrCQZone := strOvrCQZone;
         P.OvrITUZone := strOvrITUZone;
         P.OvrContinent := strOvrContinent;
         P.FFullMatch := fFullMatch;
         Add(P);
      end;

   finally
      slText.Free();
   end;
end;

procedure TPrefixList.Sort();
begin
   Sort(FPrefixComparer);
end;

{ TPrefixComparer }

function TPrefixComparer.Compare(const Left, Right: TPrefix): Integer;
begin
   Result := CompareText(Right.Prefix, Left.Prefix);
end;

{ TCity }

constructor TCity.Create;
begin
   CityNumber := '';
   CityName := '';
   PrefNumber := '';
   PrefName := '';
end;

function TCity.Abbrev: string;
var
   str: string;
begin
   str := CityNumber;
   if pos(',', str) > 0 then
      str := copy(str, 1, pos(',', str) - 1);
   Result := str;
end;

constructor TCityList.Create;
begin
   FList := TList.Create;
   FSortedMultiList := TStringList.Create;
   FSortedMultiList.Sorted := true;
end;

function TCityList.GetCity(Name: string): TCity;
var
   i: integer;
begin
   Result := nil;
   i := FSortedMultiList.IndexOf(Name);
   if i >= 0 then
      Result := TCity(FSortedMultiList.Objects[i]);
end;

destructor TCityList.Destroy;
var
   i: integer;
begin
   for i := 0 to FList.Count - 1 do begin
      if FList[i] <> nil then
         TCity(FList[i]).Free;
   end;
   FList.Free;
   FSortedMultiList.Clear;
   FSortedMultiList.Free;
end;

procedure TCityList.LoadFromFile(filename: string);
var
   str: string;
   C: TCity;
   i: integer;
   fullpath: string;
   SL: TStringList;
   L: Integer;
begin
   fullpath := filename;

   SL := TStringList.Create();
   if FileExists(fullpath) then begin
      SL.LoadFromFile(fullpath);
   end;

   for L := 1 to SL.Count - 1 do begin

      str := SL[L];

      if pos('end of file', LowerCase(str)) > 0 then begin
         break;
      end;

      C := TCity.Create;

      i := pos(' ', str);
      if i > 1 then begin
         C.CityNumber := copy(str, 1, i - 1);
      end;

      Delete(str, 1, i);
      C.CityName := TrimRight(TrimLeft(str));

      C.Index := List.Count;

      FList.Add(C);
      FSortedMultiList.AddObject(C.CityNumber, C);
   end;

   SL.Free();
end;

function TCityList.AddAndSort(C: TCity): integer;
var
   i: integer;
begin
   if FList.Count = 0 then begin
      FList.Add(C);
      Result := 0;
      exit;
   end;

   for i := 0 to List.Count - 1 do begin
      if StrMore(TCity(List[i]).CityNumber, C.CityNumber) then begin
         FList.Insert(i, C);
         Result := i;
         exit;
      end;
   end;

   FList.Add(C);

   Result := List.Count - 1;
end;

{ TState }

constructor TState.Create;
begin
   StateName := '';
   StateAbbrev := '';
   AltAbbrev := '';
   Index := 0;
end;

{ TStateList }

constructor TStateList.Create;
begin
   FList := TList.Create;
end;

destructor TStateList.Destroy;
var
   i: integer;
begin
   for i := 0 to FList.Count - 1 do begin
      if FList[i] <> nil then
         TState(FList[i]).Free;
   end;

   FList.Free;
end;

procedure TStateList.LoadFromFile(filename: string);
var
   str: string;
   S: TState;
   fullpath: string;
   SL: TStringList;
   L: Integer;
begin
   fullpath := filename;

   SL := TStringList.Create();
   SL.LoadFromFile(fullpath);

   L := 1;
   while (L < SL.Count - 1) do begin
      str := SL[L];

      if pos('end of file', LowerCase(str)) > 0 then begin
         break;
      end;

      S := TState.Create;
      S.Index := List.Count;
      S.StateName := TrimRight(Copy(str, 1, 22));
      S.StateAbbrev := TrimLeft(TrimRight(Copy(str, 30, 25)));

      Inc(L);

      if (L < SL.Count - 1) then begin
         str := SL[L];
         str := TrimRight(str);
         str := TrimLeft(str);
         if not CharInSet(str[length(str)], ['a' .. 'z', 'A' .. 'Z', '0' .. '9']) then
            System.Delete(str, length(str), 1);

         S.AltAbbrev := str;

         Inc(L);
      end;

      List.Add(S);
   end;

   SL.Free();
end;

{ TIsland }

constructor TIsland.Create;
begin
   RefNumber := '';
   Name := '';
end;

{ TIslandList }

constructor TIslandList.Create;
begin
   FList := TList.Create;
end;

destructor TIslandList.Destroy;
var
   i: Integer;
begin
   for i := 0 to FList.Count - 1 do begin
      if FList[i] <> nil then
         TIsland(FList[i]).Free;
   end;
   FList.Free;
end;

procedure TIslandList.LoadFromFile(filename: string);
var
   str: string;
   i: TIsland;
   fullpath: string;
   SL: TStringList;
   L: Integer;
begin
   fullpath := filename;

   SL := TStringList.Create();
   SL.LoadFromFile(fullpath);

   for L := 1 to SL.Count - 1 do begin
      str := SL[L];

      if Pos('end of file', LowerCase(str)) > 0 then
         break;

      i := TIsland.Create;
      i.RefNumber := Copy(str, 1, 5);
      Delete(str, 1, 6);
      i.Name := str;
      FList.Add(i);
   end;

   SL.Free();
end;

function Less(x, y: integer): integer;
begin
   if x > y then
      Result := y
   else
      Result := x;
end;

function StrMore(A, B: string): Boolean; { true if a>b }
var
   i: Integer;
begin
   for i := 1 to Less(length(A), length(B)) do begin
      if ord(A[i]) > ord(B[i]) then begin
         Result := True;
         exit;
      end;
      if ord(A[i]) < ord(B[i]) then begin
         Result := false;
         exit;
      end;
   end;
   if length(A) > length(B) then
      Result := True
   else
      Result := false;
end;

function ExPos(substr, str: string): Integer;
var
   i, j: integer;
   bad: boolean;
begin
   Result := 0;
   if (Length(substr) > Length(str)) or (substr = '') then
      exit;
   for i := 1 to (Length(str) - Length(substr) + 1) do begin
      bad := false;
      for j := 1 to Length(substr) do begin
         if substr[j] <> '?' then
            if substr[j] <> str[i + j - 1] then
               bad := true;
      end;
      if bad = false then begin
         Result := i;
         exit;
      end;
   end;
end;

end.
