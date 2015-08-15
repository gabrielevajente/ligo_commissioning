%plot stage 1 target for the BSC

clear
disp(['  running ',mfilename,' on ',date])
disp(' ')
close all

freq = logspace(-2,3,1000);

my_colors;

mySVN = '/Users/BTL/Brians_files/SeismicSVN/seismic/';
HEPI_path = 'HAM-ISI/Common/MatlabTools/HEPI_motion/';
addpath([mySVN,HEPI_path])

ground_x = Ligo2GroundMotionL(freq);
HEPI_x_shyang = HEPI_crossbeam_motion_horz(freq);
HEPI_x_samw   = HEPI_crossbeam_motion_horz_SamW(freq);

[ISI_stg2, diff_spec, old_spec, ISI_stg1] = BSC_req(freq);

%%
figure
ll=loglog(...
    freq, ground_x, 'g',...
    freq, HEPI_x_shyang, 'b',...
    freq, HEPI_x_samw, 'b--',...
    freq, ISI_stg1,'m',...
    freq, ISI_stg2, 'r');

set(ll,'LineWidth',2)
set(ll(1),'Color',[0 .7 0])
set(ll(4),'Color',dark_orange);

legend('LLO ground model','HEPI X est from Shyang','HEPI X est from Sam W',...
    'BSC stage 1 target','BSC stage 2 req');

axis([.1 100 1e-14 1e-5])
grid on
FillPage('w')
IDfig
title('SEI targets for X and Y')
xlabel('freq')
ylabel('motion ASD (m/\surdHz)')