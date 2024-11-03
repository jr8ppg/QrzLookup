unit Station;

interface

uses
  System.Classes, System.Types, SysUtils, Generics.Collections, Generics.Defaults;

type
   TStationInfo = class(TObject)
     FCallsign: string;
     FCountry: string;
     FContinent: string;
     FCQZone: string;
     FITUZone: string;
     FState: string;
     FComment: string;
   public
     constructor Create();
     property Callsign: string read FCallsign write FCallsign;
     property Country: string read FCountry write FCountry;
     property Continent: string read FContinent write FContinent;
     property CQZone: string read FCQZone write FCQZone;
     property ITUZone: string read FITUZone write FITUZone;
     property State: string read FState write FState;
     property Comment: string read FComment write FComment;
   end;

  TStationInfoComparer1 = class(TInterfacedObject, IComparer<TStationInfo>)
  public
    function Compare(const Left, Right: TStationInfo): Integer;
  end;

  TStationList = class(TObjectList<TStationInfo>)
  private
    FComparer: TStationInfoComparer1;
  public
    constructor Create(OwnsObjects: Boolean = True);
    destructor Destroy(); override;
    function IndexOf(strCallsign: string): Integer;
    function ObjectOf(strCallsign: string): TStationInfo;
    procedure Sort();
  end;

implementation

{ TStationInfo }

constructor TStationInfo.Create();
begin
   FCallsign := '';
   FCountry := '';
   FContinent := '';
   FCQZone := '';
   FITUZone := '';
   FState := '';
   FComment := '';
end;

{ TStationList }

constructor TStationList.Create(OwnsObjects: Boolean = True);
begin
   Inherited Create(OwnsObjects);
   FComparer := TStationInfoComparer1.Create();
end;

destructor TStationList.Destroy();
begin
   Inherited;
   FComparer.Free();
end;

function TStationList.IndexOf(strCallsign: string): Integer;
var
   obj: TStationInfo;
   Index: Integer;
begin
   obj := TStationInfo.Create();
   obj.Callsign := strCallsign;
   if BinarySearch(obj, Index, FComparer) = True then begin
      Result := Index;
   end
   else begin
      Result := -1;
   end;
   obj.Free();
end;

function TStationList.ObjectOf(strCallsign: string): TStationInfo;
var
   obj: TStationInfo;
   Index: Integer;
begin
   obj := TStationInfo.Create();
   obj.Callsign := strCallsign;
   if BinarySearch(obj, Index, FComparer) = True then begin
      Result := Items[Index];
   end
   else begin
      Result := nil;
   end;
   obj.Free();
end;

procedure TStationList.Sort();
begin
   inherited Sort(FComparer);
end;

{ TStationInfoComparer1 }

function TStationInfoComparer1.Compare(const Left, Right: TStationInfo): Integer;
begin
   Result := CompareText(Left.Callsign, Right.Callsign);
end;

end.
