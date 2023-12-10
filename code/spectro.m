%By Joshua Ball
%Generates 4 Spectrograms in a single figure for the paper
[audioSignal2, fs2] = audioread('forest.wav');
[audioSignal1, fs1] = audioread('speech.wav');

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

win = .31; % window length in seconds
thresh = 90; % SNR threshold

% Utilizing the np_energy_sad function from hint
[detectedSpeech, energy, snr] = np_energy_sad(mixedSignalF, fs, win, thresh);

% Define the parameters for the spectrogram
window = hamming(256);
noverlap = 128;
nfft = 512;

audioSignal3 = mixedSignalF;
audioSignal4 = detectedSpeech;

% Create a figure with four subplots
figure;

% Define subplot positions
left_margin = 0.07;
bottom_margin = 0.1;
subplot_width = 0.42;
subplot_height = 0.37; % Adjust height to make room for titles
horizontal_gap = 0.1;
vertical_gap = 0.1; % Adjust vertical gap to make room for titles

% Set the figure size and resolution
set(gcf, 'Position', [100, 100, 1024, 768]); % This sets the figure's size on your screen

% First spectrogram
subplot('Position', [left_margin, bottom_margin + subplot_height + vertical_gap, subplot_width, subplot_height]);
spectrogram(audioSignal1, window, noverlap, nfft, fs, 'yaxis');
title('Speech Signal');

% Second spectrogram
subplot('Position', [left_margin + subplot_width + horizontal_gap, bottom_margin + subplot_height + vertical_gap, subplot_width, subplot_height]);
spectrogram(audioSignal2, window, noverlap, nfft, fs, 'yaxis');
title('Ambient Signal');

% Third spectrogram
subplot('Position', [left_margin, bottom_margin, subplot_width, subplot_height]);
spectrogram(audioSignal3, window, noverlap, nfft, fs, 'yaxis');
title('Mixed Signal');

% Fourth spectrogram
subplot('Position', [left_margin + subplot_width + horizontal_gap, bottom_margin, subplot_width, subplot_height]);
spectrogram(audioSignal4, window, noverlap, nfft, fs, 'yaxis');
title('Detected Speech');

% Increase font size for titles
subplot_titles = findall(gcf, 'Type', 'axes');
for ax = subplot_titles'
    title_obj = get(ax, 'Title');
    set(title_obj, 'FontSize', 10);
end

print(gcf, 'spectrograms.png', '-dpng', '-r300'); % Saves the figure as a PNG with 300 DPI