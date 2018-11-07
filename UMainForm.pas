unit UMainForm;

interface

uses
  Classes, Forms, Controls, Dialogs, DBGrids, StdCtrls, Grids, DB, SynEdit, ADODB, SynHighlighterSQL, SynEditHighlighter, MSAccessU,
  Menus,
  ComCtrls;

type
  TMainForm = class(TForm)
    ADOConnection1: TADOConnection;
    ADOTable1: TADOTable;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    OpenDialog1: TOpenDialog;
    LBTabelas: TListBox;
    ADOQuery1: TADOQuery;
    SynEdit1: TSynEdit;
    SynSQLSyn1: TSynSQLSyn;
    MainMenu1: TMainMenu;
    Arquivo1: TMenuItem;
    Visualizar1: TMenuItem;
    Abrir1: TMenuItem;
    N1: TMenuItem;
    Sair1: TMenuItem;
    StatusBar: TStatusBar;
    abelas1: TMenuItem;
    Filtrar1: TMenuItem;
    NmerodeRegistrosnatabela1: TMenuItem;
    procedure AbrirArquivoClick(Sender: TObject);
    procedure LBTabelasClick(Sender: TObject);
    procedure SynEdit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DBGrid1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Sair1Click(Sender: TObject);
  private
    FFileName: String;
    procedure PreencheListaDeTabelas;
    function LeArquivo(const FileName: String): MSAccessU.TByteArray;
  end;

var
  MainForm: TMainForm;

implementation

uses SysUtils;

{$R *.dfm}

function TMainForm.LeArquivo(const FileName: String): MSAccessU.TByteArray;
var Arq: File;
begin
   AssignFile(Arq, FileName);
   FileMode := fmOpenRead;
   Reset(Arq, 1);
   BlockRead(Arq, Result, 85);
   CloseFile(Arq);
end;

procedure TMainForm.AbrirArquivoClick(Sender: TObject);
var Password: String;
begin
   if not OpenDialog1.Execute then Exit;

   FFileName := OpenDialog1.FileName;

   Password := XorPassword(LeArquivo(FFileName));

   ADOConnection1.Connected := False;
   ADOConnection1.ConnectionString :=
      'Provider=Microsoft.Jet.OLEDB.4.0; Data Source=' + FFileName + ';Persist Security Info=False;Jet OLEDB:Database Password="'+ Password +'"';

   ADOConnection1.Connected := True;
   PreencheListaDeTabelas;
   Caption := FFileName;
end;

procedure TMainForm.LBTabelasClick(Sender: TObject);
var SelectedTableName: String;
begin
   DataSource1.DataSet := ADOTable1;

   SelectedTableName := LBTabelas.Items[LBTabelas.ItemIndex];

   ADOTable1.Active := False;
   ADOTable1.TableName := SelectedTableName;
   ADOTable1.Active :=  True;

   Caption := FFileName + ' - ' + SelectedTableName;
end;

procedure TMainForm.PreencheListaDeTabelas;
var TableNames: TStringList;
begin
   TableNames := TStringList.Create;
   ADOConnection1.GetTableNames(TableNames);

   LBTabelas.Items := TableNames;

   TableNames.Free;

   StatusBar.Panels[0].Text := Format('%d tabelas', [LBTabelas.Count]);
end;

procedure TMainForm.SynEdit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if Key=116 then begin
      DataSource1.DataSet := ADOQuery1;
      ADOQuery1.SQL.Text := SynEdit1.Text;
      ADOQuery1.Open;
   end;
end;

procedure TMainForm.DBGrid1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if (ssCtrl in Shift) and (Key=13) then begin
      SynEdit1.SetFocus;
   end;
end;

procedure TMainForm.Sair1Click(Sender: TObject);
begin
   Application.Terminate;
end;

end.

