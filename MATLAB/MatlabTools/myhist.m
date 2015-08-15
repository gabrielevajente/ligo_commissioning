function [histVals,bars] = myhist(x)

nPoints = length(x);

% Scott Method
binWidth = (3.5 * std(x)) / nPoints^(1/3);
nBins = ceil((max(x) - min(x)) / binWidth);

bins = linspace(min(x),max(x),nBins);

[histVals,bars] = hist(x,bins);

% bb = bar(bars,histVals,1);