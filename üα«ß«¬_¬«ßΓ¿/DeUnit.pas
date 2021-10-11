unit DeUnit;
                                                                                {
                 DiceEngine   PAR DEBIARS
                              juillet 2007
                         inspiré par CubeEngone de CARIBENSILA
                                                                                }
interface

uses
  Windows, ExtCtrls, Controls, Classes, jpeg, SysUtils, Graphics, Forms,
  StdCtrls, math, Dialogs;

type
  TVal = record                        // paramètres pour un dé
           d1 : byte;   // face 1  dessus
           d2 : byte;   // face 2  côté
           nr : byte;   // nbre de rotations
           ss : byte;   // sens de rotation
         end;
  TDice = class(TImage)
    private
      fTbDes  : array[1..6] of TBitmap;  // images des faces
      fFace   : Integer;         // face visible
      fTaille : Integer;         // dimension du dé
      fTempo  : Integer;         // temporisation
      fIncan  : integer;         // incrément pour l'angle
      procedure SetTaille(Valeur : Integer);
      procedure SetTempo(Valeur : Integer);
      procedure SetIncan(Valeur : Integer);
      procedure DiceDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
      procedure DiceDragDrop(Sender, Source: TObject; X, Y: Integer);
      procedure DiceMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    public
      fPiste  : TRect;
      fParam  : TVal;
      constructor Create(AOwner:TComponent); override;
      destructor  Destroy; override;
      procedure ChargerGraphic(Index: Integer; UneImage: TGraphic);
      procedure AfficheUneFace(Index : integer);
      procedure LancerLeDe(nbr,sens : byte);
      procedure Rotation;
      function  GetFace : integer;
      property  Taille  : Integer read fTaille write SetTaille;
      property  Tempo : Integer read fTempo write SetTempo;
      property  Incan : Integer read fIncan write SetIncan;
      property  Face : integer read GetFace;
  end;

implementation

uses DeMain;

var
  MousePoint: TPoint; // Pour le drag'n drop.

constructor TDice.Create(AOwner:TComponent);
begin
  inherited;
  fTaille      := 0;    // Valeur par défaut.
  fFace        := Random(6)+1;    //         "
  self.AutoSize    := true;
  self.OnMouseDown := DiceMouseDown;
//  self.OnDragOver  := DiceDragOver;   // activer pour utiliser DragOver
//  self.OnDragDrop  := DiceDragDrop;   // activer pour utiliser DragDrop
end;

destructor TDice.Destroy;
var
  i : integer;
begin
  for i := 1 to 6 do FreeAndNil(fTbDes[i]);
  Inherited;
end;

procedure TDice.SetTaille(Valeur : Integer);
begin
  fTaille := Valeur;
end;

procedure TDice.SetTempo(Valeur : Integer);
begin
  fTempo := Valeur;
end;

procedure TDice.SetIncan(Valeur : Integer);
begin
  fIncan := Valeur;
end;

function TDice.GetFace : integer;
begin
  Result := fFace;
end;

procedure TDice.ChargerGraphic(Index: Integer; UneImage: TGraphic);
  begin
  if fTaille = 0 then exit; // La taille du cube doit être initialisée avant de charger les images.
  if Index in[1..6] then
  begin
    fTbDes[Index] := TBitmap.Create;
    fTbDes[Index].PixelFormat := pf24bit;
    fTbDes[Index].Height      := fTaille;
    fTbDes[Index].Width       := fTaille;
    fTbDes[Index].Canvas.StretchDraw(fTbDes[Index].Canvas.ClipRect,UneImage);
  end;
  if assigned(fTbDes[6]) then Picture.Assign(fTbDes[fFace]);
end;

// Pour afficher une face avec mise à jour de fFace (private)
procedure TDice.AfficheUneFace(Index : integer);
  begin
    Picture.Assign(fTbDes[Index]);
    fFace := Index;
  end;

procedure TDice.DiceDragOver(Sender, Source: TObject; X, Y: Integer;
          State: TDragState; var Accept: Boolean);
var
  tempPoint : TPoint;
begin
  getcursorpos(tempPoint);
  with (Source as TControl) do begin
    Top :=Round((Parent as TControl).screentoclient(tempPoint).Y)-MousePoint.Y;
    Left:=Round((Parent as TControl).screentoclient(tempPoint).X)-MousePoint.X;
  end;
end;

procedure TDice.DiceDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
  with (Source as TControl) do
  begin
    // déclenche un évènement dans UnitMain
    MainForm.EdEvent.Text := IntToStr(Tag);
  end;
end;

procedure TDice.DiceMouseDown(Sender: TObject; Button: TMouseButton;
          Shift: TShiftState; X, Y: Integer);
begin
  // déclenche un évènement dans UnitMain et transmet le n° du dé
  MainForm.EdEvent.Text := IntToStr(Tag);
{   Pour l'utilisation de DragOver et Drop
  Self.BringToFront;
  BeginDrag(false,3); // Le Drag commence après un mouvement de 3 pixels.
  MousePoint.X := X;
  MousePoint.Y := Y;
}
end;

procedure TDice.LancerLeDe(nbr,sens : byte);
begin
  with FParam do
  begin
    d1 := fFace;
    AfficheUneFace(d1);
    d2 := d1;
    while (d2 = d1) or (d2 = 7-d1) do d2 := Random(6)+1;
    nr := nbr;
    ss := sens;
  end;
  while FParam.nr > 0 do Rotation;
  MainForm.EdEvent.Text := IntToStr(fFace);
end;

procedure TDice.Rotation;
var
  bmp : TBitmap;
  rec1,rec2 : TRect;
  d3 : byte;
  Hypo  : integer;        // dimension du dé = Hypoténuse pour calcul
  Angle,
  PRot,                  // point de rotation
  Coop,                  // côté opposé à l'angle
  Cadj  : integer;       // côté adjacent à l'angle

    procedure Calcul;
    begin
      Coop := Abs(Round(Hypo * sin(DegToRad(Angle))));
      Cadj := Abs(Round(Hypo * cos(DegToRad(Angle))));
    end;

    procedure Afficher;
    begin
      self.Picture.Bitmap.Assign(bmp);
      (self.Owner as TForm).Refresh;
      Sleep(fTempo);
    end;

begin
  bmp := TBitmap.Create;
  Angle := fIncan;
  Hypo := fTaille;
  with fParam do
  begin
    case ss of
      0 : begin                  // à droite
            bmp.Height := Hypo;
            PRot := Left + Hypo;
            repeat
              Calcul;
              rec1 := Rect(Coop,0,Coop+Cadj,Hypo);
              rec2 := Rect(0,0,Coop,Hypo);
              bmp.Width := Coop + Cadj;
              bmp.Canvas.StretchDraw(rec2,fTbdes[d2]);
              bmp.Canvas.StretchDraw(rec1,fTbdes[d1]);
              Width := bmp.Width;
              Left := PRot - Cadj;
              Afficher;
              Angle := Angle + fIncan;
              if Left + bmp.Width >= fPiste.Right then
              begin
                ss := 1;     // changement de direction
                break;
              end;
            until Angle > 90;
            fFace := d2;
            d3 := 7-d1;      // face opposée
            d1 := d2;
            d2 := d3;
            dec(nr);
          end;
      1 : begin                  // à gauche
            bmp.Height := Hypo;
            PRot := Left;
            repeat
              Calcul;
              rec2 := Rect(Cadj,0,Coop+Cadj,Hypo);
              rec1 := Rect(0,0,Cadj,Hypo);
              bmp.Width := Coop + Cadj;
              bmp.Canvas.StretchDraw(rec2,fTbdes[d2]);
              bmp.Canvas.StretchDraw(rec1,fTbdes[d1]);
              Width := bmp.Width;
              Left := PRot - Coop;
              Afficher;
              Angle := Angle + fIncan;
              if Left <= fPiste.Left then
              begin
                ss := 0;     // changement de direction
                break;
              end;
            until Angle > 90;
            fFace := d2;
            d3 := 7-d1;      // face opposée
            d1 := d2;
            d2 := d3;
            dec(nr);
          end;
      2 : begin                   // en bas
            bmp.Width := Hypo;
            PRot := Top + Hypo;
            repeat
              Calcul;
              rec1 := Rect(0,Coop,Hypo,Coop+Cadj);
              rec2 := Rect(0,0,Hypo,Coop);
              bmp.Height := Coop + Cadj;
              bmp.Canvas.StretchDraw(rec2,fTbdes[d2]);
              bmp.Canvas.StretchDraw(rec1,fTbdes[d1]);
              Height := bmp.Height;
              Top := PRot - Cadj;
              Afficher;
              Angle := Angle + fIncan;
              if Top + bmp.Height >= fPiste.Top then
              begin
                ss := 3;     // changement de direction
                break;
              end;
            until Angle > 90;
            fFace := d2;
            d3 := 7-d1;      // face opposée
            d1 := d2;
            d2 := d3;
            dec(nr);
          end;
      3 : begin
            bmp.Width := Hypo;
            PRot := Top;
            repeat
              Calcul;
              rec2 := Rect(0,Cadj,Hypo,Coop+Cadj);
              rec1 := Rect(0,0,Hypo,Cadj);
              bmp.Height := Coop + Cadj;
              bmp.Canvas.StretchDraw(rec2,fTbdes[d2]);
              bmp.Canvas.StretchDraw(rec1,fTbdes[d1]);
              Height := bmp.Height;
              Top := PRot - Coop;
              Afficher;
              Angle := Angle + fIncan;
              if Top <= fPiste.Bottom then
              begin
                ss := 2;     // changement de direction
                break;
              end;
            until Angle > 90;
            fFace := d2;
            d3 := 7-d1;      // face opposée
            d1 := d2;
            d2 := d3;
            dec(nr);
          end;
    end;
    if (Angle < 90) and (nr = 0) then
    begin
      Width := fTaille;
      case ss of
        0 : Left := fPiste.Left + 5;
        1 : Left := fPiste.Right - FTaille - 5;
        2 : Top := fPiste.Top + 5;
        3 : Top := fPiste.Bottom - FTaille - 5;
      end;
      AfficheUneFace(d2);
    end;
    bmp.Free;
  end;
end;

end.

