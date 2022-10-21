function y = PreProcessEMGData(Data)

Fs = 1000;
Fnyq = Fs/2;
y = (Data-mean(Data));
fco = 10; %10 Hz high pass
%[b,a] = butter(2,fco*1.25/Fnyq,'stop');
[b,a] = butter(2,[59 61]/Fnyq,'stop');
y = filtfilt(b,a,y);
delay = ( (1/1000) * 48 )* 1000;
y = [ y(delay:end);zeros(delay-1,1)];
end