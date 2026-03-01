clc; clear; close all;

% ==========================
% Step 1: Load Excel files
% ==========================
fileHealthy = 'Hjorth_Results_Healthy_Patients.xlsx';
fileAD      = 'Hjorth_Results_AD_Patients.xlsx';

dataHealthy = readtable(fileHealthy);
dataAD      = readtable(fileAD);

% ==========================
% Step 2: Define bands and parameters
% ==========================
bands = {'Delta','Theta','Alpha','Beta','Gamma'};
params = {'Activity','Mobility','Complexity'};

% ==========================
% Step 3: Run one-sample t-tests (optional)
% ==========================
resultsHealthy = runOneSampleTTest(dataHealthy, bands, params, 'Healthy', 'TTest_Healthy_OneSample.xlsx');
resultsAD      = runOneSampleTTest(dataAD, bands, params, 'AD', 'TTest_AD_OneSample.xlsx');

% ==========================
% Step 4: Run two-sample t-test between groups
% ==========================
resultsComparison = runTwoSampleTTest(dataHealthy, dataAD, bands, params, 'TTest_Comparison.xlsx');
disp(resultsComparison); % Display comparison table

% ==========================
% Step 5: Visualization (Optional)
% ==========================

figure; hold on;
x = 1:length(bands);
colors = lines(length(params));

for p = 1:length(params)
    meanHealthy = resultsHealthy.Mean(strcmp(resultsHealthy.Parameter, params{p}));
    meanAD      = resultsAD.Mean(strcmp(resultsAD.Parameter, params{p}));

    % Healthy solid line
    plot(x, meanHealthy, '-o', 'Color', colors(p,:), ...
        'MarkerFaceColor', colors(p,:), 'LineWidth', 1.5, ...
        'DisplayName', ['Healthy - ' params{p}]);

    % AD dashed line
    plot(x, meanAD, '--s', 'Color', colors(p,:), ...
        'MarkerFaceColor', 'w', 'LineWidth', 1.5, ...
        'DisplayName', ['AD - ' params{p}]);
end

set(gca, 'XTick', 1:length(bands), 'XTickLabel', bands);
xlabel('Frequency Band'); ylabel('Mean Value');
title('Healthy vs AD Patients: Hjorth Parameters per Band');
legend('Location','bestoutside'); grid on; hold off;

figure;

for p = 1:length(params)
    subplot(1,length(params),p); hold on;

    meanHealthy = [];
    meanAD = [];

    for b = 1:length(bands)
        idxH = strcmp(resultsHealthy.Band, bands{b}) & strcmp(resultsHealthy.Parameter, params{p});
        idxA = strcmp(resultsAD.Band, bands{b}) & strcmp(resultsAD.Parameter, params{p});
        meanHealthy(end+1) = resultsHealthy.Mean(idxH);
        meanAD(end+1)      = resultsAD.Mean(idxA);
    end

    % Convert to matrix for bar()
    barData = [meanHealthy(:) meanAD(:)];  % Nx2 matrix
    hb = bar(barData, 'grouped'); % Grouped bar plot

    % Set bar colors
    set(hb(1),'FaceColor',[0.2 0.6 0.8]); % Healthy (Blue)
    set(hb(2),'FaceColor',[0.9 0.4 0.2]); % AD (Red)

    set(gca, 'XTick', 1:length(bands), 'XTickLabel', bands);
    xlabel('Frequency Band','FontWeight','bold');
    ylabel('Mean Value','FontWeight','bold');
    title(params{p},'FontWeight','bold');
    legend({'Healthy','AD'}, 'Location','Best');
    grid on;
    hold off;
end

% Use annotation or suptitle for title across subplots
% Adjust figure size for better spacing
set(gcf, 'Position', [100, 100, 1000, 400]);

% Add annotation title above subplots
annotation('textbox', [0 0.94 1 0.05], 'String', ...
    'Healthy vs AD Patients : Hjorth Parameters per Band (Bar Graph)', ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
    'FontWeight','bold', 'FontSize',12);




% ==========================
% Function: One-sample t-test
% ==========================
function results = runOneSampleTTest(data, bands, params, groupName, outFile)
    resultsStruct = struct('Group', {}, 'Band', {}, 'Parameter', {}, 'Mean', {}, ...
                           'SEM', {}, 'Hypothesis', {}, 'pValue', {}, 'tStat', {}, 'df', {});
    for b = 1:length(bands)
        bandData = data(strcmp(data.Band, bands{b}), :);
        for p = 1:length(params)
            vals = bandData.(params{p});
            [h, pval, ci, stats] = ttest(vals, 0);
            resultsStruct(end+1) = struct( ...
                'Group', groupName, ...
                'Band', bands{b}, ...
                'Parameter', params{p}, ...
                'Mean', mean(vals), ...
                'SEM', std(vals)/sqrt(length(vals)), ...
                'Hypothesis', h, ...
                'pValue', pval, ...
                'tStat', stats.tstat, ...
                'df', stats.df );
        end
    end
    results = struct2table(resultsStruct);
    writetable(results, outFile);
end

% ==========================
% Function: Two-sample t-test
% ==========================
function results = runTwoSampleTTest(dataHealthy, dataAD, bands, params, outFile)
    resultsStruct = struct('Band', {}, 'Parameter', {}, 'MeanHealthy', {}, 'MeanAD', {}, ...
                           'pValue', {}, 'tStat', {}, 'df', {}, 'Significant', {});
    for b = 1:length(bands)
        for p = 1:length(params)
            valsH = dataHealthy.(params{p})(strcmp(dataHealthy.Band, bands{b}));
            valsA = dataAD.(params{p})(strcmp(dataAD.Band, bands{b}));
            [h, pval, ci, stats] = ttest2(valsH, valsA);
            resultsStruct(end+1) = struct( ...
                'Band', bands{b}, ...
                'Parameter', params{p}, ...
                'MeanHealthy', mean(valsH), ...
                'MeanAD', mean(valsA), ...
                'pValue', pval, ...
                'tStat', stats.tstat, ...
                'df', stats.df, ...
                'Significant', h );
        end
    end
    results = struct2table(resultsStruct);
    writetable(results, outFile);
end