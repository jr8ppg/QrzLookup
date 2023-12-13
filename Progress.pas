unit Progress;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TformProgress = class(TForm)
    labelProgress: TLabel;
    labelTitle: TLabel;
    ProgressBar1: TProgressBar;
    buttonAbort: TButton;
    procedure buttonAbortClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private êÈåæ }
    FAbort: Boolean;
    procedure SetTitle(v: string);
    function GetTitle(): string;
    procedure SetText(v: string);
    function GetText(): string;
  public
    { Public êÈåæ }
    property Title: string read GetTitle write SetTitle;
    property Text: string read GetText write SetText;
    property Abort: Boolean read FAbort;
    procedure SetProgressData(cur, max: Integer);
  end;

implementation

{$R *.dfm}

procedure TformProgress.FormCreate(Sender: TObject);
begin
   FAbort := False;
end;

procedure TformProgress.SetTitle(v: string);
begin
   labelTitle.Caption := v;
end;

function TformProgress.GetTitle(): string;
begin
   Result := labelTitle.Caption;
end;

procedure TformProgress.SetText(v: string);
begin
   labelProgress.Caption := v;
end;

procedure TformProgress.buttonAbortClick(Sender: TObject);
begin
   FAbort := True;
end;

function TformProgress.GetText(): string;
begin
   Result := labelProgress.Caption;
end;

procedure TformProgress.SetProgressData(cur, max: Integer);
begin
   ProgressBar1.Position := cur;
   ProgressBar1.Max := max;
end;

end.
