program DeProjet;

uses
  Forms,
  DeUnit in 'DeUnit.pas',
  DeMain in 'DeMain.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
