clear
%%
addpath('../');

file.name = './140826_TT_P2A.xml';

[file.path file.base file.ext] = fileparts(file.name);

%dtt = DttData(file.name, 'verbose');
dtt = DttData(file.name); % non verbose mode

% save([file.path '/' file.base '.mat'],'dtt');

% load([file.path '/' file.base '.mat']);

color_list = [
    [1 0 0];
    [0 0 1];
    [0 .5 0];
    [1 0 1];
    [1 .5 0];
    [0 0 0];
];

chA_name1  = 'H1:SUS-OM1_M1_LOCK_P_EXC';
chB_name11 = 'H1:SUS-OM1_M1_DAMP_P_IN1_DQ';
chB_name12 = 'H1:SUS-OM1_M1_DAMP_Y_IN1_DQ';

chA_name2  = 'H1:SUS-OM2_M1_LOCK_P_EXC';
chB_name21 = 'H1:SUS-OM2_M1_DAMP_P_IN1_DQ';
chB_name22 = 'H1:SUS-OM2_M1_DAMP_Y_IN1_DQ';

chA_name3  = 'H1:SUS-OM3_M1_LOCK_P_EXC';
chB_name31 = 'H1:SUS-OM3_M1_DAMP_P_IN1_DQ';
chB_name32 = 'H1:SUS-OM3_M1_DAMP_Y_IN1_DQ';

[freq1 tf11]  = dtt.transferFunction(chA_name1, chB_name11);
[freq1 coh11] = dtt.coherence(chA_name1, chB_name11);
[freq1 tf12]  = dtt.transferFunction(chA_name1, chB_name12);
[freq1 coh12] = dtt.coherence(chA_name1, chB_name12);

[freq2 tf21]  = dtt.transferFunction(chA_name2, chB_name21);
[freq2 coh21] = dtt.coherence(chA_name2, chB_name21);
[freq2 tf22]  = dtt.transferFunction(chA_name2, chB_name22);
[freq2 coh22] = dtt.coherence(chA_name2, chB_name22);

[freq3 tf31]  = dtt.transferFunction(chA_name3, chB_name31);
[freq3 coh31] = dtt.coherence(chA_name3, chB_name31);
[freq3 tf32]  = dtt.transferFunction(chA_name3, chB_name32);
[freq3 coh32] = dtt.coherence(chA_name3, chB_name32);

%%
figure(1);
clf;
orient landscape;
subplot(4,1,[1 2]);
loglog(freq1,abs(tf11),'-','Color', color_list(1,:));
grid on;
hold on;
loglog(freq1,abs(tf12),'-','Color', color_list(2,:));
loglog(freq2,abs(tf21),'-','Color', color_list(3,:));
loglog(freq2,abs(tf22),'-','Color', color_list(4,:));
loglog(freq3,abs(tf31),'-','Color', color_list(5,:));
loglog(freq3,abs(tf32),'-','Color', color_list(6,:));
set(gca, 'FontSize', 14);
xlim([0.1,100]);
ylim([0.99e-5,1000]);
set(gca,'YTick',10.^[-5:3]);
ylabel('\bfMagnitude');
hlegend = legend(...
    [chB_name11 ' / ' chA_name1],...
    [chB_name12 ' / ' chA_name1],...
    [chB_name21 ' / ' chA_name2],...
    [chB_name22 ' / ' chA_name2],...
    [chB_name31 ' / ' chA_name3],...
    [chB_name32 ' / ' chA_name3],...
    'Location','NorthEast'...
);
set(hlegend,'FontSize',8,'Interpreter','None');
title(...
    {'\bfOM1/2/3: Pitch actuation to OSEM Pitch/Yaw transfer functions (2014/8/26)';...
    'Before setting DRIVEALIGN matrix / No dumping'},...
    'FontSize',16 ...
);

subplot(4,1,3);
semilogx(freq1,mod(angle(tf11)/pi*180,360)-180,'-','Color', color_list(1,:));
grid on;
hold on;
semilogx(freq1,mod(angle(tf12)/pi*180,360)-180,'-','Color', color_list(2,:));
semilogx(freq2,mod(angle(tf21)/pi*180,360)-180,'-','Color', color_list(3,:));
semilogx(freq2,mod(angle(tf22)/pi*180,360)-180,'-','Color', color_list(4,:));
semilogx(freq3,angle(tf31)/pi*180,'-','Color', color_list(5,:));
semilogx(freq3,angle(tf32)/pi*180,'-','Color', color_list(6,:));
xlim([0.1,100]);
ylim([-180 180]);
set(gca, 'FontSize', 14);
set(gca,'YTick',-180:60:180);
ylabel('\bfPhase [deg]');

subplot(4,1,4);
semilogx(freq1, coh11,'-','Color', color_list(1,:));
grid on;
hold on;
semilogx(freq1, coh12,'-','Color', color_list(2,:));
semilogx(freq2, coh21,'-','Color', color_list(3,:));
semilogx(freq2, coh22,'-','Color', color_list(4,:));
semilogx(freq3, coh31,'-','Color', color_list(5,:));
semilogx(freq3, coh32,'-','Color', color_list(6,:));
xlim([0.1,100]);
set(gca, 'FontSize', 14);
set(gca,'YTick',[0:0.2:1]);
xlabel('\bfFrequency [Hz]');
ylabel('\bf Coherence');

print(['./', file.base, '.pdf'],'-dpdf','-r600');
