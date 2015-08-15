function [Xnew,Ynew]= dataSmooth(X,Y,windowSize,trend)
% [freqNew,smoothedData]= dataSmoothLog(frequencyVec,dataVec,windowSize, trend)
% A function for smoothing data whose X axis is on a log or linear scale.
%
% X is usually time or frequency. It has to be a sorted vector.
%
% Y is whatever data you're plotting on the Y axis.
%
% windowSize ranges from 1 to 1000 and means an increment of
% 1+windowSize*1E-2 for log scale and windowSize*1E-2 for linear scale.
% Default is 10.
%
% trend is either "LINEAR" or "LOGARITHMIC". Use "LOGARITHMIC" if you're
% doing loglog or semilogx plots.
%
% Doug Beck 2010.06.17
% 
% Modified Daniel Clark 2011.05.10
%
% Window sizes around 1.01 work well typically 
%
    if(length(windowSize)==0)
        windowSize=10;
    end
    
    if(~(strcmp(trend,'LINEAR') || strcmp(trend,'LOGARITHMIC')))
        ERROR('Trend should be "LINEAR" or "LOGARITHMIC"')
    end
    
    if(strcmp(trend,'LOGARITHMIC'))
        windowSize=1+windowSize*1E-2;
    else
        windowSize=windowSize*1E-2;
    end
    
    oldIndex=1;
    
    if(strcmp(trend,'LOGARITHMIC'))
        newIndex=find(X>(X(oldIndex)*windowSize),1);
    else
        newIndex=find(X>(X(oldIndex)+windowSize),1);
    end
    
    smoothedIndex=1;
    
    while(newIndex<length(X))
        
        
        Xnew(smoothedIndex)=mean(X(oldIndex:newIndex));
        Ynew(smoothedIndex)=mean(Y(oldIndex:newIndex));
        
        oldIndex=newIndex;
        
        if(strcmp(trend,'LOGARITHMIC'))
            newIndex=find(X>(X(oldIndex)*windowSize),1);
        else
            newIndex=find(X>(X(oldIndex)+windowSize),1);
        end
        
        smoothedIndex=smoothedIndex+1;
        
    end


end