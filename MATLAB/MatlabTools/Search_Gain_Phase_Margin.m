% [Overall_Gain_Margin Frequency_Min_Gain_Margin Overall_Phase_Margin Frequency_Min_Phase_Margin Gain_Margin Phase_Margin] = Search_Gain_Phase_Margin(Frequency,OL)
% This function returns the Gain margin and the phase margin of the open loop
% VL - December 20, 2012: - Initial rev: 6570

function [Overall_Gain_Margin Frequency_Min_Gain_Margin Overall_Phase_Margin Frequency_Min_Phase_Margin Gain_Margin Phase_Margin UGF] = Search_Gain_Phase_Margin(Frequency,OL,Display)

I200 = find(Frequency >200,1);
Frequency = Frequency(1:I200);
OL = OL(1:I200);

Info_Color=[0 0.1 0.8];
if nargin<3
    Display=0;
end

Index=[];
rads=180/pi;
Counter_2=1;
% Phase Margin
for Counter_1=1:length(Frequency)-1
    if or(and(abs(OL(Counter_1))>=1,abs(OL(Counter_1+1))<1),and(abs(OL(Counter_1))<=1,abs(OL(Counter_1+1))>1))
        Index(Counter_2)=Counter_1;
        Counter_2=Counter_2+1;
    end
end

if isempty(Index)
    Phase_Margin(1,1:2)=[0 0];
    UGF=[];
else
    for Counter_1=1:length(Index)
        Temp=rads*(angle(OL(Index(Counter_1))));
        Phase_Margin(Counter_1,1)=180-abs(Temp);
        Phase_Margin(Counter_1,2)=(Frequency(Index(Counter_1))+Frequency(Index(Counter_1)+1))/2;
    end
    UGF=(Frequency(max(Index))+Frequency(max(Index)+1))/2;    
end
[Overall_Phase_Margin Index]=min(Phase_Margin(:,1));
Frequency_Min_Phase_Margin=Phase_Margin(Index,2);

% Gain Margin
% Phase Margin
clear Index
Index=1;
Counter_2=1;
for Counter_1=1:length(Frequency)-1
    if or(and(rads*angle(OL(Counter_1))>170,rads*angle(OL(Counter_1+1))<-170),and(rads*angle(OL(Counter_1))<-170,rads*angle(OL(Counter_1+1))>170))
        Index(Counter_2)=Counter_1;
        Counter_2=Counter_2+1;
    end
end
for Counter_1=1:length(Index)
    Gain(Counter_1,1)=(abs(OL(Index(Counter_1)))+abs(OL(Index(Counter_1)+1)))/2;
    Gain_Margin(Counter_1,2)=(Frequency(Index(Counter_1))+Frequency(Index(Counter_1)+1))/2;
end
[Gain_Max Index]=max(Gain(:,1));
Overall_Gain_Margin=-20*log10(Gain_Max);
Frequency_Min_Gain_Margin=Gain_Margin(Index,2);
switch Display
    case 1
        cprintf(Info_Color,['The minimum gain margin is ',num2str(round(10*Overall_Gain_Margin)/10),'dB at ' ,num2str(round(100*Frequency_Min_Gain_Margin)/100),'Hz.']); fprintf('\n');
        if Overall_Phase_Margin == 0
            cprintf(Info_Color,['The open loop does not cross 0.']); fprintf('\n');
        else
            cprintf(Info_Color,['The minimum phase margin is ',num2str(round(10*Overall_Phase_Margin)/10),' degrees at ' ,num2str(round(100*Frequency_Min_Phase_Margin)/100),'Hz.']); fprintf('\n');
            cprintf(Info_Color,['UGF is ', num2str(round(100*UGF)/100),'Hz.']); fprintf('\n');
        end
    case 2
        annotation(gcf,'textbox',...
            [0.67 0.96 0.3 0.04],...
            'String',['The minimum gain margin is ',num2str(round(10*Overall_Gain_Margin)/10),'dB at ' ,num2str(round(100*Frequency_Min_Gain_Margin)/100),'Hz.'],...
            'FontSize',14,...
            'FitBoxToText','off',...
            'LineStyle','none');
        if Overall_Phase_Margin == 0
            annotation(gcf,'textbox',...
            [0.67 0.94 0.3 0.04],...
            'String',['The open loop does not cross 0.'],...
            'FontSize',14,...
            'FitBoxToText','off',...
            'LineStyle','none');
        else
            annotation(gcf,'textbox',...
            [0.67 0.94 0.3 0.04],...
            'String',['The minimum phase margin is ',num2str(round(10*Overall_Phase_Margin)/10),' degrees at ' ,num2str(round(100*Frequency_Min_Phase_Margin)/100),'Hz.'],...
            'FontSize',14,...
            'FitBoxToText','off',...
            'LineStyle','none');
        
            annotation(gcf,'textbox',[0.03 0.94 0.3 0.04],...
            'String',['UGF: ',num2str(round(100*UGF)/100),'Hz'],...
            'FontSize',26,...
            'FitBoxToText','off',...
            'LineStyle','none');
        end
    case 3
        xlabel(['The minimum phase margin is ',num2str(round(10*Overall_Phase_Margin)/10),' degrees at ' ,num2str(round(100*Frequency_Min_Phase_Margin)/100),'Hz.'],...
                'fontsize',20);
end
end
