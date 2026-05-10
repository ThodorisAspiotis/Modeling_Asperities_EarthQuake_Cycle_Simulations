
       function SetStrengthFieldButtonPushed(app, event)
        % This add-on for MCQSim , an earthquake-cycle simulation framework , provides users with the
		% capability to construct and manipulate frictional asperities manually based on critical
		% distance, friction coefficients, or effective normal stress. The tool can be used either
		% to define deterministic frictional-strength fields directly or in combination with
		% stochastic spatial distributions and filters, including fractal, Von Kármán, Gaussian, 
		% and exponential models. Theodoros Aspiotis  tedaspiotis@gmail.com
                app.Manual_Strength = [] ; app.Manual_Strength2 = [] ; app.Manual_Strength3 = [] ;
            app.Manual_Strength.how_big = get(0,'ScreenSize') ; if app.Manual_Strength.how_big(1,3) > 1800 , app.Manual_Strength.a_si(1) = 18 ; app.Manual_Strength.a_si(2) = 10 ; app.Manual_Strength.a_si(3) = 10 ; app.Manual_Strength.a_si(4) = 2 ;  else , app.Manual_Strength.a_si(1) = 8 ;  app.Manual_Strength.a_si(2) = 4 ; app.Manual_Strength.a_si(3) = 2 ; app.Manual_Strength.a_si(4) = 4 ;   end
            if (app.GridImported       == 0),   app.dlga = warndlg('No Fault model has been imported' , 'ATTENTION')        ;  set(app.dlga,'Units','normalized','Position', [ .46 .46 .06 .06 ] )    ,      return;                             end
               app.Manual_Strength.xn = [] ; app.Manual_Strength.MinStkLngthVal = [] ;
            app.Manual_Strength.yn = [] ; app.Manual_Strength.MaxStkLngthVal = [] ;
            app.Manual_Strength.X = [] ; app.Manual_Strength.MinDipLngthVal = [ ] ;
            app.Manual_Strength.Y = [] ; app.Manual_Strength.MaxDipLngthVal = [ ] ;
            app.Manual_Strength.haa =  1 ; app.Strength_Field = [] ;
            app.Strength_Field.es_a1 = [] ;
            FaultNumber     = size(unique(app.FaultValues(:,23)),1);
             for ii = 1 : FaultNumber
                 SelFaultID      = app.RoughParasPerFault(ii,19);
                     SelectedPatches = app.Fault(1).TriangleList( (app.Fault(1).TriangleList(:,5) == SelFaultID) ,1:3);
                            SelVerticesList = unique(SelectedPatches(:));
                            SeletedVerts    = app.Fault(1).LocalPosVals(SelVerticesList,:); %this is in local coordinate system that is best fitting plane to all fault sections of a given fault               
                            app.Manual_Strength.MinStkLngthVal(ii)  = min(SeletedVerts(:,2));                                app.Manual_Strength.MinDipLngthVal(ii) = min(SeletedVerts(:,3));
                            app.Manual_Strength.MaxStkLngthVal(ii)  = max(SeletedVerts(:,2));                                app.Manual_Strength.MaxDipLngthVal(ii) = max(SeletedVerts(:,3));
                            app.Manual_Strength.FaultLength(ii)     = (  app.Manual_Strength.MaxStkLngthVal(ii) - app.Manual_Strength.MinStkLngthVal(ii)  );                       app.Manual_Strength.FaultWidth(ii)      = (  app.Manual_Strength.MaxDipLngthVal(ii) -app.Manual_Strength.MinDipLngthVal(ii)  );
            app.Manual_Strength.xn{ii}=linspace(app.Manual_Strength.MinStkLngthVal(ii), app.Manual_Strength.MaxStkLngthVal(ii), round(app.Manual_Strength.FaultLength(ii) ) * 10 );
             app.Manual_Strength.yn{ii}=linspace(app.Manual_Strength.MinDipLngthVal(ii),app.Manual_Strength.MaxDipLngthVal(ii), round(  app.Manual_Strength.FaultWidth(ii)   )  * 10 );
             [app.Manual_Strength.X{ii} , app.Manual_Strength.Y{ii}]=meshgrid(app.Manual_Strength.xn{ii} , app.Manual_Strength.yn{  ii  }  )  ;
             for ia = 1 : 4
         app.Manual_Strength.select_st{ ii , ia } = 'red' ;
         app.Manual_Strength.select_se( ii , ia ) = 0 ;
             end
             end
             
            ii = 1 ;
            app.Manual_Strength.geaga = 2 ;
            current = cd;
            hf=figure;
            app.Manual_Strength.ha = axes ;
            set(gcf,'NumberTitle','off','Name',' MCQSim - Build Structure of Strength Field ' , 'men' , 'no' ,  'Units'  ,  'normalized' , 'Position' , [  0.06    0.09    0.84    0.79]  )
            set( app.Manual_Strength.ha ,'Box','on' , 'units' , 'normalized' , 'OuterPosition' , [  0 0 1 .86  ]  )
            app.Manual_Strength2.main.vardraw = [];
            cd(current)
            app.Manual_Strength.ic=1;
            axis equal
                axis([  app.Manual_Strength.MinStkLngthVal(ii) app.Manual_Strength.MaxStkLngthVal(ii)  app.Manual_Strength.MinDipLngthVal(ii)  app.Manual_Strength.MaxDipLngthVal(ii)  ]  )
            set(gca,'YDir','reverse' )
            app.Manual_Strength.deletehist = [] ;
            app.Manual_Strength.hma = 1 ;
            app.Manual_Strength2.main.h.title = title('Structure of Strength Field - Friction coefficient \mu_{S} and/or \mu_{D} - Stress \sigma in MPa - D_{C} in meters. ') ;
                   hmf   = unique(app.FaultValues(:,23));
                   faultid  = size(hmf,1);  
                   app.Manual_Strength.z{1,  faultid  } = []  ;
                   app.Manual_Strength.filteredZ{1,  faultid  } = []  ;
                   app.Manual_Strength.inpo = []  ;
                        for iaa = 1 : FaultNumber
                            SelFaultID      = app.RoughParasPerFault(  iaa  ,19);
                          app.Manual_Strength.aa_si = size(app.Manual_Strength.X{ iaa })  ;  
              st2a{iaa} = [  'Fault ID ' num2str(  SelFaultID  ) ' out of '  num2str(faultid ) ' Dim: ' num2str(  app.Manual_Strength.aa_si(1)  ) ' X ' num2str(  app.Manual_Strength.aa_si(2)  ) ] ;
              for ia = 1 : 4
              app.Manual_Strength.z{ia, iaa  } = zeros( size(app.Manual_Strength.X{iaa}) )  ;
              app.Manual_Strength.filteredZ{ia,  iaa  } =   zeros( size(app.Manual_Strength.X{iaa}) )   ;
              app.Manual_Strength.inpo{ ia , faultid  ,  iaa  } =   zeros( size(app.Manual_Strength.X{iaa}) )   ;
              app.Manual_Strength.select_sta{  ia, iaa  } = ' '  ;
              end
                        end            
                        app.Manual_Strength.ai(1) = uipanel('Title','Fault Plane Selection Panel','FontSize',8,...
                         'BackgroundColor', get(gcf,'color')   ,  'fontsize' , app.Manual_Strength.a_si(1) ,  'fontweight','bold',...
                         'Position',[  .02 .86 .16 .12  ]);
            app.Manual_Strength2.a1 = uicontrol('style','popupmenu','parent' , app.Manual_Strength.ai(1) , 'un','norm',...
                'pos',  [  .02 .2 .94 .62 ] , 'fontsize' , app.Manual_Strength.a_si(1) ,  'backg' , [  get(gcf,'color') ] ,  'str', st2a  , 'callb',   {@smo2,app , 2}   );
            app.Manual_Strength2.t2 = uicontrol('style','text','parent' , app.Manual_Strength.ai(1) ,'un','norm',...
                'pos',  [ .002 .91 .06 .02  ] , 'fontsize' , app.Manual_Strength.a_si(1) ,  'backg' , [  get(gcf,'color') ] ,  'str','Fault plane Selection' , 'callb',' ');
                  app.Manual_Strength.ai(2) = uipanel('Title','Manual Strength Field','FontSize',8,...
                         'BackgroundColor', get(gcf,'color')   ,  'fontsize' , app.Manual_Strength.a_si(1) ,  'fontweight','bold',...
                         'Position',[  .19 .86 .3 .12   ]);
            app.Manual_Strength.ai(4) = uicontrol('style','pushbutton','parent' , app.Manual_Strength.ai(2) , 'un','norm',...
                'pos',  [  .02 .2 .16 .6 ] , 'fontsize' , app.Manual_Strength.a_si(1) ,  'backg' , [  get(gcf,'color') ] ,  'str', 'Polygon Area'   , 'callb',  {@drawpolygon,app , 1 }    );
            app.Manual_Strength.ai(5) = uicontrol('style','pushbutton','parent' , app.Manual_Strength.ai(2) , 'un','norm',...
                'pos',  [  .2 .2 .16 .6 ] , 'fontsize' , app.Manual_Strength.a_si(1) ,  'backg' , [  get(gcf,'color') ] ,  'str', 'Square Area'   , 'callb',   {@drawpolygon,app , 2 }    );
              app.Manual_Strength.ai(19) = uicontrol('style','pushbutton','parent' , app.Manual_Strength.ai(2) , 'un','norm',...
                'pos',  [  .38 .2 .16 .6 ] , 'fontsize' , app.Manual_Strength.a_si(1) ,  'backg' , [  get(gcf,'color') ] ,  'str', '<html><center>Entire<br />Fault Plane</center> </html>'   , 'callb',   {@draw_all,app , 2 }    );
               app.Manual_Strength2.a4 = uicontrol('style','pushbutton','parent' , app.Manual_Strength.ai(2)  , 'un','norm',...
                'pos',  [  .56 .58 .16 .4 ] , 'fontsize' , app.Manual_Strength.a_si(1) ,  'backg' , [  get(gcf,'color') ] ,  'str',  '<html><center>Load<br />Ascii file</center> </html>'  , 'callb', {@manual_area_asc ,app , 2}  ) ;
            app.Manual_Strength2.a6 = uicontrol('style','pushbutton','parent' , app.Manual_Strength.ai(2)  , 'un','norm',...
                'pos',  [  .56 .1 .16 .4 ] , 'fontsize' , app.Manual_Strength.a_si(1) ,  'backg' , [  get(gcf,'color') ] ,  'str',  '<html><center>Save<br />as Ascii</center> </html>'  , 'callb', {@save_stre ,app , 2}  ) ;        
            app.Manual_Strength.ai(6) = uicontrol('style','pushbutton','parent' , app.Manual_Strength.ai(2) , 'un','norm',...
                'pos',  [  .74 .56 .24 .48 ] , 'fontsize' , app.Manual_Strength.a_si(1) ,  'backg' , [  get(gcf,'color') ] ,  'str', 'Clear Patch'   , 'callb',   {@clear_a,app , 1 }   );
            app.Manual_Strength.ai(7) = uicontrol('style','pushbutton','parent' , app.Manual_Strength.ai(2) , 'un','norm',...
                'pos',  [  .74 .06 .24 .48 ] , 'fontsize' , app.Manual_Strength.a_si(1) ,  'backg' , [  get(gcf,'color') ] ,  'str', 'Clear entire plane'   , 'callb',   {@clear_a,app , 2 }   );
             app.Manual_Strength.ai(3) = uipanel('Title','Information of 2D Field','FontSize',8,...
                         'BackgroundColor', get(gcf,'color')   ,  'fontsize' , app.Manual_Strength.a_si(1) ,  'fontweight','bold',...
                         'Position',[  .502 .86 .2 .12  ]);
             app.Manual_Strength.ai(8) = uicontrol('style','text','parent' , app.Manual_Strength.ai(3) ,'un','norm',...
                'pos',  [ .02 .64 .96 .26  ] , 'fontsize' , app.Manual_Strength.a_si(1) ,  'backg' , [  get(gcf,'color') ] ,  'str','Current Fault plane ID size:' , 'callb',' ');
             app.Manual_Strength.ai(9) = uicontrol('style','text','parent' , app.Manual_Strength.ai(3) ,'un','norm',...
                'pos',  [ .02 .32 .96 .3  ] , 'fontsize' , app.Manual_Strength.a_si(1) ,  'backg' , [  get(gcf,'color') ] ,  'str','Nmuber of elements to be fitted:' , 'callb',' ');
             app.Manual_Strength.ai(12) = uicontrol('style','text','parent' , app.Manual_Strength.ai(3) ,'un','norm',...
                'pos',  [ .02 .01 .96 .3  ] , 'fontsize' , app.Manual_Strength.a_si(1) ,  'backg' , [  get(gcf,'color') ] ,  'str','Nmuber of assigned sub-areas:' , 'callb',' ');
            app.Manual_Strength.ai(14) = uipanel('Title','Set Strength Field','FontSize',8,...
                         'BackgroundColor', get(gcf,'color')   ,  'fontsize' , app.Manual_Strength.a_si(1) ,  'fontweight','bold',...
                         'Position',[  .764 .86 .2 .12   ]);
            app.Manual_Strength2.ed1 = uicontrol('style','edit','parent' , app.Manual_Strength.ai(14)  , 'un','norm',...
                'pos',[  .02 .2 .2 .4 ],  'fontsize' , app.Manual_Strength.a_si(1) ,  'str','1' , 'callb',' ');
            app.Manual_Strength2.t1 = uicontrol('style','text','parent' , app.Manual_Strength.ai(14)  ,'un','norm',...
                'pos',  [  .02 .7 .2 .24  ] , 'fontsize' , app.Manual_Strength.a_si(1) ,  'backg' , [  get(gcf,'color') ] ,  'str','Smooth ' , 'callb',' ');
              app.Manual_Strength2.t2 = uicontrol('style','text','parent' , app.Manual_Strength.ai(14)  ,'un','norm',...
                'pos',  [  .28 .7 .22 .24  ] , 'fontsize' , app.Manual_Strength.a_si(1) ,  'backg' , [  get(gcf,'color') ] ,  'str','Property' , 'callb',' ');
           app.Manual_Strength.ai(17) = uicontrol('style','pushbutton','parent' , app.Manual_Strength.ai(14) , 'un','norm',...
                'pos',  [  .56  .68 .2 .36 ] , 'fontsize' , app.Manual_Strength.a_si(1) ,  'backg' , [  get(gcf,'color') ] ,  'str', 'Add'   , 'callb',  {@set_segments,app , 1 }    );
              app.Manual_Strength.ai(18) = uicontrol('style','pushbutton','parent' , app.Manual_Strength.ai(14) , 'un','norm',...
                'pos',  [  .78  .68 .2 .36 ] , 'fontsize' , app.Manual_Strength.a_si(1) ,  'backg' , [  get(gcf,'color') ] ,  'str', 'Remove'   , 'callb',  {@set_segments,app , 2 }    );
            app.Manual_Strength.ai(16) = uicontrol('style','pushbutton','parent' , app.Manual_Strength.ai(14) , 'un','norm',...
                'pos',  [  .56  .08 .42 .52 ] , 'fontsize' , app.Manual_Strength.a_si(1) ,  'backg' , [  get(gcf,'color') ] ,  'str', 'Run model'   , 'callb',  {@smo,app , 2}    );
            app.Manual_Strength2.a2 = uicontrol('style','popupmenu','parent' , app.Manual_Strength.ai(14) , 'un','norm',...
                'pos',  [  .28  .22 .24 .34  ] , 'fontsize' , app.Manual_Strength.a_si(1) ,  'backg' , [  get(gcf,'color') ] ,  'str', {'<html><FONT COLOR="black" SIZE="10" FACE="ARIAL">μs<html>','μD','σ','Dc'}  , 'callb', {@smo2,app , 2}  ) ;
            smo2(1 , 2 ,app , 2) 
             app.Manual_Strength.eai = text(1,1,[' ']) ;      
            aa = 1 ;
app.Manual_Strength2.ea1 = uipanel(  'Title','Type' , 'BackgroundColor', get(gcf,'color')   ,  'fontsize' , app.Manual_Strength.a_si(1) ,  'fontweight','bold',...
                         'Position',[  .71 .86 .048 .12  ]);
app.Manual_Strength.agea = 1 ;
app.Manual_Strength2.ea2 = uicontrol('style','radiobutton','parent' , app.Manual_Strength2.ea1  , 'un','norm',...
                'pos',[  .1  .78 .8 .24   ], 'value' , 1  ,  'fontsize' , app.Manual_Strength.a_si(1) ,  'str','Normal' , 'callb', {@ena ,app , 1 } )  % set(app.Manual_Strength2.ea3 , ''value'' , 0 ) , set(app.Manual_Strength2.ea4 , ''value'' , 0 ) ');
app.Manual_Strength2.ea3 = uicontrol('style','radiobutton','parent' , app.Manual_Strength2.ea1  , 'un','norm',...
                'pos',[  .1  .52 .8 .24  ],  'fontsize' , app.Manual_Strength.a_si(1) ,  'str','a-b Profile' , 'callb', {@ena ,app , 2 } )  %  set(app.Manual_Strength2.ea2 , ''value'' , 0 ) , set(app.Manual_Strength2.ea4 , ''value'' , 0 ) ');
app.Manual_Strength2.ea4 = uicontrol('style','radiobutton','parent' , app.Manual_Strength2.ea1  , 'un','norm',...
                'pos',[  .1  .26 .8 .24   ],  'fontsize' , app.Manual_Strength.a_si(1) ,  'str','a-b & var' , 'callb', {@ena ,app , 4 } )  %  set(app.Manual_Strength2.ea2 , ''value'' , 0 ) , set(app.Manual_Strength2.ea3 , ''value'' , 0 )  ');
app.Manual_Strength.an2 = axes  ;
set(  app.Manual_Strength.an2  ,  'Units'  ,  'normalized' , 'Position' , [  0.02    0.6    0.12    0.26  ]   )
  axis off
view( 4 , 89 )
set( gcf , 'currenta' , app.Manual_Strength.an2 )
j = 1  ;
 for ha = min( app.Fault.TriangleList(:,5) )-1 : max( app.Fault.TriangleList(:,5) )-1
cur_pos = [] ; AllV1s = [] ; AllV2s = [] ; AllV3s = [] ;
cur_pos = find( app.Fault.TriangleList(:,5)== ha+1 )  ;
   AllV1s(:,1) = app.Fault.GlobalVertices(app.Fault.TriangleList(cur_pos,1),1);  AllV1s(:,2) = app.Fault.GlobalVertices(app.Fault.TriangleList(cur_pos,2),1);    AllV1s(:,3) = app.Fault.GlobalVertices(app.Fault.TriangleList(cur_pos,3),1);  AllV2s(:,1) = app.Fault.GlobalVertices(app.Fault.TriangleList(cur_pos,1),2); AllV2s(:,2) = app.Fault.GlobalVertices(app.Fault.TriangleList(cur_pos,2),2);  AllV2s(:,3) = app.Fault.GlobalVertices(app.Fault.TriangleList(cur_pos,3),2);    AllV3s(:,1)  = app.Fault.GlobalVertices(app.Fault.TriangleList(cur_pos,1),3); AllV3s(:,2)  = app.Fault.GlobalVertices(app.Fault.TriangleList(cur_pos,2),3);   AllV3s(:,3) = app.Fault.GlobalVertices(app.Fault.TriangleList(cur_pos,3),3);
app.Manual_Strength.aea2( j ) = patch(AllV1s'./1000,AllV2s'./1000,AllV3s'./1000,rand(1 , length( AllV1s ) )' , 'userdata' , ha+1  );
set( app.Manual_Strength.aea2( j ) ,'EdgeColor','k')
hold on
j = j + 1 ;
 end
set( app.Manual_Strength.aea2( 1  ) ,'EdgeColor', 'r' )
  app.Manual_Strength.ed1 = uicontrol('style','edit','parent' , app.Manual_Strength2.ea1  , 'un','norm',...
                'pos',[  .3 .04 .4 .2 ],  'fontsize' , app.Manual_Strength.a_si(1) ,  'str',' 0 ' , 'callb',' ');



            function ena(  src , evt , app , td )
                if td == 1
set(app.Manual_Strength2.ea3 , 'value' , 0 ) 
set(app.Manual_Strength2.ea4 , 'value' , 0 )
set(app.Manual_Strength2.ea2 , 'value' , 1 )
app.Manual_Strength.agea = 1 ;
                elseif td == 2
set(app.Manual_Strength2.ea2 , 'value' , 0 ) 
set(app.Manual_Strength2.ea4 , 'value' , 0 )
set(app.Manual_Strength2.ea3 , 'value' , 1 )
app.Manual_Strength.agea = 2 ;
                else
set(app.Manual_Strength2.ea2 , 'value' , 0 ) 
set(app.Manual_Strength2.ea3 , 'value' , 0 )
set(app.Manual_Strength2.ea4 , 'value' , 1 )
app.Manual_Strength.agea = 4 ;
                end

            end

            function manual_area(  src , evt , app , td )

app.Manual_Strength.atgx = zeros(1,4) ; app.Manual_Strength.atgy = zeros(1,4) ;
for i = 1 : 4
              app.Manual_Strength.atg(i) =  find(get(app.Manual_Strength2.aea(i) ,'string')==' ') ;
              sep = [] ; sep = get(app.Manual_Strength2.aea(i) ,'string') ;
              app.Manual_Strength.atgx(i) = str2num( sep(1:app.Manual_Strength.atg(i) - 1 ) ) ; app.Manual_Strength.atgy(i) = str2num( sep( app.Manual_Strength.atg(i) : end ) ) ;
end
app.Manual_Strength.gg= 1 ; app.Manual_Strength.gg=app.Manual_Strength.gg+1;
            app.Manual_Strength3.hpatch = patch( app.Manual_Strength.atgx , app.Manual_Strength.atgy ,'r');
            set( app.Manual_Strength3.hpatch ,'FaceAlpha',.2)
            app.Manual_Strength2.main.vardraw=1;
            app.Manual_Strength3.datetime = datestr(clock);       
         app.Manual_Strength.deletehist = 2 ;
            name = inputdlg('Set Strength Value  ', 'Details', [1 30]);
            namedata = (name{:});
            if isempty(  namedata  )
            app.Strength_Field.h = warndlg('No data provided'  ,  'ATTENTION'  )  ;
            set( app.Strength_Field.h ,'resize' , 'on' ) , return
            else  
            app.Manual_Strength3.infodetails = str2num(  namedata  )  ;
       [app.Manual_Strength.in,app.Manual_Strength.on] = inpolygon( app.Manual_Strength.X{ get(app.Manual_Strength2.a1,'value') }  ,  app.Manual_Strength.Y{  get(app.Manual_Strength2.a1,'value')  }   ,  app.Manual_Strength.atgx ,  app.Manual_Strength.atgy ) ;
       app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}( app.Manual_Strength.in == 1 ) =  app.Manual_Strength3.infodetails  ;
       app.Manual_Strength.filteredZ{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')} = app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}  ;
      app.Manual_Strength.hma = app.Manual_Strength.hma + 1 ; app.Manual_Strength.haa = app.Manual_Strength.haa + 1 ;
       app.Manual_Strength.sele(app.Manual_Strength.hma) = 2 ;
       smo2(1 , 2 ,app , 2) 
            end
   app.Manual_Strength.inpo{ get(app.Manual_Strength2.a2,'value') , get(app.Manual_Strength2.a1,'value'), app.Manual_Strength.hma }  =  app.Manual_Strength.in ;
           app.Manual_Strength.gg = app.Manual_Strength.gg + 1;
           smo2(1 , 2 ,app , 2) 

        end



 function save_stre(  src , evt , app , td )

        name = inputdlg('Name of Strength Field  ', 'Details'  );
            namedata = (name{:});
fid = fopen( namedata ,'wt') ;
fprintf(fid,'%s \n', 'MCQsim - EXTERNAL STRENGTH FIELD')
fprintf(fid,'%s \n', 'First number represents fault''s ID ')
fprintf(fid,'%s \n', 'Second number represents the property (1=μs 2=μd 3=σ 4=Dc)  ')
fprintf(fid,'%s \n', 'Third number represents the manually added value ' )
fprintf(fid,'%s \n', 'Fourth number stands for the profile type ( 1=Normal 2=following a-b 3=a-b plus variability ) ' )
fprintf(fid,'%s \n', 'Each line contains x and y coordinate pairs. Additional patches are seperated by a line starting with --- ')
fprintf(fid,'%s \n', 'e.g. ')
fprintf(fid,'%s \n', '1 1 .2 2 .12 14 (for the first fault segment, change the static coefficient μs by adding 0.2 using the a-b profile having an additional 0.12 value characterized by a smothing factor of 14 to the following patch area) ')
fprintf(fid,'%s \n', '12 12')
fprintf(fid,'%s \n', '12 2')
fprintf(fid,'%s \n', '10 2')
fprintf(fid,'%s \n', '10 12')
fprintf(fid,'%s \n', 'The above example creates a squared patch. Add more coordinate pairs in order to build a complex area. ')
fprintf(fid,'%s \n', 'Add manual strength fied areas below (starting from line 16)')
fprintf(fid,'%s \n', '--- ')

for i = 1 : 4
    for j = 1 : FaultNumber

        try

            how_ma = [] ;
how_ma = find(~cellfun(@isempty, app.Manual_Strength.sa_1{i,j} )) ; 
for ia = 1 : how_ma(end)
 if ~isempty(app.Manual_Strength.sa_1{i,j}{ia} )
for iaa = 1 : length(app.Manual_Strength.sa_1{i,j}{ia} ) + 1 
    if iaa == length(app.Manual_Strength.sa_1{i,j}{ia} ) + 1  
        fprintf(fid,'%s \n', '--- ') ;
    else
        if iaa == 1
 fprintf(fid,'%s \n', [ num2str(j) '  ' num2str(i) '  '  num2str( app.Manual_Strength.sa_a{i, j }{ ia } ) '  '   num2str( app.Manual_Strength.sa_e{i, j }{ ia } )  '  '  num2str( app.Manual_Strength.sa_eaa{ i , j }{ ia } )  '  '   num2str( app.Manual_Strength.sa_eas{i, j }{ ia } )  ]  )
        end

 fprintf(fid,'%s \n', [  num2str(app.Manual_Strength.sa_1{i, j }{ia}(iaa)) '  '   num2str(app.Manual_Strength.sa_2{i, j }{ia}(iaa)) ]  ) ;

    end

end

end

end

        end

    end

end

fclose(fid)

        end


  function manual_area_asc(  src , evt , app , td )
app.Manual_Strength.eva =  str2num( get( app.Manual_Strength.ed1 , 'string' ) ) ;  ;

  Density         = app.HalfspaceDensity_EditField.Value;
            AddSigN         = app.HalfspaceOverburden_EditField.Value;

set( gcf , 'currenta' , app.Manual_Strength.ha )

      try
[ es_a1,  es_a2 ] = uigetfile('*.*') ; 
cd( es_a2 ) ;
[ app.Strength_Field.fid , app.Strength_Field.msg ] = fopen(  es_a1 , 'rt' ) ;
assert( app.Strength_Field.fid>=3, app.Strength_Field.msg) 
i = 1 ;
while ~feof( app.Strength_Field.fid)
    app.Strength_Field.hdr{i} = fgetl( app.Strength_Field.fid);
i = i + 1 ;
end
fclose(  app.Strength_Field.fid);
ii = 1 ;
for i = 14 : length(app.Strength_Field.hdr )
    try
if strcmp(  app.Strength_Field.hdr{i}(1:3),'---'  )
    app.Strength_Field.lines_add(ii) = i ;
    ii = ii + 1 ;
end
    end
end
ia = 1 ;
for i = 1 : length(  app.Strength_Field.lines_add  )-1
    app.Manual_Strength.atgx =  [ ]  ; app.Manual_Strength.atgy = [  ]  ;
 for ii = app.Strength_Field.lines_add(i)+2 :  app.Strength_Field.lines_add(i+1)-1
   app.Manual_Strength.aaea = [] ;
     app.Manual_Strength.aaea =  split(  app.Strength_Field.hdr{  ii  }  ) ; 
              if ~isempty( str2num( app.Manual_Strength.aaea{1} ) ) , app.Manual_Strength.atgx(ia) = str2num( app.Manual_Strength.aaea{1} ) ;   app.Manual_Strength.atgy(ia) = str2num( app.Manual_Strength.aaea{2} ) ;  else ,  app.Manual_Strength.atgx(ia) = str2num( app.Manual_Strength.aaea{ 2 } ) ;   app.Manual_Strength.atgy(ia) = str2num( app.Manual_Strength.aaea{ 3 } ) ;  end
              ia = ia + 1 ;
 end
 app.Manual_Strength.aaea = [] ;  
 app.Manual_Strength.aaea =  split(   app.Strength_Field.hdr{   app.Strength_Field.lines_add(i)+1  }  ) ;
   if  ~isempty( app.Manual_Strength.aaea{1}  ) , ai = 1 ; else , ai = 2 ; end
 app.Manual_Strength.field1 =  str2num( app.Manual_Strength.aaea{ ai }  ) ;
      app.Manual_Strength.field2 =  str2num( app.Manual_Strength.aaea{ ai+1 }  ) ;
       app.Manual_Strength.field4 =  str2num( app.Manual_Strength.aaea{ ai+2 }  ) ;
       app.Manual_Strength.field6 =  str2num( app.Manual_Strength.aaea{ ai+3 }  )  ;
       app.Manual_Strength.field7 =  str2num( app.Manual_Strength.aaea{ ai+4 }  )  ;
       app.Manual_Strength.field8 =  str2num( app.Manual_Strength.aaea{ ai+5 }  )  ;
       set( app.Manual_Strength2.a2,'value' ,   app.Manual_Strength.field2 ) ;
set( app.Manual_Strength2.a1,'value' ,   app.Manual_Strength.field1 ) ;
app.Manual_Strength.gg= 1 ; app.Manual_Strength.gg=app.Manual_Strength.gg+1;
            app.Manual_Strength3.hpatch = patch( app.Manual_Strength.atgx , app.Manual_Strength.atgy ,'r');
            set( app.Manual_Strength3.hpatch ,'FaceAlpha',.2)
            app.Manual_Strength2.main.vardraw=1;
            app.Manual_Strength3.datetime = datestr(clock);       
         app.Manual_Strength.deletehist = 2 ;
            app.Manual_Strength3.infodetails =  app.Manual_Strength.field4    ;
       [app.Manual_Strength.in,app.Manual_Strength.on] = inpolygon( app.Manual_Strength.X{ get(app.Manual_Strength2.a1,'value') }  ,  app.Manual_Strength.Y{  get(app.Manual_Strength2.a1,'value')  }   ,  app.Manual_Strength.atgx ,  app.Manual_Strength.atgy ) ;
         if  app.Manual_Strength.field6 == 1
      app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}( app.Manual_Strength.in == 1 ) =  app.Manual_Strength3.infodetails  ;
   else 
     si = size( app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}  )
Dep = abs( app.Manual_Strength.Y{ get(app.Manual_Strength2.a1,'value') }( 1 , 1 ) + app.Manual_Strength.Y{ get(app.Manual_Strength2.a1,'value') }( 1 , 1 ) )  ;
Dep = linspace( 0 , -Dep , si(1) ) ;
  MeanAmBseis     = zeros(size(app.StrgthParasPerSectn,1),1);
for ii = 1 : size(app.StrgthParasPerSectn,1)
                AmBshape  = app.StrgthParasPerSectn(ii,9);
                minTemp   = 0;
                maxTemp   = 600;
                TempStps  = 300;
                TempVals  = linspace(minTemp,maxTemp,TempStps) +app.FricGeoThermStartTemp_EditField.Value;
                AmB_Vals  = zeros(size(TempVals));
                
                if     (AmBshape == 1)
                    AmB_Vals = app.AmBparabolic(TempVals);
                elseif (AmBshape == 2)
                    for i = 1 : size(TempVals,2)
                        if     ((TempVals(1,i) >= app.AmB_p1_temp(1,1)) && (TempVals(1,i) <= app.AmB_p1_temp(1,2)))
                            AmB_Vals(1,i) = app.AmB_p1(TempVals(1,i));
                        elseif ((TempVals(1,i) >  app.AmB_p2_temp(1,1)) && (TempVals(1,i) <= app.AmB_p2_temp(1,2)))
                            AmB_Vals(1,i) = app.AmB_p2(TempVals(1,i));
                        elseif ((TempVals(1,i) >  app.AmB_p3_temp(1,1)) && (TempVals(1,i) <= app.AmB_p3_temp(1,2)))
                            AmB_Vals(1,i) = app.AmB_p3(TempVals(1,i));
                        elseif ((TempVals(1,i) >  app.AmB_p4_temp(1,1)) && (TempVals(1,i) <= app.AmB_p4_temp(1,2)))
                            AmB_Vals(1,i) = app.AmB_p4(TempVals(1,i));
                        end
                    end
                end

                NegAmBvals        = AmB_Vals(AmB_Vals< 0);
                MeanAmBseis(ii,1) = mean(NegAmBvals);
            end

DynFric     = app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') ,4); 
DynFricVari = app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') ,5)
 for isa = 1 : si( 1 )
     for isae = 1 : si( 2 )
if   app.Manual_Strength.in( isa , isae ) == 1  
UseAmB      = app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') ,8);      
AmBshape    = app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') ,9);
                Geotherm    = app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') ,10);  
  Depth = Dep( isa )  ;
                TempAtDepth = -Geotherm*Depth +app.FricGeoThermStartTemp_EditField.Value;

                if (UseAmB == 1)
                    if     (AmBshape == 1)
                        AmB_Val = app.AmBparabolic(TempAtDepth);
                        AmB_fact= AmB_Val  / MeanAmBseis( get(app.Manual_Strength2.a1,'value') ,1);
                    elseif (AmBshape == 2)
                        if     ((TempAtDepth >= app.AmB_p1_temp(1,1)) && (TempAtDepth <= app.AmB_p1_temp(1,2))),            AmB_Val = app.AmB_p1(TempAtDepth);
                        elseif ((TempAtDepth >  app.AmB_p2_temp(1,1)) && (TempAtDepth <= app.AmB_p2_temp(1,2))),            AmB_Val = app.AmB_p2(TempAtDepth);
                        elseif ((TempAtDepth >  app.AmB_p3_temp(1,1)) && (TempAtDepth <= app.AmB_p3_temp(1,2))),            AmB_Val = app.AmB_p3(TempAtDepth);
                        elseif ((TempAtDepth >  app.AmB_p4_temp(1,1)) && (TempAtDepth <= app.AmB_p4_temp(1,2))),            AmB_Val = app.AmB_p4(TempAtDepth);
                        end
                        AmB_fact= AmB_Val  /MeanAmBseis(SectionID,1);
                    end
                else
                    AmB_fact = 1;
                end

if  app.Manual_Strength.field6 == 2
    if get(app.Manual_Strength2.a2,'value') == 3
app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}( isa , isae ) =   -(  ((   app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') , 2 )  ) -(  DynFric  )) .*((Density.*app.Gravity.*Depth.*1000)./1E+6 +AddSigN )   * 10 * AmB_fact  )   ;  %  - ( ( app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') , 2 ) -DynFric ) * AmB_fact ) + app.Manual_Strength.eva     ;
    else
app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}( isa , isae ) = - ( ( app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') , 2 ) -DynFric ) * AmB_fact )     ;
    end
    
    elseif  app.Manual_Strength.field6 ==  4

         if get(app.Manual_Strength2.a2,'value') == 3
app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}( isa , isae ) =    -( ((   app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') , 2 )  ) -(  DynFric  )) .*((Density.*app.Gravity.*Depth.*1000)./1E+6 +AddSigN )   * 10 * AmB_fact ) +  app.Manual_Strength.field7  ;  %  - ( ( app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') , 2 ) -DynFric ) * AmB_fact ) + app.Manual_Strength.eva     ;
         else

  app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}( isa , isae ) =  (  (  app.Manual_Strength3.infodetails  - ( (  app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') , 2 ) -DynFric ) * AmB_fact )  ) - app.Manual_Strength3.infodetails  + DynFric*(rand(1)*2-1)*DynFricVari/100  )  +  app.Manual_Strength.field7  ;
         end
         
 end




end
     end
 end
 
         end


         if app.Manual_Strength.field8 ~= 1

                      app.Manual_Strength.smoa = app.Manual_Strength.field8  ;
        app.Manual_Strength.inae = app.Manual_Strength.smoa  ; 
    H = ones( app.Manual_Strength.inae )./( app.Manual_Strength.inae ^ 2 ) ; 

  try
    
    app.Manual_Strength.filteredZ{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}  = filter2(H,app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}  );
   
  catch

         app.Manual_Strength.filteredZ{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}  = app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}   ;
    
  end

else

       app.Manual_Strength.filteredZ{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}  = app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}  ;
    
  end
       
     app.Manual_Strength.hma = app.Manual_Strength.hma + 1 ; app.Manual_Strength.haa = app.Manual_Strength.haa + 1 ;
       app.Manual_Strength.sele(app.Manual_Strength.hma) = 2 ;
             app.Manual_Strength.sa_1{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}{app.Manual_Strength.haa-1} = app.Manual_Strength.atgx ;
        app.Manual_Strength.sa_2{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}{app.Manual_Strength.haa-1} = app.Manual_Strength.atgy  ;
          app.Manual_Strength.sa_a{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}{app.Manual_Strength.haa-1} = app.Manual_Strength3.infodetails ;   
          app.Manual_Strength.sa_e{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}{app.Manual_Strength.haa-1} =  app.Manual_Strength.field6  ;
                    app.Manual_Strength.sa_eaa{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}{app.Manual_Strength.haa-1} =   app.Manual_Strength.field7  ;
       app.Manual_Strength.sa_eas{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}{app.Manual_Strength.haa-1} =  app.Manual_Strength.field8 ;
        
          set_segments( 1 , 2 ,app , 2 )
   app.Manual_Strength.inpo{ get(app.Manual_Strength2.a2,'value') , get(app.Manual_Strength2.a1,'value'), app.Manual_Strength.hma }  =  app.Manual_Strength.in ;
           app.Manual_Strength.gg = app.Manual_Strength.gg + 1;
app.Manual_Strength.atgx = [] ; app.Manual_Strength.atgy = [] ;
ia =  1 ;
app.Manual_Strength.atgx = [] ; app.Manual_Strength.atgy = [] ;
set( app.Manual_Strength.eai , 'visible' , 'off'  )
end

      catch
 app.Strength_Field.h = warndlg('Please try again','ATTENTION') ;
 set( app.Strength_Field.h ,'resize' , 'on' )
 app.Strength_Field = [] ;
             es_a1 = [] ;
      end
 smo2(1 , 2 ,app , 2) 
        end



            
                 function drawpolygon(  src , evt , app , td )
                  
            app.Manual_Strength3 = [] ;

            if td == 2 ,   app.Manual_Strength2.main.cfpos=[];   else  ,  app.Manual_Strength2.main.cfpos=.1;    end
             set(gcf,'Pointer','crosshair') 
             app.Manual_Strength.deletehist = 1;
            app.Manual_Strength.closepolygon = [];
            
             set(gcf,'WindowKeyPressFcn', {@wbd_1_p_fcn , app   } ) 
            if isempty(app.Manual_Strength2.main.vardraw)
            else 
               app.Manual_Strength.gg = 1;
               clear app.Manual_Strength3
               app.Manual_Strength3 = [] ;
            end
            app.Manual_Strength.gg = 1;
            set(gcf,'WindowButtonMotionFcn',...
            {@wbm_1_p_fcn, app   } )
            set(gcf,'WindowButtonDownFcn', {@wbd_1_p_fcn , app  } )
     end


   function draw_all(  src , evt , app , td ) 
app.Manual_Strength.eva =  str2num( get( app.Manual_Strength.ed1 , 'string' ) ) ;
 name = inputdlg('Set Strength Value  ', 'Details', [1 30]);
            namedata = (name{:});
            if isempty(  namedata  )
            app.Strength_Field.h = warndlg('No data provided'  ,  'ATTENTION'  )  ;
            set( app.Strength_Field.h ,'resize' , 'on' ) , return
            else     
            app.Manual_Strength3.infodetails = str2num(  namedata  )  ;
      app.Manual_Strength.deletehist = 2 ;
        if  get(app.Manual_Strength2.ea2 , 'value'  ) == 1
      app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}( :,: ) =  app.Manual_Strength3.infodetails  ;
        else 
     si = size( app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}  )
Dep = abs(  abs( app.Manual_Strength.Y{  get(app.Manual_Strength2.a1,'value') }( 1 , 1 )  ) + app.Manual_Strength.Y{ get(app.Manual_Strength2.a1,'value') }( end , 1 ) )  ;
Dep = linspace( 0 , -Dep , si(1) ) ;
  MeanAmBseis     = zeros(size(app.StrgthParasPerSectn,1),1);
for ii = 1 : size(app.StrgthParasPerSectn,1)
                AmBshape  = app.StrgthParasPerSectn(ii,9);
                minTemp   = 0;
                maxTemp   = 600;
                TempStps  = 300;
                TempVals  = linspace(minTemp,maxTemp,TempStps) +app.FricGeoThermStartTemp_EditField.Value;
                AmB_Vals  = zeros(size(TempVals));
                %-----------------------------------
                if     (AmBshape == 1)
                    AmB_Vals = app.AmBparabolic(TempVals);
                elseif (AmBshape == 2)
                    for i = 1 : size(TempVals,2)
                        if     ((TempVals(1,i) >= app.AmB_p1_temp(1,1)) && (TempVals(1,i) <= app.AmB_p1_temp(1,2)))
                            AmB_Vals(1,i) = app.AmB_p1(TempVals(1,i));
                        elseif ((TempVals(1,i) >  app.AmB_p2_temp(1,1)) && (TempVals(1,i) <= app.AmB_p2_temp(1,2)))
                            AmB_Vals(1,i) = app.AmB_p2(TempVals(1,i));
                        elseif ((TempVals(1,i) >  app.AmB_p3_temp(1,1)) && (TempVals(1,i) <= app.AmB_p3_temp(1,2)))
                            AmB_Vals(1,i) = app.AmB_p3(TempVals(1,i));
                        elseif ((TempVals(1,i) >  app.AmB_p4_temp(1,1)) && (TempVals(1,i) <= app.AmB_p4_temp(1,2)))
                            AmB_Vals(1,i) = app.AmB_p4(TempVals(1,i));
                        end
                    end
                end
                %-----------------------------------
                NegAmBvals        = AmB_Vals(AmB_Vals< 0);
                MeanAmBseis(ii,1) = mean(NegAmBvals);
            end
DynFric     = app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') ,4); 
DynFricVari = app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') ,5)
 for isa = 1 : si( 1 )
     for isae = 1 : si( 2 )
UseAmB      = app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') ,8);      
AmBshape    = app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') ,9);
                Geotherm    = app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') ,10);  
  Depth = Dep( isa )  ;
                TempAtDepth = -Geotherm*Depth +app.FricGeoThermStartTemp_EditField.Value;
                
                if (UseAmB == 1)
                    if     (AmBshape == 1)
                        AmB_Val = app.AmBparabolic(TempAtDepth);
                        AmB_fact= AmB_Val  / MeanAmBseis( get(app.Manual_Strength2.a1,'value') ,1);
                    elseif (AmBshape == 2)
                        if     ((TempAtDepth >= app.AmB_p1_temp(1,1)) && (TempAtDepth <= app.AmB_p1_temp(1,2))),            AmB_Val = app.AmB_p1(TempAtDepth);
                        elseif ((TempAtDepth >  app.AmB_p2_temp(1,1)) && (TempAtDepth <= app.AmB_p2_temp(1,2))),            AmB_Val = app.AmB_p2(TempAtDepth);
                        elseif ((TempAtDepth >  app.AmB_p3_temp(1,1)) && (TempAtDepth <= app.AmB_p3_temp(1,2))),            AmB_Val = app.AmB_p3(TempAtDepth);
                        elseif ((TempAtDepth >  app.AmB_p4_temp(1,1)) && (TempAtDepth <= app.AmB_p4_temp(1,2))),            AmB_Val = app.AmB_p4(TempAtDepth);
                        end
                        AmB_fact= AmB_Val  /MeanAmBseis(SectionID,1);
                    end
                else
                    AmB_fact = 1;
                end
if  get(app.Manual_Strength2.ea3 , 'value'  ) == 1
    if get(app.Manual_Strength2.a2,'value') == 3
app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}( isa , isae ) =    ((   app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') , 2 )  ) -(  DynFric  )) .*((Density.*app.Gravity.*Depth.*1000)./1E+6 +AddSigN )   * 10 * AmB_fact ;  %  - ( ( app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') , 2 ) -DynFric ) * AmB_fact ) + app.Manual_Strength.eva     ;
    else
app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}( isa , isae ) = - ( ( app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') , 2 ) -DynFric ) * AmB_fact )      ;
    end
    
    elseif  get(app.Manual_Strength2.ea4 , 'value'  ) ==  1

         if get(app.Manual_Strength2.a2,'value') == 3
app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}( isa , isae ) =   ( ((   app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') , 2 )  ) -(  DynFric  )) .*((Density.*app.Gravity.*Depth.*1000)./1E+6 +AddSigN )   * 10 * AmB_fact ) + app.Manual_Strength.eva ;  %  - ( ( app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') , 2 ) -DynFric ) * AmB_fact ) + app.Manual_Strength.eva     ;
         else

  app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}( isa , isae ) =  (  (  app.Manual_Strength3.infodetails  - ( (  app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') , 2 ) -DynFric ) * AmB_fact )  ) - app.Manual_Strength3.infodetails  + DynFric*(rand(1)*2-1)*DynFricVari/100  )  + app.Manual_Strength.eva  ;
         end
         
 end
     end
 end
        end


        


if str2num( get(  app.Manual_Strength2.ed1  ,  'str' ) ) ~= 1

                      app.Manual_Strength.smoa = str2num( get(  app.Manual_Strength2.ed1  ,  'str' ) )  ;
        app.Manual_Strength.inae = app.Manual_Strength.smoa  ; 
    H = ones( app.Manual_Strength.inae )./( app.Manual_Strength.inae ^ 2 ) ; 

  try
    
    app.Manual_Strength.filteredZ{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}  = filter2(H,app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}  );
   
  catch

         app.Manual_Strength.filteredZ{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}  = app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}   ;
    
  end

else

       app.Manual_Strength.filteredZ{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}  = app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}  ;
    
  end


   %   app.Manual_Strength.filteredZ{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')} = app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}  ;
  
  app.Manual_Strength.hma = app.Manual_Strength.hma + 1 ;  app.Manual_Strength.haa = app.Manual_Strength.haa + 1 ;
      app.Manual_Strength.sele(app.Manual_Strength.hma) = 2 ;
            app.Manual_Strength.sa_e{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}{app.Manual_Strength.haa-1} =  app.Manual_Strength.agea  ;
                  app.Manual_Strength.sa_eaa{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}{app.Manual_Strength.haa-1} =   app.Manual_Strength.eva ;
       app.Manual_Strength.sa_eas{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}{app.Manual_Strength.haa-1} = str2num(  get(app.Manual_Strength2.ed1,'string')  ) ;
      smo2(1 , 2 ,app , 4  ) 
            app.Manual_Strength.sa_1{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}{app.Manual_Strength.haa-1} = [ app.Manual_Strength.X{ get(app.Manual_Strength2.a1,'value') }(1,1)  app.Manual_Strength.X{ get(app.Manual_Strength2.a1,'value') }(1,1)  app.Manual_Strength.X{ get(app.Manual_Strength2.a1,'value') }(1,end)   app.Manual_Strength.X{ get(app.Manual_Strength2.a1,'value') }(1,end)  ] ;
        app.Manual_Strength.sa_2{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}{app.Manual_Strength.haa-1} = [ app.Manual_Strength.Y{ get(app.Manual_Strength2.a1,'value') }(1,1)  app.Manual_Strength.Y{ get(app.Manual_Strength2.a1,'value') }(end, 1 ) app.Manual_Strength.Y{ get(app.Manual_Strength2.a1,'value') }(end, 1 )  app.Manual_Strength.Y{ get(app.Manual_Strength2.a1,'value') }(1, 1 ) ] ;
          app.Manual_Strength.sa_a{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}{app.Manual_Strength.haa-1} = app.Manual_Strength3.infodetails ;
      
            end
         app.Manual_Strength.inpo{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value'), app.Manual_Strength.hma }  =  logical( ones( size(app.Manual_Strength.X{get(app.Manual_Strength2.a1,'value')}) ) )  ;
          
app.Manual_Strength.select_sta{  get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')  } = ' Plane' ;
   end



 function wbm_1_p_fcn(  a , s , app  )

    set( app.Manual_Strength.eai , 'visible' , 'on'  )
            if ~isempty(app.Manual_Strength2.main.cfpos)
            coord = get(gca,'CurrentPoint');
            if app.Manual_Strength.gg~=1
                set(app.Manual_Strength3.line(app.Manual_Strength.gg-1),'xdata',[app.Manual_Strength3.x(app.Manual_Strength.gg-1) coord(1,1)],'ydata',[app.Manual_Strength3.y(app.Manual_Strength.gg-1) coord(1,2)],'color',[1 0 0])
              if app.Manual_Strength.gg>2
                if coord(1,1) >= app.Manual_Strength3.x(1) - .02 & coord(1,1) <= app.Manual_Strength3.x(1) + .02 & coord(1,2) >= app.Manual_Strength3.y(1) - .02 & coord(1,2) <= app.Manual_Strength3.y(1) + .02
                    set(gcf,'color',[1 0 0])
                    app.Manual_Strength.closepolygon=1;
                else
                    app.Manual_Strength.closepolygon=[];
                end
              end
            end
            else  
            coord = get(gca,'CurrentPoint');
            if app.Manual_Strength.gg~=1
                
                if app.Manual_Strength.gg==2
                        set(app.Manual_Strength3.line(app.Manual_Strength.gg-1),'xdata',[app.Manual_Strength3.x(app.Manual_Strength.gg-1) app.Manual_Strength3.x(app.Manual_Strength.gg-1)],'ydata',[app.Manual_Strength3.y(app.Manual_Strength.gg-1) coord(1,2)],'color',[1 0 0])
                elseif app.Manual_Strength.gg==3
                        set(app.Manual_Strength3.line(app.Manual_Strength.gg-1),'xdata',[app.Manual_Strength3.x(app.Manual_Strength.gg-1) coord(1,1)],'ydata',[app.Manual_Strength3.y(app.Manual_Strength.gg-1) app.Manual_Strength3.y(app.Manual_Strength.gg-1)],'color',[1 0 0])
                elseif app.Manual_Strength.gg==4
                        set(app.Manual_Strength3.line(app.Manual_Strength.gg-1),'xdata',[app.Manual_Strength3.x(app.Manual_Strength.gg-1) app.Manual_Strength3.x(app.Manual_Strength.gg-1)],'ydata',[app.Manual_Strength3.y(app.Manual_Strength.gg-1) coord(1,2)],'color',[1 0 0])
                else
                    app.Manual_Strength.closepolygon=1;
                end
            end  
               if app.Manual_Strength.gg==4
                   app.Manual_Strength.closepolygon=1;
               end
            end
    if coord(1,1)+ abs( ( app.Manual_Strength.Y{    1    ,get(app.Manual_Strength2.a1,'value')}( end ,1) ) - ( app.Manual_Strength.Y{    1    ,get(app.Manual_Strength2.a1,'value')}( 1 ,1) ) )/app.Manual_Strength.a_si(2) > app.Manual_Strength.X{    1    ,get(app.Manual_Strength2.a1,'value')}( 1 , end )
     set( app.Manual_Strength.eai , 'position' , [  coord(1,1)- abs( ( app.Manual_Strength.Y{    1    ,get(app.Manual_Strength2.a1,'value')}( end ,1) ) - ( app.Manual_Strength.Y{    1    ,get(app.Manual_Strength2.a1,'value')}( 1 ,1) ) )/app.Manual_Strength.a_si(4) coord(1,2) ] , 'string' , [ 'X: ' num2str(round( coord(1,1) , 2 ) ) , 10 , 'Y: ' num2str(round( coord(1,2) , 2 ) )  ] ,  'EdgeColor',  [  1 1 1 ]  ,  'Color',  [  1 1 1 ]  ,  'LineWidth',2,'FontSize', app.Manual_Strength.a_si(1)  )     
     else
            set( app.Manual_Strength.eai , 'position' , [  coord(1,1)+ abs( ( app.Manual_Strength.Y{    1    ,get(app.Manual_Strength2.a1,'value')}( end ,1) ) - ( app.Manual_Strength.Y{      1    ,get(app.Manual_Strength2.a1,'value')  }( 1 ,1) ) )/app.Manual_Strength.a_si(3) coord(1,2) ] , 'string' , [ 'X: ' num2str(round( coord(1,1) , 2 ) ) , 10 , 'Y: ' num2str(round( coord(1,2) , 2 ) )  ] ,  'EdgeColor',  [  1 1 1 ]  ,  'Color',  [  1 1 1 ]  ,  'LineWidth',2,'FontSize', app.Manual_Strength.a_si(1)  )    
    end
 end


 function wbd_1_p_fcn( a , b , app   )
app.Manual_Strength.eva =  str2num( get( app.Manual_Strength.ed1 , 'string' ) ) ;
  Density         = app.HalfspaceDensity_EditField.Value;
            AddSigN         = app.HalfspaceOverburden_EditField.Value;
        wdia =    get(gcf,'SelectionType') ;
        if ~strcmp(wdia,'normal') , app.Manual_Strength.closepolygon=.1; end
    coord = get(gca,'CurrentPoint');
    app.Manual_Strength3.x(app.Manual_Strength.gg) = coord(1,1);
    app.Manual_Strength3.y(app.Manual_Strength.gg) = coord(1,2); 
    if app.Manual_Strength.gg==1
        app.Manual_Strength3.line(1) = line([coord(1,1) coord(1,1)],[coord(1,2) coord(1,2)]);
    else
        hold on
        if ~isempty(app.Manual_Strength.closepolygon)
            if ~isempty(app.Manual_Strength2.main.cfpos)
            app.Manual_Strength3.x(app.Manual_Strength.gg) = app.Manual_Strength3.x(1);
            app.Manual_Strength3.y(app.Manual_Strength.gg) = app.Manual_Strength3.y(1); 
            app.Manual_Strength3.line(app.Manual_Strength.gg) = line([app.Manual_Strength3.x(app.Manual_Strength.gg-1) app.Manual_Strength3.x(1)],[app.Manual_Strength3.y(app.Manual_Strength.gg-1) app.Manual_Strength3.y(1)]);
            set(gcf,'WindowButtonMotionFcn','')
            set(gcf,'WindowButtonDownFcn','')
            set(gcf,'WindowKeyPressFcn','')
            delete(app.Manual_Strength3.line(end-1))
            for i = 1 : length(app.Manual_Strength3.line)
              if i~=length(app.Manual_Strength3.line)-1
            delete(app.Manual_Strength3.line(i))
              end
            end
            app.Manual_Strength3.hpatch = patch(app.Manual_Strength3.x,app.Manual_Strength3.y,'r');
            set(app.Manual_Strength3.hpatch,'FaceAlpha',.2)
            app.Manual_Strength2.main.vardraw=1;
            app.Manual_Strength3.datetime = datestr(clock); 
            name = inputdlg('Set Strength Value  ', 'Details', [1 30]);
                try
            namedata = (name{:});
            catch
           namedata = [] ;
            end
            if isempty(  namedata  )
            app.Strength_Field.h = warndlg('No data provided'  ,  'ATTENTION'  )  ;
            set( app.Strength_Field.h ,'resize' , 'on' ) , return
            else     
            app.Manual_Strength3.infodetails = str2num(  namedata  )  ;
      app.Manual_Strength.deletehist = 2 ;
      [app.Manual_Strength.in,app.Manual_Strength.on] = inpolygon( app.Manual_Strength.X{ get(app.Manual_Strength2.a1,'value') }  ,  app.Manual_Strength.Y{  get(app.Manual_Strength2.a1,'value')  }  , app.Manual_Strength3.x, app.Manual_Strength3.y  ) ;
   if  get(app.Manual_Strength2.ea2 , 'value'  ) == 1
      app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}( app.Manual_Strength.in == 1 ) =  app.Manual_Strength3.infodetails  ;
   else 
      
     si = size( app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}  )
Dep = abs(  abs( app.Manual_Strength.Y{  get(app.Manual_Strength2.a1,'value') }( 1 , 1 )  ) + app.Manual_Strength.Y{ get(app.Manual_Strength2.a1,'value') }( end , 1 ) )  ;
Dep = [ linspace( max( app.Fault.RoughCentVals(:,3) ) , -Dep , si(1) ) ] ;  %  linspace(  -Dep/2  ,  0   , si(1)/2 )    ;
  MeanAmBseis     = zeros(size(app.StrgthParasPerSectn,1),1);
for ii = 1 : size(app.StrgthParasPerSectn,1)
                AmBshape  = app.StrgthParasPerSectn(ii,9);
                minTemp   = 0;
                maxTemp   = 600;
                TempStps  = 300;
                TempVals  = linspace(minTemp,maxTemp,TempStps) +app.FricGeoThermStartTemp_EditField.Value;
                AmB_Vals  = zeros(size(TempVals));
                %-----------------------------------
                if     (AmBshape == 1)
                    AmB_Vals = app.AmBparabolic(TempVals);
                elseif (AmBshape == 2)
                    for i = 1 : size(TempVals,2)
                        if     ((TempVals(1,i) >= app.AmB_p1_temp(1,1)) && (TempVals(1,i) <= app.AmB_p1_temp(1,2)))
                            AmB_Vals(1,i) = app.AmB_p1(TempVals(1,i));
                        elseif ((TempVals(1,i) >  app.AmB_p2_temp(1,1)) && (TempVals(1,i) <= app.AmB_p2_temp(1,2)))
                            AmB_Vals(1,i) = app.AmB_p2(TempVals(1,i));
                        elseif ((TempVals(1,i) >  app.AmB_p3_temp(1,1)) && (TempVals(1,i) <= app.AmB_p3_temp(1,2)))
                            AmB_Vals(1,i) = app.AmB_p3(TempVals(1,i));
                        elseif ((TempVals(1,i) >  app.AmB_p4_temp(1,1)) && (TempVals(1,i) <= app.AmB_p4_temp(1,2)))
                            AmB_Vals(1,i) = app.AmB_p4(TempVals(1,i));
                        end
                    end
                end
                %-----------------------------------
                NegAmBvals        = AmB_Vals(AmB_Vals< 0);
                MeanAmBseis(ii,1) = mean(NegAmBvals);
            end

DynFric     = app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') ,4); 
DynFricVari = app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') ,5) ;


curx = zeros(  size(  app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}  )  )  ;

 for isa = 1 : si( 1 )
     for isae = 1 : si( 2 )
if   app.Manual_Strength.in( isa , isae ) == 1  
      curx(isa,isae) = 1 ;
UseAmB      = app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') ,8);      
AmBshape    = app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') ,9);
                Geotherm    = app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') ,10);  
  Depth = Dep( isa )  ;



                TempAtDepth = -Geotherm*Depth +app.FricGeoThermStartTemp_EditField.Value;
                %------------------------------------
                if (UseAmB == 1)
                    if     (AmBshape == 1)
                        AmB_Val = app.AmBparabolic(TempAtDepth);
                        AmB_fact= AmB_Val / MeanAmBseis( get(app.Manual_Strength2.a1,'value') ,1);
                    elseif (AmBshape == 2)
                        if     ((TempAtDepth >= app.AmB_p1_temp(1,1)) && (TempAtDepth <= app.AmB_p1_temp(1,2))),            AmB_Val = app.AmB_p1(TempAtDepth);
                        elseif ((TempAtDepth >  app.AmB_p2_temp(1,1)) && (TempAtDepth <= app.AmB_p2_temp(1,2))),            AmB_Val = app.AmB_p2(TempAtDepth);
                        elseif ((TempAtDepth >  app.AmB_p3_temp(1,1)) && (TempAtDepth <= app.AmB_p3_temp(1,2))),            AmB_Val = app.AmB_p3(TempAtDepth);
                        elseif ((TempAtDepth >  app.AmB_p4_temp(1,1)) && (TempAtDepth <= app.AmB_p4_temp(1,2))),            AmB_Val = app.AmB_p4(TempAtDepth);
                        end
                        AmB_fact= AmB_Val  /MeanAmBseis(SectionID,1);
                    end
                else
                    AmB_fact = 1;
                end
if  get(app.Manual_Strength2.ea3 , 'value'  ) == 1
    if get(app.Manual_Strength2.a2,'value') == 3
        try
app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}( isa , isae ) =    -((   app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') , 2 )  ) -(  DynFric  )) .*((Density.*app.Gravity.*Depth.*1000)./1E+6 +AddSigN )   * 10 * AmB_fact  ;  %  - ( ( app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') , 2 ) -DynFric ) * AmB_fact ) + app.Manual_Strength.eva     ;
  
        catch

            afgaegea = 1 ; 

        end
        
        else
app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}( isa , isae ) = - ( ( app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') , 2 ) -DynFric ) * AmB_fact )      ;
    end
    
    elseif  get(app.Manual_Strength2.ea4 , 'value'  ) ==  1

         if get(app.Manual_Strength2.a2,'value') == 3
app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}( isa , isae ) =   -( ((   app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') , 2 )  ) -(  DynFric  )) .*((Density.*app.Gravity.*Depth.*1000)./1E+6 +AddSigN )   * 10 * AmB_fact  ) + app.Manual_Strength.eva ;  %  - ( ( app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') , 2 ) -DynFric ) * AmB_fact ) + app.Manual_Strength.eva     ;
         else

  app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}( isa , isae ) =  (  (  app.Manual_Strength3.infodetails  - ( (  app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') , 2 ) -DynFric ) * AmB_fact )  ) - app.Manual_Strength3.infodetails  + DynFric*(rand(1)*2-1)*DynFricVari/100  )  + app.Manual_Strength.eva  ;
         end
         
end






end
     end
 end
   end




if str2num( get(  app.Manual_Strength2.ed1  ,  'str' ) ) ~= 1

                      app.Manual_Strength.smoa = str2num( get(  app.Manual_Strength2.ed1  ,  'str' ) )  ;
        app.Manual_Strength.inae = app.Manual_Strength.smoa  ; 
    H = ones( app.Manual_Strength.inae )./( app.Manual_Strength.inae ^ 2 ) ; 

  try
    
    app.Manual_Strength.filteredZ{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}( curx == 1 )  = filter2(H,app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}( curx == 1 )  );
   
  catch

         app.Manual_Strength.filteredZ{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}( app.Manual_Strength.in == 1 )  = app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}( app.Manual_Strength.in == 1 )   ;
    
  end

else

       app.Manual_Strength.filteredZ{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}( app.Manual_Strength.in == 1 )  = app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}( app.Manual_Strength.in == 1 )  ;
    
  end




     app.Manual_Strength.X_pol = app.Manual_Strength.X{ get(app.Manual_Strength2.a1,'value') }(app.Manual_Strength.in==1);
      app.Manual_Strength.Y_pol = app.Manual_Strength.Y{ get(app.Manual_Strength2.a1,'value') }(app.Manual_Strength.in==1);

      app.Manual_Strength.hma = app.Manual_Strength.hma + 1 ;  app.Manual_Strength.haa = app.Manual_Strength.haa + 1 ;
      app.Manual_Strength.sele(app.Manual_Strength.hma) = 2 ;
      smo2(1 , 2 ,app , 2) 
      set( app.Manual_Strength.eai , 'visible' , 'off'  )
      app.Manual_Strength.sa_1{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}{app.Manual_Strength.haa-1} = app.Manual_Strength3.x ;
        app.Manual_Strength.sa_2{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}{app.Manual_Strength.haa-1} = app.Manual_Strength3.y ;
          app.Manual_Strength.sa_a{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}{app.Manual_Strength.haa-1} = app.Manual_Strength3.infodetails ;
            app.Manual_Strength.sa_e{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}{app.Manual_Strength.haa-1} =  app.Manual_Strength.agea  ;
                  app.Manual_Strength.sa_eaa{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}{app.Manual_Strength.haa-1} =   app.Manual_Strength.eva ;
       app.Manual_Strength.sa_eas{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}{app.Manual_Strength.haa-1} = str2num(  get(app.Manual_Strength2.ed1,'string')  ) ;
            end
           s_polygon(app.Manual_Strength.hma).x =  app.Manual_Strength3.x ;
          s_polygon(app.Manual_Strength.hma).y =  app.Manual_Strength3.y ;
           app.Manual_Strength.inpo{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value'), app.Manual_Strength.hma }  =  app.Manual_Strength.in ;
            else
                hold on
                app.Manual_Strength3.line(app.Manual_Strength.gg) = line([app.Manual_Strength3.x(app.Manual_Strength.gg-1) app.Manual_Strength3.x(app.Manual_Strength.gg-1)],[app.Manual_Strength3.y(1) app.Manual_Strength3.y(1)]);
                       set(app.Manual_Strength3.line(app.Manual_Strength.gg),'color',[1 0 0]) 
                       app.Manual_Strength3.x(app.Manual_Strength.gg) = app.Manual_Strength3.x(app.Manual_Strength.gg-1);
                       app.Manual_Strength3.y(app.Manual_Strength.gg) = app.Manual_Strength3.y(1);
                hold on
                app.Manual_Strength.gg=app.Manual_Strength.gg+1;
                app.Manual_Strength3.x(app.Manual_Strength.gg) = app.Manual_Strength3.x(1);
            app.Manual_Strength3.y(app.Manual_Strength.gg) = app.Manual_Strength3.y(1); 
            app.Manual_Strength3.line(app.Manual_Strength.gg) = line([app.Manual_Strength3.x(app.Manual_Strength.gg-1) app.Manual_Strength3.x(1)],[app.Manual_Strength3.y(app.Manual_Strength.gg-1) app.Manual_Strength3.y(1)]);
            set(gcf,'WindowButtonMotionFcn','')
            set(gcf,'WindowButtonDownFcn','')
            set(gcf,'WindowKeyPressFcn','')
            delete(app.Manual_Strength3.line(end-1))
            for i = 1 : length(app.Manual_Strength3.line)
              if i~=length(app.Manual_Strength3.line)-1
            delete(app.Manual_Strength3.line(i))
              end
            end
            app.Manual_Strength3.hpatch = patch(app.Manual_Strength3.x,app.Manual_Strength3.y,'r');
            set( app.Manual_Strength3.hpatch ,'FaceAlpha',.2)
            app.Manual_Strength2.main.vardraw=1;
            app.Manual_Strength3.datetime = datestr(clock);       
         app.Manual_Strength.deletehist = 2 ;
            name = inputdlg('Set Strength Value  ', 'Details', [1 30]);
            try
            namedata = (name{:});
            catch
           namedata = [] ;
            end
            if isempty(  namedata  )  
            app.Strength_Field.h = warndlg('No data provided'  ,  'ATTENTION'  )  ;
            set( app.Strength_Field.h ,'resize' , 'on' ) , return
            else  
            app.Manual_Strength3.infodetails = str2num(  namedata  )  ;
       [app.Manual_Strength.in,app.Manual_Strength.on] = inpolygon( app.Manual_Strength.X{ get(app.Manual_Strength2.a1,'value') }  ,  app.Manual_Strength.Y{  get(app.Manual_Strength2.a1,'value')  }   , app.Manual_Strength3.x,app.Manual_Strength3.y ) ;
         if  get(app.Manual_Strength2.ea2 , 'value'  ) == 1
      app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}( app.Manual_Strength.in == 1 ) =  app.Manual_Strength3.infodetails  ;
   else 
     si = size( app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}  )
Dep = abs(  abs( app.Manual_Strength.Y{  get(app.Manual_Strength2.a1,'value') }( 1 , 1 ) ) + app.Manual_Strength.Y{ get(app.Manual_Strength2.a1,'value') }( end , 1 ) )  ;
Dep = linspace( 0 , -Dep , si(1) ) ;
  MeanAmBseis     = zeros(size(app.StrgthParasPerSectn,1),1);
for ii = 1 : size(app.StrgthParasPerSectn,1)
                AmBshape  = app.StrgthParasPerSectn(ii,9);
                minTemp   = 0;
                maxTemp   = 600;
                TempStps  = 300;
                TempVals  = linspace(minTemp,maxTemp,TempStps) +app.FricGeoThermStartTemp_EditField.Value;
                AmB_Vals  = zeros(size(TempVals));
                %-----------------------------------
                if     (AmBshape == 1)
                    AmB_Vals = app.AmBparabolic(TempVals);
                elseif (AmBshape == 2)
                    for i = 1 : size(TempVals,2)
                        if     ((TempVals(1,i) >= app.AmB_p1_temp(1,1)) && (TempVals(1,i) <= app.AmB_p1_temp(1,2)))
                            AmB_Vals(1,i) = app.AmB_p1(TempVals(1,i));
                        elseif ((TempVals(1,i) >  app.AmB_p2_temp(1,1)) && (TempVals(1,i) <= app.AmB_p2_temp(1,2)))
                            AmB_Vals(1,i) = app.AmB_p2(TempVals(1,i));
                        elseif ((TempVals(1,i) >  app.AmB_p3_temp(1,1)) && (TempVals(1,i) <= app.AmB_p3_temp(1,2)))
                            AmB_Vals(1,i) = app.AmB_p3(TempVals(1,i));
                        elseif ((TempVals(1,i) >  app.AmB_p4_temp(1,1)) && (TempVals(1,i) <= app.AmB_p4_temp(1,2)))
                            AmB_Vals(1,i) = app.AmB_p4(TempVals(1,i));
                        end
                    end
                end
                %-----------------------------------
                NegAmBvals        = AmB_Vals(AmB_Vals< 0);
                MeanAmBseis(ii,1) = mean(NegAmBvals);
            end

DynFric     = app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') ,4); 
DynFricVari = app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') ,5)  ;

curx = zeros(  size(  app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}  )  )  ;

 for isa = 1 : si( 1 )
     for isae = 1 : si( 2 )
if   app.Manual_Strength.in( isa , isae ) == 1  
    curx(isa,isae) = 1 ;
UseAmB      = app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') ,8);      
AmBshape    = app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') ,9);
                Geotherm    = app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') ,10);  
  Depth = Dep( isa )  ;
                TempAtDepth = -Geotherm*Depth +app.FricGeoThermStartTemp_EditField.Value;

                if (UseAmB == 1)
                    if     (AmBshape == 1)
                        AmB_Val = app.AmBparabolic(TempAtDepth);
                        AmB_fact= AmB_Val  / MeanAmBseis( get(app.Manual_Strength2.a1,'value') ,1);
                    elseif (AmBshape == 2)
                        if     ((TempAtDepth >= app.AmB_p1_temp(1,1)) && (TempAtDepth <= app.AmB_p1_temp(1,2))),            AmB_Val = app.AmB_p1(TempAtDepth);
                        elseif ((TempAtDepth >  app.AmB_p2_temp(1,1)) && (TempAtDepth <= app.AmB_p2_temp(1,2))),            AmB_Val = app.AmB_p2(TempAtDepth);
                        elseif ((TempAtDepth >  app.AmB_p3_temp(1,1)) && (TempAtDepth <= app.AmB_p3_temp(1,2))),            AmB_Val = app.AmB_p3(TempAtDepth);
                        elseif ((TempAtDepth >  app.AmB_p4_temp(1,1)) && (TempAtDepth <= app.AmB_p4_temp(1,2))),            AmB_Val = app.AmB_p4(TempAtDepth);
                        end
                        AmB_fact= AmB_Val  /MeanAmBseis(SectionID,1);
                    end
                else
                    AmB_fact = 1;
                end
if  get(app.Manual_Strength2.ea3 , 'value'  ) == 1
    if get(app.Manual_Strength2.a2,'value') == 3
app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}( isa , isae ) =    -((   app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') , 2 )  ) -(  DynFric  )) .*((Density.*app.Gravity.*Depth.*1000)./1E+6 +AddSigN )   * 10 * AmB_fact    ;  %  - ( ( app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') , 2 ) -DynFric ) * AmB_fact ) + app.Manual_Strength.eva     ;
    else
app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}( isa , isae ) = - ( ( app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') , 2 ) -DynFric ) * AmB_fact )      ;
    end
    
    elseif  get(app.Manual_Strength2.ea4 , 'value'  ) ==  1

         if get(app.Manual_Strength2.a2,'value') == 3
app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}( isa , isae ) =   -( ((   app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') , 2 )  ) -(  DynFric  )) .*((Density.*app.Gravity.*Depth.*1000)./1E+6 +AddSigN )   * 10 * AmB_fact ) + app.Manual_Strength.eva ;  %  - ( ( app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') , 2 ) -DynFric ) * AmB_fact ) + app.Manual_Strength.eva     ;
         else

  app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}( isa , isae ) =  (  (  app.Manual_Strength3.infodetails  - ( (  app.StrgthParasPerSectn( get(app.Manual_Strength2.a1,'value') , 2 ) -DynFric ) * AmB_fact )  ) - app.Manual_Strength3.infodetails  + DynFric*(rand(1)*2-1)*DynFricVari/100  )  + app.Manual_Strength.eva  ;
         end
         
end





end
     end
 end
         end


if str2num( get(  app.Manual_Strength2.ed1  ,  'str' ) ) ~= 1

                      app.Manual_Strength.smoa = str2num( get(  app.Manual_Strength2.ed1  ,  'str' ) )  ;
        app.Manual_Strength.inae = app.Manual_Strength.smoa  ; 
    H = ones( app.Manual_Strength.inae )./( app.Manual_Strength.inae ^ 2 ) ; 

  try
    
    app.Manual_Strength.filteredZ{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}( curx == 1 )  = filter2(H,app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}( curx == 1 )  );
   
  catch

         app.Manual_Strength.filteredZ{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}( app.Manual_Strength.in == 1 )  = app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}( app.Manual_Strength.in == 1 )   ;
    
  end

else

       app.Manual_Strength.filteredZ{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}( app.Manual_Strength.in == 1 )  = app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}( app.Manual_Strength.in == 1 ) ;
    
  end

 %   app.Manual_Strength.filteredZ{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')} = app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}  ;
      app.Manual_Strength.hma = app.Manual_Strength.hma + 1 ; app.Manual_Strength.haa = app.Manual_Strength.haa + 1 ;
       app.Manual_Strength.sele(app.Manual_Strength.hma) = 2 ;
       smo2(1 , 2 ,app , 2) 
       set( app.Manual_Strength.eai , 'visible' , 'off'  )
             app.Manual_Strength.sa_1{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}{app.Manual_Strength.haa-1} = app.Manual_Strength3.x ;
        app.Manual_Strength.sa_2{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}{app.Manual_Strength.haa-1} = app.Manual_Strength3.y ;
      app.Manual_Strength.sa_a{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}{app.Manual_Strength.haa-1} = app.Manual_Strength3.infodetails ;
         app.Manual_Strength.sa_e{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}{app.Manual_Strength.haa-1} =  app.Manual_Strength.agea  ;
      app.Manual_Strength.sa_eaa{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}{app.Manual_Strength.haa-1} =   app.Manual_Strength.eva ;
       app.Manual_Strength.sa_eas{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}{app.Manual_Strength.haa-1} = str2num(  get(app.Manual_Strength2.ed1,'string')  ) ;
            end
          s_polygon(app.Manual_Strength.hma).x =  app.Manual_Strength3.x ;
          s_polygon(app.Manual_Strength.hma).y =  app.Manual_Strength3.y ;
           app.Manual_Strength.inpo{ get(app.Manual_Strength2.a2,'value') , get(app.Manual_Strength2.a1,'value'), app.Manual_Strength.hma }  =  app.Manual_Strength.in ;
            end
        else 
            if ~isempty(app.Manual_Strength2.main.cfpos)
            app.Manual_Strength3.line(app.Manual_Strength.gg) = line([app.Manual_Strength3.x(app.Manual_Strength.gg-1) app.Manual_Strength3.x(app.Manual_Strength.gg)],[app.Manual_Strength3.y(app.Manual_Strength.gg-1) app.Manual_Strength3.y(app.Manual_Strength.gg)]);
            set(app.Manual_Strength3.line(app.Manual_Strength.gg),'color',[1 0 0])
            else   
                if app.Manual_Strength.gg ==2
                       app.Manual_Strength3.line(app.Manual_Strength.gg) = line([app.Manual_Strength3.x(app.Manual_Strength.gg-1) app.Manual_Strength3.x(app.Manual_Strength.gg-1)],[app.Manual_Strength3.y(app.Manual_Strength.gg-1) app.Manual_Strength3.y(app.Manual_Strength.gg)]);
                       set(app.Manual_Strength3.line(app.Manual_Strength.gg),'color',[1 0 0]) 
                       app.Manual_Strength3.x(app.Manual_Strength.gg) = app.Manual_Strength3.x(app.Manual_Strength.gg-1);
                       app.Manual_Strength3.y(app.Manual_Strength.gg) = coord(1,2);
                elseif app.Manual_Strength.gg==3
                       app.Manual_Strength3.line(app.Manual_Strength.gg) = line([app.Manual_Strength3.x(app.Manual_Strength.gg-1) app.Manual_Strength3.x(app.Manual_Strength.gg)],[app.Manual_Strength3.y(app.Manual_Strength.gg-1) app.Manual_Strength3.y(app.Manual_Strength.gg-1)]);
                       set(app.Manual_Strength3.line(app.Manual_Strength.gg),'color',[1 0 0])  
                       app.Manual_Strength3.x(app.Manual_Strength.gg) = coord(1,1);
                       app.Manual_Strength3.y(app.Manual_Strength.gg) = app.Manual_Strength3.y(app.Manual_Strength.gg-1);
                else
                        app.Manual_Strength3.line(app.Manual_Strength.gg) = line([app.Manual_Strength3.x(app.Manual_Strength.gg-1) app.Manual_Strength3.x(app.Manual_Strength.gg-1)],[app.Manual_Strength3.y(g1) app.Manual_Strength3.y(1)]);
                       set(app.Manual_Strength3.line(app.Manual_Strength.gg),'color',[1 0 0]) 
                       app.Manual_Strength3.x(app.Manual_Strength.gg) = app.Manual_Strength3.x(app.Manual_Strength.gg-1);
                       app.Manual_Strength3.y(app.Manual_Strength.gg) = app.Manual_Strength3.y(1);
                       app.Manual_Strength.closepolygon = .1;
                app.Manual_Strength3.x(app.Manual_Strength.gg) = app.Manual_Strength3.x(1);
            app.Manual_Strength3.y(app.Manual_Strength.gg) = app.Manual_Strength3.y(1); 
            app.Manual_Strength3.line(app.Manual_Strength.gg) = line([app.Manual_Strength3.x(app.Manual_Strength.gg-1) app.Manual_Strength3.x(1)],[app.Manual_Strength3.y(app.Manual_Strength.gg-1) app.Manual_Strength3.y(1)]);
            set(gcf,'WindowButtonMotionFcn','')
            set(gcf,'WindowButtonDownFcn','')
            set(gcf,'WindowKeyPressFcn','')
            delete(app.Manual_Strength3.line(end-1))
            for i = 1 : length(app.Manual_Strength3.line)
              if i~=length(app.Manual_Strength3.line)-1
            delete(app.Manual_Strength3.line(i))
              end
            end
            app.Manual_Strength3.hpatch = patch(app.Manual_Strength3.x,app.Manual_Strength3.y,'r');
            set(app.Manual_Strength3.hpatch,'FaceAlpha',.2)
            app.Manual_Strength2.main.vardraw=1;
            app.Manual_Strength3.datetime = datestr(clock); 
            datatostore = length(history.data);
            name = inputdlg('Set Strength Value  ', 'Details', [1 30]);
            try
            namedata = (name{:});
            catch
           namedata = [] ;
            end
            if isempty(  namedata  )
              app.Strength_Field.h = warndlg('No data provided'  ,  'ATTENTION'  )  ;
            set( app.Strength_Field.h ,'resize' , 'on' ) , return
            else  
    
            app.Manual_Strength3.infodetails = str2num(  namedata  )  ;esa
       [app.Manual_Strength.in,app.Manual_Strength.on] = inpolygon( app.Manual_Strength.X{ get(app.Manual_Strength2.a1,'value') }  ,  app.Manual_Strength.Y{  get(app.Manual_Strength2.a1,'value')  }   , app.Manual_Strength3.x,app.Manual_Strength3.y ) ;
       app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}( app.Manual_Strength.in == 1 ) =  app.Manual_Strength3.infodetails  ;
       app.Manual_Strength.filteredZ{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')} = app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}  ;
         app.Manual_Strength.filteredZ{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')} = app.Manual_Strength.z{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}  ;
       app.Manual_Strength.sele(app.Manual_Strength.hma) = 2 ;
       smo2(1 , 2 ,app , 2) 
       app.Manual_Strength.inpo{ get(app.Manual_Strength2.a2,'value') , get(app.Manual_Strength2.a1,'value'), app.Manual_Strength.hma }  =  app.Manual_Strength.in ;
    
            end
                end
              
            end
        end
    end
    app.Manual_Strength.gg = app.Manual_Strength.gg + 1;

        end



            function set_segments(a , b , app , td )
           
app.Manual_Strength.ae =  get(app.Manual_Strength2.a1, 'value')  ;
app.Manual_Strength.ae2 =  get(app.Manual_Strength2.a2, 'value')  ;
if td ==1  
    app.Manual_Strength.select_se(app.Manual_Strength.ae , app.Manual_Strength.ae2 ) = 1 ;
    app.Manual_Strength.select_st{app.Manual_Strength.ae , app.Manual_Strength.ae2 } = 'green' ;
else
app.Manual_Strength.select_se(app.Manual_Strength.ae , app.Manual_Strength.ae2 ) = 0 ;
app.Manual_Strength.select_st{app.Manual_Strength.ae , app.Manual_Strength.ae2 } = 'red' ;
end
refre_displa_fields(a , b , app , 2 )
    
            end


 function refre_displa_fields(a , b , app , td )

app.Manual_Strength.ae =  get(app.Manual_Strength2.a1, 'value')  ;
app.Manual_Strength.ae2 =  get(app.Manual_Strength2.a2, 'value')  ;
   set( app.Manual_Strength2.a2  ,  'str', {['<html><FONT color="white" bgcolor="'  app.Manual_Strength.select_st{app.Manual_Strength.ae , 1 }  '" SIZE="10" FACE="ARIAL">μs<html>'],['<html><FONT color="white" bgcolor="'  app.Manual_Strength.select_st{app.Manual_Strength.ae , 2 }  '" SIZE="10" FACE="ARIAL">μD<html>'],['<html><FONT color="white" bgcolor="'  app.Manual_Strength.select_st{app.Manual_Strength.ae , 3 }  '" SIZE="10" FACE="ARIAL">σ<html>'],['<html><FONT color="white" bgcolor="'  app.Manual_Strength.select_st{app.Manual_Strength.ae , 4 }  '" SIZE="10" FACE="ARIAL">Dc<html>']}  ) ;  
ase = size( app.Manual_Strength.select_se  ) ;
hma2  =  0  ;
for i = 1 : ase(1)  ,  for j = 1 : ase(2)  ,  if app.Manual_Strength.select_se(i,j)==1  ,  hma2 = hma2 + 1 ;  end  ,  end  ,  end
set( app.Manual_Strength.ai(12),'str',['Assigned sub-areas: ', num2str(app.Manual_Strength.haa-1) ' | Enabled Fields: ' num2str( hma2 ) ])

 end
            


            function smo(a , b , app , td )
 
           GenerateStrength_ButtonPushed(app, event)
           
        CombinewGridButtonPushed(app, event)        
PlotStrength_ButtonPushed(app, event)  


            end


              function smo2(a , b , app , td )
 
try
set( gcf , 'currenta' , app.Manual_Strength.an2 )
for iae = 1 : length( app.Manual_Strength.aea2 )
 set( app.Manual_Strength.aea2( iae  ) ,'EdgeColor', 'k' )
end
set( app.Manual_Strength.aea2( get(app.Manual_Strength2.a1 ,'value')  ) ,'EdgeColor', 'r' )
end


try

set(  app.Manual_Strength.ed1  ,  'str' , num2str(  app.Manual_Strength.sa_eaa  ) )

set(  app.Manual_Strength2.ed1  ,  'str' , num2str(  app.Manual_Strength.sa_eas  )  )

end

                  set( gcf , 'currenta' , app.Manual_Strength.ha )
           hold off
       app.Manual_Strength.smoa = get(app.Manual_Strength2.ed1,'string');
        app.Manual_Strength.inae = str2num(app.Manual_Strength.smoa)  ; 
    H = ones( app.Manual_Strength.inae )./( app.Manual_Strength.inae ^ 2 ) ; 

    
    app.Manual_Strength.filteredZ{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}  = app.Manual_Strength.filteredZ{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}  ; 
    app.Manual_Strength.a2 = surf( app.Manual_Strength.X{ get(app.Manual_Strength2.a1,'value') }  ,  app.Manual_Strength.Y{  get(app.Manual_Strength2.a1,'value')  }  ,app.Manual_Strength.filteredZ{get(app.Manual_Strength2.a2,'value'),get(app.Manual_Strength2.a1,'value')}  )   ;
     shading interp 
    view( 0 , -90 ) 
   xlabel(' Along Strike (km)','FontSize',app.Manual_Strength.a_si(1),'FontWeight','bold'); 
    ylabel(' Along Dip (km)' ,'FontSize',app.Manual_Strength.a_si(1),'FontWeight','bold'); 
    zlabel('Strength  (A.U.)' ,'FontSize',app.Manual_Strength.a_si(1),'FontWeight','bold');
    ca = colorbar  ;
    ca.Label.String = 'Strength Field '  ;
    ca.FontSize = app.Manual_Strength.a_si(1) ;
    ca.FontWeight = 'bold' ;
    a22.YAxis.FontWeight = 'bold';
    a22.XAxis.FontWeight = 'bold'; 
    a22.ZAxis.FontWeight = 'bold';
    ga.FontSize = app.Manual_Strength.a_si(1) ; 
    ga.FontWeight = 'bold'  ;
  set(gca,'ydir','normal' , 'color' , [ .6 .3 0 ] )
  app.Manual_Strength2.main.h.title = title('Structure of Strength Field - Friction coefficient \mu_{S} and/or \mu_{D} - Stress \sigma in MPa - D_{C} in meters. ') ;
  axis equal
 app.Manual_Strength.aa_si = size(app.Manual_Strength.X{get(app.Manual_Strength2.a1,'value')})  ;
 set( app.Manual_Strength.ai(8),'str',['Current Fault plane ID size: ', num2str(  app.Manual_Strength.aa_si(1)  ) ' X ' num2str(  app.Manual_Strength.aa_si(2)  ) ])
 set( app.Manual_Strength.ai(9),'str',['Number of elements to be fitted: ', num2str(app.Fault.SizeTrigList) ])
ase = size( app.Manual_Strength.select_se  ) ;
hma2  =  0  ;
for i = 1 : ase(1)  ,  for j = 1 : ase(2)  ,  if app.Manual_Strength.select_se(i,j)==1  ,  hma2 = hma2 + 1 ;  end  ,  end  ,  end
set( app.Manual_Strength.ai(12),'str',['Assigned sub-areas: ', num2str(app.Manual_Strength.haa-1) ' | Enabled Fields: ' num2str( hma2 ) ])
 if app.Manual_Strength.how_big(1,3) > 1800 , set(gca,'FontSize',16 , 'FontWeight','b') ; else  ,  set(gca,'FontSize', 8 , 'FontWeight','b')  ;  end
  axis([  app.Manual_Strength.MinStkLngthVal(get(app.Manual_Strength2.a1,'value'))- abs(app.Manual_Strength.X{1,1}(1,end)-app.Manual_Strength.X{1,1}(1,1) )/40 app.Manual_Strength.MaxStkLngthVal(get(app.Manual_Strength2.a1,'value'))+ abs(app.Manual_Strength.X{1,1}(1,end)-app.Manual_Strength.X{1,1}(1,1) )/40  app.Manual_Strength.MinDipLngthVal(get(app.Manual_Strength2.a1,'value'))- abs( ( app.Manual_Strength.Y{1,1}( end ,1) ) - ( app.Manual_Strength.Y{1,1}( 1 ,1) ) )/20  app.Manual_Strength.MaxDipLngthVal(get(app.Manual_Strength2.a1,'value'))+ abs( ( app.Manual_Strength.Y{1,1}( end ,1) ) - ( app.Manual_Strength.Y{1,1}( 1 ,1) ) )/20  ]  )
  app.Manual_Strength.eai = text(1,1,[' ']) ;
  
  set( app.Manual_Strength.eai , 'visible' , 'on'  )
  
 refre_displa_fields(a , b , app , 2 )
          
              end

        
            function  clear_a(a , b , app , td )

                if td == 2 
smo2(1 , 2 ,app , 2)   
for i = 2 : length( app.Manual_Strength.inpo( get(app.Manual_Strength2.a2,'value'), get(app.Manual_Strength2.a1,'value'),:) ) 
    if islogical(  app.Manual_Strength.inpo{ get(app.Manual_Strength2.a2,'value'), get(app.Manual_Strength2.a1,'value'), i }  )
    if   app.Manual_Strength.sele(i) ~= 1
app.Manual_Strength.filteredZ{ get(app.Manual_Strength2.a2,'value'), get(app.Manual_Strength2.a1,'value')}( app.Manual_Strength.inpo{ get(app.Manual_Strength2.a2,'value') , get(app.Manual_Strength2.a1,'value'), i } == 1 ) = 0 ;
app.Manual_Strength.z{ get(app.Manual_Strength2.a2,'value'), get(app.Manual_Strength2.a1,'value')}( app.Manual_Strength.inpo{ get(app.Manual_Strength2.a2,'value') , get(app.Manual_Strength2.a1,'value'), i } == 1 ) = 0 ;
   app.Manual_Strength.haa = app.Manual_Strength.haa - 1 ;
   app.Manual_Strength.sele(i) = 1 ;
   app.Manual_Strength.sa_1{  get(app.Manual_Strength2.a2,'value'), get(app.Manual_Strength2.a1,'value')  }{i-1} = [] ;
    app.Manual_Strength.sa_2{  get(app.Manual_Strength2.a2,'value'), get(app.Manual_Strength2.a1,'value')  }{i-1} = [] ;
     app.Manual_Strength.sa_a{  get(app.Manual_Strength2.a2,'value'), get(app.Manual_Strength2.a1,'value')  }{i-1} = [] ;
    end
    end
end
smo2(1 , 2 ,app , 2) 
                else
[loca_x , loca_y ] = ginput(1) ;
for i = 2 : length( app.Manual_Strength.inpo( get(app.Manual_Strength2.a2,'value'), get(app.Manual_Strength2.a1,'value'),:) ) 
    if ~isempty(  app.Manual_Strength.inpo{ get(app.Manual_Strength2.a2,'value'), get(app.Manual_Strength2.a1,'value'), i }  )
app.Manual_Strength.poa = find(app.Manual_Strength.xn{get(app.Manual_Strength2.a1,'value')}>=round(loca_x)  );
app.Manual_Strength.poaa = find(app.Manual_Strength.yn{get(app.Manual_Strength2.a1,'value')}>=round(loca_y)  );
    if app.Manual_Strength.inpo{ get(app.Manual_Strength2.a2,'value'), get( app.Manual_Strength2.a1,'value'), i }(    app.Manual_Strength.poaa(1) , app.Manual_Strength.poa(1)  )  ==  1 &&  app.Manual_Strength.sele(i) ~= 1
app.Manual_Strength.filteredZ{ get(app.Manual_Strength2.a2,'value'), get(app.Manual_Strength2.a1,'value')}( app.Manual_Strength.inpo{ get(app.Manual_Strength2.a2,'value') , get(app.Manual_Strength2.a1,'value'), i } == 1 ) = 0 ;
app.Manual_Strength.z{ get(app.Manual_Strength2.a2,'value'), get(app.Manual_Strength2.a1,'value')}( app.Manual_Strength.inpo{ get(app.Manual_Strength2.a2,'value') , get(app.Manual_Strength2.a1,'value'), i } == 1 ) = 0 ;
   app.Manual_Strength.haa = app.Manual_Strength.haa - 1 ;
   app.Manual_Strength.sele(i) = 1 ;
      app.Manual_Strength.sa_1{  get(app.Manual_Strength2.a2,'value'), get(app.Manual_Strength2.a1,'value')  }{i-1} = [] ;
    app.Manual_Strength.sa_2{  get(app.Manual_Strength2.a2,'value'), get(app.Manual_Strength2.a1,'value')  }{i-1} = [] ;
     app.Manual_Strength.sa_a{  get(app.Manual_Strength2.a2,'value'), get(app.Manual_Strength2.a1,'value')  }{i-1} = [] ;
    end
    end
end
smo2(1 , 2 ,app , 2) 
                end

            end


        end