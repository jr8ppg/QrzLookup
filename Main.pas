unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.IniFiles, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, System.Math,
  Vcl.ExtCtrls, Vcl.StdCtrls, Xml.xmldom, Xml.XMLIntf, Xml.XMLDoc,
  Vcl.WinXCtrls, WtUtils, Dxcc, Vcl.Grids, JclDebug, Check,
  System.Net.URLClient, System.Net.HttpClient, System.Net.HttpClientComponent;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    editCallsign: TEdit;
    Label1: TLabel;
    buttonQuery: TButton;
    timerWtCheck: TTimer;
    StatusBar1: TStatusBar;
    ToggleSwitch1: TToggleSwitch;
    StringGrid1: TStringGrid;
    checkUseWt: TCheckBox;
    Label2: TLabel;
    editInterval: TEdit;
    updownInterval: TUpDown;
    Label3: TLabel;
    NetHTTPClient1: TNetHTTPClient;
    NetHTTPRequest1: TNetHTTPRequest;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure buttonQueryClick(Sender: TObject);
    procedure editCallsignEnter(Sender: TObject);
    procedure editCallsignExit(Sender: TObject);
    procedure timerWtCheckTimer(Sender: TObject);
    procedure ToggleSwitch1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure StringGrid1TopLeftChanged(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure FormResize(Sender: TObject);
    procedure httpConnected(Sender: TObject);
    procedure httpDisconnected(Sender: TObject);
    procedure editCallsignChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure checkUseWtClick(Sender: TObject);
    procedure updownIntervalClick(Sender: TObject; Button: TUDBtnType);
    procedure NetHTTPRequest1RequestError(const Sender: TObject;
      const AError: string);
    procedure NetHTTPRequest1RequestException(const Sender: TObject;
      const AError: Exception);
  private
    { Private �錾 }
    FWtUtils: TWtUtils;
    FQrzComSessionKey: string;
    FQrzUserId, FQrzPassword: string;
    FDxccList: TDxccList;
    FLogFileName: string;
    FQueryNow: Boolean;
    FCheckWindow: TformCheck;
    FSite: Integer;
    FLastQueryTickCount: DWORD;
    FKeepAliveMinute: DWORD;
    function QrzComLogin(strUserID, strPassword: string; var strResult: string): Boolean;
    function QueryOneStation(strSessionKey: string; strCallsign: string; var strCountry, strCQZone, strITUZone, strState: string): Boolean;
    function GetXmlNode(start_node: IXMLNode; tagname: string; name: string): IXMLNode;
    procedure SetEnable(fEnable: Boolean);
    procedure ClearInfo();
    function GetCallsign(strCallsign: string): string;
  public
    { Public �錾 }
    procedure GoLookup();
    procedure LogWrite(msg: string);
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
var
   ini: TIniFile;
   x, y: Integer;
   n: Integer;
begin
   FWtUtils := TWtUtils.Create();
   FDxccList := TDxccList.Create();
   FDxccList.LoadFromResourceName(SysInit.HInstance, 'ID_DXCCLIST');
   FQueryNow := False;

   FCheckWindow := TformCheck.Create(Self);

   FLogFileName := ExtractFilePath(Application.ExeName) +
                   ChangeFileExt(ExtractFileName(Application.ExeName), '') + '_' + FormatDateTime('yyyymmdd', Now) + '.log';

   ini := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
   try
      FSite := ini.ReadInteger('SETTINGS', 'SiteSelect', 0);
      FLastQueryTickCount := GetTickCount();

      x := ini.ReadInteger('SETTINGS', 'X', -1);
      y := ini.ReadInteger('SETTINGS', 'Y', -1);
      if (x > -1) and (y > -1) then begin
         Left := x;
         Top := y;
         Position := poDesigned;
      end
      else begin
         Position := poDefaultPosOnly;
      end;

      x := ini.ReadInteger('CheckWindow', 'X', -1);
      y := ini.ReadInteger('CheckWindow', 'Y', -1);
      if (x > -1) and (y > -1) then begin
         FCheckWindow.Left := x;
         FCheckWindow.Top := y;
         Position := poDesigned;
      end
      else begin
         FCheckWindow.Left := Left + Width + 1;
         FCheckWindow.Top := Top;
         Position := poDesigned;
      end;

      n := ini.ReadInteger('SETTINGS', 'ScanInterval', 500);
      n := Min(Max(n, 100), 3000);
      updownInterval.Position := n;
      timerWtCheck.Interval := n;

      n := ini.ReadInteger('SETTINGS', 'KeepAliveMinute', 0);
      FKeepAliveMinute := n;

      if FSite = 0 then begin
         FQrzUserId := ini.ReadString('QRZ.COM', 'UserID', '');
         FQrzPassword := ini.ReadString('QRZ.COM', 'Password', '');

         Caption := 'QRZ.COM Lookup Tool';
      end
      else begin
         FQrzUserId := ini.ReadString('QRZCQ.COM', 'UserID', '');
         FQrzPassword := ini.ReadString('QRZCQ.COM', 'Password', '');

         Caption := 'QRZCQ.COM Lookup Tool';
      end;
   finally
      ini.Free();
   end;

   StringGrid1.Cells[0, 0] := 'Country';
   StringGrid1.Cells[1, 0] := 'Continent';
   StringGrid1.Cells[2, 0] := 'CQ Zone';
   StringGrid1.Cells[3, 0] := 'ITU Zone';
   StringGrid1.Cells[4, 0] := 'State';
   StringGrid1.ColWidths[0] := 300;
   StringGrid1.ColWidths[1] := 80;
   StringGrid1.ColWidths[2] := 80;
   StringGrid1.ColWidths[3] := 80;
   StringGrid1.ColWidths[4] := 80;
   StringGrid1.RowHeights[1] := 80;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   LogWrite('*** QrzLookup stopped ***');
end;

procedure TForm1.FormDestroy(Sender: TObject);
var
   ini: TIniFile;
begin
   FWtUtils.Free();
   FDxccList.Free();

   ini := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
   try
      ini.WriteInteger('SETTINGS', 'X', Left);
      ini.WriteInteger('SETTINGS', 'Y', Top);
      ini.WriteInteger('SETTINGS', 'ScanInterval', updownInterval.Position);

      ini.WriteInteger('CheckWindow', 'X', FCheckWindow.Left);
      ini.WriteInteger('CheckWindow', 'Y', FCheckWindow.Top);
   finally
      ini.Free();
   end;

   FCheckWindow.Release();
end;

procedure TForm1.FormResize(Sender: TObject);
var
   w: Integer;
   h: Integer;
begin
   w := (ClientWidth - 12) div 7;
   h := ClientHeight - (Panel1.Height + StringGrid1.RowHeights[0] + StatusBar1.Height);
   StringGrid1.ColWidths[0] := w * 3;
   StringGrid1.ColWidths[1] := w;
   StringGrid1.ColWidths[2] := w;
   StringGrid1.ColWidths[3] := w;
   StringGrid1.ColWidths[4] := w;
   StringGrid1.RowHeights[1] := h;
   ClientWidth := w * 7 + 12;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
   SetEnable(False);
   LogWrite('*** QrzLookup started ***');
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
   if editCallsign.Enabled = True then begin
      editCallsign.SetFocus();
   end;
end;

procedure TForm1.buttonQueryClick(Sender: TObject);
var
   strCallsign: string;
   dwTick: DWORD;
   strCountry, strCQZone, strITUZone, strContinent, strState: string;
   dxcc: TDxccObject;
begin
   if FQueryNow = True then begin
      Exit;
   end;

   FQueryNow := True;
   try
   try
      strCallsign := UpperCase(Trim(editCallsign.Text));
      if strCallsign = '' then begin
         Exit;
      end;

      strCallsign := GetCallsign(strCallsign);

      if Length(strCallsign) < 4 then begin
         Exit;
      end;

      ClearInfo();

      dwTick := GetTickCount();

      if QueryOneStation(FQrzComSessionKey, strCallsign, strCountry, strCQZone, strITUZone, strState) = True then begin

         dxcc := FDxccList.ObjectOf(StrToIntDef(strCountry, 0));
         if dxcc = nil then begin
            strCountry := 'Unknown';
            strContinent := '';
         end
         else begin
            strCountry := dxcc.country;
            strContinent := dxcc.Continent;

            if strCQZone = '' then begin
               strCQZone := dxcc.CQZone;
            end;

            if strITUZone = '' then begin
               strITUZone := dxcc.ITUZone;
            end;
         end;

         StringGrid1.Cells[0, 1] := strCountry;
         StringGrid1.Cells[1, 1] := strContinent;
         StringGrid1.Cells[2, 1] := strCQZone;
         StringGrid1.Cells[3, 1] := strITUZone;
         StringGrid1.Cells[4, 1] := strState;
      end
      else begin
         StringGrid1.Cells[0, 1] := strCountry;
         StringGrid1.Cells[1, 1] := '';
         StringGrid1.Cells[2, 1] := '';
         StringGrid1.Cells[3, 1] := '';
         StringGrid1.Cells[4, 1] := '';
      end;

      dwTick := GetTickCount() - dwTick;

      StatusBar1.Panels[0].Text := IntToStr(dwTick) + ' ms';

      editCallsign.SelectAll();
      editCallsign.SetFocus();
   except
      on E: Exception do begin
         LogWrite('*** Exception in buttonQueryClick() ***');
         LogWrite(E.Message);
         LogWrite(E.StackTrace);
      end;
   end;
   finally
      FQueryNow := False;
   end;
end;

procedure TForm1.editCallsignChange(Sender: TObject);
begin
   if editCallsign.Text = '' then begin
      ClearInfo();
   end;
end;

procedure TForm1.editCallsignEnter(Sender: TObject);
begin
   buttonQuery.Default := True;
end;

procedure TForm1.editCallsignExit(Sender: TObject);
begin
   buttonQuery.Default := False;
end;

procedure TForm1.timerWtCheckTimer(Sender: TObject);
begin
   timerWtCheck.Enabled := False;
   try
   try
      if FWtUtils.IsWtPresent() = False then begin
         checkUseWt.Visible := False;
         Exit;
      end
      else begin
         checkUseWt.Visible := True;
      end;

      if checkUseWt.Checked = False then begin
         Exit;
      end;

      GoLookup();
   except
      on E: Exception do begin
         LogWrite('*** Exception in timerWtCheckTimer() ***');
         LogWrite(E.Message);
         LogWrite(E.StackTrace);
      end;
   end;
   finally
      timerWtCheck.Enabled := True;
   end;
end;

procedure TForm1.ToggleSwitch1Click(Sender: TObject);
var
   strResult: string;
   curBack: TCursor;
begin
   if FQueryNow = True then begin
      Exit;
   end;

   FQueryNow := True;
   curBack := Screen.Cursor;
   Screen.Cursor := crHourGlass;
   try
   try
      if ToggleSwitch1.State = tssOn then  begin
         if (FQrzUserid = '') or (FQrzPassword = '') then begin
            MessageBox(Handle, PChar('please enter the user id and password'), PChar(Application.Title), MB_OK or MB_ICONEXCLAMATION);
            ToggleSwitch1.State := tssOff;
            SetEnable(False);
            Exit;
         end;

         if QrzComLogin(FQrzUserId, FQrzPassword, strResult) = True then begin
            SetEnable(True);
            editCallsign.SetFocus();
            FQrzComSessionKey := strResult;
         end
         else begin
            ToggleSwitch1.State := tssOff;
            SetEnable(False);
            StatusBar1.Panels[3].Text := strResult;
         end;
      end
      else begin
         ToggleSwitch1.State := tssOff;
         ClearInfo();
         FQrzComSessionKey := '';
         SetEnable(False);
         checkUseWt.Checked := False;
      end;
   except
      on E: Exception do begin
         LogWrite('*** Exception in ToggleSwitch1Click() ***');
         LogWrite(E.Message);
         LogWrite(E.StackTrace);
      end;
   end;
   finally
      Screen.Cursor := curBack;
      FQueryNow := False;
   end;
end;

procedure TForm1.updownIntervalClick(Sender: TObject; Button: TUDBtnType);
begin
   timerWtCheck.Interval := updownInterval.Position;
end;

function TForm1.QrzComLogin(strUserID, strPassword: string; var strResult: string): Boolean;
var
   strQuery: string;
   strResponse: string;
   xmldoc: TXMLDocument;
   rootnd: IXMLNode;
   node: IXMLNode;
   sessionnd: IXMLNode;
   res: IHttpResponse;
begin
   //MSXML6_ProhibitDTD := False;

   xmldoc := TXMLDocument.Create(Self);
   try
   try
      LogWrite(' **** Enter - QrzComLogin() *** ');

      if FSite = 0 then begin
         strQuery := 'https://xmldata.qrz.com/xml/current/';
      end
      else begin
         strQuery := 'https://ssl.qrzcq.com/xml';
      end;

      strQuery := strQuery + '?username=' + strUserID + ';password=' + strPassword;

      res := NetHTTPRequest1.Get(strQuery);
      strResponse := res.ContentAsString();

      xmldoc.DOMVendor := GetDOMVendor('MSXML');
      xmldoc.XML.Text := strResponse;
      xmldoc.Active := True;

      rootnd := xmldoc.DocumentElement;

      sessionnd := GetXmlNode(rootnd, 'Session', '');
      node := GetXmlNode(sessionnd, 'Key', '');
      if Assigned(node) then begin
         strResult := node.Text;
         Result := True;
      end
      else begin
         node := GetXmlNode(sessionnd, 'Error', '');
         if Assigned(node) then begin
            strResult := node.Text;
         end
         else begin
            strResult := 'Unkown Error';
         end;

         Result := False;
      end;
   except
      on E: Exception do begin
         LogWrite('*** Exception in QrzComLogin() ***');
         LogWrite(E.Message);
         LogWrite(E.StackTrace);
         strResult := E.Message;
         Result := False;
      end;
   end;
   finally
      xmldoc.Free;
      LogWrite(' **** Leave - QrzComLogin() *** ');
   end;
end;

function TForm1.QueryOneStation(strSessionKey: string; strCallsign: string; var strCountry, strCQZone, strITUZone, strState: string): Boolean;
var
   strQuery: string;
   strResponse: string;
   xmldoc: TXMLDocument;
   rootnd: IXMLNode;
   callnd: IXMLNode;
   node: IXMLNode;
   res: IHttpResponse;
begin
   xmldoc := TXMLDocument.Create(Self);
   try
   try
      LogWrite(' **** Enter - QueryOneStation() *** ');

      strCallsign := UpperCase(Trim(strCallsign));
      if strCallsign = '' then begin
         Result := False;
         Exit;
      end;

      strCountry := '';
      strCQZone := '';
      strITUZone := '';
      strState := '';

      if FSite = 0 then begin
         strQuery := 'https://xmldata.qrz.com/xml/current/';
      end
      else begin
         strQuery := 'https://ssl.qrzcq.com/xml';
      end;

      strQuery := strQuery + '?s=' + strSessionKey + ';callsign=' + strCallsign;

      // URL���L�^
      LogWrite(strQuery);

      // http�Ɖ�
      res := NetHTTPRequest1.Get(strQuery);
      strResponse := res.ContentAsString();


      xmldoc.DOMVendor := GetDOMVendor('MSXML');
      xmldoc.XML.Text := strResponse;
      xmldoc.Active := True;

      rootnd := xmldoc.DocumentElement;

      node := GetXmlNode(rootnd, 'Session', '');
      node := GetXmlNode(node, 'Error', '');
      if node <> nil then begin
         strCountry := node.Text;
         Result := False;
         Exit;
      end;

      callnd := GetXmlNode(rootnd, 'Callsign', '');
      node := GetXmlNode(callnd, 'call', '');

      if node.Text = strCallsign then begin
         Result := True;

         node := GetXmlNode(callnd, 'dxcc', '');
         if Assigned(node) then begin
            strCountry := node.Text;
         end;

         node := GetXmlNode(callnd, 'cqzone', '');
         if Assigned(node) then begin
            strCQZone := node.Text;
         end;

         node := GetXmlNode(callnd, 'ituzone', '');
         if Assigned(node) then begin
            strITUZone := node.Text;
         end;

         node := GetXmlNode(callnd, 'state', '');
         if Assigned(node) then begin
            strState := node.Text;
         end;
      end
      else begin
         strCountry := 'No Data';
         Result := False;
      end;
   except
      on E: Exception do begin
         strCountry := '**Exception**';
         LogWrite('*** Exception in QueryOneStation() ***');
         LogWrite(E.Message);
         LogWrite(E.StackTrace);
         Result := False;
      end;
   end;
   finally
      xmldoc.Free;
      LogWrite(' **** Leave - QueryOneStation() *** ');
   end;
end;

function TForm1.GetXmlNode(start_node: IXMLNode; tagname: string; name: string): IXMLNode;
var
   i: integer;
begin
   if start_node = nil then begin
      Result := nil;
      Exit;
   end;

   for i := 0 to start_node.ChildNodes.Count - 1 do begin
      if name = '' then begin
         if (start_node.ChildNodes[i].NodeName = tagname) then begin
            Result := start_node.ChildNodes[i];
            Exit;
         end;
      end
      else begin
         if (start_node.ChildNodes[i].NodeName = tagname) and (start_node.ChildNodes[i].Attributes['Name'] = name) then begin
            Result := start_node.ChildNodes[i];
            Exit;
         end;
      end;
      if start_node.ChildNodes[i].HasChildNodes = True then begin
         Result := GetXmlNode(start_node.ChildNodes[i], tagname, name);
         if Result <> nil then begin
            Exit;
         end;
      end;
   end;

   Result := nil;
end;

procedure TForm1.httpConnected(Sender: TObject);
begin
   StatusBar1.Panels[3].Text := 'Connected';
   LogWrite('http connected');
end;

procedure TForm1.httpDisconnected(Sender: TObject);
begin
   StatusBar1.Panels[3].Text := 'Disconnected';
//   ToggleSwitch1.State := tssOff;
   LogWrite('http disconnected');
end;

procedure TForm1.SetEnable(fEnable: Boolean);
begin
   editCallsign.Enabled := fEnable;
   buttonQuery.Enabled := fEnable;
   StringGrid1.Enabled := fEnable;
   checkUseWt.Enabled := fEnable;
   editInterval.Enabled := fEnable;
   updownInterval.Enabled := fEnable;
   FCheckWindow.Visible := fEnable;
end;
procedure TForm1.StringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
   strText: string;
   x, y: Integer;
begin
   with StringGrid1.Canvas do begin
      Font.Name := '�l�r �o�S�V�b�N';
      if ARow = 0 then begin
         Brush.Color := StringGrid1.FixedColor;
         Brush.Style := bsSolid;
         FillRect(Rect);
         Font.Size := 11;
         Font.Color := clBlack;
      end;
      if ARow = 1 then begin
         Brush.Color := clWhite;
         Brush.Style := bsSolid;
         FillRect(Rect);
         Font.Size := 30;
         Font.Color := clBlack;
      end;

      strText := StringGrid1.Cells[ACol, ARow];

      while TextWidth(strText) > StringGrid1.ColWidths[ACol] do begin
         Font.Size := Font.Size - 1;
         if Font.Size <= 6 then begin
            Break;
         end;
      end;

      x := ((Rect.Right - Rect.Left) - TextWidth(strText)) div 2;
      y := ((Rect.Bottom - Rect.Top) - TextHeight(strText)) div 2;

      TextRect(Rect, Rect.Left + x, Rect.Top + y, strText);
   end;
end;

procedure TForm1.StringGrid1TopLeftChanged(Sender: TObject);
begin
   StringGrid1.LeftCol := 0;
end;

procedure TForm1.checkUseWtClick(Sender: TObject);
begin
   FWtUtils.Init();
end;

procedure TForm1.ClearInfo();
begin
   StringGrid1.Cells[0, 1] := '';
   StringGrid1.Cells[1, 1] := '';
   StringGrid1.Cells[2, 1] := '';
   StringGrid1.Cells[3, 1] := '';
   StringGrid1.Cells[4, 1] := '';
end;

function TForm1.GetCallsign(strCallsign: string): string;
var
   Index: Integer;
   strLeft, strRight: string;
begin
   Index := Pos('/', strCallsign);
   if Index = 0 then begin
      Result := strCallsign;
      Exit;
   end;

   strLeft := Copy(strCallsign, 1, Index - 1);
   strRight := Copy(strCallsign, Index + 1);

   if Length(strLeft) >= Length(strRight) then begin
      Result := strLeft;
   end
   else begin
      Result := strRight;
   end;
end;

procedure TForm1.GoLookup();
var
   strCallsign: string;
   strCountry, strCQZone, strITUZone, strState: string;
begin
   try
      strCallsign := FWtUtils.GetCallsign();

      strCallsign := GetCallsign(strCallsign);

      if editCallsign.Text <> strCallsign then begin
         editCallsign.Text := strCallsign;

         if strCallsign = '' then begin
            Exit;
         end;

         buttonQueryClick(nil);

         FLastQueryTickCount := GetTickCount();
      end;
   finally
      // keep alive
      if (FKeepAliveMinute > 0) and
         ((GetTickCount() - FLastQueryTickCount) > (FKeepAliveMinute {min} * 60 {sec} * 1000 {msec})) then begin
         strCountry := '';
         strCQZone := '';
         strITUZone := '';
//         QueryOneStation(FQrzComSessionKey, 'JR8PPG', strCountry, strCQZone, strITUZone, strState);
         FLastQueryTickCount := GetTickCount();
      end;
   end;
end;

procedure TForm1.LogWrite(msg: string);
var
   str: string;
   txt: TextFile;
begin
   AssignFile(txt, FLogFileName);
   if FileExists(FLogFileName) then begin
      Reset(txt);
   end
   else begin
      Rewrite(txt);
   end;

   str := FormatDateTime( 'yyyy/mm/dd hh:nn:ss ', Now ) + msg;

   Append( txt );
   WriteLn( txt, str );
   Flush( txt );
   CloseFile( txt );
end;

procedure TForm1.NetHTTPRequest1RequestError(const Sender: TObject; const AError: string);
begin
   LogWrite('request error: ' + AError);
end;

procedure TForm1.NetHTTPRequest1RequestException(const Sender: TObject; const AError: Exception);
begin
   LogWrite('request exception: ' + AError.Message);
end;

function GetExceptionStackInfoProc(P: PExceptionRecord): Pointer;
var
   LLines: TStringList;
   LText: String;
   LResult: PChar;
begin
   LLines := TStringList.Create;
   try
      JclLastExceptStackListToStrings(LLines, True, True, True, True);
      LText := LLines.Text;
      LResult := StrAlloc(Length(LText));
      StrCopy(LResult, PChar(LText));
      Result := LResult;
   finally
      LLines.Free;
   end;
end;

function GetStackInfoStringProc(Info: Pointer): string;
begin
   Result := string(PChar(Info));
end;

procedure CleanUpStackInfoProc(Info: Pointer);
begin
   StrDispose(PChar(Info));
end;

initialization

// Start the Jcl exception tracking and register our Exception
// stack trace provider.
if JclStartExceptionTracking then
begin
   Exception.GetExceptionStackInfoProc := GetExceptionStackInfoProc;
   Exception.GetStackInfoStringProc := GetStackInfoStringProc;
   Exception.CleanUpStackInfoProc := CleanUpStackInfoProc;
end;

finalization

// Stop Jcl exception tracking and unregister our provider.
if JclExceptionTrackingActive then
begin
   Exception.GetExceptionStackInfoProc := nil;
   Exception.GetStackInfoStringProc := nil;
   Exception.CleanUpStackInfoProc := nil;
   JclStopExceptionTracking;
end;

end.