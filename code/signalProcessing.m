%mixedSignal.m
%Read in audio signals
[audioSignal1, fs1] = audioread('speech.wav');
[audioSignal2, fs2] = audioread('forest.wav');

% Resample if necessary
if fs1 ~= fs2
    audioSignal2 = resample(audioSignal2, fs1, fs2);
end
fs = fs1;
% Adjust lengths
len1 = length(audioSignal1);
len2 = length(audioSignal2);
minLen = min(len1, len2);

audioSignal1 = audioSignal1(1:minLen);
audioSignal2 = audioSignal2(1:minLen);

% Mix the signals
mixedSignalF = audioSignal1 + audioSignal2;

%Normalize the mixed signal to prevent clipping
mixedSignalF = mixedSignalF / max(abs(mixedSignalF));

% Write the mixed signal to a new file
%audiowrite('mixed_signal.wav', mixedSignalF, fs1);

win = .31; % window length in seconds
thresh = 90; % SNR threshold

% Utilizing the np_energy_sad function from hint
[detectedSpeech, energy, snr] = np_energy_sad(mixedSignalF, fs, win, thresh);


%  Visualization
figure;
subplot(2,1,1);
plot(filteredSignal);
title('Original Signal With Speech Present and Ambient Forest Noise');
xlabel('Sample');
ylabel('Amplitude');

subplot(2,1,2);
plot(detectedSpeech);
title('Detected Speech');
xlabel('Frame');
ylabel('Speech Presence');

%Read in 
[audioSignal, fs] = audioread('forest.wav'); 
[detectedSpeech, energy, snr] = np_energy_sad(audioSignal, fs, win, thresh);

figure;
subplot(2,1,1);
plot(audioSignal);
title('Silent Audio Signal');
xlabel('Sample');
ylabel('Amplitude');

subplot(2,1,2);
plot(detectedSpeech);
title('Detected Speech');
xlabel('Frame');
ylabel('Speech Presence');
