function y = FilterEMG(Data)
Fs = 1000;
Fnyq = Fs/2;
fco = 10;
[b,a] =  butter(2,fco/Fnyq,'low');
x = abs(Data - mean(Data));
y = filtfilt(b,a,x);
end