program FieldLogger;

uses
  System.StartUpCopy,
  FMX.Forms,
  formMain in 'forms\formMain.pas' {frmMain},
  fieldlogger.databaseutil in 'units\fieldlogger.databaseutil.pas',
  fieldlogger.authentication in 'units\fieldlogger.authentication.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.