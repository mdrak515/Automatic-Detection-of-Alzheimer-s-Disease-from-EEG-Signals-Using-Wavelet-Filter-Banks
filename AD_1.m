%% Wavelet filter-bank preprocessing + band reconstruction + Hjorth (MATLAB)
% Requirements: Wavelet Toolbox
% Author: Abhinandan Basu

clc; clear; close all;

% --------- User settings (edit paths & patient IDs) ----------
Fs = 256;  % Sampling frequency

% List of 20 AD patients
patients = {'Paciente1','Paciente2','Paciente3','Paciente4','Paciente5', ...
            'Paciente6','Paciente7','Paciente8','Paciente9','Paciente10', ...
            'Paciente11','Paciente12','Paciente13','Paciente14','Paciente15', ...
            'Paciente16','Paciente17','Paciente18','Paciente19','Paciente20'};

% Define paths (update these with your actual folder locations)
base_open   = 'D:\EEG_Project\EEG_data\EEG_data\AD\Eyes_open\';
base_closed = 'D:\EEG_Project\EEG_data\EEG_data\AD\Eyes_closed\';

% Wavelet packet settings
wname   = 'db4';
wpLevel = 6;  % decomposition level

% Desired EEG bands (Hz)
bandsDef = { 'Delta', [0.5 4];
             'Theta', [4 8];
             'Alpha', [8 13];
             'Beta',  [13 30];
             'Gamma', [30 45] };

% Preallocate results
results = {};

% --------- Loop through patients ----------
for p = 1:length(patients)
    subj = patients{p};
    f_open  = fullfile(base_open,  subj, 'Cz.txt');
    f_close = fullfile(base_closed, subj, 'Cz.txt');
    if ~isfile(f_open) || ~isfile(f_close)
        fprintf('Skipping %s (missing file)\n', subj);
        continue;
    end

    % ---------- Load EEG data ----------
    x_open  = load(f_open);
    x_close = load(f_close);

    % Convert to column vectors
    x_open  = double(x_open(:));
    x_close = double(x_close(:));

    % Match lengths
    N = min(length(x_open), length(x_close));
    x_open  = x_open(1:N);
    x_close = x_close(1:N);

    % ---------- Preprocessing ----------
    % 1) Notch filter at 60 Hz
    wo = 60 / (Fs/2);
    Q  = 30;
    [bn, an] = iirnotch(wo, wo/Q);
    x_open_n  = filtfilt(bn, an, x_open);
    x_close_n = filtfilt(bn, an, x_close);

    % 2) Bandpass 0.5 - 100 Hz (4th order Butterworth)
    bp = [0.5 100] / (Fs/2);
    [bb, ab] = butter(4, bp, 'bandpass');
    x_open_f  = filtfilt(bb, ab, x_open_n);
    x_close_f = filtfilt(bb, ab, x_close_n);

    % ---------- Difference signal ----------
    x_diff = x_open_f - x_close_f;

    % ---------- Wavelet-packet decomposition ----------
    wpt = wpdec(x_diff', wpLevel, wname);  % tree object

    % Node frequency bands
    nNodes = 2^wpLevel;
    nodeBands = zeros(nNodes,2);
    for k = 0:(nNodes-1)
        f_low  = k * Fs / 2^(wpLevel+1);
        f_high = (k+1) * Fs / 2^(wpLevel+1);
        nodeBands(k+1,:) = [f_low, f_high];
    end

    % ---------- Reconstruct EEG bands ----------
    bandSignals = struct();
    for b = 1:size(bandsDef,1)
        bandName  = bandsDef{b,1};
        bandRange = bandsDef{b,2};
        nodesToSum = [];

        for k = 1:nNodes
            nb = nodeBands(k,:);
            overlap = min(nb(2), bandRange(2)) - max(nb(1), bandRange(1));
            if overlap > 0
                nodesToSum(end+1) = k-1; %#ok<SAGROW>
            end
        end

        recon = zeros(1,N);
        for idx = nodesToSum
            rn = wprcoef(wpt, [wpLevel idx]);
            recon = recon + rn;
        end
        bandSignals.(bandName) = recon(:);
    end

    % ---------- Hjorth parameters ----------
    for b = 1:size(bandsDef,1)
        bandName = bandsDef{b,1};
        sig = bandSignals.(bandName);
        [A, M, C] = hjorth_params(sig);
        results = [results; {subj, bandName, A, M, C}]; %#ok<SAGROW>
    end

    % ==================================================
    %                 FIGURE 1: Raw + Difference
    %% ==================================================
    t = (0:N-1)/Fs;
    figure('Name', sprintf('FIG1 - Raw & Diff - %s (AD)', patients{p}), 'NumberTitle', 'off');

    subplot(2,1,1);
    plot(t, x_open_f, 'b', 'LineWidth', 1.2); hold on;
    plot(t, x_close_f, 'r', 'LineWidth', 1.2);
    xlabel('Time (s)', 'FontWeight', 'bold');
    ylabel('Amplitude (\muV)', 'FontWeight', 'bold');
    title(sprintf('Filtered EEG of AD - %s (Eyes Open vs Eyes Closed)', patients{p}), 'FontWeight', 'bold');
    legend('Eyes Open', 'Eyes Closed');
    grid on;

    subplot(2,1,2);
    plot(t, x_diff, 'k', 'LineWidth', 1.2);
    xlabel('Time (s)', 'FontWeight', 'bold');
    ylabel('Amplitude (\muV)', 'FontWeight', 'bold');
    title('Difference Signal (Open - Closed)', 'FontWeight', 'bold');
    grid on;

    % ==================================================
    %             FIGURE 2: Band-wise Reconstruction
    % ==================================================
    figure('Name', sprintf('FIG2 - Bands - %s (AD)', patients{p}), 'NumberTitle', 'off');
    nBands = size(bandsDef,1);
    colors = lines(nBands);

    for b = 1:nBands
        subplot(nBands,1,b);
        plot(t, bandSignals.(bandsDef{b,1}), 'Color', colors(b,:), 'LineWidth', 1.2);
        xlabel('Time (s)', 'FontWeight', 'bold');
        ylabel('Amplitude (\muV)', 'FontWeight', 'bold');
        title(sprintf('%s Band (%d–%d Hz)', bandsDef{b,1}, bandsDef{b,2}), 'FontWeight', 'bold');
        grid on;
    end
end

%% ---------- Save results ----------
if ~isempty(results)
    T = cell2table(results, 'VariableNames', ...
        {'Patient','Band','Activity','Mobility','Complexity'});
    disp(T);

    output_file = fullfile(pwd, 'Hjorth_Results_AD_Patients.xlsx');
    try
        writetable(T, output_file);
        fprintf('? Results saved to: %s\n', output_file);
    catch ME
        warning('Could not write Excel file: %s\nError: %s', output_file, ME.message);
        output_file_csv = fullfile(pwd, 'Hjorth_Results_AD_Patients.csv');
        writetable(T, output_file_csv);
        fprintf('Saved results as CSV instead: %s\n', output_file_csv);
    end
else
    warning('? No results computed. Check patient paths.');
end

%% -------------- Hjorth Function ----------------
function [Activity, Mobility, Complexity] = hjorth_params(x)
    x = double(x(:)) - mean(x);
    Activity = var(x,1);
    dx = diff(x);
    if isempty(dx)
        Mobility = NaN; Complexity = NaN; return;
    end
    Mobility = sqrt(var(dx,1) / Activity);
    ddx = diff(dx);
    if isempty(ddx) || var(dx,1)==0
        Complexity = NaN;
    else
        Mobility_dx = sqrt(var(ddx,1)/var(dx,1));
        Complexity = Mobility_dx / Mobility;
    end
end
