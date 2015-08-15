% [Gain_Peaking Frequency_Max_Gain_Peaking] = Search_Gain_Peaking(Frequency,Suppression,Display)
% This function returns the Gain margin and the phase margin of the open loop
% VL - December 20, 2012: - Initial rev: 6570

function [Gain_Peaking Frequency_Max_Gain_Peaking] = Search_Gain_Peaking(Frequency,Suppression,Display)

I200 = find(Frequency >200,1);
Frequency = Frequency(1:I200);
Suppression = Suppression(1:I200);



Info_Color=[0 0.1 0.8];
[Gain_Peaking Index]=max(abs(Suppression));
Frequency_Max_Gain_Peaking=Frequency(Index);
switch Display
    case 1
        cprintf(Info_Color,['The maximum gain peaking ',num2str(round(100*Gain_Peaking)/100),' is obtained at ' ,num2str(round(100*Frequency_Max_Gain_Peaking)/100),'Hz.']); fprintf('\n');
    case 2
        annotation(gcf,'textbox',...
            [0.67 0.92 0.3 0.04],...
            'String',['The maximum gain peaking ',num2str(round(100*Gain_Peaking)/100),' is obtained at ' ,num2str(round(100*Frequency_Max_Gain_Peaking)/100),'Hz.'],...
            'FontSize',14,...
            'FitBoxToText','off',...
            'LineStyle','none');
    case 3
        annotation(gcf,'textbox',...
        [0.67 0.95 0.3 0.04],...
            'String',['The maximum gain peaking ',num2str(round(100*Gain_Peaking)/100),' is obtained at ' ,num2str(round(100*Frequency_Max_Gain_Peaking)/100),'Hz.'],...
            'FontSize',14,...
            'FitBoxToText','off',...
            'LineStyle','none');
            case 4
       title(['The maximum gain peaking ',num2str(round(100*Gain_Peaking)/100),' is obtained at ' ,num2str(round(100*Frequency_Max_Gain_Peaking)/100),'Hz.'],...
                'fontsize',20);

end
end
