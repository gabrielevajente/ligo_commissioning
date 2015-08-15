% Plot_Comparison_TF_ISI(TF_1_frd,TF_2_frd,Coh_1_frd,Coh_2_frd,Date_1,Date_2,Actuator,Sensor,Unit,Unit_ID,save_path,save_file_name)
% November 15, 2011 - VL
function Plot_Comparison_TF_HEPI(TF_1_frd,TF_2_frd,Coh_1_frd,Coh_2_frd,Date_1,Date_2,Actuator,Sensor,Unit,Unit_ID,save_path,save_file_name)

scrsz = get(0,'ScreenSize');
rads=180/pi;
Position_figure=[1 1 scrsz(3)/2 scrsz(4)/1.07]; %for double screen display
fontsize_gca=14;
fontsize_title=18;
fontsize_legend=12;
color=lines(12);

[TF_1 Frequency_1]=frdata(TF_1_frd);
[TF_2 Frequency_2]=frdata(TF_2_frd);
if isempty(Coh_1_frd) == 0
    [Coh_1 Frequency_1]=frdata(Coh_1_frd);
end
if isempty(Coh_2_frd) == 0
    [Coh_2 Frequency_2]=frdata(Coh_2_frd);
end
Min_Freq=min(min(Frequency_1),min(Frequency_2));
Max_Freq=max(max(Frequency_1),max(Frequency_2));

Date_1_cat(1:4)=Date_1(1:4);
Date_1_cat(5:6)=Date_1(6:7);
Date_1_cat(7:8)=Date_1(9:10);
Date_2_cat(1:4)=Date_2(1:4);
Date_2_cat(5:6)=Date_2(6:7);
Date_2_cat(7:8)=Date_2(9:10);

Notes_cat_1=strcat(TF_1_frd.Notes,'-',Date_1_cat);
Notes_cat_2=strcat(TF_2_frd.Notes,'-',Date_2_cat);

if nargin<7
    Unit=1;
end

figure('Name','Transfer functions comparison')
set(gcf,'Position',Position_figure)
set(gcf,'Color','white')
subplot(7,1,[1 2 3])
hold on
for Counter_1=1:4
    TF_1_V=squeeze(TF_1(Sensor(Counter_1),Actuator(Counter_1),:));
    TF_2_V=squeeze(TF_2(Sensor(Counter_1),Actuator(Counter_1),:));
    TF_1_Index=find(TF_1_V);
    TF_2_Index=find(TF_2_V);
    
    Mini_mag_exp(Counter_1)=floor(min(log10(min(abs(TF_1_V(TF_1_Index)))),log10(min(abs(TF_2_V(TF_2_Index))))));
    Maxi_mag_exp(Counter_1)=ceil(max(log10(max(abs(TF_1_V(TF_1_Index)))),log10(max(abs(TF_2_V(TF_2_Index))))));
    
    plot(Frequency_1(TF_1_Index),abs(TF_1_V(TF_1_Index)),'Color',color(Counter_1,:),'LineWidth',2)
    plot(Frequency_2(TF_2_Index),abs(TF_2_V(TF_2_Index)),'Color',color(Counter_1+4,:),'LineStyle','-.','LineWidth',2)
end
Mini_mag_exp=min(Mini_mag_exp);
Maxi_mag_exp=max(Maxi_mag_exp);

grid on
set(gca,'XScale','log','yScale','log','FontSize',fontsize_gca,'Ytick',10.^[Mini_mag_exp:1:Maxi_mag_exp])
ylim([10^Mini_mag_exp 10^Maxi_mag_exp])
xlim([max(Frequency_1(1),Frequency_2(1)) max(Frequency_1(TF_1_Index(end)),Frequency_2(TF_2_Index(end)))]);

switch Unit
    case 1
    ylabel('Magnitude (count/count)')
    case 2
    ylabel('Magnitude (nm/count)')
    case 3
    ylabel('Magnitude (nrad/count)')
    case 4
	ylabel('Magnitude ((nm/s)/count)')
    case 5
	ylabel('Magnitude ((nrad/s)/count)')
    case 6
	ylabel('Magnitude (nm/count or nrad/count)')    
    case 7
	ylabel('Magnitude ((nm/s)/count or (nrad/s)/count)') 
end
legend_str=[[TF_1_frd.InputName(Actuator(1),:), ' to ', TF_1_frd.OutputName(Sensor(1),:), ' : ', Date_1_cat];...
            [TF_2_frd.InputName(Actuator(1),:), ' to ', TF_2_frd.OutputName(Sensor(1),:), ' : ', Date_2_cat];...
            [TF_1_frd.InputName(Actuator(2),:), ' to ', TF_1_frd.OutputName(Sensor(2),:), ' : ', Date_1_cat];...
            [TF_2_frd.InputName(Actuator(2),:), ' to ', TF_2_frd.OutputName(Sensor(2),:), ' : ', Date_2_cat];...
            [TF_1_frd.InputName(Actuator(3),:), ' to ', TF_1_frd.OutputName(Sensor(3),:), ' : ', Date_1_cat];...
            [TF_2_frd.InputName(Actuator(3),:), ' to ', TF_2_frd.OutputName(Sensor(3),:), ' : ', Date_2_cat];...
            [TF_1_frd.InputName(Actuator(4),:), ' to ', TF_1_frd.OutputName(Sensor(4),:), ' : ', Date_1_cat];...
            [TF_2_frd.InputName(Actuator(4),:), ' to ', TF_2_frd.OutputName(Sensor(4),:), ' : ', Date_2_cat]];

for Counter_1=1:8
    legend_str_cat{Counter_1,:}=strcat(legend_str{Counter_1,1},legend_str{Counter_1,2},legend_str{Counter_1,3},legend_str{Counter_1,4},legend_str{Counter_1,5});
end
title_str_cat=strcat({'Comparison transfer functions '}, {Date_1_cat},{' vs '}, {Date_2_cat});

legend(legend_str_cat,'FontSize',fontsize_legend,'Location','best');
title(title_str_cat,'FontSize',fontsize_title);

subplot(7,1,[4 5 6])
hold on
for Counter_1=1:4
    plot(Frequency_1(TF_1_Index),rads*angle(squeeze(TF_1(Sensor(Counter_1),Actuator(Counter_1),TF_1_Index))),'Color',color(Counter_1,:),'LineWidth',2)
    plot(Frequency_2(TF_2_Index),rads*angle(squeeze(TF_2(Sensor(Counter_1),Actuator(Counter_1),TF_2_Index))),'Color',color(Counter_1+4,:),'LineStyle','-.','LineWidth',2)
end
grid on
set(gca,'XScale','log','yScale','lin','FontSize',fontsize_gca,'Ytick',-180:45:180)
ylabel('Angle(\circ)')
xlim([max(Frequency_1(1),Frequency_2(1)) max(Frequency_1(TF_1_Index(end)),Frequency_2(TF_2_Index(end)))]);
ylim([-200 200])

subplot(7,1,7)
hold on
for Counter_1=1:3
    if isempty(Coh_1_frd)==0
        plot(Frequency_1,squeeze(Coh_1(Sensor(Counter_1),Actuator(Counter_1),:)),'Color',color(Counter_1,:),'LineWidth',2)
    end
    if isempty(Coh_2_frd)==0
        plot(Frequency_2,squeeze(Coh_2(Sensor(Counter_1),Actuator(Counter_1),:)),'Color',color(Counter_1+4,:),'LineStyle','-.','LineWidth',2)
    end
end
grid on
set(gca,'XScale','log','yScale','lin','FontSize',fontsize_gca)
xlim([max(Frequency_1(1),Frequency_2(1)) max(Frequency_1(TF_1_Index(end)),Frequency_2(TF_2_Index(end)))]);
xlabel('Frequency (Hz)')
ylabel('Coherence')
ylim([0 1])
IDfig

annotation(gcf,'textbox',...
    [0.69 0.95 0.3 0.04],...
    'String',{Notes_cat_1{:},Notes_cat_2{:}},...
    'FontSize',14,...
    'FitBoxToText','off',...
    'LineStyle','none');

date_str=strcat(Date_1_cat ,'_vs_', Date_2_cat);
figure_fig=strcat(save_path, '/', Unit_ID, '_Comparison_', save_file_name ,'_' ,date_str, '.fig');
figure_pdf=strcat(save_path, '/', Unit_ID, '_Comparison_', save_file_name ,'_' ,date_str, '.pdf');
FillPage('w')
saveas(gcf,['/' figure_pdf{:}])
saveas(gcf,['/' figure_fig{:}])
