                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    % Simple Reaction Time Program
% Simple Reaction Time 
% This program does the following:

% 1. Looks for additional display monitor and if there is any , the program
% sets that screen to be the Participant Display and in case there is no
% additonal monitor attached. Then the current screen will be used as the
% participant display.
% The program calls different fucntion and all functions have meaningful
%                          
% names and should be clear from the name of the function of what it is
% doing.
% 2. Displays a filled circle on the participant screen and waits for the
% user to press the button and then collects data from the EMG sensor.
% 3. The process repeats till the number of trails are are executed.
% 4. Saves the sensor data as an excel sheet with name %RAWEMG.xls for
% practice and test trials.
% 5. ProcessTimeCalculation does the post experiment data processing whihc
% involves time calculation , genearation of plots for all trials.
% 6. SaveAllFig4Me saves all the plots generated in a sub-directory under 
% the output folder.

% Some of the controls have been provided to the user by setting a 
% parameter to a boolean value . Setting the value to 1 will enable the corresponding
% function and setting it to 0 will disable it. For ex : The create file
% variable is initially set to 1 . This will result in creating a processed
% file where the variables like PMT MT and RT are calculated and displayed
% in the command window. Other such variables can be easily located in the
% program as they have a comment next to them , stating the change the of
% state of the variable and corresponding action.

% The program has been divided into section, where the title of the section
% briefly explains what that particular block of code will be doing . 

% For ex: The section with title " Looking for additional Display" will
% contain the piece of code that will look for any additional display
% device attached to the current machine. Similarly the section with title  
% "Practice Trails" will contain the code for practice trail. and so on.

% The variable names are longer than usual programming convention but have
% a menaingful name so in most of the cases it is self evident of what a
% paricular variable  does.

% Created on '11-Feb-2022 11:37:28'
% Last modified on '9-Sep-2022 18:49:31'

% Author : Ajai Singh



%% Do not edit 
clear
clc
close all  
warning('off','all');
addpath('C:\Ajai\Simple_Reaction_Time\Simple_Reaction_Time_1.1\dependecies');

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DAQ Initialization ( DO NOT EDIT)
AvailableDevice  = daqlist;
d = daq('ni');
d.Rate = 1000; % number of samples per second


    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


CreateProcessedFile = 1; % set it to 1 in case creating processed file is required

%% Getting Subject and O/P related info
global OPDir FName RandTimeMatrix
InputDlgPrompt1 = {'Enter Subject ID','Enter Sensor Number','Enter rest period (seconds): '};
InputDlgPrompt1Title = 'Basic Initialization Information';
SubID = inputdlg(InputDlgPrompt1,InputDlgPrompt1Title);
TimeStamp = erase(datestr(datetime('now','InputFormat',"dd-MM-uuuu HH:mm:ss")),{'-',':',' '});
FName = strcat(SubID{1},TimeStamp);
OPDir = uigetdir('title','Select the output folder');
%%% Pairing Sensor Number and Channel 
SNum = str2double(SubID{2});
RestPeriod = str2double(SubID{3});

if( isnan(RestPeriod) )
    RestPeriod = 1;
end
switch SNum
    case 1
        Channel = 'ai6';
        disp(['Using ai6 for sensor number : ', num2str(SNum)])
    case 2
        Channel = 'ai7';
        disp(['Using ai7 for sensor number : ', num2str(SNum)])
    case 3
        Channel = 'ai16';
        disp(['Using ai16 for sensor number : ', num2str(SNum)])
    case 4
        Channel = 'ai17';
        disp(['Using ai17 for sensor number : ', num2str(SNum)])
    case 5
        Channel = 'ai18';
        disp(['Using ai18 for sensor number : ', num2str(SNum)])

    case 6
        Channel = 'ai19';
        disp(['Using ai19 for sensor number : ', num2str(SNum)])

    case 7
        Channel = 'ai20';
        disp(['Using ai20 for sensor number : ', num2str(SNum)])

    case 8
        Channel = 'ai21';
        disp(['Using ai21 for sensor number : ', num2str(SNum)])

    otherwise
            disp('No Sensor Found, Enter in the range of [1 8]')
end

if(  isempty(AvailableDevice) )
    errordlg( ' The specified device is not present or is not active in the system. The device may not be installed on this system, may have been unplugged, or may not be installed correctly. ','DAQ Device Error');
    disp('Exited with Error : DAQ Device not found');
    return
else
    Ch1 = addinput(d,AvailableDevice.DeviceID,Channel,'Voltage');
    
end


%% Getting the number of Practice Trials and Test Trials
DlgPrompt = {'Enter the number of practice trials: ','Enter the number of test trails: '};
DlgTitle = 'Input number of trials';
TrialsInfo = inputdlg(DlgPrompt,DlgTitle,[1,50]);
PReps = str2double(TrialsInfo{1,1});
TestReps = str2double(TrialsInfo{2,1});


%% creating a folder with SubID TimeStamp as its name

mkdir(OPDir,FName);

%% PRE ALLOCATING NECESSARY VECTORS
BRTMat = zeros(TestReps,1);
BRTMatDeltaT = zeros(TestReps,1);

PBRTMat = zeros(PReps,1);
PBRTMatDeltaT = zeros(PReps,1);

DataAcquiredInMTimeFrame = [];

%% Looking for Additional Display

MonitorPos =  get(0,'MonitorPositions');
global DisplayWindowPos DisplayWindowAxes DisplayWindow i
if (size(MonitorPos,1) >1)
    
    DisplayWindowPos = MonitorPos(2,:);
    DisplayWindow = figure('MenuBar','none','WindowState','fullscreen','Position',DisplayWindowPos ...
        ,'WindowStyle','normal');
    DisplayWindowAxes = gca(DisplayWindow);
    set(DisplayWindow,'Color',[0.5 0.5 0.5]);
else
    DisplayWindowPos = MonitorPos;
    DisplayWindow = figure('MenuBar','none','WindowState','fullscreen','Position',DisplayWindowPos ...
        ,'WindowStyle','normal');
    DisplayWindowAxes = gca(DisplayWindow);
    set(DisplayWindow,'Color',[0.5 0.5 0.5]);
end

%plot(DisplayWindowAxes,1, 1, '.', 'MarkerSize',1000,'Color',[0.8500 0.3250 0.0980]);
%% Code for Practice Trails 
if (PReps)
TxtHndl = text(1,1,'Press the button to begin Practice trials','FontSize',70,'Color',[0 0 0],'FontWeight','bold') ;
set(DisplayWindowAxes,'visible','off','xlim',[0 2],'ylim',[0 2],'Position',[0 0 1 1]) ;
set(TxtHndl,'visible','on','HorizontalAlignment','center','VerticalAlignment','middle');

waitforbuttonpress;
cla(DisplayWindowAxes)
plot(DisplayWindowAxes,1, 1.3 , '.', 'MarkerSize',1000,'Color',[0.6350 0.0780 0.1840]);
TxtHndl = text(1,1,{' ',' means press button'},'FontSize',100,'Color',[0 0 0],'FontWeight','bold') ;
set(DisplayWindowAxes,'visible','off','xlim',[0 2],'ylim',[0 2],'Position',[0 0 1 1]) ;
set(TxtHndl,'visible','on','HorizontalAlignment','center','VerticalAlignment','middle');
TxtHndl2 = text(2,0.05,{'Press the button to continue'},'FontSize',50,'Color',[0 0 0],'FontWeight','bold') ;
set(TxtHndl2,'visible','on','HorizontalAlignment','right','VerticalAlignment','bottom');
waitforbuttonpress;
cla(DisplayWindowAxes)


%%
disp('================= PRACTICE TRIALS ==================')
for j = 1:PReps
    TorP = 'Practice';
   % if(j == 1)
%         plot(DisplayWindowAxes,1, 1.3 , '.', 'MarkerSize',500,'Color',[0.8500 0.3250 0.0980]);
%         TxtHndl = text(1,1,{' means press button'},'FontSize',100,'Color',[0 0 0],'FontWeight','bold') ;
%         set(DisplayWindowAxes,'visible','off','xlim',[0 2],'ylim',[0 2],'Position',[0 0 1 1]) ;
%         set(TxtHndl,'visible','on','HorizontalAlignment','center','VerticalAlignment','middle');
%         TxtHndl2 = text(2,0.05,{'Press the button to continue'},'FontSize',50,'Color',[0 0 0],'FontWeight','bold') ;
%         set(TxtHndl2,'visible','on','HorizontalAlignment','right','VerticalAlignment','bottom');
%         waitforbuttonpress;
%         cla(DisplayWindowAxes)
        

   % else
        BasicWaitBar2(RestPeriod,DisplayWindowAxes)
        
        TxtHndl = text(1,1,'Get Ready','FontSize',200,'Color',[0 0 0],'FontWeight','bold') ;
        set(DisplayWindowAxes,'visible','off','xlim',[0 2],'ylim',[0 2],'Position',[0 0 1 1]) ;
        set(TxtHndl,'visible','on','HorizontalAlignment','center','VerticalAlignment','middle');
        
        
        pause(1)
       
        cla(DisplayWindowAxes)
        
        
        InitTime4DAQ = tic;
        Time4EMGDaq = tic;
        start(d,'duration',seconds(3)); % Uncomment this when running on lab computer
        InitTime4Parti = tic;
        
        Chndl = plot(DisplayWindowAxes,1, 1, '.', 'MarkerSize',1000,'Color',[0.6350 0.0780 0.1840]);
        set(DisplayWindowAxes,'visible','off','xlim',[0 2],'ylim',[0 2],'Position',[0 0 1 1]) ;
        waitforbuttonpress;
        FinalTIme4DAQ = toc(InitTime4DAQ);
        PBRTMat(j,1) = toc(InitTime4Parti); %
        disp(['RT for Test Trial : ',num2str(j),' is ',num2str(PBRTMat(j,1))])
        PBRTMatDeltaT(j,1) = FinalTIme4DAQ - PBRTMat(j,1);
        cla(DisplayWindowAxes)
        
        pause(1)
        stop(d)
        Time4EMGDaqEnd = toc(Time4EMGDaq);
        DataAcquiredInMTimeFrame = [DataAcquiredInMTimeFrame;Time4EMGDaqEnd];
        CollectData(d,j,TorP)
        BasicWaitBar2(RestPeriod,DisplayWindowAxes)
        try 
            
            flush(d); % Uncomment this in labs computer
        catch ME
           disp(ME.identifier)
        end
        
    %end
end
%% Practice Conclusion Message
set(DisplayWindow,'WindowStyle','normal')
TxtHndl = text(1,1,{'Practice Concludes'},'FontSize',100,'Color',[0.3010 0.7450 0.9330],'FontWeight','bold') ;
set(DisplayWindowAxes,'visible','off','xlim',[0 2],'ylim',[0 2],'Position',[0 0 1 1]) ;
set(TxtHndl,'visible','on','HorizontalAlignment','center','VerticalAlignment','middle');


%% Writing Practice Data

Fname4MotorReacTimeP = fullfile(OPDir,FName,'PracticeReactionTime.xls');
TempCombined = [PBRTMat,PBRTMatDeltaT,DataAcquiredInMTimeFrame];
ReactionTimeTable = array2table(TempCombined);
ReactionTimeTable.Properties.VariableNames(1:3) = {'ReactionTime','Lag','DataAcquiredInMatlabTimeFrame'};
writetable(ReactionTimeTable,Fname4MotorReacTimeP,'WriteMode','append');
TorP = '';
ProcessTimeCalculation(fullfile(OPDir,FName,'PracticeRawData.xls'),Fname4MotorReacTimeP,fullfile(OPDir,FName),'P',CreateProcessedFile)

end
%% Clear Used Vars

ClearVarList = {'Fname4MotorReacTime','TempCombined','ReactionTimeTable',...
               'InitTime4DAQ','Time4EMGDaq','InitTime4Parti','FinalTIme4DAQ',...
                 'Time4EMGDaqEnd','DataAcquiredInMTimeFrame'};
clear(ClearVarList{:});

if ( TestReps)
%% Code for Test Trails

TxtHndl = text(1,1,{'Hit the button to','start the test'},'FontSize',100,'Color',[0.3010 0.7450 0.9330],'FontWeight','bold') ;
set(DisplayWindowAxes,'visible','off','xlim',[0 2],'ylim',[0 2],'Position',[0 0 1 1]) ;
set(TxtHndl,'visible','on','HorizontalAlignment','center','VerticalAlignment','middle');
waitforbuttonpress;
cla(DisplayWindowAxes);
%TestReps = 3; % comment this when running real subject
RandTimeMatrix = randi ([1500,2000],TestReps,1);

DataAcquiredInMTimeFrame = [];
disp('================= TEST TRIALS ======================')
for i = 1:TestReps
        TorP = 'Test';
        
        BasicWaitBar2(RestPeriod,DisplayWindowAxes)
    

        
        TxtHndl = text(1,1,'Get Ready','FontSize',200,'Color',[0 0 0],'FontWeight','bold') ;
        set(DisplayWindowAxes,'visible','off','xlim',[0 2],'ylim',[0 2],'Position',[0 0 1 1]) ;
        set(TxtHndl,'visible','on','HorizontalAlignment','center','VerticalAlignment','middle');
        
       
        
        %disp(RandTimeMatrix(i))
        pause(RandTimeMatrix(i)/1000)
        cla(DisplayWindowAxes)
        %disp(i)
        
        InitTime4DAQ = tic;
        Time4EMGDaq = tic;
        start(d,'duration',seconds(3)); % Uncomment this when running on lab computer
        InitTime4Parti = tic;
        
        Chndl = plot(DisplayWindowAxes,1, 1, '.', 'MarkerSize',1000,'Color',[0.6350 0.0780 0.1840]);
        set(DisplayWindowAxes,'visible','off','xlim',[0 2],'ylim',[0 2],'Position',[0 0 1 1]) ;
        
        waitforbuttonpress;
        FinalTIme4DAQ = toc(InitTime4DAQ);
        BRTMat(i,1) = toc(InitTime4Parti); %
        disp(['RT for Test Trial : ',num2str(i),' is ',num2str(BRTMat(i,1))])
        BRTMatDeltaT(i,1) = FinalTIme4DAQ - BRTMat(i,1);
        cla(DisplayWindowAxes)
        
        pause(1)
        stop(d)
        Time4EMGDaqEnd = toc(Time4EMGDaq);
        DataAcquiredInMTimeFrame = [DataAcquiredInMTimeFrame;Time4EMGDaqEnd];
        CollectData(d,i,TorP)
        BasicWaitBar2(RestPeriod,DisplayWindowAxes)
        try 
            
            flush(d); % Uncomment this in labs computer
        catch ME
           disp(ME.identifier)
        end

                        
         
end
%% Test Conclusion message
set(DisplayWindow,'WindowStyle','normal')
TxtHndl = text(1,1,{'Thank you for','your participation'},'FontSize',100,'Color',[0.3010 0.7450 0.9330],'FontWeight','bold') ;
set(DisplayWindowAxes,'visible','off','xlim',[0 2],'ylim',[0 2],'Position',[0 0 1 1]) ;
set(TxtHndl,'visible','on','HorizontalAlignment','center','VerticalAlignment','middle');


%% Creating Raw data file & Post Processing of test traials
Fname4MotorReacTime = fullfile(OPDir,FName,'TestReactionTime.xls');
TempCombined = [BRTMat,BRTMatDeltaT,DataAcquiredInMTimeFrame];
ReactionTimeTable = array2table(TempCombined);
ReactionTimeTable.Properties.VariableNames(1:3) = {'ReactionTime','Lag','DataAcquiredInMatlabTimeFrame'};
writetable(ReactionTimeTable,Fname4MotorReacTime,'WriteMode','append'); 
ProcessTimeCalculation(fullfile(OPDir,FName,'TestRawData.xls'),fullfile(OPDir,FName,'TestReactionTime.xls'),fullfile(OPDir,FName),'T',CreateProcessedFile)

end



%% Saving and closing figures


SaveAllFig4Me(fullfile(OPDir,FName));
SFWaitBar()
CloseFigure()

%% Resetting TorP
TorP = '';



%% BASIC WAIT FUNC
function BasicWaitBar2(RP,DisplayWindowAxes)

    TxtHndl = text(1,1,'Relax','FontSize',200,'Color',[0 0 1],'FontWeight','bold') ;
    set(DisplayWindowAxes,'visible','off','xlim',[0 2],'ylim',[0 2],'Position',[0 0 1 1]) ;
    set(TxtHndl,'visible','on','HorizontalAlignment','center','VerticalAlignment','middle');


    pause(RP)
    cla(DisplayWindowAxes)
   
end

%% function for collecting real time data
function CollectData(obj,k,TorP)

       global  OPDir FName

%      [data,TS,~] = read(obj,obj.ScansAvailableFcnCount,"OutputFormat","Matrix");
%       TempDisp = [TS,data];
% 
%      
%      disp('In writing function')
      if( strcmp(TorP,'Practice') )
          
          EMGDatafile = fullfile(OPDir,FName,'PracticeRawData.xls');
          %      writematrix(TempDisp,EMGDatafile,'WriteMode','append','Sheet',i);
          
          [EMData,Time,~] = read(obj,'all',"OutputFormat","Matrix");
          T = array2table([Time,EMData]);
          T.Properties.VariableNames(1:2) = {'Time','EMG'};
          writetable( T,EMGDatafile,'WriteMode','append','Sheet',k)
      elseif(strcmp(TorP,'Test') )
          EMGDatafile = fullfile(OPDir,FName,'TestRawData.xls');
          %      writematrix(TempDisp,EMGDatafile,'WriteMode','append','Sheet',i);
          
          [EMData,Time,~] = read(obj,'all',"OutputFormat","Matrix");
          T = array2table([Time,EMData]);
          T.Properties.VariableNames(1:2) = {'Time','EMG'};
          writetable( T,EMGDatafile,'WriteMode','append','Sheet',k)
      else
          disp('WARNING: No Data Written')
      end
          

end
%             ProcessTimeCalculation(fullfile(OPDir,FName,'TestRawData.xls'),fullfile(OPDir,FName,'TestReactionTime.xls'),fullfile(OPDir,FName),'T',CreateProcessedFile)

function SFWaitBar()
f = waitbar(0,'Please wait...');
pause(1)

waitbar(.33,f,'Looking for plots generated');
pause(1)

waitbar(.67,f,'Creating Directory for plots');
pause(1)

waitbar(1,f,'Saving');
pause(2)

close(f)
end

function CloseFigure()
confirmation = questdlg('Do you want to close all generated figures','Close Figures');
switch confirmation
    case 'Yes'
        close all
        disp('All figures closed');
    case 'No'
        disp('No figures closed');
    case 'Cancel'
        disp('Operation cancelled by user')
end
end
        
