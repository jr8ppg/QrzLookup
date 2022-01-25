unit Check;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TformCheck = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private éŒ¾ }
  public
    { Public éŒ¾ }
  end;

implementation

{$R *.dfm}

uses
  Main;

procedure TformCheck.Button1Click(Sender: TObject);
begin
   Button1.Enabled := False;
   try
      Form1.GoLookup();
   finally
      Button1.Enabled := True;
   end;
end;

end.
