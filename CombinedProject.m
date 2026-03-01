%% =========================================================
% EEG MASTER ANALYSIS - Combined Program (Healthy + AD + Stats)
% Author: Abhinandan Basu
%% =========================================================
function CombinedProject

clc; clear; close all;

choice = menu('Select Operation', ...
    'Run Healthy EEG Analysis', ...
    'Run AD EEG Analysis', ...
    'Run Statistical Analysis (t-tests & plots)', ...
    'Exit');

switch choice
    case 1
        runEEGAnalysis('Healthy');
    case 2
        runEEGAnalysis('AD');
    case 3
        runStatisticalAnalysis();
    otherwise
        disp('Program exited.');
end

end   % end main function

%% =========================================================
% FUNCTION: EEG ANALYSIS
%% =========================================================
function runEEGAnalysis(groupType)

Fs = 256; wname = 'db4'; wpLevel = 6;

bandsDef = { 'Delta', [0.5 4];
             'Theta', [4 8];
             'Alpha', [8 13];
             'Beta',  [13 30];
             'Gamma', [30 45] };

if strcmp(groupType,'Healthy')
    patients = {'Paciente1','Paciente2','Paciente3','Paciente4','Paciente5', ...
                'Paciente7','Paciente8','Paciente9','Paciente10','Paciente11'};
    base_open  = 'D:\EEG_Project\EEG_data\EEG_data\Healthy\Eyes_open\';
    base_closed= 'D:\EEG_Project\EEG_data\EEG_data\Healthy\Eyes_closed\';
    outFile = 'Hjorth_Results_Healthy_Patients.xlsx';
else
    patients = {'Paciente1','Paciente2','Paciente3','Paciente4','Paciente5', ...
        'Paciente6','Paciente7','Paciente8','Paciente9','Paciente10', ...
        'Paciente11','Paciente12','Paciente13','Paciente14','Paciente15', ...
        'Paciente16','Paciente17','Paciente18','Paciente19','Paciente20'};
    base_open  = 'D:\EEG_Project\EEG_data\EEG_data\AD\Eyes_open\';
    base_closed= 'D:\EEG_Project\EEG_data\EEG_data\AD\Eyes_closed\';
    outFile = 'Hjorth_Results_AD_Patients.xlsx';
end

results = {};

for p = 1:length(patients)
    subj = patients{p};
    f_open  = fullfile(base_open, subj, 'Cz.txt');
    f_close = fullfile(base_closed, subj, 'Cz.txt');

    if ~isfile(f_open) || ~isfile(f_close)
        fprintf('Skipping %s (missing files)\n', subj);
        continue;
    end

    x_open = double(load(f_open)); 
    x_close = double(load(f_close));
    x_open = x_open(:); x_close = x_close(:);

    N = min(length(x_open), length(x_close));
    x_open = x_open(1:N); 
    x_close = x_close(1:N);

    % Filters
    wo = 60/(Fs/2); Q = 30;
    [bn, an] = iirnotch(wo, wo/Q);
    x_open = filtfilt(bn, an, x_open);
    x_close = filtfilt(bn, an, x_close);

    [bb, ab] = butter(4, [0.5 100]/(Fs/2), 'bandpass');
    x_open = filtfilt(bb, ab, x_open);
    x_close = filtfilt(bb, ab, x_close);

    x_diff = x_open - x_close;

    % Wavelet decomposition
    wpt = wpdec(x_diff', wpLevel, wname);
    nNodes = 2^wpLevel;

    nodeBands = zeros(nNodes,2);
    for k=0:nNodes-1
        nodeBands(k+1,:) = [k*Fs/2^(wpLevel+1), (k+1)*Fs/2^(wpLevel+1)];
    end

    bandSignals = struct();

    for b = 1:size(bandsDef,1)
        bandName = bandsDef{b,1};
        bandRange = bandsDef{b,2};
        recon = zeros(1,N);

        for k = 1:nNodes
            overlap = min(nodeBands(k,2), bandRange(2)) - ...
                      max(nodeBands(k,1), bandRange(1));
            if overlap > 0
                recon = recon + wprcoef(wpt, [wpLevel k-1]);
            end
        end
        bandSignals.(bandName) = recon(:);
    end

    for b = 1:size(bandsDef,1)
        sig = bandSignals.(bandsDef{b,1});
        [A,M,C] = hjorth_params(sig);
        results(end+1,:) = {subj, bandsDef{b,1}, A, M, C}; %#ok<SAGROW>
    end

    % Plot
    t = (0:N-1)/Fs;
    figure('Name',sprintf('%s - %s',groupType,subj));
    subplot(2,1,1); plot(t, x_open,'b'); hold on; plot(t, x_close,'r');
    legend('Eyes Open','Eyes Closed'); grid on;
    subplot(2,1,2); plot(t, x_diff,'k'); grid on;
end

T = cell2table(results, 'VariableNames', ...
    {'Patient','Band','Activity','Mobility','Complexity'});
writetable(T, outFile);
disp(['Results saved to: ' outFile]);

end

%% =========================================================
% STATISTICAL ANALYSIS
%% =========================================================
function runStatisticalAnalysis()

fileHealthy = 'Hjorth_Results_Healthy_Patients.xlsx';
fileAD = 'Hjorth_Results_AD_Patients.xlsx';

dataHealthy = readtable(fileHealthy);
dataAD = readtable(fileAD);

bands = {'Delta','Theta','Alpha','Beta','Gamma'};
params = {'Activity','Mobility','Complexity'};

resultsHealthy = runOneSampleTTest(dataHealthy, bands, params, 'Healthy', 'TTest_Healthy.xlsx');
resultsAD      = runOneSampleTTest(dataAD, bands, params, 'AD', 'TTest_AD.xlsx');

resultsComp = runTwoSampleTTest(dataHealthy, dataAD, bands, params, 'TTest_Comparison.xlsx');
disp(resultsComp);

% Line Plot
figure; hold on;
x = 1:length(bands);
for p = 1:length(params)
    for b = 1:length(bands)
        meanH(b) = resultsHealthy.Mean(strcmp(resultsHealthy.Band,bands{b}) & strcmp(resultsHealthy.Parameter,params{p}));
        meanA(b) = resultsAD.Mean(strcmp(resultsAD.Band,bands{b}) & strcmp(resultsAD.Parameter,params{p}));
    end
    plot(x, meanH,'-o'); plot(x, meanA,'--s');
end
set(gca,'XTick',x,'XTickLabel',bands); grid on; hold off;

% Bar Plot
figure;
for p=1:length(params)
    subplot(1,3,p);
    for b=1:length(bands)
        H(b)=resultsHealthy.Mean(strcmp(resultsHealthy.Band,bands{b}) & strcmp(resultsHealthy.Parameter,params{p}));
        A(b)=resultsAD.Mean(strcmp(resultsAD.Band,bands{b}) & strcmp(resultsAD.Parameter,params{p}));
    end
    bar([H(:) A(:)]);
    set(gca,'XTickLabel',bands); title(params{p}); grid on;
end

end

%% =========================================================
% HJORTH PARAMETERS
%% =========================================================
function [Activity, Mobility, Complexity] = hjorth_params(x)

x = double(x(:)) - mean(x);
Activity = var(x,1);

dx = diff(x);
if isempty(dx)
    Mobility=NaN; Complexity=NaN; return;
end

Mobility = sqrt(var(dx,1)/Activity);
ddx = diff(dx);

if isempty(ddx)||var(dx,1)==0
    Complexity=NaN;
else
    Complexity = sqrt(var(ddx,1)/var(dx,1)) / Mobility;
end

end

%% =========================================================
% ONE-SAMPLE T-TEST
%% =========================================================
function results = runOneSampleTTest(data,bands,params,groupName,outFile)

resultsStruct = struct([]);

for b=1:length(bands)
    for p=1:length(params)
        vals = data.(params{p})(strcmp(data.Band,bands{b}));
        [h,pval,~,stats] = ttest(vals,0);
        resultsStruct(end+1).Group=groupName;
        resultsStruct(end).Band=bands{b};
        resultsStruct(end).Parameter=params{p};
        resultsStruct(end).Mean=mean(vals);
        resultsStruct(end).SEM=std(vals)/sqrt(length(vals));
        resultsStruct(end).Hypothesis=h;
        resultsStruct(end).pValue=pval;
        resultsStruct(end).tStat=stats.tstat;
        resultsStruct(end).df=stats.df;
    end
end

results = struct2table(resultsStruct);
writetable(results,outFile);
fprintf('%s one-sample results saved: %s\n',groupName,outFile);

end

%% =========================================================
% TWO-SAMPLE T-TEST
%% =========================================================
function results = runTwoSampleTTest(dataH,dataA,bands,params,outFile)

resultsStruct = struct([]);

for b=1:length(bands)
    for p=1:length(params)
        vH = dataH.(params{p})(strcmp(dataH.Band,bands{b}));
        vA = dataA.(params{p})(strcmp(dataA.Band,bands{b}));
        [h,pval,~,stats] = ttest2(vH,vA);
        resultsStruct(end+1).Band=bands{b};
        resultsStruct(end).Parameter=params{p};
        resultsStruct(end).MeanHealthy=mean(vH);
        resultsStruct(end).MeanAD=mean(vA);
        resultsStruct(end).pValue=pval;
        resultsStruct(end).tStat=stats.tstat;
        resultsStruct(end).df=stats.df;
        resultsStruct(end).Significant=h;
    end
end

results = struct2table(resultsStruct);
writetable(results,outFile);
fprintf('Comparison results saved: %s\n',outFile);

end
