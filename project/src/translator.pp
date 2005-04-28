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
unit translator;
{$mode objfpc}
interface

const maxBaseItems=40000;

type TTransKind=(tkWhole, tkBegin, tkEnd, tkPart); //vrsta pretrage iz baze
     TTransStatus=(tsInactive, tsLoading, tsActive, tsSearching); //stanja instance klase TTranslator

type TTranslator=class(TObject)

			private
			baseRoot, base, baseFile: string;
			
			_baseName: string;
			function  ReadBaseName: string;
			procedure WriteBaseName(s: string);
			
			
			_searchBy: TTransKind;
			function ReadSearchBy: TTransKind;
			procedure WriteSearchBy(sb: TTransKind);
			
			
			_status: TTransStatus;
			
			_translations: cardinal;
			
			_lookFor: string;
			function  ReadLookFor: string;
			procedure WriteLookFor(s: string);
			
			function obrniRecc(s: string; i: byte): string;
			function  obrni(s: string): string;
			
			//********* BAZA U RAMU *************
			baseItems: cardinal;
			item : array[1..maxBaseItems] of string[50];
			index: array[1..maxBaseItems] of cardinal;
			trans: array[1..maxBaseItems] of string[250];
			
			//********* PROCEDURE ZA UCITAVANJE BAZE U RAM *************
			procedure LoadRegularBase;
			procedure LoadInvertedBase;
			procedure LoadBase;
			
			//*********************************************************************************
			//************************** FUNKCIJE ZA PRETRAGU BAZE ****************************
			
			function  bstIndex(rec: string; levo, desno: cardinal):cardinal; //samo za rekurziju
			function  IndexOf(rec: string):cardinal; //za koriscenje
			procedure FindWhole(rec: string); //prevod cele reci
			
			function  bstPartIndex(rec: string; levo, desno: cardinal): cardinal; //samo za rekurziju
			function  PartIndexOf(rec: string): cardinal; //za koriscenje
			procedure FindPart(rec: string); //prevod pocetka reci
			
			procedure FindAnyPart(rec: string); //prevod reci koja sadrzi zadati string ***SPORO***
			
			procedure FindWord(rec: string);
			//*********************************************************************************
			
			public
			constructor Create;
			procedure   AddResult(s: string); virtual;
			prevodi: array [1..500] of string[250];
			
			published
			property lookFor: string read ReadLookFor write WriteLookFor;
			property searchBy: TTransKind read ReadSearchBy write WriteSearchBy;
			property status: TTransStatus read _status;
			property baseName: string read ReadBaseName write WriteBaseName;
			property translations: cardinal read _translations;
		 end;


implementation
function  TTranslator.ReadLookFor: string;
begin
	ReadLookFor:=_lookFor;
end;

procedure TTranslator.WriteLookFor(s: string);
begin
	_lookFor:=s;
	_translations:=0;
	{******kod za razdvajanje stringova!!!*********}
	
	FindWord(_lookFor);
end;

constructor TTranslator.Create;
var prevod: text; i: cardinal;
begin
	inherited Create;
	_status:=tsInactive;
	
	baseRoot:=ParamStr(0);
	while baseRoot[length(baseRoot)]<>'/' do delete(baseRoot, length(BaseRoot), 1);
	baseRoot:=baseRoot+'base';
	base:=baseRoot+'/en2sr';
	baseFile:=base+'/regular';
	_baseName:='en2sr';
	{***********obradi za 'multiplace' baze************}
	assign(prevod, base+'/trans'); reset(prevod);
		i:=0;
		while not eof(prevod) do begin
			inc(i);
			readln(prevod, trans[i]);
		end;
	close(prevod);
	
	baseItems:=0;
	
	_searchBy:=tkWhole;
	{***********kod za podizanje baze u RAM************}{ODRADJENO}
	LoadBase;	

	_lookFor:='';
	
	
	_status:=tsActive;
end;

function TTranslator.ReadSearchBy: TTransKind;
begin
	ReadSearchBy:=_searchBy;
end;

procedure TTranslator.WriteSearchBy(sb: TTransKind);
var needReload: Boolean;
begin
	if sb<>_searchBy then begin
	
		needReload:= (_searchBy=tkEnd) or (sb=tkEnd);
		_searchBy:=sb;
		if _searchBy=tkEnd
		then baseFile:=base+'/invert'
		else baseFile:=base+'/regular';
		
		if needReload then LoadBase;
		
	end;
end;

function  TTranslator.ReadBaseName: string;
begin
	ReadBaseName:=_baseName;
end;

procedure TTranslator.WriteBaseName(s: string);
var prevod: text; i: cardinal;
begin
	if _baseName<>s then begin
		_baseName:=s;
		base:=baseRoot+'/'+_baseName;
		
		if _searchBy=tkEnd
		then baseFile:=base+'/invert'
		else baseFile:=base+'/regular';
		
		LoadBase;
		
		assign(prevod, base+'/trans'); reset(prevod);
		i:=0;
		while not eof(prevod) do begin
			inc(i);
			readln(prevod, trans[i]);
		end;
		close(prevod);
		{***********************}
	end;
end;

procedure TTranslator.LoadRegularBase;
var ulaz, indeksi: text;
begin
	baseItems:=0;	
	
	assign(ulaz, baseFile); assign(indeksi, base+'/regular-index');
	reset(ulaz); reset(indeksi);
	
	while not eof(ulaz) do begin
		inc(baseItems);
		readln(ulaz, item[baseItems]);		
		readln(indeksi, index[baseItems]);
	end;
	
	close(ulaz); close(indeksi);
end;

procedure TTranslator.LoadInvertedBase;
var ulaz, indeksi: text;
begin
	baseItems:=0;
	
	assign(ulaz, baseFile); assign(indeksi, base+'/index');
	reset(ulaz); reset(indeksi);
	
	while not eof(ulaz) do begin 
		inc(baseItems);
		readln(ulaz, item[baseItems]);
		readln(indeksi, index[baseItems]);
	end;
	
	close(ulaz); close(indeksi);
end;

procedure TTranslator.LoadBase;
var exstatus:TTransStatus;
begin
	exstatus:=_status;
	_status:=tsLoading;
	
	if _searchBy=tkEnd
	then LoadInvertedBase
	else LoadRegularBase;
	
	_status:=exstatus;
end;

function  TTranslator.bstIndex(rec: string; levo, desno: cardinal) :cardinal; //samo za rekurziju
var sredina: cardinal;
begin
	if upcase(item[levo])=upcase(rec) then bstIndex:=levo
	else begin
	
	if upcase(item[desno])=upcase(rec) then bstIndex:=desno
	else begin
	
	if (desno-levo)>1 
	then begin
		sredina:=(levo + desno) div 2;
		{writeln(item[levo]+'<<<'+item[sredina]+'>>>'+item[desno]);}
		if upcase(item[sredina])>upcase(rec)
		then bstIndex:=bstIndex(rec, sredina, desno)
		else bstIndex:=bstIndex(rec, levo, sredina);
	end
	
	else begin
		bstIndex:=0;
	end;
	
	
	end;
	end;
	
end;

function  TTranslator.IndexOf(rec: string): cardinal; //za koriscenje
begin
	IndexOf:=bstIndex(rec, 1, baseItems); 
end;

procedure TTranslator.AddResult(s: string);
begin
	if _translations<500 then begin
		inc(_translations);
		writeln(s);
		prevodi[_translations]:=s;
	end;
	{writeln(_lookFor, ' ', _translations);}
	
end;

procedure TTranslator.FindWhole(rec: string);
var i: cardinal;
begin
	i:=IndexOf(rec);	
	if i<>0 then AddResult(item[i]+'|'+trans[index[i]]);
end;

function TTranslator.bstPartIndex(rec: string; levo, desno: cardinal): cardinal; 
var sredina, duzina: cardinal;
begin
	duzina:=length(rec);	
	
	if upcase(rec)=upcase( copy( item[levo], 1, duzina ) ) then bstPartIndex:=levo
	else begin
	
	if upcase(rec)=upcase( copy( item[desno], 1, duzina ) ) then bstPartIndex:=desno
	else begin
	
	if (desno-levo)>1
	
	then begin
		sredina:= (levo + desno) div 2;
		if upcase(item[sredina])<upcase(rec)
		then bstPartIndex:=bstPartIndex( rec, levo, sredina )
		else bstPartIndex:=bstPartIndex( rec, sredina, desno);
	end
	
	else begin
		bstPartIndex:=0;
	end;
	
	
	end;
	end;
	
end;

function TTranslator.PartIndexOf(rec: string): cardinal; 
begin
	PartIndexOf:=bstPartIndex(rec, 1, baseItems)
end;

procedure TTranslator.FindPart(rec: string); 
var i, levo, desno, duzina: cardinal;
begin
	if _searchBy=tkEnd then rec:=obrni(rec);	
	i:=PartIndexOf(rec);
	
	if i<>0 then begin
	duzina:=length(rec);
	
	levo:=i;	
	while (levo>1) and ( upcase(rec)=upcase( copy( item[levo], 1, duzina ) ) ) do dec(levo);
	inc(levo);
	
	desno:=i;
	while (desno<baseItems) and ( upcase(rec)=upcase( copy( item[desno], 1, duzina ) ) ) do inc(desno);
	dec(desno);	
	
	if _searchBy=tkEnd 
	then for i:=levo to desno do AddResult( obrni(item[i]) +'|'+ trans[index[i]])
	else for i:=desno downto levo do AddResult(item[i]+'|'+trans[index[i]]);
	
	end; {if i<>0}
end;

procedure TTranslator.FindAnyPart(rec: string);
var i: integer;
begin
	for i:=1 to baseItems do
		if pos(rec, item[i]) <> 0
		then AddResult(item[i]+'|'+trans[i]);
end;

procedure TTranslator.FindWord(rec: string);
var exstatus: TTransStatus;
begin
	exstatus:=_status;
	_status:=tsSearching;
	
	_translations:=0;
	case _searchBy of	
	tkWhole : FindWhole(rec);
	tkBegin, tkEnd: FindPart(rec);
	tkPart: FindAnyPart(rec);
	end; {case}
	
	_status:=exstatus;
end;

function TTranslator.obrniRecc(s: string; i: byte): string;
begin
	if i=length(s)
	then obrniRecc:=s[i]
	else obrniRecc:=obrniRecc(s, i+1)+s[i];
end;

function TTranslator.obrni(s: string): string;
begin
	if s<>''
	then obrni:=ObrniRecc(s,1)
	else obrni:='';
end;

end.
