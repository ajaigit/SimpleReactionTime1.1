% File1 contains fullfile info of Raw EMG data
% File2 contains fullfile info of Reaction Time file
% FilePath is for writing Time Calculations if the user wants
% If YesNo is true then a processed file is created in the O/P folder
% If YesNo is false then only processed data is displayed in the command
% window
% Created on '11-Feb-2022 11:37:28'

% Author : Ajai Singh

% 'TestRawData.xls'

% 'TestReactionTime.xls'
% 'C:\Ajai\Simple_Reaction_Time\'


function ProcessTimeCalculation(File1,File2,FilePath,TorP,YesNo)
% clear
% clc


%% Forcing plot to generate plots on Monitor not displaying stimulus for participant

MP =  get(0,'MonitorPositions');

if (size(MP,1) >1)
    
    DisplayWindowPos = MP(1,:);
    
else
    DisplayWindowPos = MP;
    
end
%%
warning('off')
SheetNum = sheetnames(File1);
for i = 1:length(SheetNum)
    RawEMG.(strcat('T',num2str(i))) = xlsread(File1,SheetNum(i));
    PrePEMG.(strcat('T',num2str(i))) =  PreProcessEMGData(RawEMG.(strcat('T',num2str(i)))(:,2));
    FiltEMG.(strcat('T',num2str(i))) =  FilterEMG(PrePEMG.(strcat('T',num2str(i)))(:,1));
end
%%

RTData = xlsread(File2);
PostReactionDAQ = 50; % in number of  samples
%EndDAQ = RTData(13,1)*1000 + PostReactionDAQ;
ProcessedData = zeros(size(RTData,1),3);
if( strcmp('P',TorP))
    disp('Practice Trial Time Calculations')
else
    disp('Test Trial Time Calculations')
end
disp(['    Trial','       PMT','       MT ','       RT '])
%%
TrialNames = fieldnames(FiltEMG);


for k = 1:length(TrialNames)
    
    try
        clear EndDAQ
        %EndDAQ = fix(EndDAQ);
        TN = TrialNames{k};
        SignalData = FiltEMG.(TN);
        skip = 50;
        EndDAQ = RTData(k,1)*1000 + PostReactionDAQ;
        % The above ensures to find a peak before stimulus is set to zero
        SDDataTemp = zeros(4000,1);
        SDDataTemp(1:length(SignalData)) = SignalData;
        SignalData = SDDataTemp;


        [MaxV,MaxVLoc ] = max(SignalData(skip:EndDAQ));
        [MinV,MinVLoc ] = min(SignalData(skip:EndDAQ));
        time = RawEMG.(TN)(:,1);
        RT = RTData(k,1);
        fsamp = 1000;
        t  = ( (1/fsamp)*100 )*fsamp; % number of samples for detecting noise peak
        noise = max(SignalData(skip:t));
        threshold = noise + 0.1*noise;
        figure('Position',DisplayWindowPos);
        lw=2;
        plot(time,SignalData(1:length(time)),'LineWidth',lw)
        hold on
    %     thXSig = InterX([time;SignalData(1:length(time))],[time;threshold + zeros(length(RawEMG.(TN)),1)]);
        plot(time,threshold + zeros(length(RawEMG.(TN)),1),'LineWidth',lw)

        plot(time,0.15*MaxV+threshold + zeros(length(RawEMG.(TN)),1),'LineWidth',lw)
        plot(time,noise + zeros(length(RawEMG.(TN)),1),'LineWidth',lw,'LineStyle','--')
        StimStep = zeros(size(time));
        StimStep(time <= RT ) = 1.2*MaxV;
        plot(time,StimStep,'LineWidth',lw)
        if( strcmp('P',TorP))
            title(strcat('PTN',num2str(k)))
        else
            title(strcat('TTN',num2str(k)))
        end
        xlabel('$Time(s)$','Interpreter','latex','FontWeight','bold','FontSize',20)
        ylabel('$Signal Amplitude $','Interpreter','latex','FontWeight','bold','FontSize',20)
        grid on

        legend({'$Filtered EMG$','$Threshold$','EMG Onset','$Noise$','$Stimulus Step Fn$'},'Interpreter','latex','FontSize',13,'FontWeight','bold')

        i = 0;
        for i = MaxVLoc:-1:1
            if(SignalData(i) < threshold + 0.15*MaxV )
                EMGthreshold  = i+1 ; % EMGthreshold == EMG Onset
                break;
            end
        end

        if(k==32)
            disp([' EMG Threshold : ',num2str(EMGthreshold)])
        end

        % Time Between EMG Onset and peak EMG signal
        %EMGT1 = MaxVLoc - EMGthreshold;
        EMGOnSetTime = time(EMGthreshold);
        TempTime =  time - RT < 1e-7;
        TempTimeIndexVec = find(TempTime == 1);
        TempTimeIndex = TempTimeIndexVec(end);

        PMRT = time(TempTimeIndex) - EMGOnSetTime;
        %PMRT = RT - EMGOnSetTime;
        ProcessedData(k,1) = EMGOnSetTime;
        ProcessedData(k,2) = PMRT;
        ProcessedData(k,3) = RT;
        disp([fix(k),EMGOnSetTime,PMRT,RT])
        % MT is the time from threshold to button press 
        % So the following algo is to be used
        % RTIndex =  find(SiganlData == RT );
        % PMRT = time(RTIndex) - time(EMGOnSetTime)
        % figure
        % stackedplot([RawEMG.(TN),FiltEMG.(TN),PrePEMG.(TN)])
        %waitforbuttonpress;

    catch
        disp(['Incosistent data in trial number ', num2str(k) ,' ,skipping.']);
    end

end
if( YesNo)
    if( strcmp('T',TorP))
        ProcessedDataTbl = array2table(ProcessedData);
        ProcessedDataTbl.Properties.VariableNames(1:3) = {'PMT','MT','RT'};
        PFName = 'ProcessedTestTimeCalculations.xls';
        PFFile = fullfile(FilePath,PFName);
        writetable( ProcessedDataTbl,PFFile,'WriteMode','append','Sheet',1);
    else
        
        ProcessedDataTbl = array2table(ProcessedData);
        ProcessedDataTbl.Properties.VariableNames(1:3) = {'PMT','MT','RT'};
        PFName = 'ProcessedPracticeTimeCalculations.xls';
        PFFile = fullfile(FilePath,PFName);
        writetable( ProcessedDataTbl,PFFile,'WriteMode','append','Sheet',1);
    end
end
%% Code for saving generated plots goes here

end