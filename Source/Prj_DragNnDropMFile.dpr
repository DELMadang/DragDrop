program Prj_DragNnDropMFile;

uses
  Vcl.Forms,
  DragNnDropMultiFile in 'DragNnDropMultiFile.pas' {frmDragNnDropMultiFile},
  DataSample in 'DataSample.pas' {dmDataSample: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmDragNnDropMultiFile, frmDragNnDropMultiFile);
  Application.CreateForm(TdmDataSample, dmDataSample);
  Application.Run;
end.
