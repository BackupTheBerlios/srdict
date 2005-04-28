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


program srdict;
{$mode objfpc}
uses translator;


var mahina: TTranslator;
	i: cardinal;
	curr: string;

procedure RunSwitches(s: string);
var i: integer;
begin
	for i:=2 to length(s) do
	case s[i] of
	's','S': mahina.baseName:='sr2en';
	'e','E': mahina.baseName:='en2sr';
	'p','P': mahina.searchBy:=tkBegin;
	'k','K': mahina.searchBy:=tkEnd;
	'c','C': mahina.searchBy:=tkWhole;
	'd','D': mahina.searchBy:=tkPart;
	end; {case}
end;

procedure RunTranslate(s: string);
begin
	writeln;
	writeln('Prevodim frazu: '+s);
	
	mahina.lookFor:=s;
	
	if mahina.translations=0 
	then writeln('Nema prevoda za frazu "'+s+'"!');
end;

begin
	writeln('Srpsko-engleski recnik, SrDict 0.1');
	writeln('Copyright (C) 2005, Srdjan Rilak <rile@users.sourceforge.net>');
	mahina:= TTranslator.Create;
	
	for i:=1 to ParamCount do begin
		curr:=ParamStr(i);
		if curr[1]='-'
		then RunSwitches(curr)
		else RunTranslate(curr);
	end;
	
	mahina.destroy;
end.
