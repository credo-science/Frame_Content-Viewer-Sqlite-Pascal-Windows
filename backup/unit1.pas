unit Unit1;

{$MODE Delphi}

interface

uses
  LCLType, LCLIntf, Classes, SysUtils, DB, sqldb, sqlite3conn, FileUtil,
  TAGraph, TASeries, Forms, Controls, Graphics, Dialogs, Buttons, DBGrids,
  DBCtrls, StdCtrls, ExtCtrls, Menus, ComCtrls, TADrawUtils, TACustomSeries,
  SynHighlighterSQL, SynEdit;

type
  PRGB32Array = ^TRGB32Array;
  TRGB32Array = packed array[0..MaxInt div SizeOf(TRGBQuad) - 1] of TRGBQuad;

type

  TRGB = packed record
    b, g, r: byte;
  end;
  TRGBarray = array[0..0] of TRGB;
  pRGBarray = ^TRGBarray;

type

  { TForm1 }
  THackDBGrid = class(TDBGrid);

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Chart1: TChart;
    bar1: TBarSeries;
    DBNavigator1: TDBNavigator;
    Label10: TLabel;
    Label11: TLabel;
    Label7: TLabel;
    Label9: TLabel;
    ListBox1: TListBox;
    Memo2: TMemo;
    os1: TLineSeries;
    Label2: TLabel;
    os: TLineSeries;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    Image1: TImage;
    Label1: TLabel;
    Label4: TLabel;
    Memo1: TMemo;
    OpenDialog1: TOpenDialog;
    SQLite3Connection1: TSQLite3Connection;
    SQLQuery1: TSQLQuery;
    SQLScript1: TSQLScript;
    SQLTransaction1: TSQLTransaction;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure DBGrid1CellClick(Sender: TObject);
    procedure DBGrid1GetCellHint(Sender: TObject; Column: TColumn;
      var AText: string);
    procedure DBNavigator1Click(Sender: TObject; Button: TDBNavButtonType);
     procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    imagenActual: TBitmap;

  end;

var
  Form1: TForm1;
  rutaEXE: string;
  framecol: integer;
  filename: string;


implementation

{$R *.lfm}
uses base64;

{ TForm1 }
function Base64ToStream(const ABase64: string; var AStream: TMemoryStream): boolean;
var
  Str: string;
begin
  Result := False;
  if Length(Trim(ABase64)) = 0 then
    Exit;
  try
    Str := DecodeStringBase64(ABase64);
    AStream.Write(Pointer(Str)^, Length(Str) div SizeOf(char));
    AStream.Position := 0;
    Result := AStream.Size > 0;
  except
    on E: Exception do
      ShowMessage(E.Message);
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  button2.Click;

end;

procedure TForm1.Button3Click(Sender: TObject);

begin
  { OpenDialog1.Execute ;
    filename := OpenDialog1.Filename;  }

  SQLite3Connection1.DatabaseName := filename;
  SQLite3Connection1.Connected := True;
  SQLTransaction1.DataBase := SQLite3Connection1;
  SQLQuery1.DataBase := SQLite3Connection1;
  SQLTransaction1.Active := True;
  SQLQuery1.SQL.Text :=
    'SELECT  user_id, frame_content, device_id ,datetime(timestamp/1000,"unixepoch") FROM (SELECT  *  ,(Timestamp) - LAG(Timestamp ,1)   OVER (PARTITION BY device_id ORDER BY Device_id) diff    FROM        detections) d Where  diff > 60000 and (visible=1)';

  memo2.Lines.Text := SQLQuery1.SQL.Text;

  SQLQuery1.Close;
  SQLQuery1.Open;
  framecol := SQLQuery1.FieldByName('frame_content').FieldNo;
  DataSource1.DataSet := SQLQuery1;
  DBGrid1.DataSource := DataSource1;
  DBGrid1.AutoFillColumns := True;
  dbgrid1.SelectedIndex := framecol - 1;
  datasource1.DataSet.Last;

  datasource1.DataSet.First;
  label11.Caption := 'Rec ' + DataSource1.DataSet.RecNo.ToString +
    '  of ' + DataSource1.DataSet.RecordCount.ToString;

end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  button2.Click;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  SQLite3Connection1.DatabaseName := filename;
  SQLite3Connection1.Connected := True;
  SQLTransaction1.DataBase := SQLite3Connection1;
  SQLQuery1.DataBase := SQLite3Connection1;
  SQLTransaction1.Active := True;
  SQLQuery1.SQL.Text :=
    'select frame_content, device_id,datetime(timestamp/1000,"unixepoch"),x,y from detections where    ((x<50 and y<50) or    ( x>width-50 and y> height-50 )) and (visible=1) ORDER BY Device_id';
  memo2.Lines.Text := SQLQuery1.SQL.Text;

  SQLQuery1.Close;
  SQLQuery1.Open;
  framecol := SQLQuery1.FieldByName('frame_content').FieldNo;
  DataSource1.DataSet := SQLQuery1;
  DBGrid1.DataSource := DataSource1;
  DBGrid1.AutoFillColumns := True;
  dbgrid1.SelectedIndex := framecol - 1;
  datasource1.DataSet.Last;

  datasource1.DataSet.First;
  label11.Caption := 'Rec ' + DataSource1.DataSet.RecNo.ToString +
    '  of ' + DataSource1.DataSet.RecordCount.ToString;

end;

procedure TForm1.Button6Click(Sender: TObject);
begin

  SQLite3Connection1.DatabaseName := filename;
  SQLite3Connection1.Connected := True;
  SQLTransaction1.DataBase := SQLite3Connection1;
  SQLQuery1.DataBase := SQLite3Connection1;
  SQLTransaction1.Active := True;
  SQLQuery1.SQL.Text :=
    'SELECT  user_id, frame_content, device_id ,datetime(timestamp/1000,"unixepoch"),x,width,y,height FROM (SELECT  *  ,(Timestamp) - LAG(Timestamp ,1)   OVER (PARTITION BY device_id ORDER BY Timestamp) diff    FROM        detections) d Where  (diff < 60000)  or ( (x<50 and y<50) or( x>width-50 and y> height-50) ) and (visible=1) ORDER BY Device_id';

  memo2.Lines.Text := SQLQuery1.SQL.Text;

  SQLQuery1.Close;
  SQLQuery1.Open;
  framecol := SQLQuery1.FieldByName('frame_content').FieldNo;
  DataSource1.DataSet := SQLQuery1;
  DBGrid1.DataSource := DataSource1;
  DBGrid1.AutoFillColumns := True;
  dbgrid1.SelectedIndex := framecol - 1;
  datasource1.DataSet.Last;

  datasource1.DataSet.First;
  label11.Caption := 'Rec ' + DataSource1.DataSet.RecNo.ToString +
    '  of ' + DataSource1.DataSet.RecordCount.ToString;

end;

procedure TForm1.Button7Click(Sender: TObject);
begin

  SQLite3Connection1.DatabaseName := filename;
  SQLite3Connection1.Connected := True;
  SQLTransaction1.DataBase := SQLite3Connection1;
  SQLQuery1.DataBase := SQLite3Connection1;
  SQLTransaction1.Active := True;
  SQLQuery1.SQL.Text :=
    'SELECT  user_id, frame_content, device_id ,datetime(timestamp/1000,"unixepoch"),x,width,y,height FROM (SELECT  *  ,(Timestamp) - LAG(Timestamp ,1)   OVER (PARTITION BY device_id ORDER BY Timestamp) diff    FROM        detections) d Where  (diff > 60000)  and ( (x>100 and y>100) and ( x<(width-100)and y< (height-100)) ) and (visible=1) ORDER BY Device_id';

  memo2.Lines.Text := SQLQuery1.SQL.Text;

  SQLQuery1.Close;
  SQLQuery1.Open;
  framecol := SQLQuery1.FieldByName('frame_content').FieldNo;
  DataSource1.DataSet := SQLQuery1;
  DBGrid1.DataSource := DataSource1;
  DBGrid1.AutoFillColumns := True;
  dbgrid1.SelectedIndex := framecol - 1;
  datasource1.DataSet.Last;

  datasource1.DataSet.First;
  label11.Caption := 'Rec ' + DataSource1.DataSet.RecNo.ToString +
    '  of ' + DataSource1.DataSet.RecordCount.ToString;

end;

procedure TForm1.Button1Click(Sender: TObject);

begin
  dbgrid1.Clear;
  SQLite3Connection1.DatabaseName := filename;//'bad.sqlite';
  SQLite3Connection1.Connected := True;
  SQLTransaction1.DataBase := SQLite3Connection1;
  SQLQuery1.DataBase := SQLite3Connection1;
  SQLTransaction1.Active := True;
  SQLQuery1.SQL.Text := memo2.Lines.Text;

  try
    SQLQuery1.Close;
    SQLQuery1.Open;
    framecol := SQLQuery1.FieldByName('frame_content').FieldNo;
    DataSource1.DataSet := SQLQuery1;
    DBGrid1.DataSource := DataSource1;
    DBGrid1.AutoFillColumns := True;

    label10.Caption := framecol.ToString;

    dbgrid1.SelectedIndex := framecol;
    label9.Caption := '';
    datasource1.DataSet.Last;

    label11.Caption := 'Rec ' + DataSource1.DataSet.RecNo.ToString +
      '  of ' + DataSource1.DataSet.RecordCount.ToString;
    datasource1.DataSet.First;

  except
    on E: Exception do
      { label9.Caption:='Error '; }  memo2.Font.Color := clred;
  end;
  // SQLQuery1.Open;

end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  filename := '';
  if OpenDialog1.Execute then
  begin
    filename := OpenDialog1.Filename;
  end;
  rutaEXE := ExtractFilePath(UTF8Encode(Application.ExeName));
  SQLQuery1.SQL.Clear;
  dbgrid1.Clear;
  begin
    SQLite3Connection1.DatabaseName := filename;// 'bad.sqlite';
    SQLite3Connection1.Connected := True;
    SQLTransaction1.DataBase := SQLite3Connection1;
    SQLQuery1.DataBase := SQLite3Connection1;
    SQLTransaction1.Active := True;
    SQLQuery1.SQL.Text :=
      'SELECT device_id, frame_content,datetime(timestamp/1000,"unixepoch") as time,user_id,x,y,width,height  FROM detections where (visible=1) order by device_id';
    memo2.Lines.Text := SQLQuery1.SQL.Text;
    SQLQuery1.Close;



    SQLQuery1.Open;
    framecol := SQLQuery1.FieldByName('frame_content').FieldNo;
    DataSource1.DataSet := SQLQuery1;
    DBGrid1.DataSource := DataSource1;
    label10.Caption := framecol.ToString;
    DBGrid1.AutoFillColumns := True;
    dbgrid1.SelectedIndex := framecol - 1;
    //     label11.Caption:= sqlquery1.SQL..ToString;
    datasource1.DataSet.Last;
    datasource1.DataSet.First;
    label11.Caption := 'Rec ' + DataSource1.DataSet.RecNo.ToString +
      '  of ' + DataSource1.DataSet.RecordCount.ToString;

  end;
end;

procedure TForm1.DBGrid1CellClick(Sender: TObject);
var
  f: TmemoryStream;
  enc: ansistring;
  Ms: TMemoryStream;
  Png: TPortableNetworkGraphic;
  Z,ZZ,contador_b,contador, a, clipx, clipy, w, h, x, y: integer;
  sl: PRGB32Array;
  XX,grey: real;

begin
  label11.Caption := 'Rec ' + DataSource1.DataSet.RecNo.ToString +
    '  of ' + DataSource1.DataSet.RecordCount.ToString;
  dbgrid1.Refresh;
  dbgrid1.SelectedIndex := framecol - 1;

  chart1.Canvas.Clear;
  image1.Canvas.Brush.Color := clblack;

  image1.Canvas.FillRect(0, 0, image1.Width, image1.Height);
  label1.Caption := dbgrid1.SelectedField.AsString;
  label1.Caption := dbgrid1.SelectedField.FieldName;
  if dbgrid1.SelectedField.Index = framecol - 1 then
  begin
    memo1.Lines.Text := dbgrid1.SelectedField.AsString;

    Ms := TMemoryStream.Create;
    try
      if Base64ToStream(Memo1.Text, MS) then
      begin
        Png := TPortableNetworkGraphic.Create;
        try
          Png.LoadFromStream(Ms);
          Image1.Canvas.Draw(0, 0, Png);
        finally
          Png.Free;
        end;
      end;
    finally
      Ms.Free;

    end;
    GREY := 0;
    imagenactual := image1.Picture.Bitmap;
    a := 0;
     w := imagenactual.Width;
    h := imagenactual.Height;
    contador := 0;
    os.Clear;
    os1.Clear;
    listbox1.Clear;
    for y := 0 to 60 do
    begin
      sl := imagenActual.ScanLine[y];
      for x := 0 to 60 do
        with sl[x] do
        begin
          grey := (rgbBlue + rgbGreen + rgbRed);
          os1.AddXY(round(grey), x);
          os.AddXY(round(grey), y);
          listbox1.items.add(floattostr(grey));
        end;
      contador := contador + 1;
    end;
    label2.Caption := 'Brightest point ' + os.MaxXValue.ToString;
    contador := 0;
    contador_b := 0;
      for z := 1 to listbox1.Count - 1 do
    begin
      zz := listbox1.Items[z].ToInteger;
       if zz > (os.MaxxValue * 0.9) then
        contador := contador + 1;
      if zz < 2 then
        contador_b := contador_b + 1;
      xx := xx + zz;
    end;


    xx := xx / listbox1.Count - 1;

    if (os.MaxXValue > 50) and
      {(contador < 2) and }(xx < (listbox1.Count * 0.1)) and
      (contador > 0) and (contador < 10) then
    begin
      label7.Font.Color := cllime;
      label7.Caption := 'GOOD';
    end
    else
    begin
      label7.Font.Color := clred;
      label7.Caption := 'Bad or WORMS';
    end;

    chart1.Repaint;
    with imagenactual do
    begin
      PixelFormat := pf24bit;
      TransparentMode := tmAuto;
      Canvas.StretchDraw(Rect(0, 0, image1.Width * 4, image1.Height * 4), imagenactual);
    end;

  end;
end;


procedure TForm1.DBGrid1GetCellHint(Sender: TObject; Column: TColumn;
  var AText: string);
begin

end;



procedure TForm1.DBNavigator1Click(Sender: TObject; Button: TDBNavButtonType);
var
  f: TmemoryStream;
  enc: ansistring;
  Ms: TMemoryStream;
  Png: TPortableNetworkGraphic;
  zz, z, a, w, h, x, y: integer;
  xx, contador, contador_b, av_05, av_15, av_b, av_0, av_10, av_20,
  av_30, av_40, av_50, av_60, av_70, av_80, av_90, av_100: real;
  sl: PRGB32Array;

  max, najjasniejszy, srednia, grey: real;

begin
  label11.Caption := 'Rec ' + DataSource1.DataSet.RecNo.ToString +
    '  of ' + DataSource1.DataSet.RecordCount.ToString;
  dbgrid1.Refresh;
  dbgrid1.SelectedIndex := framecol - 1;

  chart1.Canvas.Clear;
  image1.Canvas.Brush.Color := clblack;

  image1.Canvas.FillRect(0, 0, image1.Width, image1.Height);
  label1.Caption := dbgrid1.SelectedField.AsString;
  label1.Caption := dbgrid1.SelectedField.FieldName;
  if dbgrid1.SelectedField.Index = framecol - 1 then
  begin
    memo1.Lines.Text := dbgrid1.SelectedField.AsString;

    Ms := TMemoryStream.Create;
    try
      if Base64ToStream(Memo1.Text, MS) then
      begin
        Png := TPortableNetworkGraphic.Create;
        try
          Png.LoadFromStream(Ms);
          Image1.Canvas.Draw(0, 0, Png);
        finally
          Png.Free;
        end;
      end;
    finally
      Ms.Free;

    end;
    GREY := 0;
    imagenactual := image1.Picture.Bitmap;
    a := 0;
    srednia := 0;
    najjasniejszy := 0;
    w := imagenactual.Width;
    h := imagenactual.Height;
    contador := 0;
    os.Clear;
    os1.Clear;
    listbox1.Clear;
    for y := 0 to 60 do
    begin
      sl := imagenActual.ScanLine[y];
      for x := 0 to 60 do
        with sl[x] do
        begin
          grey := (rgbBlue + rgbGreen + rgbRed);
          os1.AddXY(round(grey), x);
          os.AddXY(round(grey), y);
          listbox1.items.add(floattostr(grey));
        end;
      contador := contador + 1;
    end;
    label2.Caption := 'Brightest point ' + os.MaxXValue.ToString;
    contador := 0;
    contador_b := 0;
    max := listbox1.Count - 1;
    for z := 1 to listbox1.Count - 1 do
    begin
      zz := listbox1.Items[z].ToInteger;
       if zz > (os.MaxxValue * 0.9) then
        contador := contador + 1;
      if zz < 2 then
        contador_b := contador_b + 1;
      xx := xx + zz;
    end;


    xx := xx / listbox1.Count - 1;

    if (os.MaxXValue > 50) and
      {(contador < 2) and }(xx < (listbox1.Count * 0.1)) and
      (contador > 0) and (contador < 10) then
    begin
      label7.Font.Color := cllime;
      label7.Caption := 'GOOD';
    end
    else
    begin
      label7.Font.Color := clred;
      label7.Caption := 'Bad or WORMS';
    end;

    chart1.Repaint;
    with imagenactual do
    begin
      PixelFormat := pf24bit;
      TransparentMode := tmAuto;
      Canvas.StretchDraw(Rect(0, 0, image1.Width * 4, image1.Height * 4), imagenactual);
    end;

  end;
end;



end.
