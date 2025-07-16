unit DragNnDropMultiFile;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  Winapi.ShellAPI,

  System.SysUtils,
  System.Variants,
  System.Classes,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Grids,
  Vcl.DBGrids,
  Vcl.Buttons,
  Vcl.Menus,
  Vcl.ComCtrls,
  Data.DB;

type
  TfrmDragNnDropMultiFile = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    btnEnd: TButton;
    btnAdd: TButton;
    btnEdit: TButton;
    btnDelete: TButton;
    BitBtn1: TBitBtn;
    Label3: TLabel;
    Panel10: TPanel;
    DBGrid1: TDBGrid;
    Panel11: TPanel;
    Panel3: TPanel;
    Panel9: TPanel;
    ComboBox1: TComboBox;
    DBGrid2: TDBGrid;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel8: TPanel;
    Label1: TLabel;
    bbtnLbxListClear: TBitBtn;
    lbxFileList: TListBox;
    Panel15: TPanel;
    Label2: TLabel;
    lbxOnlyFileList: TListBox;
    Panel7: TPanel;
    Label7: TLabel;
    Label9: TLabel;
    Label11: TLabel;
    Label4: TLabel;
    Bevel1: TBevel;
    Panel18: TPanel;
    Panel19: TPanel;
    edtDmsChkerNm: TEdit;
    edtDmsCfmerNm: TEdit;
    edtDmsMakerNm: TEdit;
    edtDocCd: TEdit;
    edtDocNm: TEdit;
    Panel6: TPanel;
    ProgressBar1: TProgressBar;
    btnBatchInsert: TButton;
    btnBatchUpdate: TButton;
    Button1: TButton;
    procedure bbtnLbxListClearClick(Sender: TObject);
    procedure btnBatchInsertClick(Sender: TObject);
    procedure BtnCRUD(Sender: TObject);
    procedure btnEndClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure DBGrid2CellClick(Column: TColumn);
    procedure FormActivate(Sender: TObject);
  private
    procedure WMDropFiles(Var Msg: TWMDropFiles); Message WM_DropFiles;
    function  GetOnlyFileName(const cFullName: String): String;
    procedure SetCRUDBtnlMode;
    procedure SetCRUDOkMode;
    procedure ExecSQL_DocEntList;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
  end;

  TSchVarB = Record
      doc_cd:   String;
      doc_nm:   String;
      file_nm:  String;
  end;

var
  frmDragNnDropMultiFile: TfrmDragNnDropMultiFile;

  rcSchB:  TSchVarB;

implementation

{$R *.dfm}

uses
  DataSample;

procedure TfrmDragNnDropMultiFile.bbtnLbxListClearClick(Sender: TObject);
begin
  if lbxFileList.Items.Count > 0 then begin
    lbxFileList.Clear;
  end;

  if lbxOnlyFileList.Items.Count > 0 then begin
    lbxOnlyFileList.Clear;
  end;

  SetCRUDBtnlMode;
end;

procedure TfrmDragNnDropMultiFile.btnBatchInsertClick(Sender: TObject);
begin
  var nIdx: Integer := lbxOnlyFileList.Items.Count;
  if nIdx < 1 then begin
    ShowMessage('등록할 파일리스트가 없습니다!!!');
    Exit;
  end;

  var cOpenDir:  String := '';
  var cSaveDir:  String := 'c:\SavDocFile';
  var I: Integer      := 0;
  var nLen: Integer   := 0;
  var cDocNm: String  := '';

  var cSouFile: String := '';
  var cTgtFile: String := '';

  if not DirectoryExists(cSaveDir)  then
  begin
    try
      CreateDir(cSaveDir);
    finally
      ShowMessage('File Save Dir : ' + cSaveDir   + Chr(13) + Chr(13) +
                  'File Server에  Directory를 생성하였습니다!!!');
    end;
  end;

  cSaveDir := 'c:\SavDocFile' + '\';

  ProgressBar1.Min := 0;
  ProgressBar1.Max := lbxOnlyFileList.Items.Count -1;

  with dmDataSample.fdmtbl_DocData do
  begin
    // UpdateOptions.RequestLive := True;
    CachedUpdates := True;

    if not Active then
    begin
      Open;
    end;

    for I := 0 to lbxOnlyFileList.Items.Count - 1 do
    begin
      rcSchB.file_nm := lbxOnlyFileList.Items[I];
      cOpenDir       := lbxFileList.Items[I];

      ProgressBar1.Position := I;
      ProgressBar1.Update;

      nLen   := Length(Trim(rcSchB.file_nm));
      cDocNm := Copy(rcSchB.file_nm, 1, nLen - 4);

      cSouFile := lbxFileList.Items[I];
      cTgtFile := cSaveDir + rcSchB.file_nm;

      try
        CopyFile(PChar(cSouFile), PChar(cTgtFile), False);
      except
        ShowMessage('Source  : ' + rcSchB.file_nm  + Chr(13) +
                    'cTgtget : ' + cTgtFile        + Chr(13) +
                    'File 서버에 파일이 저장되지 못했습니다!!!');
      end;

      Insert;

      FieldByName('_doc_cd'   ).AsString  := rcSchB.doc_cd;
      FieldByName('_doc_nm'   ).AsString  := cDocNm;  // 문서명, 확장자를 제거한 파일명으로 Assign

      FieldByName('_maker_nm' ).AsString  := edtDmsMakerNm.Text;
      FieldByName('_chker_nm' ).AsString  := edtDmsChkerNm.Text;
      FieldByName('_confmr_nm').AsString  := edtDmsCfmerNm.Text;

      FieldByName('_file_nm'  ).AsString  := rcSchB.file_nm;
    end;

    ApplyUpdates(-1);
    CommitUpdates;
  end;

  lbxOnlyFileList.Items.Clear;
  lbxFileList.Clear;

  ShowMessage(' DB-Server에 DoC 정보를 저장하였습니다...');
end;

procedure TfrmDragNnDropMultiFile.BtnCRUD(Sender: TObject);
const
  GV_I_ADD = 1;  // Record Append
  GV_I_EDT = 2;  // Current Record Edit
  GV_I_DEL = 3;  // Current Record Delete
begin
  var nMode: Integer := (Sender as TButton).Tag;

  case nMode of
    GV_I_ADD: ShowMessage('Doc 자료를 신규로 등록합니다...');
    GV_I_EDT: ShowMessage('Doc 자료를 수정합니다...');
    GV_I_DEL: ShowMessage('Doc 자료를 삭제합니다...');
  end;
end;

procedure TfrmDragNnDropMultiFile.btnEndClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfrmDragNnDropMultiFile.Button1Click(Sender: TObject);
begin
  var cFileName: String := '';
  var cViewFile: String := '';
  var cSaveDir:  String := 'c:\SavDocFile';

  with dmDataSample.fdmtbl_DocData do begin
    if RecNo = 0  then begin
      ShowMessage('먼저 DMS자료를 선택하십시오!!!');
      Exit;
    end;

    cFileName := FieldByName('_file_nm').AsString;
    cViewFile := cSaveDir + '\' + cFileName;
  end;


  if not FileExists(cViewFile) then begin
    ShowMessage('DOC 문서 파일이 없습니다!!!');
    Exit;
  end;

  try
    ShellExecute(Application.Handle, 'Open', PChar(cViewFile), nil, nil, SW_SHOWNORMAL);
  except
    ShowMessage('DOC 문서 파일이 정상적으로 열리지 않았습니다.!!');
  end;
end;

procedure TfrmDragNnDropMultiFile.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.EXStyle or WS_EX_ACCEPTFILES;
end;

procedure TfrmDragNnDropMultiFile.DBGrid2CellClick(Column: TColumn);
begin
  with dmDataSample.fdmtbl_Code do begin

    rcSchB.doc_cd   := FieldByName('_doc_cd').AsString;
    rcSchB.doc_nm   := FieldByName('_doc_nm').AsString;

    edtDocCd.Text   := rcSchB.doc_cd;
    edtDocNm.Text   := rcSchB.doc_nm;
  end;

  // 해당되는 Doc Child Tbl 설정.
  ExecSQL_DocEntList;
end;

procedure TfrmDragNnDropMultiFile.ExecSQL_DocEntList;
begin
  {//
  with dmDataSample.fdQry_DocEnt do begin
    DisableControls;
    if Active then begin
      Close;
    end;

    SQL.Clear;
    SQL.Text := '''
        SELECT
          *
        FROM
          tbl_dmc_ent
        WHERE
          ( doc_cd = :doc_cd ) and
          ( doc_cls_cd = :doc_cls_cd );
      ''';

    Params[0].AsString := rcSchB.doc_cd;
    Params[1].AsString := rcSchB.doc_cls_cd;

    Open;

    btnBatchUpdate.Enabled := False;
    if RecordCount > 0 then begin
      btnBatchUpdate.Enabled := True;
    end;

    EnableControls;
  end;
  //}

  with dmDataSample.fdmtbl_DocData do begin
    DisableControls;

    if not Active then begin
      Open;
    end;

    IndexFieldNames := '_doc_cd';
    SetRange([rcSchB.doc_cd], [rcSchB.doc_cd]);

    EnableControls;
  end;
end;

procedure TfrmDragNnDropMultiFile.FormActivate(Sender: TObject);
begin
  with dmDataSample do begin
    if not fdmtbl_Code.Active then begin
      fdmtbl_Code.Open;
    end;

    if fdmtbl_DocData.Active then begin
      fdmtbl_DocData.Open;
    end;
  end;
end;

function TfrmDragNnDropMultiFile.GetOnlyFileName(const cFullName: String): String;
begin
  var nLen: Integer;
  var nPos: Integer;
  var cItm: String := cFullName;;

  Result := '';

  // 서브폴더의 최대크기를 20으로 충분히 설정
  for var I := 1 to 20 do begin
    nLen := Length(cItm);
    nPos := Pos('\', cItm);

    // 서브폴더 구분자('\')가 더이상 없으면 Exit.
    if nPos > 0 then begin
      cItm := Copy(cItm, nPos + 1, nLen - 1);
      Result := cItm;
    end else begin
      Exit;
    end;
  end;
end;

procedure TfrmDragNnDropMultiFile.SetCRUDBtnlMode;
var
  cTag: String;
  nLen, nPos: Integer;
begin
  bbtnLbxListClear.Enabled := False;
  btnBatchInsert.Enabled   := False;

  if lbxFileList.Items.Count > 0 then begin
    bbtnLbxListClear.Enabled := True;
  end;

  if (lbxOnlyFileList.Items.Count > 0) then begin

    // 일괄등록이 가능한 조건인지를 Check.
    SetCRUDOkMode;

    lbxOnlyFileList.ItemIndex := 0;
    cTag := lbxOnlyFileList.Items[lbxOnlyFileList.ItemIndex];
    nLen := Length(cTag);
    // nPos := Pos('.', cTag);
    // cTag := Copy(cTag, nPos + 1, 3);

    if nLen > 4 then begin
      cTag := Copy(cTag, nLen - 2, 3);
      cTag := UpperCase(cTag);
      if cTag = 'DWG' then begin
        // cbxDmsType.ItemIndex := 0;
      end else if cTag = 'PDF' then begin
        // cbxDmsType.ItemIndex := 1;
      end else if (cTag = 'JPG') or (cTag = 'PNG') then begin
        // cbxDmsType.ItemIndex := 2;
      end else if (cTag = 'MP4') or (cTag = 'MKV') or (cTag = 'AVI') then begin
        // cbxDmsType.ItemIndex := 3;
      end else begin
        // cbxDmsType.ItemIndex := 4;
      end;
    end;
  end;
end;

procedure TfrmDragNnDropMultiFile.SetCRUDOkMode;
begin
  var IsOk: Boolean := True;
  btnBatchInsert.Enabled  := IsOk;

  if (lbxOnlyFileList.Items.Count < 1) then
  begin
    IsOk := False;
  end;

  btnBatchInsert.Enabled := IsOk;
  ProgressBar1.Visible   := IsOk;
end;

procedure TfrmDragNnDropMultiFile.WMDropFiles(var Msg: TWMDropFiles);
var
  FileName: Array[0..MAX_PATH] of Char;
  i, Count: integer;
  cItem, cFile: String;
begin
  // 2025.06.09.
  // lbxFileList.Items.clear;
  // lbxOnlyFileList.Items.clear;

  Count := DragQueryFile(Msg.Drop, DWord(-1), FileName, SizeOf(FileName));
  for i := 0 to count - 1 do
  begin
    DragQueryFile(Msg.Drop, i, FileName, SizeOf(FileName));
    lbxFileList.items.add(String(FileName));

    cItem := lbxFileList.Items[I];
  end;
  DragFinish(Msg.Drop);


  // 2025.06.13.
  // 순수한 파일명만 계산한다
  Count := lbxFileList.Items.Count;
  cItem := '';
  lbxOnlyFileList.Items.Clear;
  for I := 0 to Count - 1 do begin
    cItem := lbxFileList.Items[I];
    cFile := GetOnlyFileName(cItem);
    lbxOnlyFileList.Items.Add(cFile);
  end;

  SetCRUDBtnlMode;
end;

end.
