% Function to Load Configuration File

function Data = loadConfigurationFile_New(filename,pathname)

ConfigurationFileName = strcat(pathname,filename);

% Initialize the Data structure
Data = struct;

if (~exist(ConfigurationFileName,'file'))
    Data = '';
    msgbox(strcat('Configuration File - ',filename,' is absent from current directory. Make sure file is present in current directory ( ',pathname,' ) and try again.'),'Absent Configuration File','error');
    return;
end

% Open and Read the Configuration File
fid = fopen(ConfigurationFileName,'rt');
tline = fgetl(fid);
if (ischar(tline))

    while (ischar(tline))

        C = strsplit(tline,'\t');
        if (length(C) ~= 2) % Handle corrupt files
            msgbox(strcat('Configuration File - ',filename,' is corrupted. Use another file.'),'Corrupt Configuration File','error');
            Data = '';
            fclose(fid);
            return;
        end

        switch C{1}
            case 'DeviceName'
                Data.DeviceName = C{2};
            case 'DeviceID'
                Data.DeviceID = C{2};
            case 'InputType'
                Data.InputType = C{2};
            case 'LeftForceName'
                Data.LeftForceName = C{2};
            case 'LeftForceChannel'
                if (isnan(str2double(C{2})))
                    msgbox(strcat('Configuration File - ',filename,' is corrupted. Left Force Channel has invalid number. Fix it and try again.'),'Corrupt Configuration File','error');
                    Data = '';
                    fclose(fid);
                    return;
                else
                    Data.LeftForceChannel = str2double(C{2});
                end
            case 'LeftEMG1Name'
                Data.LeftEMG1Name = C{2};
            case 'LeftEMG1Channel'
                if (isnan(str2double(C{2})))
                    msgbox(strcat('Configuration File - ',filename,' is corrupted. Left EMG1 Channel has invalid number. Fix it and try again.'),'Corrupt Configuration File','error');
                    Data = '';
                    fclose(fid);
                    return;
                else
                    Data.LeftEMG1Channel = str2double(C{2});
                end
            case 'LeftCalibration'
                if (isnan(str2double(C{2})))
                    msgbox(strcat('Configuration File - ',filename,' is corrupted. Left Calibration has invalid number. Fix it and try again.'),'Corrupt Configuration File','error');
                    Data = '';
                    fclose(fid);
                    return;
                else
                    Data.LeftCalibration = str2double(C{2});
                end
            case 'RightForceName'
                Data.RightForceName = C{2};
            case 'RightForceChannel'
                if (isnan(str2double(C{2})))
                    msgbox(strcat('Configuration File - ',filename,' is corrupted. Right Force Channel has invalid number. Fix it and try again.'),'Corrupt Configuration File','error');
                    Data = '';
                    fclose(fid);
                    return;
                else
                    Data.RightForceChannel = str2double(C{2});
                end
            case 'RightEMG1Name'
                Data.RightEMG1Name = C{2};
            case 'RightEMG1Channel'
                if (isnan(str2double(C{2})))
                    msgbox(strcat('Configuration File - ',filename,' is corrupted. Right EMG1 Channel has invalid number. Fix it and try again.'),'Corrupt Configuration File','error');
                    Data = '';
                    fclose(fid);
                    return;
                else
                    Data.RightEMG1Channel = str2double(C{2});
                end
            case 'RightCalibration'
                if (isnan(str2double(C{2})))
                    msgbox(strcat('Configuration File - ',filename,' is corrupted. Right Calibration has invalid number. Fix it and try again.'),'Corrupt Configuration File','error');
                    Data = '';
                    fclose(fid);
                    return;
                else
                    Data.RightCalibration = str2double(C{2});
                end
            otherwise
                msgbox(strcat('Configuration File - ',filename,' is corrupted. Invalid field - ',C{2},'. Fix it and try again.'),'Corrupt Configuration File','error');
                Data = '';
                fclose(fid);
                return;
        end
        tline = fgetl(fid);
    end

else % File exists but it is empty. Display Warning
    msgbox(strcat('Configuration File -  ',filename,' is Empty'),'Empty File','warn');
    Data = '';
    fclose(fid);
    return;
end

fclose(fid);

return