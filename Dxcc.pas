unit Dxcc;

interface

uses
  System.Classes, System.Types, SysUtils, Generics.Collections, Generics.Defaults;

type
  TDxccObject = class(TObject)
  private
    FNumber: Integer;
    FCountry: string;
    FCQZone: string;
    FITUZone: string;
    FContinent: string;
  public
    constructor Create();
    property Number: Integer read FNumber write FNumber;
    property Country: string read FCountry write FCountry;
    property CQZone: string read FCQZone write FCQZone;
    property ITUZone: string read FITUZone write FITUZone;
    property Continent: string read FContinent write FContinent;
  end;

  TDxccObjectComparer1 = class(TInterfacedObject, IComparer<TDxccObject>)
  public
    function Compare(const Left, Right: TDxccObject): Integer;
  end;

  TDxccList = class(TObjectList<TDxccObject>)
  private
    FComparer: TDxccObjectComparer1;
    procedure LoadStringList(SL: TStringList);
  public
    constructor Create(OwnsObjects: Boolean = True);
    procedure LoadFromFile(AFileName: string);
    procedure LoadFromResourceName(hinst: THandle; resname: string);
    function ObjectOf(DxccNumber: Integer): TDxccObject;
    procedure Sort();
  end;

var
  EmptyDxcc: TDxccObject;

implementation

{ TDxccObject }

constructor TDxccObject.Create();
begin
   FNumber := 0;
   FCountry := '';
   FCQZone := '';
   FITUZone := '';
   FContinent := '';
end;

{ TDxccList }

constructor TDxccList.Create(OwnsObjects: Boolean = True);
begin
   inherited Create(OwnsObjects);
   FComparer := TDxccObjectComparer1.Create();
end;

procedure TDxccList.LoadFromFile(AFileName: string);
var
   slText: TStringList;
begin
   slText := TStringList.Create();
   slText.StrictDelimiter := True;
   try
      slText.LoadFromFile(AFileName);
      LoadStringList(slText);
   finally
      slText.Free();
   end;
end;

procedure TDxccList.LoadFromResourceName(hinst: THandle; resname: string);
var
   RS: TResourceStream;
   SL: TStringList;
begin
   RS := TResourceStream.Create(hinst, resname, RT_RCDATA);
   SL := TStringList.Create();
   SL.StrictDelimiter := True;
   try
      SL.LoadFromStream(RS);
      LoadStringList(SL);
   finally
      RS.Free();
      SL.Free();
   end;
end;

procedure TDxccList.LoadStringList(SL: TStringList);
var
   i: Integer;
   slLine: TStringList;
   obj: TDxccObject;
   strText: string;
begin
   slLine := TStringList.Create();
   slLine.StrictDelimiter := True;
   slLine.Delimiter := #09;   // TAB
   try
      for i := 0 to SL.Count - 1 do begin
         strText := SL[i] + #09#09#09#09#09#09;
         slLine.DelimitedText := strText;
         if Copy(strText, 1, 1) = ';' then begin
            Continue;
         end;

         obj := TDxccObject.Create();
         obj.Number := StrToIntDef(Trim(slLine[5]), 0);
         obj.Country := Trim(slLine[1]);
         obj.CQZone := Trim(slLine[4]);
         obj.ITUZone := Trim(slLine[3]);
         obj.Continent := Trim(slLine[2]);
         Self.Add(obj);
      end;

      Sort();
   finally
      slLine.Free();
   end;
end;

function TDxccList.ObjectOf(DxccNumber: Integer): TDxccObject;
var
   obj: TDxccObject;
   Index: Integer;
begin
   obj := TDxccObject.Create();
   obj.Number := DxccNumber;
   if BinarySearch(obj, Index, FComparer) = True then begin
      Result := Items[Index];
   end
   else begin
      Result := nil;
   end;
end;

procedure TDxccList.Sort();
begin
   inherited Sort(FComparer);
end;

function TDxccObjectComparer1.Compare(const Left, Right: TDxccObject): Integer;
begin
   Result := Left.Number - Right.Number;
end;

initialization
   EmptyDxcc := TDxccObject.Create();

finalization
   EmptyDxcc.Free();

end.
