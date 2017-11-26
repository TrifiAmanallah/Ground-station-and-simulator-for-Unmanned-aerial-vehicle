function start_GUI()
h=waitbar(0.1,'Inisialisation'); 
global nbr_points_trajectory %variable qui contient le nombre de points dans le trajet
global Html_path %variable qui contient le chemin de la page html a afficher
global browser %variable d'affichage du navigateur
global temporisateur_serial temporisateur_simulator %variable du temporisateur de la lecture 
global test_acquisition_mode %variable pour specifier le mode d'acquisition(serial=true/simulator=false)
global test_debut_acquisition %variable qui contient l'etat de l'acquisition (true=started/false=not started)
%variables acquises a partir des capteurs ou du simulateur
global yaw_simulink pitch_simulink roll_simulink heading_simulink  
global Airspeed_simulink vertical_speed_simulink RPM_simulink
global temperature_simulink pressure_simulink Altitude_simulink
%Inisialisation des variables
test_acquisition_mode=true;%(serial=true/simulator=false)
periode_lecture_serial=1;%periode de lecture serial
periode_lecture_simulator=1;%periode a partir du simulateur
test_debut_acquisition=false; %par defaut l'acquisition n'est pas activé
nbr_points_trajectory=2;
Html_path=[pwd,'\Ressources\google_map\map.html'];
yaw_simulink=0;
pitch_simulink=0;
roll_simulink=0;
Altitude_simulink=0;
Airspeed_simulink=0;
heading_simulink=0;
RPM_simulink=0;
vertical_speed_simulink=0;
temperature_simulink=0;
pressure_simulink=0;

%Charger le modele simulink
close(h);
h=waitbar(0.2,'Loading simulator acquisition serial.mdl');
load_system('simulator_acquisition_serial');
set_param('simulator_acquisition_serial','simulationcommand','stop');
close(h);
h=waitbar(0.3,'Loading simulator model.mdl');
load_system('simulator_model');
set_param('simulator_model','simulationcommand','stop');
set_param('simulator_model/VR_Acquisition_Simulateur','value','0');
set_param('simulator_model/Simulator_Acquisition_Mode','value','2');
close(h);
h=waitbar(0.4,'Loading VR acquisition serial.mdl');
load_system('VR_acquisition_serial');
set_param('VR_acquisition_serial','simulationcommand','stop');
set_param('VR_acquisition_serial/Pitch_from_serial','value',num2str(pitch_simulink));
set_param('VR_acquisition_serial/Roll_from_serial','value',num2str(roll_simulink));
set_param('VR_acquisition_serial/Yaw_from_serial','value',num2str(yaw_simulink));
%Charger les modeles virtual reality
close(h);
h=waitbar(0.5,'Loading WRL files');
 Airplane_3d = vrworld('spitfire_3d.wrl');
 Airplane_3d_pitch = vrworld('spitfire_3d_pitch.wrl');
 Airplane_3d_roll = vrworld('spitfire_3d_roll.wrl');
 Airplane_3d_yaw = vrworld('spitfire_3d_yaw.wrl');
 Cockpit_3d = vrworld('Cockpit_Instruments_VR.wrl');
 
  open(Cockpit_3d);
  open(Airplane_3d);
  open(Airplane_3d_pitch);
  open(Airplane_3d_roll);
  open(Airplane_3d_yaw);

%Construction de la figure principale
Main_figure = figure('Name','Autonomous Navigation System',...
    'MenuBar','none',...
    'NumberTitle','off',...
    'units','normalized',...
    'outerposition',[0 0 1 1],...
    'CloseRequestFcn',@Closing_function);
    
if (ishandle(findobj('Name','Autonomous Navigation System')))     
close(h);
h=waitbar(0.6,'Loading Menu');
%Construction du menu  
Menu_acquisition=uimenu(Main_figure,'Label','Acquisition Mode');
Menu_acquisition_a=uimenu(Menu_acquisition,'Label','From Real hardware','callback',{@Acquisition_mode_Serial,Main_figure});
Menu_acquisition_b=uimenu(Menu_acquisition,'Label','From Simulation Platform','callback',{@Acquisition_mode_Simulator,Main_figure});

Menu_acquisition_status=uimenu(Main_figure,'Label','Acquisition Control');
Menu_acquisition_status_a=uimenu(Menu_acquisition_status,'Label','Start Acquisition','callback',{@start_acquisition,Main_figure});
Menu_acquisition_status_b=uimenu(Menu_acquisition_status,'Label','Stop Acquisition','callback',{@stop_acquisition,Main_figure});

Menu_simulation=uimenu(Main_figure,'Label','Simulator');
Menu_simulation_a=uimenu(Menu_simulation,'Label','Connect To Simulator','callback',{@start_simulator_model,Main_figure});
Menu_simulation_b=uimenu(Menu_simulation,'Label','Disconnect From Simulator','callback',{@stop_simulator_model,Main_figure});

%les tab panels des visualisations
tabgp = uitabgroup(Main_figure,'Position',[[.01 .04 .98 .95]],'Tag','tab_group');
Map_tab = uitab(tabgp,'Title','Coordinates Visualisation');
model_tab = uitab(tabgp,'Title','Gyroscopic Visualisation');
Cockpit_tab = uitab(tabgp,'Title','Cockpit Instruments','BackgroundColor','black');
Virtual_tab = uitab(tabgp,'Title','Virtual Simulation');

%%%%%%%%%%%%%%%%%%%%%%%%%%contenue de la model_tab%%%%%%%%%%%%%%%%%%%%%%%%%
modelPanel = uipanel('Title', 'Tri-dimensional view', 'Parent',model_tab,'Tag','model_3d_panel','Position',[.22 .001 .774 .999]);
model_front_Panel = uipanel('Title', 'Roll angle view', 'Parent',model_tab,'Tag','model_3d_panel_front','Position',[.01 .36 .20 .3]);
model_up_Panel = uipanel('Title', 'Yaw angle view', 'Parent',model_tab,'Tag','model_3d_panel_up','Position',[.01 .01 .20 .3]);
model_left_Panel = uipanel('Title', 'Pitch angle view', 'Parent',model_tab,'Tag','model_3d_panel_left','Position',[.01 .695 .20 .3]);
%%%
close(h);
h=waitbar(0.7,'Loading Gyroscopic Visualisation');
virtualCanvas = vr.canvas(Airplane_3d,findobj('Tag','model_3d_panel'),[.1 .01 1030 620]);
set(virtualCanvas,'Units','normalized');
vrdrawnow;

virtualCanvas_front = vr.canvas(Airplane_3d_roll,findobj('Tag','model_3d_panel_front'),[.1 .1 260 200]);
set(virtualCanvas_front,'Units','normalized')
vrdrawnow;

virtualCanvas_up = vr.canvas(Airplane_3d_yaw,findobj('Tag','model_3d_panel_up'),[.1 .1 260 200]);
set(virtualCanvas_up,'Units','normalized')
vrdrawnow;

virtualCanvas_left = vr.canvas(Airplane_3d_pitch,findobj('Tag','model_3d_panel_left'),[.1 .1 260 200]);
set(virtualCanvas_left,'Units','normalized')
vrdrawnow;
%%%%%%%%%%%%%%%%%%%%%contenue de la Map_tab%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close(h);
h=waitbar(0.8,'Loading Map & browser');
MapPanel = uipanel('Title', 'Flight Plan', 'Parent',Map_tab,'Position',[.28 .02 .7 .95]);
TrajectoryPanel = uipanel('Title', 'Flight Plan settings', 'Parent',Map_tab,'Position',[.01 .367 .25 .60]);
%%%affichage du navigateur
browser = com.mathworks.mlwidgets.html.HTMLBrowserPanel(Html_path);
posPanel = getpixelposition(MapPanel,true);
[webBrowser,browserContainer] = javacomponent(browser,[1,1,max(posPanel(3)-1,1),max(posPanel(4)-1,1)],MapPanel);
set(browserContainer,'Units','normalized');

close(h);
h=waitbar(0.9,'Loading Cockpit Instruments');
%%%%%%%%%%%%%%%%%%%%%contenue de Cockpit_tab%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cockpitPanel = uipanel('Parent',Cockpit_tab,'Tag','cockpit_panel','Position',[.001 .001 .999 .999]);
virtualCanvas = vr.canvas( Cockpit_3d,findobj('Tag','cockpit_panel'),[.1 .01 1350 640]);
set(virtualCanvas,'Units','normalized','Sound','off');
vrdrawnow;
Horizon_display = uipanel('Parent',Cockpit_tab,'Tag','horizon_display_panel','Position',[[.327 .478 .376 .44]],'BackgroundColor','black','ForegroundColor','red');
axes('Parent',findobj('Tag','horizon_display_panel'));
Horizon_display_initialisation;
functionHorizonDisplay(pitch_simulink,roll_simulink,Altitude_simulink,Airspeed_simulink); 
%%%%%%%%%%%%%%%%%%%%Contenue de virtual simulation tab%%%%%%%%%%%%%%%%%%%%%
close(h);
h=waitbar(1,'Loading Simulation Settings');
Run_script_generation = uipanel('Title', 'Run Script Generation', 'Parent',Virtual_tab,'Position',[[.01 .5 .2 .5]]);
simulator_settings = uipanel('Title', 'Simulator Controle methode', 'Parent',Virtual_tab,'Position',[[.01 .01 .2 .48]]);
ControleMethode_buttonGroup = uibuttongroup('Visible','off',...
                  'Parent',simulator_settings ,...
                  'Position',[0 0 1 1],...
                  'SelectionChangedFcn',@Simulator_Controle_method_selection);
joystich_radio = uicontrol(ControleMethode_buttonGroup,'Style',...
                  'radiobutton',...
                  'String','Controle from Joystick',...
                  'Position',[10 250 200 30],...
                  'HandleVisibility','off');
              
autopilot_radio = uicontrol(ControleMethode_buttonGroup,'Style','radiobutton',...
                  'String','Controle from Autopilot Model',...
                  'Position',[10 200 200 30],...
                  'HandleVisibility','on');
hardware_radio = uicontrol(ControleMethode_buttonGroup,'Style','radiobutton',...
                  'String','Simulate Hardware behavior',...
                  'Position',[10 150 200 30],...
                  'HandleVisibility','off');              
ControleMethode_buttonGroup.Visible = 'off';              


%%%%%%%%%%%%%%%%%%%%declarations des boutons%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
button_add_point=uicontrol('Parent',TrajectoryPanel, 'Style', 'pushbutton', 'Position', [12 ,40, 100, 20],'string','ADD point');
set(button_add_point,'callback',{@add_point,TrajectoryPanel});
button_delete_point=uicontrol('Parent',TrajectoryPanel, 'Style', 'pushbutton', 'Position', [121 ,40, 100, 20],'string','DEL point');
set(button_delete_point,'callback',{@delete_point,TrajectoryPanel});
button_update_trajectory=uicontrol('Parent',TrajectoryPanel, 'Style', 'pushbutton', 'Position', [12 ,10, 210, 20],'string','Update trajectory');
set(button_update_trajectory,'callback',{@update_trajectory,TrajectoryPanel});
button_generate_script=uicontrol('Parent',Run_script_generation, 'Style', 'pushbutton', 'Position', [5 ,10, 218, 20],'string','Generate Run Script');
set(button_generate_script,'callback',{@Generate_script,Run_script_generation});

%%%%%%%%%%%%%%%%%%%%%%%%declarations des textes%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Text_longitude=uicontrol('Parent',TrajectoryPanel, 'Style', 'text','String','Longitude','Position', [12 ,320, 100, 20]);
Text_latitude=uicontrol('Parent',TrajectoryPanel, 'Style', 'text','String','Latitude','Position', [121 ,320, 100, 20]);
Text_start=uicontrol('Parent',TrajectoryPanel, 'Style', 'text','String','S:','Position', [1 ,300, 15, 20]);
Text_1=uicontrol('Parent',TrajectoryPanel, 'Style', 'text','String','F:','Tag','Text_point1','Position', [1 ,260, 15, 20]);
Text_2=uicontrol('Parent',TrajectoryPanel, 'Style', 'text','String','1:','Tag','Text_point2','Position', [1 ,220, 15, 20],'visible','off');
Text_3=uicontrol('Parent',TrajectoryPanel, 'Style', 'text','String','2:','Tag','Text_point3','Position', [1 ,180, 15, 20],'visible','off');
Text_4=uicontrol('Parent',TrajectoryPanel, 'Style', 'text','String','2:','Tag','Text_point4','Position', [1 ,140, 15, 20],'visible','off');
Text_temperature=uicontrol('Parent',Cockpit_tab, 'Style', 'text','String','TEMPERATURE:','Tag','Text_temperature','Position', [ 20,573,160, 20],'BackgroundColor','black','FontSize',15,'ForegroundColor','red');
Text_pressure=uicontrol('Parent',Cockpit_tab, 'Style', 'text','String','PRESSURE:','Tag','Text_pressure','Position', [ 1170,573,150, 20],'BackgroundColor','black','FontSize',15,'ForegroundColor','red');
Text_temperature_value=uicontrol('Parent',Cockpit_tab, 'Style', 'text','String','100','Tag','value_temperature','Position', [50,553,70, 20],'BackgroundColor','black','FontSize',15,'ForegroundColor','red');
Text_pressure_value=uicontrol('Parent',Cockpit_tab, 'Style', 'text','String','500','Tag','value_pressure','Position', [ 1220,553,70, 20],'BackgroundColor','black','FontSize',15,'ForegroundColor','red');
Text_output_file=uicontrol('Parent',Run_script_generation, 'Style', 'text','String','Output File Name:','Position', [.1 ,260, 100, 20]);
Text_BaseDirectory=uicontrol('Parent',Run_script_generation, 'Style', 'text','String','Simulator Directory:','Position', [.1 ,220, 110, 20]);
Text_GeometryModelName=uicontrol('Parent',Run_script_generation, 'Style', 'text','String','Airplane Name:','Position', [.1 ,180, 100, 20]);
Text_AirportId=uicontrol('Parent',Run_script_generation, 'Style', 'text','String','Airport ID:','Position', [.1 ,140, 100, 20]);
Text_RunwayId=uicontrol('Parent',Run_script_generation, 'Style', 'text','String','Runway ID:','Position', [.1 ,100, 100, 20]);
Text_Architecture=uicontrol('Parent',Run_script_generation, 'Style', 'text','String','Architecture:','Position', [.1 ,60, 100, 20]);
Text_DestinationIpAddress=uicontrol('Parent',Run_script_generation, 'Style', 'text','String','Destination Ip Address:','Position', [110 ,260, 130, 20]);
Text_DestinationPort=uicontrol('Parent',Run_script_generation, 'Style', 'text','String','Destination Port:','Position', [120 ,220, 100, 20]);
Text_InitialAltitude=uicontrol('Parent',Run_script_generation, 'Style', 'text','String','Initial Altitude:','Position', [120 ,180, 100, 20]);
Text_InitialHeading=uicontrol('Parent',Run_script_generation, 'Style', 'text','String','Initial Heading:','Position', [120 ,140, 100, 20]);
Text_OffsetDistance=uicontrol('Parent',Run_script_generation, 'Style', 'text','String','Offset Distance:','Position',  [120 ,100, 100, 20]);
Text_OffsetAzimuth=uicontrol('Parent',Run_script_generation, 'Style', 'text','String','Offset Azimuth:','Position', [120 ,60, 100, 20]);


%%%%%%%%%%%%%%%%%%%%%%%%%declarations des EditTextes%%%%%%%%%%%%%%%%%%%%%%%
Longitude1=uicontrol('Parent',TrajectoryPanel, 'Style', 'edit','Tag','Longitude1', 'Position', [15 ,300, 100, 20],'String','10.063206');
Latitude1=uicontrol('Parent',TrajectoryPanel, 'Style', 'edit','Tag','Latitude1', 'Position', [121 ,300, 100, 20],'String','36.815543');
Longitude2=uicontrol('Parent',TrajectoryPanel, 'Style', 'edit','Tag','Longitude2','Position', [15 ,260, 100, 20],'String','10.063933');
Latitude2=uicontrol('Parent',TrajectoryPanel, 'Style', 'edit','Tag','Latitude2', 'Position', [121 ,260, 100, 20],'String','36.816087');
Longitude3=uicontrol('Parent',TrajectoryPanel, 'Style', 'edit','Tag','Longitude3', 'Position', [15 ,220, 100, 20],'visible','off');
Latitude3=uicontrol('Parent',TrajectoryPanel, 'Style', 'edit','Tag','Latitude3', 'Position', [121 ,220, 100, 20],'visible','off');
Longitude4=uicontrol('Parent',TrajectoryPanel, 'Style', 'edit','Tag','Longitude4', 'Position', [15 ,180, 100, 20],'visible','off');
Latitude4=uicontrol('Parent',TrajectoryPanel, 'Style', 'edit','Tag','Latitude4', 'Position', [121 ,180, 100, 20],'visible','off');
Longitude5=uicontrol('Parent',TrajectoryPanel, 'Style', 'edit','Tag','Longitude5', 'Position', [15 ,140, 100, 20],'visible','off');
Latitude5=uicontrol('Parent',TrajectoryPanel, 'Style', 'edit','Tag','Latitude5', 'Position', [121 ,140, 100, 20],'visible','off');
output_file_name=uicontrol('Parent',Run_script_generation, 'Style', 'edit','Tag','output_file_name','String','Run.bat','Position', [6 ,240, 100, 20]);
output_BaseDirectory=uicontrol('Parent',Run_script_generation, 'Style', 'edit','Tag','BaseDirectory','String','C:\Program Files\FlightGear','Position', [6 ,200, 100, 20]);
output_GeometryModelName=uicontrol('Parent',Run_script_generation, 'Style', 'edit','Tag','GeometryModelName','String','spitfireIIa','Position', [6 ,160, 100, 20]);
output_AirportId=uicontrol('Parent',Run_script_generation, 'Style', 'edit','Tag','AirportId','String','KSFO','Position', [6 ,120, 100, 20]);
output_RunwayId=uicontrol('Parent',Run_script_generation, 'Style', 'edit','Tag','RunwayId','String','10L','Position', [6 ,80, 100, 20]);
output_Architecture=uicontrol('Parent',Run_script_generation, 'Style', 'edit','Tag','Architecture','String','Win64','Position', [6 ,40, 100, 20]);
output_DestinationIpAddress=uicontrol('Parent',Run_script_generation, 'Style', 'edit','Tag','DestinationIpAddress','String','127.0.0.1','Position', [120 ,240, 100, 20]);
output_DestinationPort=uicontrol('Parent',Run_script_generation, 'Style', 'edit','Tag','DestinationPort','String','5502','Position', [120 ,200, 100, 20]);
output_InitialAltitude=uicontrol('Parent',Run_script_generation, 'Style', 'edit','Tag','InitialAltitude','String','7224','Position',[120 ,160, 100, 20]);
output_InitialHeading=uicontrol('Parent',Run_script_generation, 'Style', 'edit','Tag','InitialHeading','String','113','Position', [120 ,120, 100, 20]);
output_OffsetDistance=uicontrol('Parent',Run_script_generation, 'Style', 'edit','Tag','OffsetDistance','String','4.72','Position', [120 ,80, 100, 20]);
output_OffsetAzimuth=uicontrol('Parent',Run_script_generation, 'Style', 'edit','Tag','OffsetAzimuth','String','0','Position', [120 ,40, 100, 20]);


%%%%%%%%%%%%%%%%%%%%%%definition de la frequence de lecture%%%%%%%%%%%%%%%%
temporisateur_serial = timer('ExecutionMode', 'FixedRate', ...
    'Period',periode_lecture_serial, ...
    'TimerFcn', {@UpdateFromSerialCallback});
temporisateur_simulator = timer('ExecutionMode', 'FixedRate', ...
    'Period',periode_lecture_simulator, ...
    'TimerFcn', {@UpdateFromSimulator});
close(h);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

%%%%%%%%%%%%%%%%%%%%%Definitions des Callbacks%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateFromSerialCallback(hObj, eventdata)
global test_acquisition_mode test_debut_acquisition
global yaw_simulink pitch_simulink roll_simulink heading_simulink  
global Airspeed_simulink vertical_speed_simulink RPM_simulink
global temperature_simulink pressure_simulink Altitude_simulink

    %%%%Acquisition a partir du port serial%%%
if test_debut_acquisition     


if (ishandle(findobj('Name','Autonomous Navigation System')))     
%%%%%%%%%%%%%%%Mise a jour de l'interface%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Update VR models display
status = get_param('VR_acquisition_serial','simulationstatus');
 if strcmp(status,'running')
     try
set_param('VR_acquisition_serial/Pitch_from_serial','value',num2str(pitch_simulink));
set_param('VR_acquisition_serial/Roll_from_serial','value',num2str(roll_simulink));
set_param('VR_acquisition_serial/Yaw_from_serial','value',num2str(yaw_simulink));
     catch 
     end 
 end
%%%Update Simulator display
status = get_param('simulator_model','simulationstatus');
 if strcmp(status,'running')
     try
     set_param('simulator_model/Hardware_controller/Pitch_from_serial','value',num2str(pitch_simulink));
     set_param('simulator_model/Hardware_controller/Roll_from_serial','value',num2str(roll_simulink));
     set_param('simulator_model/Hardware_controller/Yaw_from_serial','value',num2str(yaw_simulink));
     catch 
     end 
 end


%Update Cockpit
  %%%Update Horizon_display
axes('Parent',findobj('Tag','horizon_display_panel'));
Horizon_display_initialisation;
functionHorizonDisplay(pitch_simulink,roll_simulink,Altitude_simulink,Airspeed_simulink);
%Update Numeric Values
set(findobj('Tag','value_temperature'),'String',num2str(temperature_simulink));
set(findobj('Tag','value_pressure'),'String',num2str(pressure_simulink));


end;
if pitch_simulink==0
pitch_simulink=input('saisir une valeur (pitch=roll=yaw):');
yaw_simulink=pitch_simulink; 
roll_simulink=pitch_simulink;
%%%........
end
end


end
function UpdateFromSimulator(hObj, eventdata)

end

%%%
function start_acquisition(hObject, varargin)
global temporisateur_serial temporisateur_simulator test_acquisition_mode test_debut_acquisition
if test_debut_acquisition
    if test_acquisition_mode
    msgbox('Acquisition already started (From Serial Port)');
    else
    msgbox('Acquisition already started (From Simulator');    
    end
else
if test_acquisition_mode
 selection = questdlg('Start Acquisition from Serial Port ?',...
      'Starting Acquisition',...
      'Yes','No','No'); 
   switch selection, 
      case 'Yes',
          set_param('VR_acquisition_serial','simulationcommand','start');
          start(temporisateur_serial);
          test_debut_acquisition=false;
          try
              stop(temporisateur_simulator);
          catch
          end
         test_debut_acquisition=true;
      case 'No'
      return 
   end   

else
 selection = questdlg('Start Acquisition from Simulator ?',...
      'Starting Acquisition',...
      'Yes','No','No'); 
   switch selection, 
      case 'Yes',
         try
          status = get_param('simulator_model','simulationstatus');
          if strcmp(status,'stopped')
          msgbox('You are not connected to simulator');
          else
         start(temporisateur_simulator);
         test_debut_acquisition=false;
         try
              stop(temporisateur_serial);
         catch
         end
         test_debut_acquisition=true;
             
         end
          set_param('simulator_model/VR_Acquisition_Simulateur','value','1');
          catch msgbox('An error occured in simulator_model.mdl');
         end
      case 'No'
      return 
   end   
   
end

end
end
%%%
function stop_acquisition(hObject, varargin)
global temporisateur_serial temporisateur_simulator test_acquisition_mode test_debut_acquisition
if ~test_debut_acquisition
 if test_acquisition_mode
    msgbox('Acquisition already stopped (From Serial Port)');
    else
    msgbox('Acquisition already stopped (From Simulator');    
 end
else 
if test_acquisition_mode
 selection = questdlg('Stop Acquisition from Serial Port ?',...
      'Stopping Acquisition',...
      'Yes','No','No'); 
   switch selection, 
      case 'Yes',
         stop(temporisateur_serial);
         test_debut_acquisition=false;
         try
         set_param('VR_acquisition_serial','simulationcommand','stop');
         catch
         end    
      case 'No'
      return 
   end   

else
 selection = questdlg('Stop Acquisition from Simulator ?',...
      'Stopping Acquisition',...
      'Yes','No','No'); 
   switch selection, 
      case 'Yes',
         stop(temporisateur_simulator);
         test_debut_acquisition=false;
         try
         set_param('simulator_model','simulationcommand','stop');
         catch
         end    
      case 'No'
      return 
   end   
   
end

end
end
%%%
function Acquisition_mode_Serial (hObject, varargin)
global temporisateur_serial temporisateur_simulator test_acquisition_mode test_debut_acquisition
test_acquisition_mode=true;
 try
 set_param('simulator_model','simulationcommand','stop');    
 set_param('simulator_model/VR_Acquisition_Simulateur','value','0');
 catch  
 end
 if test_debut_acquisition
 try
 test_debut_acquisition=false;
 stop(temporisateur_simulator);
 start(temporisateur_serial)
 test_debut_acquisition=true;
 set_param('VR_acquisition_serial','simulationcommand','start');
 catch
 end
 end
         
end
%%%
function Acquisition_mode_Simulator (hObject, varargin)
global temporisateur_serial temporisateur_simulator test_acquisition_mode test_debut_acquisition
test_acquisition_mode=false;
try
 set_param('VR_acquisition_serial','simulationcommand','stop');
 
 catch  
end
 if test_debut_acquisition
 try
 test_debut_acquisition=false;
 stop(temporisateur_serial);
 start(temporisateur_simulator)
 test_debut_acquisition=true;
 set_param('simulator_model','simulationcommand','start');
 set_param('simulator_model/VR_Acquisition_Simulateur','value','1');
 catch msgbox('Unable to switch mode');
       test_debut_acquisition=false;
       stop(temporisateur_simulator);
 end
 end
end
%%%
function start_simulator_model(hObject, varargin)

selection = questdlg('Connect to simulator ?',...
      'Simulator',...
      'Yes','No','No'); 
   switch selection, 
    case 'Yes',
        try
          status = get_param('simulator_model','simulationstatus');
          if strcmp(status,'stopped')
          set_param('simulator_model','simulationcommand','start');
          set_param('simulator_model/VR_Acquisition_Simulateur','value','0');
          end 
        catch msgbox('Unable to run: simulator_model.mdl');   
        end
    case 'No'
      return 
    end
 

end
%%%
function stop_simulator_model(hObject, varargin)
   selection = questdlg('Disconnect from simulator ?',...
      'Simulator',...
      'Yes','No','No'); 
  switch selection, 
    case 'Yes',
        try
        status = get_param('simulator_model','simulationstatus');
           if strcmp(status,'running')
           set_param('simulator_model','simulationcommand','stop');
           msgbox('Disconnected Succefully');    
           else msgbox('You are already disconnected from simulator');
           end 
        catch msgbox('simulator_model.mdl is not loaded in memory');    
        end
    case 'No'
      return 
  end   

end
%%%
function Simulator_Controle_method_selection(source,callbackdata)
 status = get_param('simulator_model','simulationstatus');
 if strcmp(status,'running')
       if strcmp(callbackdata.NewValue.String,'Controle from Joystick')
       set_param('simulator_model/Simulator_Acquisition_Mode','value','1');
      else if strcmp(callbackdata.NewValue.String,'Controle from Autopilot Model')
       set_param('simulator_model/Simulator_Acquisition_Mode','value','2');  
          else
       set_param('simulator_model','simulationcommand','stop');
       set_param('simulator_acquisition_serial','simulationcommand','start');
          end   
       end
 else
     status = get_param('simulator_acquisition_serial','simulationstatus');
     if strcmp(status,'running')
     if strcmp(callbackdata.NewValue.String,'Controle from Joystick')
       set_param('simulator_acquisition_serial','simulationcommand','stop');
       set_param('simulator_model','simulationcommand','start');  
       set_param('simulator_model/Simulator_Acquisition_Mode','value','1');
      else if strcmp(callbackdata.NewValue.String,'Controle from Autopilot Model')
       set_param('simulator_acquisition_serial','simulationcommand','stop');
       set_param('simulator_model','simulationcommand','start');         
       set_param('simulator_model/Simulator_Acquisition_Mode','value','2');  
          else
       set_param('simulator_model','simulationcommand','stop');
       set_param('simulator_acquisition_serial','simulationcommand','start');
          end   
       end    
     end
 end
end
function Closing_function(src,callbackdata)
% Close request function 
% to display a question dialog box
   global temporisateur_simulator temporisateur_serial
   selection = questdlg('Please Confirm',...
      'Close Request Function',...
      'Yes','No','Yes'); 
   switch selection, 
      case 'Yes',
         delete(gcf);
         vrclear('-force')
         clear all;
         try
         stop(temporisateur_simulator);
         stop(temporisateur_serial);
         bdclose('all');
         catch
             
         end;
      case 'No'
      return 
   end
end
function Generate_script(hObject, varargin)
 h = fganimation 
 try
 h.OutputFileName=get(findobj('Tag','output_file_name'),'String');
 h.FlightGearBaseDirectory=get(findobj('Tag','BaseDirectory'),'String');
 h.GeometryModelName=get(findobj('Tag','GeometryModelName'),'String');
 h.DestinationIpAddress=get(findobj('Tag','DestinationIpAddress'),'String');
 h.DestinationPort=get(findobj('Tag','DestinationPort'),'String');
 h.AirportId=get(findobj('Tag','AirportId'),'String');
 h.RunwayId=get(findobj('Tag','RunwayId'),'String');
 h.InitialAltitude=str2num(get(findobj('Tag','InitialAltitude'),'String'));
 h.InitialHeading=str2num(get(findobj('Tag','InitialHeading'),'String'));
 h.OffsetDistance=str2num(get(findobj('Tag','OffsetDistance'),'String'));
 h.OffsetAzimuth=str2num(get(findobj('Tag','OffsetAzimuth'),'String'));
 h.Architecture=get(findobj('Tag','Architecture'),'String');
 GenerateRunScript(h);
 msgbox('Generation Successful');
 catch
 msgbox('An error occured during generation');    
 end;
end    
function add_point(hObject, varargin)

global nbr_points_trajectory
switch nbr_points_trajectory
   case 2
   set(findobj('Tag','Longitude3'),'visible','on');
   set(findobj('Tag','Latitude3'),'visible','on');  
   set(findobj('Tag','Text_point1'),'String','1:');
   set(findobj('Tag','Text_point2'),'String','F:','visible','on');
   nbr_points_trajectory=nbr_points_trajectory+1;
   case 3
   set(findobj('Tag','Longitude4'),'visible','on');
   set(findobj('Tag','Latitude4'),'visible','on');
   set(findobj('Tag','Text_point2'),'String','2:');
   set(findobj('Tag','Text_point3'),'String','F:','visible','on');
   nbr_points_trajectory=nbr_points_trajectory+1;
   case 4
   set(findobj('Tag','Longitude5'),'visible','on');
   set(findobj('Tag','Latitude5'),'visible','on');
   set(findobj('Tag','Text_point3'),'String','3:');
   set(findobj('Tag','Text_point4'),'String','F:','visible','on');
   nbr_points_trajectory=nbr_points_trajectory+1;
   otherwise
   msgbox('You have reached maximum of points');
end       
end
function delete_point(hObject, varargin)

global nbr_points_trajectory
switch nbr_points_trajectory
   case 2
   msgbox('You need at least two points');
   case 3
   set(findobj('Tag','Longitude3'),'visible','off');
   set(findobj('Tag','Latitude3'),'visible','of');  
   set(findobj('Tag','Text_point1'),'String','F:');
   set(findobj('Tag','Text_point2'),'visible','off');
   nbr_points_trajectory=nbr_points_trajectory-1;
   case 4
   set(findobj('Tag','Longitude4'),'visible','off');
   set(findobj('Tag','Latitude4'),'visible','off');
   set(findobj('Tag','Text_point2'),'String','F:');
   set(findobj('Tag','Text_point3'),'visible','off');
   nbr_points_trajectory=nbr_points_trajectory-1;
   case 5
   set(findobj('Tag','Longitude5'),'visible','off');
   set(findobj('Tag','Latitude5'),'visible','off');
   set(findobj('Tag','Text_point3'),'String','F:');
   set(findobj('Tag','Text_point4'),'visible','off');
   nbr_points_trajectory=nbr_points_trajectory-1;
   end       
end
function update_trajectory(hObject, varargin)
global browser Html_path nbr_points_trajectory
global next_point_longitude next_point_latitude
Longitude1= get(findobj('Tag','Longitude1'),'String');
Latitude1= get(findobj('Tag','Latitude1'),'String');
Longitude2= get(findobj('Tag','Longitude2'),'String');
Latitude2= get(findobj('Tag','Latitude2'),'String');
Longitude3= get(findobj('Tag','Longitude3'),'String');
Latitude3= get(findobj('Tag','Latitude3'),'String');
Longitude4= get(findobj('Tag','Longitude4'),'String');
Latitude4= get(findobj('Tag','Latitude4'),'String');
Longitude5= get(findobj('Tag','Longitude5'),'String');
Latitude5= get(findobj('Tag','Latitude5'),'String');
next_point_longitude=str2num(Longitude1);
next_point_latitude=str2num(Latitude1);
Longitude_data={Longitude1 ; Longitude2 ; Longitude3 ; Longitude4 ; Longitude5};
Latitude_data ={Latitude1 ; Latitude2 ; Latitude3 ; Latitude4 ; Latitude5};
Longitude_vector=cellstr(Longitude_data);
Latitude_vector=cellstr(Latitude_data);
trajectory='';
for i=1:nbr_points_trajectory
    trajectory=strcat(trajectory,'new google.maps.LatLng(',Latitude_vector{i},',',Longitude_vector{i},'),\r\n');
end
fileID = fopen(Html_path,'w');
fprintf(fileID,['<!DOCTYPE html>\r\n',...
'<html>\r\n',...
  '<head>\r\n',...
    '<meta name="viewport" content="initial-scale=1.0, user-scalable=no">\r\n',...
    '<meta charset="utf-8">\r\n',...
    '<title>Simple Polylines</title>\r\n',...
    '<style> \r\n',...
      'html, body, #map-canvas {\r\n',...
        'height: 100%%;\r\n',...
        'margin: 0px;\r\n',...
        'padding: 0px\r\n',...
      '}\r\n',...
   ' </style>\r\n',...
    '<script src="https://maps.googleapis.com/maps/api/js?v=3.exp&signed_in=true"></script>\r\n',...
    '<script>\r\n',...
'var flightPath;\r\n',...
'function initialize() {\r\n',...
  'var mapOptions = {\r\n',...
    'zoom: 20,\r\n',...
    'center: new google.maps.LatLng(',Latitude_vector{1},',',Longitude_vector{1},'),\r\n',...
    'mapTypeId: google.maps.MapTypeId.SATELLITE\r\n',...
  '};\r\n',...
  'var map = new google.maps.Map(document.getElementById(''map-canvas''),\r\n',...
      'mapOptions);\r\n',...
  'var flightPlanCoordinates = [\r\n',...
    trajectory,...
  '];\r\n',...
  ' var flightPathSymbol = {\r\n',...
  'path: google.maps.SymbolPath.FORWARD_CLOSED_ARROW,\r\n',...
  'scale: 4,\r\n',...
  'strokeColor: ''#b23aee''\r\n',...
  ' };\r\n',...
  '///drawing flight Plan\r\n',...
 ' flightPath = new google.maps.Polyline({\r\n',...
    'path: flightPlanCoordinates,\r\n',...
    'icons: [{\r\n',...
    ' icon: flightPathSymbol,\r\n',...
    'offset: ''100%%''\r\n',...
    '  }],\r\n',...
    'geodesic: true,\r\n',...
    'strokeColor: ''#ff1493'',\r\n',...
    'strokeOpacity: 1.0,\r\n',...
    'strokeWeight: 2\r\n',...
  '});\r\n',...
  'flightPath.setMap(map);\r\n',...
  ' animateCircle();\r\n',...
  '///Markers:\r\n',...
  'var startLatlng = new google.maps.LatLng(',Latitude_vector{1},',',Longitude_vector{1},');\r\n',...
  'var image = ''start.png'';\r\n',...
  'var marker = new google.maps.Marker({\r\n',...
  'position: startLatlng,\r\n',...
  'map: map,\r\n',...
  'icon: image,\r\n',...
  'title: ''Start point''\r\n',...
  '  });\r\n',...
  'var finishLatlng = new google.maps.LatLng(',Latitude_vector{i},',',Longitude_vector{i},');\r\n',...
  'var image = ''finish.png'';\r\n',...
  'var marker = new google.maps.Marker({\r\n',...
  'position: finishLatlng,\r\n',...
  'map: map,\r\n',...
  'icon: image,\r\n',...
  'title: ''finish point''\r\n',...
  '  });\r\n',... 
'}\r\n',...
'///Line animation\r\n',...
'function animateCircle() {\r\n',...
' var count = 0;\r\n',...
'window.setInterval(function() {\r\n',...
'count = (count + 1) %% 200;\r\n',...
' var icons = flightPath.get(''icons'');\r\n',...
'icons[0].offset = (count / 2) + ''%%'';\r\n',...
'flightPath.set(''icons'', icons);\r\n',...
' }, 20);}\r\n',...
'google.maps.event.addDomListener(window,''load'', initialize);\r\n',...
    '</script>\r\n',...
  '</head>\r\n',...
  '<body>\r\n',...
   ' <div id="map-canvas"></div>\r\n',...
 ' </body>\r\n',...
'</html>']);
 fclose(fileID);
   browser.setCurrentLocation(Html_path);
end