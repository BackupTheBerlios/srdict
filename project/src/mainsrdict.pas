{
     Copyright (C) 2005 by Srdjan Rilak                                     
     rile@users.sourceforge.net                                        
                                                                            
     This program is free software; you can redistribute it and/or modify   
     it under the terms of the GNU General Public License as published by   
     the Free Software Foundation; either version 2 of the License, or      
     (at your option) any later version.                                    
                                                                            
     This program is distributed in the hope that it will be useful,        
     but WITHOUT ANY WARRANTY; without even the implied warranty of         
     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          
     GNU General Public License for more details.                           
                                                                            
     You should have received a copy of the GNU General Public License      
     along with this program; if not, write to the                          
     Free Software Foundation, Inc.,                                        
     59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.              
}


unit MainSrDict;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs,
  PairSplitter, Grids, ComCtrls, ExtCtrls, StdCtrls, Menus, translator, about,
  Buttons;

type
  TMainForm = class(TForm)
    appProp: TApplicationProperties;
    fraza: TComboBox;
    Label1: TButton;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    nacin: TComboBox;
    LabelNacin: TLabel;
    smer: TComboBox;
    LabelSmer: TLabel;
    pano: TPanel;
    prevodi: TStringGrid;
    procedure PromenaNacina(Sender: TObject);
    procedure PromenaJezika(Sender: TObject);
    procedure MainFormCreate(Sender: TObject);
    procedure MainFormDestroy(Sender: TObject);
    procedure ComboJezikChange(Sender: TObject);
    procedure ComboNacinChange(Sender: TObject);
    procedure Prevedi;
    procedure PrevediClick(Sender: Tobject);
    procedure ClearClick(Sender: TObject);
    procedure CloseClick(Sender: Tobject);
    Procedure AboutClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    engine: TTranslator;
  end; 

var
  MainForm: TMainForm;

implementation

procedure TMainForm.PromenaNacina(Sender: TObject);
begin
	{kod za menjanje nacina pretrage}
        (Sender as TMenuItem).checked:=true;
        if nacin.ItemIndex<>(Sender as TMenuItem).tag then
        nacin.ItemIndex:=(Sender as TMenuItem).tag;

        case (Sender as TMenuItem).tag of
        0 : engine.searchBy:=tkWhole;
        1 : engine.searchBy:=tkBegin;
        2 : engine.searchBy:=tkEnd;
        3 : engine.searchBy:=tkPart;
        end; {case}
end;

procedure TMainForm.PromenaJezika(Sender: TObject);
begin
	{kod za menjanje aktivnog jezika}
        (Sender as TMenuItem).checked:=true;
        if smer.ItemIndex<>(Sender as TMenuItem).tag then
        smer.ItemIndex:=(Sender as TMenuItem).tag;
        if (Sender as TMenuItem).tag=0
        then engine.baseName:='en2sr'
        else engine.baseName:='sr2en';
end;

procedure TMainForm.MainFormCreate(Sender: TObject);

begin
         engine:= TTranslator.Create;
end;

procedure TMainForm.MainFormDestroy(Sender: TObject);
begin
          engine.destroy;
end;

procedure TMainForm.ComboJezikChange(Sender: TObject);
begin
          {promena nacina prevoda}
end;

procedure TMainForm.ComboNacinChange(Sender: TObject);
begin
     {promena nacina prevoda}
end;

procedure TMainForm.Prevedi;
var rec, prevod: string; i, p, j: cardinal;
begin
          prevodi.cols[0].clear;
          prevodi.cols[1].clear;
          prevodi.rowCount:=1;

          engine.lookFor:=fraza.text;
          
          if engine.translations=0 then ShowMessage('Nije pronadjen nijedan prevod zadate fraze.')
          else begin
                    prevodi.rowCount:=engine.translations;

                    p:=pos('|', engine.prevodi[1]);
                    rec:=copy(engine.prevodi[1], 1, p-1);
                    prevod:=engine.prevodi[1];
                    delete(prevod, 1, p);
                    
                    prevodi.cells[0,0]:=rec;
                    rec:='';
                    p:=1;
                    for i:=1 to length(prevod) do
                        if prevod[i]<>';'
                        then rec:=rec+prevod[i]
                        else begin
                                  inc(p);
                                  rec:=rec+#10#13;
                        end;
                    prevodi.cells[1,0]:=rec;
                    prevodi.RowHeights[0]:=p*20;
                    
                    for j:=2 to engine.translations do begin
                           p:=pos('|', engine.prevodi[j]);
                           rec:=copy(engine.prevodi[j], 1, p-1);
                           prevod:=engine.prevodi[j];
                           delete(prevod, 1, p);

                           prevodi.cells[0,j-1]:=rec;
                           rec:='';
                           p:=1;
                           for i:=1 to length(prevod) do
                                 if prevod[i]<>';'
                                 then rec:=rec+prevod[i]
                                 else begin
                                           inc(p);
                                           rec:=rec+#10#13;
                                 end;
                           prevodi.cells[1,j-1]:=rec;
                           prevodi.RowHeights[j-1]:=p*20;
                    end;
          end;
end;

procedure TMainForm.PrevediClick(Sender: Tobject);
begin
          prevedi;
          fraza.items.add(fraza.text);
          fraza.text:='';
end;

procedure TMainForm.ClearClick(Sender: TObject);
begin
          fraza.items.clear;
end;

procedure TMainForm.CloseClick(Sender: Tobject);
begin
          close;
end;

procedure TMainForm.AboutClick(Sender: TObject);
begin
          Form1.ShowModal;
end;

initialization
  {$I mainsrdict.lrs}

end.

