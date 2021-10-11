unit DeMain;

interface

uses
  Windows, SysUtils, Classes, ExtCtrls, ComCtrls, Forms, Controls, StdCtrls,
  Graphics, Dialogs, DeUnit, ImgList;

type
  TMainForm = class(TForm)
    BCreer: TButton;
    Lancer: TButton;
    Pano: TPanel;
    BQuitter: TButton;
    EdEvent: TEdit;
    PInfo: TPanel;
    Listima: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BCreerClick(Sender: TObject);
    procedure LancerClick(Sender: TObject);
    procedure BQuitterClick(Sender: TObject);
    procedure EdEventChange(Sender: TObject);
  private
    { D�clarations priv�es }
  public
    { D�clarations publiques }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

var
  UnDe : TDice;
  Dima : TBitmap;
  Prec : TRect;

procedure Trace(n : integer);
begin
  SHowMessage(IntToStr(n));
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  DoubleBuffered := true;
  Randomize;
  Dima := TBitmap.Create;
  Dima.Width := 40;
  Dima.Height := 40;
  Prec := Pano.ClientRect;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  UnDe.Free;
  Dima.Free;
end;

procedure TMainForm.BCreerClick(Sender: TObject);
var
  Index : Integer;
begin
  UnDe := TDice.Create(self);
  UnDe.Parent := Pano;
  UnDe.Tempo  := 5;
  UnDe.Incan  := 5;
  UnDe.Top    := 30;
  UnDe.Left   := 20;
  UnDe.Taille := 40;
  UnDe.fPiste := Prec;
  UnDe.Tag    := 0;      // si plusieurs d�s, Tag re�oit le num�ro du d�
  for Index := 1 to 6 do
  begin
    Listima.GetBitmap(Index,Dima);
    UnDe.ChargerGraphic(Index,Dima);
  end;
  BCreer.Enabled := false;
end;

procedure TMainForm.LancerClick(Sender: TObject);
var  nbr : byte;     // nbre de rotations
begin
  if UnDe = nil then exit;
  nbr := Random(10)+10;  // nbre de rotation
  with UnDe.fParam do         // mise � joure des param�tres de lancer
  begin
    d1 := UnDe.GetFace;       // face visible
    d2 := d1;
    while (d2 = d1) or (d2 = 7-d1) do d2 := Random(6)+1;  // 2�me face
      // la 2�me face doit �tre diff�rente de la 1�re et de son oppos�e,
      // la somme de 2 faces oppos�e �tant �gales � 7.
    end;
  UnDe.LancerLeDe(nbr,0);
end;

procedure TMainForm.BQuitterClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.EdEventChange(Sender: TObject);
begin
  if EdEvent.Text = '0'
  then PInfo.Caption := ''
  else PInfo.Caption := '��������� �����: '+ EdEvent.Text;
end;

end.






