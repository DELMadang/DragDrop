unit DataSample;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.StorageBin, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TdmDataSample = class(TDataModule)
    fdmtbl_Code: TFDMemTable;
    ds_Code: TDataSource;
    fdmtbl_DocData: TFDMemTable;
    ds_DocData: TDataSource;
    fdmtbl_Code_doc_cd: TStringField;
    fdmtbl_Code_doc_nm: TStringField;
    fdmtbl_DocData_doc_cd: TStringField;
    fdmtbl_DocData_doc_nm: TStringField;
    fdmtbl_DocData_make_nm: TStringField;
    fdmtbl_DocData_chker_nm: TStringField;
    fdmtbl_DocData_confmr_nm: TStringField;
    fdmtbl_DocData_file_nm: TStringField;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dmDataSample: TdmDataSample;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

end.
