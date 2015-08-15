%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Clean Indentical poles and zeros
%
%
% None bugs to be fixed:
%
% - doesn't work if the filter has reals poles and zeros non equal to 0
% 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function Cleaned_Filter = Clean_Filter(Initial_Filter, Criteria)


pif=sort(pole(Initial_Filter)); % Pole of initial filter
zif=sort(zero(Initial_Filter)); % Zeros of initial filter

pif_reals=find(pif==0);         % find the number of poles =0
zif_reals=find(zif==0);         % find the number of poles =0
 
pif=pif((length(pif_reals)+1):length(pif));     % Remove the 0 of the poles list
zif=zif((length(zif_reals)+1):length(zif));    % Remove the 0 of the zeros list

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make a list of bad poles and zeros for each pair of complex pole
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bad_list=[];                     
for jj=1:2:length(pif)                
    for kk=1:2:length(zif)
        test=1-abs(pif(jj)/zif(kk)); 
        if abs(test) < Criteria;
            if abs(real(pif(jj))-real(zif(kk))) < Criteria;
               bad_list=[bad_list;jj kk];
           end
        end   
    end 
end    
                            % (Bad poles in first column, Bad zeros in 2nd column)
[aa,bb]=size(bad_list);


%%
% If identical poles and zeros exist
if [aa,bb]~= [0,0]
    
    % Remove poles equals to two different zeros from the list
    Bad_list=[bad_list(1,:)];
    for nn=2:aa
        if bad_list(nn,1)~=bad_list(nn-1,1)
            if bad_list(nn,2)~=bad_list(nn-1,2)
                Bad_list=[Bad_list; bad_list(nn,:)];
            end
        end
    end
    bad_list=Bad_list;
    [aa,bb]=size(bad_list);

    
    % Make a new list of Poles (cleaned filter)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    pcf=[];
    nn=[1];
    for kk=1:2:(length(pif)-1)
        if kk~=bad_list(nn,1)                % If this pole is not in the bas list, then keep it
            pcf=[pcf; pif(kk); pif(kk+1)];   % then keep it           
        else
            if nn < aa
                nn=nn+1;          % next pole in the bad list
            end
        end
    end

    % Make a new list of Zeros (cleaned filter)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    zcf=[];                           % Zeros of cleaned filter
    nn=[1];
    for kk=1:2:(length(zif)-1)
        if kk~=bad_list(nn,2)
            zcf=[zcf; zif(kk); zif(kk+1)];
        else
            if nn<aa
                nn=nn+1;
            end
        end
    end

    % add the removed 0 
    Removed=length(pif_reals)-length(zif_reals);   
    if Removed>0
        pcf=[zeros(Removed,1); pcf];
        zcf=[zcf];
    elseif  Removed<0   
        pcf=[pcf];
        zcf=[zeros(abs(Removed),1); zcf];
    elseif  Removed==0   
        pcf=[pcf];
        zcf=[zcf];   
    end
    
    % Rebuild the final filter
    [a,g]=zero(Initial_Filter);
    Cleaned_Filter =zpk([zcf],[pcf],g);   

else   % If there is no identical complex poles and zeros 
    % add the removed 0 
    Removed=length(pif_reals)-length(zif_reals);   
    if Removed>0
        pcf=[zeros(Removed,1); pif];
        zcf=[zif];
    elseif  Removed<0   
        pcf=[pif];
        zcf=[zeros(abs(Removed),1); zif];
    elseif  Removed==0   
        pcf=[pif];
        zcf=[zif];   
    end
    

    % Rebuild the final filter
    [a,g]=zero(Initial_Filter);
    Cleaned_Filter =zpk([zcf],[pcf],g);      
 
end


pcf;
zcf;
Test=Cleaned_Filter/Initial_Filter;
disp('Test:');
Test;

