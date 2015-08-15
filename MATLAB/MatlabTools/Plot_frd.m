% Plot_frd(TF_frd,Coh_frd,Input,Output,Plot_Info)
% January 24, 2013 - VL

function Plot_frd(TF_frd,Coh_frd,Input,Output,Plot_Info)
scrsz = get(0,'ScreenSize');
rads=180/pi;
if scrsz(3)>2*scrsz(4)
    Position_figure=[1 1 scrsz(3)/2 scrsz(4)/1.07]; 
else
	Position_figure=[1 1 scrsz(3) scrsz(4)/1.07]; 
end
fontsize_gca=14;
fontsize_title=18;
fontsize_legend=12;
color=lines(12);

[TF Frequency]=frdata(TF_frd);
[Coh Frequency]=frdata(Coh_frd);
Min_Freq=min(Frequency);
Max_Freq=max(Frequency);


figure('Name','Transfer functions comparison')
set(gcf,'Position',Position_figure)
set(gcf,'Color','white')
subplot(7,1,[1 2 3])
hold on
for Counter_1=1:length(Input)
    plot(Frequency,abs(squeeze(TF(Output(Counter_1),Input(Counter_1),:))),'Color',color(Counter_1,:),'LineWidth',2)
    Mini_mag_exp(Counter_1)=min(floor(log10(min(abs(squeeze(TF(Output(Counter_1),Input(Counter_1),:)))))));
    Maxi_mag_exp(Counter_1)=max(ceil(log10(max(abs(squeeze(TF(Output(Counter_1),Input(Counter_1),:)))))));
end
Mini_mag_exp=min(Mini_mag_exp);
Maxi_mag_exp=max(Maxi_mag_exp);
axis([Min_Freq Max_Freq 10^Mini_mag_exp 10^Maxi_mag_exp])
grid on
set(gca,'XScale','log','yScale','log','FontSize',fontsize_gca)
ylabel('Magnitude (count/count)')
title(Plot_Info.Title_str,'FontSize',fontsize_title)

for Counter_1=1:length(Input)
    legend_str(Counter_1,:)=[[TF_frd.InputName(Input(Counter_1),:) ' to ' TF_frd.OutputName(Output(Counter_1),:)]];
end

for Counter_1=1:length(Input)
    legend_str_cat{Counter_1,:}=strcat(legend_str{Counter_1,1},legend_str{Counter_1,2},legend_str{Counter_1,3});
end
legend_str_cat=regexprep(legend_str_cat, '_', ' ');
legend(legend_str_cat,'FontSize',fontsize_legend,'Location','best');

subplot(7,1,[4 5 6])
hold on
for Counter_1=1:length(Input)
    plot(Frequency,rads*angle(squeeze(TF(Output(Counter_1),Input(Counter_1),:))),'Color',color(Counter_1,:),'LineWidth',2)
end
grid on
set(gca,'XScale','log','yScale','lin','FontSize',fontsize_gca,'Ytick',-180:45:180)
ylabel('Angle(\circ)')
axis([Min_Freq Max_Freq -200 200])

subplot(7,1,7)
hold on
for Counter_1=1:length(Input)
    plot(Frequency,abs(squeeze(Coh(Output(Counter_1),Input(Counter_1),:))),'Color',color(Counter_1,:),'LineWidth',2)
end
grid on
set(gca,'XScale','log','yScale','lin','FontSize',fontsize_gca)
xlabel('Frequency (Hz)')
ylabel('Coherence')
axis([Min_Freq Max_Freq 0 1])
IDfig

if Plot_Info.Autosave==1
	figure_fig=strcat(Plot_Info.save_path, '/', Plot_Info.save_file_name , '.fig');
	figure_pdf=strcat(Plot_Info.save_path, '/', Plot_Info.save_file_name , '.pdf');
	FillPage('w')
	saveas(gcf,['/' figure_pdf{:}])
	saveas(gcf,['/' figure_fig{:}])
end
