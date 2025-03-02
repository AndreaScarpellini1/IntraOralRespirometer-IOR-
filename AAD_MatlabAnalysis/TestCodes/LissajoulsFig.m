clc
clear 
close all

directory =  cd;
root  = directory(1:end-length('\AAD_MatlabAnalysis'));
filefolder = fullfile(root,'Data\OPTOvsIOR1_Processed');

%%
load(fullfile(filefolder,'OPTvsIOR1.mat'));

plotLissajous(FILE1(1836:2934,:))
plotLissajous(FILE1(1:1215,:))

%%
load(fullfile(filefolder,'OPTvsIOR2.mat'));
plotLissajous(FILE2(:,:))
plotLissajous(FILE2(1:1222,:))
plotLissajous(FILE2(1222:1615,:))
plotLissajous(FILE2(1615:2876,:))
plotLissajous(FILE2(2876:3261,:))
%%
function plotLissajous(FILE1)
    % plotLissajous(FILE1)
    % FILE1 is expected to be an N-by-2 matrix where:
    %   FILE1(:,1) is the first signal
    %   FILE1(:,2) is the second signal
    %
    % This function:
    %   (1) Normalizes both signals individually to the range [-1, +1].
    %   (2) Plots both normalized signals vs. sample index (time-domain).
    %   (3) Plots the Lissajous figure (2D phase plot of the two signals).

    % --- Check input size ---
    if size(FILE1,2) < 2
        error('Input matrix FILE1 must have at least two columns.');
    end

    % --- Extract signals ---
    sig1 = FILE1(:,1);
    sig2 = FILE1(:,2);

    % --- Normalize each signal to [-1, +1] ---
    normSig1 = normalizeToNeg1Pos1(sig1);
    normSig2 = normalizeToNeg1Pos1(sig2);

    % Create a new figure
    figure;

    % --- Subplot 1: Normalized signals vs. sample index ---
    subplot(2,1,1)
    plot(normSig1, 'r', 'LineWidth', 1.2);
    hold on
    plot(normSig2, 'b', 'LineWidth', 1.2);
    hold off
    title('Time-Domain Signals (Normalized to [-1, +1])')
    xlabel('Sample Index')
    ylabel('Amplitude')
    legend('Signal 1','Signal 2', 'Location', 'best')
    grid on

    % --- Subplot 2: Lissajous figure using normalized signals ---
    subplot(2,1,2)
    plot(normSig1, normSig2, '.k', 'LineWidth', 1.2);
    title('Lissajous Figure (Normalized)')
    xlabel('Signal 1')
    ylabel('Signal 2')
    grid on
    axis equal 
    xlim([-1,1])
    ylim([-1,1])

end

% --- Local helper function for normalization ---
function out = normalizeToNeg1Pos1(x)
    % normalizeToNeg1Pos1 scales input vector x to the range [-1, +1].
    minVal = min(x);
    maxVal = max(x);
    rangeVal = maxVal - minVal;

    % If the signal is constant or all zeros, avoid dividing by zero:
    if rangeVal == 0
        % We can set it to zero or handle it differently
        out = zeros(size(x));  % All values become zero
    else
        % First map to [0, 1], then shift and scale to [-1, 1]
        out = 2*((x - minVal) / rangeVal) - 1;
    end
end
