unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.IniFiles, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, System.Math,
  Vcl.ExtCtrls, Vcl.StdCtrls, Xml.xmldom, Xml.XMLIntf, Xml.XMLDoc,
  Vcl.WinXCtrls, Vcl.Grids, JclDebug, Vcl.Menus, Winapi.WinSock,
  System.Net.URLClient, System.Net.HttpClient, System.Net.HttpClientComponent,
  WtUtils, Dxcc, RbnFilter, UOptions, UCustomListDlg, Station, Vcl.Buttons;

const
  MAXPACKETLEN = 2048;
  WM_USER_N1MM_BROADCAST = (WM_USER + 101);

type
  TformMain = class(TForm)
    timerWtCheck: TTimer;
    StatusBar1: TStatusBar;
    StringGrid1: TStringGrid;
    NetHTTPClient1: TNetHTTPClient;
    NetHTTPRequest1: TNetHTTPRequest;
    Panel1: TPanel;
    Label1: TLabel;
    editCallsign: TEdit;
    buttonQuery: TButton;
    ToggleSwitch1: TToggleSwitch;
    buttonMenu: TSpeedButton;
    popupMainMenu: TPopupMenu;
    menuOptions: TMenuItem;
    menuCustomList: TMenuItem;
    N3: TMenuItem;
    menuRbnTool: TMenuItem;
    N4: TMenuItem;
    menuExit: TMenuItem;
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
    procedure StringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure FormResize(Sender: TObject);
    procedure httpConnected(Sender: TObject);
    procedure httpDisconnected(Sender: TObject);
    procedure editCallsignChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure checkUseWtClick(Sender: TObject);
    procedure NetHTTPRequest1RequestError(const Sender: TObject; const AError: string);
    procedure NetHTTPRequest1RequestException(const Sender: TObject; const AError: Exception);
    procedure menuRbnToolClick(Sender: TObject);
    procedure menuExitClick(Sender: TObject);
    procedure menuFileClick(Sender: TObject);
    procedure StringGrid1MouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure StringGrid1MouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure menuOptionsClick(Sender: TObject);
    procedure menuCustomListClick(Sender: TObject);
    procedure buttonMenuClick(Sender: TObject);
  protected
    procedure ReadBroadcastPacket( var Message: TMessage ); message WM_USER_N1MM_BROADCAST;
  private
    { Private 宣言 }
    FWtUtils: TWtUtils;
    FDxccList: TDxccList;
    FLogFileName: string;
    FQueryNow: Boolean;
    FLastQueryTickCount: DWORD;
    FQrzComSessionKey: string;

    // 設定項目
    FSelectSite: Integer;
    FKeepAliveMinute: Integer;
    FUserId: array[0..1] of string;
    FPassword: array[0..1] of string;
    FLinkLogger: Integer;
    FScanInterval: Integer;
    FUdpPort: Integer;

    // zLog
    m_zLogV28: Boolean;
    FZLogLoggerWnd: HWND;

    // N1MM+
    FN1mmLoggerWnd: HWND;

    // 表示用フォントサイズ
    FInfoFontSize: Integer;
    FLocalQuery: Boolean;

    // UDPサーバー用
    FUdpServer: TSocket;
    FServerAddr: TSockAddrIn;
    FClientAddr: TSockAddrIn;

    // カスタムリスト
    FCustomListFile: TStringList;
    FCustomList: TStationList;

    function QrzComLogin(strUserID, strPassword: string; var strResult: string): Boolean;
    function QueryOneStation(strSessionKey: string; strCallsign: string; var strCountry, strCQZone, strITUZone, strState: string): Boolean; overload;
    function GetXmlNode(start_node: IXMLNode; tagname: string; name: string): IXMLNode;
    procedure SetEnable(fEnable: Boolean);
    procedure ClearInfo();
    function GetCallsign(strCallsign: string): string;
    function FindZlogWindow(): HWND;
    function FindN1mmWindow(): HWND;
    function Find_zLog(): HWND;
    function Find_n1mm(): HWND;
    procedure LoadSettings();
    procedure SaveSettings();
    procedure StartN1mmUdpServer();
    procedure StopN1mmUdpServer();
    function GetXmlValue(xml: string; tag: string): string;
    procedure BuildCustomList();
  public
    { Public 宣言 }
    function QueryOneStation(strCallsign: string; var strCountry, strCQZone, strITUZone, strState: string): Boolean; overload;
    procedure GoWtLookup();
    procedure GoZlogLookup();
    procedure GoN1mmLookup();
    procedure LogWrite(msg: string);
    property DxccList: TDxccList read FDxccList;
  end;

function IsDomestic(strCallsign: string): Boolean;

var
  formMain: TformMain;

implementation

{$R *.dfm}

uses
  SelectZlog;

procedure TformMain.FormCreate(Sender: TObject);
begin
   FWtUtils := TWtUtils.Create();
   FDxccList := TDxccList.Create();
   FDxccList.LoadFromResourceName(SysInit.HInstance, 'ID_DXCCLIST');
   FCustomListFile := TStringList.Create();
   FCustomListFile.StrictDelimiter := True;
   FCustomList := TStationList.Create();
   FQueryNow := False;
   FUdpServer := 0;

   FLogFileName := ExtractFilePath(Application.ExeName) +
                   ChangeFileExt(ExtractFileName(Application.ExeName), '') + '_' + FormatDateTime('yyyymmdd', Now) + '.log';

   LoadSettings();

   if FSelectSite = 0 then begin
      Caption := 'QRZ.COM Lookup Tool';
   end
   else begin
      Caption := 'QRZCQ.COM Lookup Tool';
   end;

   StringGrid1.Cells[0, 0] := 'Country';
   StringGrid1.Cells[1, 0] := 'Continent';
   StringGrid1.Cells[2, 0] := 'CQ Zone';
   StringGrid1.Cells[3, 0] := 'ITU Zone';
   StringGrid1.Cells[4, 0] := 'State';
   StringGrid1.Cells[5, 0] := 'Comment';
   StringGrid1.ColWidths[0] := 240;
   StringGrid1.ColWidths[1] := 80;
   StringGrid1.ColWidths[2] := 80;
   StringGrid1.ColWidths[3] := 80;
   StringGrid1.ColWidths[4] := 80;
   StringGrid1.ColWidths[5] := 240;
   StringGrid1.RowHeights[1] := 80;
end;

procedure TformMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   LogWrite('*** QrzLookup stopped ***');
   if FLinkLogger = 4 then begin
      StopN1mmUdpServer();
   end;
end;

procedure TformMain.FormDestroy(Sender: TObject);
begin
   SaveSettings();
   FWtUtils.Free();
   FDxccList.Free();
   FCustomListFile.Free();
   FCustomList.Free();
end;

procedure TformMain.FormResize(Sender: TObject);
var
   w: Integer;
   h: Integer;
begin
   w := (ClientWidth - 12) div 10;
   h := ClientHeight - (Panel1.Height + StringGrid1.RowHeights[0] + StatusBar1.Height);
   StringGrid1.ColWidths[0] := w * 3;
   StringGrid1.ColWidths[1] := w;
   StringGrid1.ColWidths[2] := w;
   StringGrid1.ColWidths[3] := w;
   StringGrid1.ColWidths[4] := w;
   StringGrid1.ColWidths[5] := w * 3;
   StringGrid1.RowHeights[1] := h;
   ClientWidth := w * 10 + 12;
end;

procedure TformMain.FormShow(Sender: TObject);
begin
   SetEnable(False);
   LogWrite('*** QrzLookup started ***');
end;

procedure TformMain.FormActivate(Sender: TObject);
begin
   if editCallsign.Enabled = True then begin
      editCallsign.SetFocus();
   end;
end;

procedure TformMain.buttonMenuClick(Sender: TObject);
var
   pt: TPoint;
begin
   pt.X := buttonMenu.Left;
   pt.Y := buttonMenu.Top + buttonMenu.Height;
   pt := Panel1.ClientToScreen(pt);
   popupMainMenu.Popup(pt.X, pt.Y);
end;

procedure TformMain.buttonQueryClick(Sender: TObject);
var
   strCallsign: string;
   dwTick: DWORD;
   strCountry, strCQZone, strITUZone, strContinent, strState: string;
   dxcc: TDxccObject;
   station: TStationInfo;
begin
   if FQueryNow = True then begin
      Exit;
   end;

   FLocalQuery := False;
   FQueryNow := True;
   try
   try
      strCallsign := UpperCase(Trim(editCallsign.Text));
      if strCallsign = '' then begin
         Exit;
      end;

      strCallsign := GetCallsign(strCallsign);

      // ローカルクエリーから
      station := FCustomList.ObjectOf(strCallsign);
      if station <> nil then begin
         ClearInfo();

         StringGrid1.Cells[0, 1] := station.Country;
         StringGrid1.Cells[1, 1] := station.Continent;
         StringGrid1.Cells[2, 1] := station.CQZone;
         StringGrid1.Cells[3, 1] := station.ITUZone;
         StringGrid1.Cells[4, 1] := station.State;
         StringGrid1.Cells[5, 1] := station.Comment;

         FLocalQuery := True;
         StatusBar1.Panels[0].Text := 'local query';

         editCallsign.SelectAll();
         editCallsign.SetFocus();
         Exit;
      end;

      // ４文字未満はクエリーしない
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
         StringGrid1.Cells[5, 1] := '';
      end
      else begin
         StringGrid1.Cells[0, 1] := strCountry;
         StringGrid1.Cells[1, 1] := '';
         StringGrid1.Cells[2, 1] := '';
         StringGrid1.Cells[3, 1] := '';
         StringGrid1.Cells[4, 1] := '';
         StringGrid1.Cells[5, 1] := '';
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

procedure TformMain.editCallsignChange(Sender: TObject);
begin
   if editCallsign.Text = '' then begin
      ClearInfo();
   end;
end;

procedure TformMain.editCallsignEnter(Sender: TObject);
begin
   buttonQuery.Default := True;
end;

procedure TformMain.editCallsignExit(Sender: TObject);
begin
   buttonQuery.Default := False;
end;

procedure TformMain.timerWtCheckTimer(Sender: TObject);
begin
   timerWtCheck.Enabled := False;
   try
   try
      case FLinkLogger of
         // None
         0: begin
            //
         end;

         // Win-Test
         1: begin
            if FWtUtils.IsWtPresent() = True then begin
               GoWtLookup();
            end;
         end;

         // zLog
         2: begin
            if FZlogLoggerWnd <> 0 then begin
               GoZlogLookup();
            end;
         end;

         // N1MM+
         3: begin
            if FN1mmLoggerWnd <> 0 then begin
               GoN1mmLookup();
            end;
         end;

         // N1MM+ (UDP)
         4: begin
            //
         end;
      end;
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

procedure TformMain.ToggleSwitch1Click(Sender: TObject);
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
         if (FUserid[FSelectSite] = '') or (FPassword[FSelectSite] = '') then begin
            menuOptionsClick(nil);
//            MessageBox(Handle, PChar('please enter the user id and password'), PChar(Application.Title), MB_OK or MB_ICONEXCLAMATION);
            ToggleSwitch1.State := tssOff;
            SetEnable(False);
            Exit;
         end;

         if QrzComLogin(FUserId[FSelectSite], FPassword[FSelectSite], strResult) = True then begin
            SetEnable(True);
            editCallsign.SetFocus();
            FQrzComSessionKey := strResult;

            if FLinkLogger = 4 then begin
               StartN1mmUdpServer();
            end;

            // カスタムリストを展開
            BuildCustomList();
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

         if FLinkLogger = 4 then begin
            StopN1mmUdpServer();
         end;
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

function TformMain.QrzComLogin(strUserID, strPassword: string; var strResult: string): Boolean;
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

      if FSelectSite = 0 then begin
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

function TformMain.QueryOneStation(strSessionKey: string; strCallsign: string; var strCountry, strCQZone, strITUZone, strState: string): Boolean;
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
//      LogWrite(' **** Enter - QueryOneStation() *** ');

      strCallsign := UpperCase(Trim(strCallsign));
      if strCallsign = '' then begin
         Result := False;
         Exit;
      end;

      strCountry := '';
      strCQZone := '';
      strITUZone := '';
      strState := '';

      if FSelectSite = 0 then begin
         strQuery := 'https://xmldata.qrz.com/xml/current/';
      end
      else begin
         strQuery := 'https://ssl.qrzcq.com/xml';
      end;

      strQuery := strQuery + '?s=' + strSessionKey + ';callsign=' + strCallsign;

      // URLを記録
      LogWrite(strQuery);

      // http照会
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
//      LogWrite(' **** Leave - QueryOneStation() *** ');
   end;
end;

function TformMain.QueryOneStation(strCallsign: string; var strCountry, strCQZone, strITUZone, strState: string): Boolean;
begin
   Result := QueryOneStation(FQrzComSessionKey, strCallsign, strCountry, strCQZone, strITUZone, strState);
end;

function TformMain.GetXmlNode(start_node: IXMLNode; tagname: string; name: string): IXMLNode;
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

procedure TformMain.httpConnected(Sender: TObject);
begin
   StatusBar1.Panels[3].Text := 'Connected';
   LogWrite('http connected');
end;

procedure TformMain.httpDisconnected(Sender: TObject);
begin
   StatusBar1.Panels[3].Text := 'Disconnected';
//   ToggleSwitch1.State := tssOff;
   LogWrite('http disconnected');
end;

procedure TformMain.SetEnable(fEnable: Boolean);
begin
   editCallsign.Enabled := fEnable;
   buttonQuery.Enabled := fEnable;
   StringGrid1.Enabled := fEnable;
   menuOptions.Enabled := not fEnable;
   menuCustomList.Enabled := not fEnable;
end;

procedure TformMain.StringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
   strText: string;
   x, y: Integer;
begin
   with StringGrid1.Canvas do begin
      Font.Name := 'ＭＳ Ｐゴシック';
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
         Font.Size := FInfoFontSize;

         if FLocalQuery = True then begin
            Font.Color := clGreen;
         end
         else begin
            Font.Color := clBlack;
         end;
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

procedure TformMain.StringGrid1MouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
var
   font_size: Integer;
begin
   // CTRL+DOWNでフォントサイズDOWN
   if GetAsyncKeyState(VK_CONTROL) < 0 then begin
      font_size := FInfoFontSize;
      Dec(font_size);
      if font_size < 6 then begin
         font_size := 6;
      end;
      FInfoFontSize := font_size;
      StringGrid1.Refresh();
      Handled := True;
   end;
end;

procedure TformMain.StringGrid1MouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
var
   font_size: Integer;
begin
   // CTRL+UPでフォントサイズUP
   if GetAsyncKeyState(VK_CONTROL) < 0 then begin
      font_size := FInfoFontSize;
      Inc(font_size);
      if font_size > 50 then begin
         font_size := 50;
      end;
      FInfoFontSize := font_size;
      StringGrid1.Refresh();
      Handled := True;
   end;
end;

procedure TformMain.StringGrid1TopLeftChanged(Sender: TObject);
begin
   StringGrid1.LeftCol := 0;
end;

procedure TformMain.checkUseWtClick(Sender: TObject);
begin
   FWtUtils.Init();
end;

procedure TformMain.ClearInfo();
begin
   StringGrid1.Cells[0, 1] := '';
   StringGrid1.Cells[1, 1] := '';
   StringGrid1.Cells[2, 1] := '';
   StringGrid1.Cells[3, 1] := '';
   StringGrid1.Cells[4, 1] := '';
   StringGrid1.Cells[5, 1] := '';
end;

function TformMain.GetCallsign(strCallsign: string): string;
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

procedure TformMain.GoWtLookup();
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
         FLastQueryTickCount := GetTickCount();
      end;
   end;
end;

procedure TformMain.GoZlogLookup();
var
   szWindowText: array[0..1024] of Char;
   nLen: Integer;
   strText: string;
   strCallsign: string;
   strCountry, strCQZone, strITUZone, strState: string;
   callsign_atom: ATOM;
begin
   try
      ZeroMemory(@szWindowText, SizeOf(szWindowText));

      if m_zLogV28 = True then begin
         nLen := SendMessage(FZlogLoggerWnd, (WM_USER + 200), 0, 0);
         callsign_atom := LOWORD(nLen);
         if callsign_atom = 0 then begin
            Exit;
         end;

         nLen := GlobalGetAtomName(callsign_atom, PChar(@szWindowText), SizeOf(szWindowText));
         if (nLen = 0) then begin
            Exit;
         end;

         GlobalDeleteAtom(callsign_atom);
      end
      else begin
         nLen := SendMessage(FZlogLoggerWnd, WM_GETTEXT, SizeOf(szWindowText), LPARAM(PChar(@szWindowText)));
      end;

      strCallsign := szWindowText;

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
         FLastQueryTickCount := GetTickCount();
      end;
   end;
end;

procedure TformMain.GoN1mmLookup();
var
   szWindowText: array[0..100] of Char;
   strText: WideString;
   strCallsign: string;
   strCountry, strCQZone, strITUZone, strState: string;
   nLen: Integer;
   dwError: DWORD;
begin
   try
      ZeroMemory(@szWindowText, SizeOf(szWindowText));
      nLen := SendMessage(FN1mmLoggerWnd, WM_GETTEXTLENGTH, 0, 0);
      if nLen = 0 then begin
         Exit;
      end;

      nLen := SendMessage(FN1mmLoggerWnd, WM_GETTEXT, SizeOf(szWindowText), LPARAM(PChar(@szWindowText)));
      if nLen = 0 then begin
         dwError := GetLastError();
         Exit;
      end;

      strText := PChar(@szWindowText);
      strCallsign := strText;

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
         FLastQueryTickCount := GetTickCount();
      end;
   end;
end;

procedure TformMain.LogWrite(msg: string);
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

procedure TformMain.NetHTTPRequest1RequestError(const Sender: TObject; const AError: string);
begin
   LogWrite('request error: ' + AError);
end;

procedure TformMain.NetHTTPRequest1RequestException(const Sender: TObject; const AError: Exception);
begin
   LogWrite('request exception: ' + AError.Message);
end;

procedure TformMain.menuFileClick(Sender: TObject);
begin
   menuRbnTool.Enabled := (FQrzComSessionKey <> '')
end;

procedure TformMain.menuOptionsClick(Sender: TObject);
var
   dlg: TformOptions;
begin
   dlg := TformOptions.Create(Self);
   try
      dlg.Site := FSelectSite;

      dlg.UserId[0] := FUserId[0];
      dlg.Password[0] := FPassword[0];
      dlg.UserId[1] := FUserId[1];
      dlg.Password[1] := FPassword[1];

      dlg.KeepAliveMin := FKeepAliveMinute;
      dlg.UdpPort := FUdpPort;

      dlg.LinkLogger := FLinkLogger;
      dlg.ScanInterval := FScanInterval;

      if dlg.ShowModal() <> mrOK then begin
         Exit;
      end;

      FSelectSite := dlg.Site;

      FUserId[0] := dlg.UserId[0];
      FPassword[0] := dlg.Password[0];
      FUserId[1] := dlg.UserId[1];
      FPassword[1] := dlg.Password[1];

      FKeepAliveMinute := dlg.KeepAliveMin;
      FUdpPort := dlg.UdpPort;

      FLinkLogger := dlg.LinkLogger;

      if FLinkLogger = 2 then begin
         FZLogLoggerWnd := Find_zlog();
         if FZLogLoggerWnd = 0 then begin
            FLinkLogger := 0;
         end;
      end;

      if FLinkLogger = 3 then begin
         FN1mmLoggerWnd := Find_n1mm();
         if FN1mmLoggerWnd = 0 then begin
            FLinkLogger := 0;
         end;
      end;

      FScanInterval := dlg.ScanInterval;

      SaveSettings();
   finally
      dlg.Release();
   end;
end;

procedure TformMain.menuCustomListClick(Sender: TObject);
var
   dlg: TformCustomListDialog;
begin
   dlg := TformCustomListDialog.Create(Self);
   try
      dlg.CustomListFile.Assign(FCustomListFile);

      if dlg.ShowModal() <> mrOK then begin
         Exit;
      end;

      FCustomListFile.Assign(dlg.CustomListFile);

      SaveSettings();
   finally
      dlg.Release();
   end;
end;

procedure TformMain.menuRbnToolClick(Sender: TObject);
var
   dlg: TformRbnFilter;
begin
   dlg := TformRbnFilter.Create(Self);
   try
      dlg.ShowModal();
   finally
      dlg.Release();
   end;
end;

procedure TformMain.menuExitClick(Sender: TObject);
begin
   Close();
end;

// ----------------------------------------------------------------------------

function TformMain.FindZlogWindow(): HWND;
var
   hZlogWnd: HWND;
   szCaption: array[0..1024] of Char;
   strCaption: string;
   nLen: Integer;
   slWindows: TStringList;
   f: TformSelectZLog;
   childwnd: HWND;
begin
   f := TformSelectZLog.Create(Self);
   slWindows := TStringList.Create();
   try
      hZlogWnd := GetTopWindow(0);
      repeat
         nLen := GetWindowText(hZlogWnd, szCaption, SizeOf(szCaption));
         if nLen > 0 then begin
            strCaption := StrPas(szCaption);
            if Pos('zLog for Windows', strCaption) > 0 then begin
               // 子ウインドウを持たないウインドウは除外
               childwnd := GetWindow(hZlogWnd, GW_CHILD);
               if (childwnd <> 0) then begin
                  slWindows.AddObject(strCaption, TObject(hZlogWnd));
               end;
            end;
         end;

         hZlogWnd := GetNextWindow(hZlogWnd, GW_HWNDNEXT)
      until hZlogWnd = 0;

      if slWindows.Count = 0 then begin
         Result := 0;
      end
      else if slWindows.Count = 1 then begin
         Result := HWND(slWindows.Objects[0]);
      end
      else begin  // >= 2
         f.List := slWindows;
         if f.ShowModal() <> mrOK then begin
            Result := 0;
            Exit;
         end;

         Result := HWND(slWindows.Objects[f.SelectedIndex]);
      end;
   finally
      slWindows.Free();
      f.Release();
   end;
end;

// ----------------------------------------------------------------------------

function TformMain.FindN1mmWindow(): HWND;
var
   hN1mmWnd: HWND;
   szCaption: array[0..1024] of Char;
   strCaption: string;
   szClassName: array[0..1024] of Char;
   strClassName: string;
   nLen: Integer;
   slWindows: TStringList;
   f: TformSelectZLog;
   childwnd: HWND;
begin
   f := TformSelectZLog.Create(Self);
   slWindows := TStringList.Create();
   try
      hN1mmWnd := GetTopWindow(0);
      repeat
         ZeroMemory(@szClassName, SizeOf(szClassName));
         nLen := GetClassName(hN1mmWnd, szClassName, SizeOf(szClassName));
         if nLen > 0 then begin
            strClassName := StrPas(szClassName);
            if Pos('WindowsForms10.Window.8.app.', strClassName) > 0 then begin
               // 子ウインドウを持たないウインドウは除外
               childwnd := GetWindow(hN1mmWnd, GW_CHILD);
               if (childwnd <> 0) then begin
                  nLen := GetWindowText(hN1mmWnd, szCaption, SizeOf(szCaption));
                  strCaption := StrPas(szCaption);
                  slWindows.AddObject(strCaption, TObject(hN1mmWnd));
               end;
            end;
         end;

         hN1mmWnd := GetNextWindow(hN1mmWnd, GW_HWNDNEXT)
      until hN1mmWnd = 0;

      if slWindows.Count = 0 then begin
         Result := 0;
      end
      else if slWindows.Count = 1 then begin
         Result := HWND(slWindows.Objects[0]);
      end
      else begin  // >= 2
         f.List := slWindows;
         if f.ShowModal() <> mrOK then begin
            Result := 0;
            Exit;
         end;

         Result := HWND(slWindows.Objects[f.SelectedIndex]);
      end;
   finally
      slWindows.Free();
      f.Release();
   end;
end;

// ----------------------------------------------------------------------------

function TformMain.Find_zLog(): HWND;
var
   hZlogWnd: HWND;
   wnd: HWND;
   ver: Integer;
begin
   // zLogのコントロールを調べる
   hZlogWnd := FindZlogWindow();
   if (hZlogWnd = 0) then begin
      Application.MessageBox('zLog for Windowsが見つかりません', 'QRZLOOKUP', MB_OK or MB_ICONEXCLAMATION);
      Result := 0;
      Exit;
   end;

   // zLog V2.8以降か調べる
   ver := SendMessage(hZlogWnd, (WM_USER + 201), 0, 0);
   if ver >= 2800 then begin
      m_zLogV28 := True;
      Result := hZlogWnd;
      Exit;
   end
   else begin
      m_zLogV28 := False;
   end;

   // 最初の子ウインドウ
   wnd := GetWindow(hZlogWnd, GW_CHILD);
   if (wnd = 0) then begin
      Application.MessageBox('can not find first child window', 'QRZLOOKUP', MB_OK or MB_ICONEXCLAMATION);
      Result := 0;
      Exit;
   end;

   // 次のウインドウ　たぶんこれが対象のパネル
   wnd := GetWindow(wnd, GW_HWNDNEXT);
   if (wnd = 0) then begin
      Result := 0;
      Exit;
   end;

   // timeのTOvrEdit
   wnd := GetWindow(wnd, GW_CHILD);
   if (wnd = 0) then begin
      Result := 0;
      Exit;
   end;

   // memo欄
   wnd := GetWindow(wnd, GW_HWNDNEXT);
   if (wnd = 0) then begin
      Result := 0;
      Exit;
   end;

   // rcvd
   wnd := GetWindow(wnd, GW_HWNDNEXT);
   if (wnd = 0) then begin
      Result := 0;
      Exit;
   end;

   // callsign
   wnd := GetWindow(wnd, GW_HWNDNEXT);
   if (wnd = 0) then begin
      Result := 0;
      Exit;
   end;

   Result := wnd;
end;

// ----------------------------------------------------------------------------

function TformMain.Find_n1mm(): HWND;
var
   hN1mmWnd: HWND;
   wnd: HWND;
   wnd2: HWND;
   szClassName: array[0..1024] of Char;
   strClassName: string;
begin
   hN1mmWnd := FindN1mmWindow();
   if (hN1mmWnd = 0) then begin
      Application.MessageBox('N1MM+が見つかりません', 'QRZLOOKUP', MB_OK or MB_ICONEXCLAMATION);
      Result := 0;
      Exit;
   end;

   // 最初の子ウインドウ
   wnd := GetWindow(hN1mmWnd, GW_CHILD);
   if (wnd = 0) then begin
      Application.MessageBox('can not find first child window', 'QRZLOOKUP', MB_OK or MB_ICONEXCLAMATION);
      Result := 0;
      Exit;
   end;

   repeat
      GetClassName(wnd, szClassName, SizeOf(szClassName));
      strClassName := StrPas(szClassName);
      if Pos('WindowsForms10.Window.8.app.', strClassName) > 0 then begin
         wnd2 := GetWindow(wnd, GW_CHILD);
         if (wnd2 = 0) then begin
            Result := 0;
            Exit;
         end;

         GetClassName(wnd2, szClassName, SizeOf(szClassName));
         strClassName := StrPas(szClassName);
         if Pos('WindowsForms10.EDIT.', strClassName) > 0 then begin
            wnd := wnd2;
            Break;
         end;
      end;

      wnd := GetWindow(wnd, GW_HWNDNEXT);
   until wnd = 0;

   if (wnd = 0) then begin
      Application.MessageBox('can not find edit control', 'QRZLOOKUP', MB_OK or MB_ICONEXCLAMATION);
      Result := 0;
      Exit;
   end;

   Result := wnd;
end;

// ----------------------------------------------------------------------------

procedure TformMain.LoadSettings();
var
   ini: TIniFile;
   x, y: Integer;
   w, h: Integer;
   n: Integer;
   fname: string;
begin
   ini := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
   try
      FSelectSite := ini.ReadInteger('SETTINGS', 'SiteSelect', 0);
      FLastQueryTickCount := GetTickCount();

      x := ini.ReadInteger('SETTINGS', 'X', -1);
      y := ini.ReadInteger('SETTINGS', 'Y', -1);
      w := ini.ReadInteger('SETTINGS', 'W', -1);
      h := ini.ReadInteger('SETTINGS', 'H', -1);
      if (x > -1) and (y > -1) then begin
         Left := x;
         Top := y;
         Position := poDesigned;
      end
      else begin
         Position := poDefaultPosOnly;
      end;

      if w > -1 then begin
         Width := w;
      end;

      if h > -1 then begin
         Height := h;
      end;

      FInfoFontSize := ini.ReadInteger('SETTINGS', 'FontSize', 30);

      FLinkLogger := ini.ReadInteger('SETTINGS', 'LinkLogger', 0);

      n := ini.ReadInteger('SETTINGS', 'ScanInterval', 500);
      n := Min(Max(n, 100), 3000);
      FScanInterval := n;
      timerWtCheck.Interval := n;

      n := ini.ReadInteger('SETTINGS', 'KeepAliveMinute', 0);
      FKeepAliveMinute := n;

      FUserId[0] := ini.ReadString('QRZ.COM', 'UserID', '');
      FPassword[0] := ini.ReadString('QRZ.COM', 'Password', '');
      FUserId[1] := ini.ReadString('QRZCQ.COM', 'UserID', '');
      FPassword[1] := ini.ReadString('QRZCQ.COM', 'Password', '');
      FUdpPort := ini.ReadInteger('SETTINGS', 'UdpPort', 12060);

      fname := ExtractFilePath(Application.ExeName) + 'customlist.txt';
      if FileExists(fname) then begin
         FCustomListFile.LoadFromFile(fname);
      end;
   finally
      ini.Free();
   end;
end;

procedure TformMain.SaveSettings();
var
   ini: TIniFile;
   fname: string;
begin
   ini := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
   try
      ini.WriteInteger('SETTINGS', 'SiteSelect', FSelectSite);
      ini.WriteInteger('SETTINGS', 'X', Left);
      ini.WriteInteger('SETTINGS', 'Y', Top);
      ini.WriteInteger('SETTINGS', 'W', Width);
      ini.WriteInteger('SETTINGS', 'H', Height);
      ini.WriteInteger('SETTINGS', 'FontSize', FInfoFontSize);
      ini.WriteInteger('SETTINGS', 'ScanInterval', FScanInterval);
      ini.WriteInteger('SETTINGS', 'KeepAliveMinute', FKeepAliveMinute);
      ini.WriteInteger('SETTINGS', 'LinkLogger', FLinkLogger);
      ini.WriteInteger('SETTINGS', 'UdpPort', FUdpPort);
      ini.WriteString('QRZ.COM', 'UserID', FUserId[0]);
      ini.WriteString('QRZ.COM', 'Password', FPassword[0]);
      ini.WriteString('QRZCQ.COM', 'UserID', FUserId[1]);
      ini.WriteString('QRZCQ.COM', 'Password', FPassword[1]);

      fname := ExtractFilePath(Application.ExeName) + 'customlist.txt';
      FCustomListFile.SaveToFile(fname);
   finally
      ini.Free();
   end;
end;

// ----------------------------------------------------------------------------

procedure TformMain.StartN1mmUdpServer();
var
   optval: Integer;
   nResult: Integer;
begin
   // UDPソケットを準備
   FUdpServer := Socket(AF_INET, SOCK_DGRAM, 0);
   optval := 1;
   SetSockOpt(FUdpServer, SOL_SOCKET, SO_REUSEADDR, @optval, SizeOf(Integer));

   // アドレス情報
   FServerAddr.sin_family := AF_INET;
   FServerAddr.sin_addr.s_addr := htonl(INADDR_ANY);
   FServerAddr.sin_port := htons(FUdpPort);

   // ソケットにアドレス情報をバインド
   Bind(FUdpServer, FServerAddr, SizeOf(TSockAddrIn) );

   // 受信開始
   nResult := WSAAsyncSelect(FUdpServer, Handle, WM_USER_N1MM_BROADCAST, FD_READ);
   if nResult = SOCKET_ERROR then begin
      StatusBar1.Panels[3].Text := 'UDPサーバーを開始できません errorcode=' + IntToStr(WSAGetLastError());
   end;
end;

procedure TformMain.StopN1mmUdpServer();
begin
   if FUdpServer <> 0 then begin
      CloseSocket(FUdpServer);
      FUdpServer := 0;
   end;
end;

procedure TformMain.ReadBroadcastPacket(var Message: TMessage);
var
   nResult: Integer;
   nLen: Integer;
   Buffer: array [0..MAXPACKETLEN-1] of AnsiChar;
   info_utf8: UTF8String;
   strCallsign: string;
begin
   // エラーがあったか確認
   if WSAGetSelectError(Message.lParam) <> 0 then begin
      StatusBar1.Panels[3].Text := 'WSAGetSelectError() errorcode=' + IntToStr(WSAGetLastError());
      Exit;
   end;

   // 受信バッファクリア
   ZeroMemory(@Buffer, SizeOf(Buffer));

   // UDPから受信
   nLen := SizeOf(TSockAddrIn);
   nResult := RecvFrom(FUdpServer, Buffer, MAXPACKETLEN, 0, FClientAddr, nLen);
   if nResult = SOCKET_ERROR then begin
      StatusBar1.Panels[3].Text := 'RecvFrom() errorcode=' + IntToStr(WSAGetLastError());
      Exit;
   end;

   // 受信データの処理
   Buffer[nResult] := #0;

   // XMLをパースする
   info_utf8 := UTF8String(Buffer);

   // contactinfo
   //<?xml version="1.0" encoding="utf-8"?>
   //<contactinfo>
   //    <app>N1MM</app>
   //    <contestname>CWOPS</contestname>
   //    <contestnr>73</contestnr>
   //    <timestamp>2020-01-17 16 :43:38</timestamp>
   //    <mycall>W2XYZ</mycall>
   //    <band>3.5</band>
   //    <rxfreq>352519</rxfreq>
   //    <txfreq>352519</txfreq>
   //    <operator></operator>
   //    <mode>CW</mode>
   //    <call>WlAW</call>
   //    <countryprefix>K</countryprefix>
   //    <wpxprefix>Wl</wpxprefix>
   //    <stationprefix>W2XYZ</stationprefix>
   //    <continent>NA</continent>
   //    <snt>599</snt>
   //    <sntnr>5</sntnr>
   //    <rcv>599</rcv>
   //    <rcvnr>0</rcvnr>
   //    <gridsquare></gridsquare>
   //    <exchangel></exchangel>
   //    <section></section>
   //    <comment></comment>
   //    <qth></qth>
   //    <name></name>
   //    <power></power>
   //    <misctext></misctext>
   //    <zone>0</zone>
   //    <prec></prec>
   //    <ck>0</ck>
   //    <ismultiplierl>l</ismultiplierl>
   //    <ismultiplier2>0</ismultiplier2>
   //    <ismultiplier3>0</ismultiplier3>
   //    <points>l</points>
   //    <radionr>l</radionr>
   //    <run1run2>1<run1run2>
   //    <RoverLocation></RoverLocation>
   //    <RadioInterfaced>l</RadioInterfaced>
   //    <NetworkedCompNr>0</NetworkedCompNr>
   //    <IsOriginal>False</IsOriginal>
   //    <NetBiosName></NetBiosName>
   //    <IsRunQSO>0</IsRunQSO>
   //    <StationName>CONTEST-PC</StationName>
   //    <ID>f9ff ac4f cd3e 479c a86e 137d f133 8531</ID>
   //    <IsClaimedQso>1</IsClaimedQso>
   //</contactinfo>
   if Pos('<lookupinfo>', info_utf8) = 0 then begin
      Exit;
   end;

   // コールサイン取得
   strCallsign := GetXmlValue(info_utf8, 'call');
   if strCallsign = '' then begin
      Exit;
   end;

   // Query実行
   editCallsign.Text := strCallsign;
   buttonQueryClick(nil);
end;

//
// XML風なので簡易にデータを取得する。
//
// 00000000011111111
// 12345678901234567
// <call>WlAW</call>
//
// in= 1 + 6 = 7
// out = 11 - 7 = 4
//
function TformMain.GetXmlValue(xml: string; tag: string): string;
var
   tag_in: string;
   tag_out: string;
   Index_in: Integer;
   Index_out: Integer;
begin
   tag_in := '<' + tag + '>';
   tag_out := '</' + tag + '>';

   Index_in := Pos(tag_in, xml) + Length(tag_in);

   Index_out := Pos(tag_out, xml);

   Result := Copy(xml, Index_in, Index_out - Index_in);
end;

procedure TformMain.BuildCustomList();
var
   i: Integer;
   slLine: TStringList;
   listitem: TListItem;
   obj: TStationInfo;
begin
   slLine := TStringList.Create();
   slLine.StrictDelimiter := True;
   try
      FCustomList.Clear();

      for i := 0 to FCustomListFile.Count - 1 do begin
         slLine.CommaText := FCustomListFile[i];

         obj := TStationInfo.Create();
         obj.Callsign := slLine[0];
         obj.Country := slLine[1];
         obj.Continent := slLine[2];
         obj.CQZone := slLine[3];
         obj.ITUZone := slLine[4];
         obj.State := slLine[5];
         obj.Comment := slLine[6];

         FCustomList.Add(obj);
      end;

      FCustomList.Sort();
   finally
      slLine.Free();
   end;
end;

// ----------------------------------------------------------------------------

// JA1–JS1, 7J1, 8J1–8N1, 7K1–7N4
// JA2–JS2, 7J2, 8J2–8N2
// JA3–JS3, 7J3, 8J3–8N3
// JA4–JS4, 7J4, 8J4–8N4
// JA5–JS5, 7J5, 8J5–8N5
// JA6–JS6, 7J6, 8J6–8N6
// JA7–JS7, 7J7, 8J7–8N7
// JA8–JS8, 7J8, 8J8–8N8
// JA9–JS9, 7J9, 8J9–8N9
// JA0–JS0, 7J0, 8J0–8N0
function IsDomestic(strCallsign: string): Boolean;
var
   S1: Char;
   S2: Char;
   S3: Char;
begin
   if strCallsign = '' then begin
      Result := True;
      Exit;
   end;

   S1 := strCallsign[1];
   S2 := strCallsign[2];
   S3 := strCallsign[3];

   if S1 = 'J' then begin
      if (S2 >= 'A') and (S2 <= 'S') then begin
         Result := True;
         Exit;
      end;
   end;

   if (S1 = '7') and (S2 = 'J') then begin
      Result := True;
      Exit;
   end;

   if S1 = '7' then begin
      if (S2 >= 'K') and (S2 <= 'N') then begin
         if (S3 >= '1') and (S3 <= '4') then begin
            Result := True;
            Exit;
         end;
      end;
   end;

   if S1 = '8' then begin
      if (S2 >= 'J') and (S2 <= 'N') then begin
         Result := True;
         Exit;
      end;
   end;

   Result := False;
end;

// ----------------------------------------------------------------------------

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
