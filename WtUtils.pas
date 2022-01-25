unit WtUtils;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Forms;

type
  TBitmapArray = array of TBitmap;

  TWtUtils = class(TObject)
  private
    FWtCharactors: TBitmap;
    FWtCapture: TBitmap;
    FWtTemp: TBitmap;
    FCharBmp: TBitmapArray;
    FCharMap: string;
    FWndWt: HWND;
    FWtLastLine: Boolean;
    procedure AdjustImage(bmp: TBitmap);
    function DecodeBitmap(bmparray: TBitmapArray): string;
    procedure FreeBitmapArray(bmparray: TBitmapArray);
    function SplitBitmap(srcbitmap: TBitmap): TBitmapArray;
    function findchar(bmp: TBitmap): Char;
    function bmpcmp(bmp1, bmp2: TBitmap): Boolean;
  public
    constructor Create();
    destructor Destroy(); override;
    function GetCallsign(): string;
    function IsWtPresent(): Boolean;
    procedure Init();
  end;

implementation

constructor TWtUtils.Create();
var
   i: Integer;
   {$IFDEF DEBUG}
   fname: string;
   {$ENDIF}
begin
   FWtLastLine := False;
   FWtCharactors := TBitmap.Create();
   FWtCharactors.PixelFormat := pf24bit;
   FWtCharactors.LoadFromResourceName(SysInit.HInstance, 'IDB_WTCHARS');
   AdjustImage(FWtCharactors);

   FWtCapture := TBitmap.Create();
   FWtCapture.PixelFormat := pf24bit;
   FWtTemp := TBitmap.Create();
   FWtTemp.PixelFormat := pf24bit;

   FCharBmp := SplitBitmap(FWtCharactors);
   FCharMap := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/? ';

   {$IFDEF DEBUG}
   for i := Low(FCharBmp) to High(FCharBmp) do begin
      if FCharMap[i] = '/' then begin
         fname := 'slash';
      end
      else if FCharMap[i] = '?' then begin
         fname := 'hatena';
      end
      else begin
         fname := FCharMap[i + 1];
      end;
      FCharBmp[i].SaveToFile(fname + '.bmp');
   end;
   {$ENDIF}
end;

destructor TWtUtils.Destroy();
begin
   FreeBitmapArray(FCharBmp);
   FWtCharactors.Free();
   FWtCapture.Free();
   FWtTemp.Free();
end;

procedure TWtUtils.Init();
begin
   FWtLastLine := False;   // last line not found
end;

procedure TWtUtils.AdjustImage(bmp: TBitmap);
var
   x, y: Integer;
   p: PByteArray;
   r, g, b: BYTE;
begin
   for y := 0 to bmp.Height - 1 do begin
      p := bmp.ScanLine[y];
      for x := 0 to bmp.Width - 1 do begin
         b := p[x * 3 + 0];
         g := p[x * 3 + 1];
         r := p[x * 3 + 2];

         if b < 40 then b := 0;
         if g < 40 then g := 0;
         if r < 40 then r := 0;

         if (b <> 0) or (g <> 0) or (r <> 0) then begin
            b := 255;
            g := 255;
            r := 255;
         end;

         p[x * 3 + 0] := b;
         p[x * 3 + 1] := g;
         p[x * 3 + 2] := r;
      end;
   end;
end;

function TWtUtils.IsWtPresent(): Boolean;
var
   wnd: HWND;
begin
   wnd := FindWindow('AfxFrameOrView80s', nil);
   if wnd = 0 then begin
      Result := False;
   end
   else begin
      Result := True;
   end;
end;

function TWtUtils.GetCallsign(): string;
var
   winrect: TRect;
   srcrect: TRect;
   dstrect: TRect;
   C: TCanvas;
   callbmp: TBitmapArray;
   qsonobmp: TBitmapArray;
   strCallsign: string;
   strQsoNo: string;
   y: Integer;
   hWtDC: HDC;
   {$IFDEF DEBUG}
   i: Integer;
   {$ENDIF}
begin
   hWtDC := 0;
   FWndWt := FindWindow('AfxFrameOrView80s', nil);
   if FWndWt = 0 then begin
//      MessageBox(Self.Handle, 'WTが見つかりません', 'WtTest', MB_OK or MB_ICONEXCLAMATION);
      Result := '';
      Exit;
   end;

   // Wtのウインドウサイズ取得
   WinApi.Windows.GetClientRect(FWndWt, winrect);

   // Wtのウインドウをキャプチャ
   C := TCanvas.Create();
   try
      hWtDC := GetDC(FWndWt);
      C.Handle := hWtDC;

      if FWtLastLine = False then begin
         // コールサインエリアの座標
         srcrect.Top := winrect.Height - 192;
         srcrect.Left := 0;                    // 30 156
         srcrect.Bottom := srcrect.Top + 146;
         srcrect.Right := srcrect.Left + 269;   // 36 117

         // コールサインエリアをキャプチャ
         dstrect.Top := 0;
         dstrect.Left := 0;
         dstrect.Bottom := dstrect.Top + 146;
         dstrect.Right := 269;

         FWtCapture.Height := 146;
         FWtCapture.Width := 269;
         FWtCapture.Canvas.CopyMode := cmSrcCopy;
         FWtCapture.Canvas.CopyRect(dstrect, C, srcrect);
      end
      else begin
         // コールサインエリアの座標
         srcrect.Left := 0;                    // 30 156
         srcrect.Bottom := (winrect.Height - 192) + 150;
         srcrect.Top := srcrect.Bottom - 15;
         srcrect.Right := srcrect.Left + 269;   // 36 117

         // コールサインエリアをキャプチャ
         dstrect.Top := 0;
         dstrect.Left := 0;
         dstrect.Bottom := dstrect.Top + 15;
         dstrect.Right := 269;

         FWtCapture.Height := 15;
         FWtCapture.Width := 269;
         FWtCapture.Canvas.CopyMode := cmSrcCopy;
         FWtCapture.Canvas.CopyRect(dstrect, C, srcrect);
      end;

      AdjustImage(FWtCapture);

      {$IFDEF DEBUG}
      FWtCapture.SaveToFile('cap.bmp');
      {$ENDIF}
   finally
      if hWtDC <> 0 then begin
         ReleaseDC(FWndWt, hWtDC);
      end;
      C.Free();
   end;

   if FWtLastLine = False then begin
      // 下からQSO#を調べて番号のある行を現在コール入力欄とする
      for y := 9 downto 0 do begin
         // QSO#エリアを切り出し
         srcrect.Top := (y * 15);
         srcrect.Left := 19;
         srcrect.Bottom := srcrect.Top + 11;
         srcrect.Right := srcrect.Left + 36;

         dstrect.Top := 0;
         dstrect.Left := 0;
         dstrect.Bottom := dstrect.Top + 11;
         dstrect.Right := 36;

         FWtTemp.Height := 11;
         FWtTemp.Width := 36;
         FWtTemp.Canvas.CopyMode := cmSrcCopy;
         FWtTemp.Canvas.CopyRect(dstrect, FWtCapture.Canvas, srcrect);

         {$IFDEF DEBUG}
         FWtTemp.SaveToFile('fwtqsono_' + IntToStr(y) + '.bmp');
         {$ENDIF}

         qsonobmp := SplitBitmap(FWtTemp);
         {$IFDEF DEBUG}
         for i := Low(qsonobmp) to High(qsonobmp) do begin
            qsonobmp[i].SaveToFile('qso#-' + IntToStr(i) + '.bmp');
         end;
         {$ENDIF}
         try
            strQsoNo := DecodeBitmap(qsonobmp);
            if strQsoNo = '' then begin
               Continue;
            end;

            {$IFDEF DEBUG}
            OutputDebugString(PChar('QSO#=' + strQsoNo));
            {$ENDIF}

            Break;
         finally
            FreeBitmapArray(qsonobmp);
         end;
      end;

      // コールサインエリアの切り出し
      srcrect.Top := (y * 15);
      srcrect.Left := 154;
      srcrect.Bottom := srcrect.Top + 11;
      srcrect.Right := srcrect.Left + 117;

      if y = 9 then begin
         FWtLastLine := True;
      end;
   end
   else begin
      // コールサインエリアの切り出し
      srcrect.Top := 0;
      srcrect.Left := 154;
      srcrect.Bottom := srcrect.Top + 11;
      srcrect.Right := srcrect.Left + 117;
   end;

   dstrect.Top := 0;
   dstrect.Left := 0;
   dstrect.Bottom := dstrect.Top + 11;
   dstrect.Right := 117;

   FWtTemp.Height := 11;
   FWtTemp.Width := 117;
   FWtTemp.Canvas.CopyMode := cmSrcCopy;
   FWtTemp.Canvas.CopyRect(dstrect, FWtCapture.Canvas, srcrect);

   {$IFDEF DEBUG}
   FWtTemp.SaveToFile('fwttemp_' + IntToStr(y) + '.bmp');
   {$ENDIF}

   // キャプチャ内容を事前に用意した画像と比較して文字を特定する
   callbmp := SplitBitmap(FWtTemp);

   {$IFDEF DEBUG}
   for i := Low(callbmp) to High(callbmp) do begin
      callbmp[i].SaveToFile('call-' + IntToStr(i) + '.bmp');
   end;
   {$ENDIF}

   try
      strCallsign := DecodeBitmap(callbmp);

      {$IFDEF DEBUG}
      OutputDebugString(PChar('CALL=' + strCallsign));
      {$ENDIF}

      Result := strCallsign;
   finally
      FreeBitmapArray(callbmp);
   end;
end;

function TWtUtils.DecodeBitmap(bmparray: TBitmapArray): string;
var
   i: Integer;
   ch: Char;
   strText: string;
begin
   strText := '';
   for i := Low(bmparray) to High(bmparray) do begin
      ch := findchar(bmparray[i]);
      if ch = Char(0) then begin
         Exit;
      end;
      strText := strText + ch;
   end;

   Result := Trim(strText);
end;

procedure TWtUtils.FreeBitmapArray(bmparray: TBitmapArray);
var
   i: Integer;
begin
   for i := Low(bmparray) to High(bmparray) do begin
      bmparray[i].Free();
   end;
end;

function TWtUtils.findchar(bmp: TBitmap): Char;
var
   i: Integer;
begin
   for i := Low(FCharBmp) to High(FCharBmp) do begin
      if bmpcmp(bmp, FCharBmp[i]) = True then begin
         Result := FCharMap[i + 1]; //Char(ord('A') + i);
         Exit;
      end;
   end;
   Result := Char(0);
end;

function TWtUtils.SplitBitmap(srcbitmap: TBitmap): TBitmapArray;
var
   i: Integer;
   x: Integer;
   src, dst: TRect;
   n: Integer;
   splitbmp: TBitmapArray;
begin
   n := srcbitmap.Width div 9;

   SetLength(splitbmp, n);

   for i := 0 to n - 1do begin
      splitbmp[i] := TBitmap.Create();
      splitbmp[i].PixelFormat := pf24bit;
      splitbmp[i].Width := 9;
      splitbmp[i].Height := 11;

      x := (i) * 9;

      src.Left := x;
      src.Right := src.Left + 9;
      src.Top := 0;
      src.Bottom := src.Top + 11;

      dst.Left := 0;
      dst.Right := 9;
      dst.Top := 0;
      dst.Bottom := 11;
      splitbmp[i].Canvas.CopyRect(dst, srcbitmap.Canvas, src);
//      splitbmp[i].SaveToFile('char-bmp-' + IntToStr(i) + '.bmp');
   end;

   Result := splitbmp;
end;

function TWtUtils.bmpcmp(bmp1, bmp2: TBitmap): Boolean;
var
   x, y: Integer;
   p1, p2: PByteArray;
   pixel_count: Integer;
   same_count: Integer;
begin
   pixel_count := 0;
   same_count := 0;
   for y := 0 to bmp1.Height - 1 do begin
      p1 := bmp1.ScanLine[y];
      p2 := bmp2.ScanLine[y];
      for x := 0 to bmp1.Width - 1 do begin
         if (p1[x * 3 + 0] = p2[x * 3 + 0]) and
            (p1[x * 3 + 1] = p2[x * 3 + 1]) and
            (p1[x * 3 + 2] = p2[x * 3 + 2]) then begin
            Inc(same_count);
         end;

         Inc(pixel_count);
      end;
   end;

   if (pixel_count - same_count) < 4 then begin
      Result := True;
   end
   else begin
      Result := False;
   end;
end;

end.
