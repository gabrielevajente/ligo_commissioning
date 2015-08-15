clear
rads = 180/pi;
nppts = 20E6;  %number of points in the data
total_time = 5000; %seconds

dt = total_time/nppts;  %data sample rate
df = 1/total_time;      %freqeucny resolution for fft
Nyquist = 0.5/dt;

%drive parameters
start_freq = 0.5;       
stop_freq = 10;
delta_freq = 0.05;

  %make sure that the frequencys are nice multiples of the data time
start_freq = df*ceil(start_freq/df);
stop_freq = df*floor(stop_freq/df);
delta_freq = round(delta_freq*total_time)/ total_time; %not sure if this is correct

%generate drive, use random phases
drive = zeros(1,nppts);
drive_freq = [];
for jj = start_freq:delta_freq:stop_freq;
    drive = drive + sin(2*pi*jj*(0:nppts-1)*dt+2*pi*rand);
   % plot(drive);
   drive_freq = [drive_freq jj];
end

%make up a tf filter that we are going to put into the signal as the plant
tf_filter_a = zpk(-2*pi*[0 pair(7,78)],-2*pi*[pair(2,87) pair(20,50)],1)*NOTCH(5,20,20);
tf_filter = c2d(tf_filter_a,dt);
figure(1)
 bode(tf_filter,tf_filter_a);
 grid on

 
 %filter the drive with the "plant" to create the signal
[b,a] = tfdata(tf_filter);
signal = filter(b{1},a{1},drive);
if max(abs(signal)) > 1E6
    error('Probable filter fault');
end

%try adding some noise (Noise_1 has amplitude 1, Noise_2 has amplitude 10) 
signal = signal + 10* rand(1,nppts);
%retrieve plant using tfestimate
num_ave  = delta_freq/df;
 
pts = nppts/num_ave;
tic
WIN = hanning(pts);
 
[TF,freq] = tfestimate(drive,signal,WIN,pts/2,pts,1/dt);
tfe_time = toc;

disp(['tfestimate took ',num2str(tfe_time),' seconds to run']);

%get coherence for plotting purposes
[COH,freq] = mscohere(drive,signal,WIN,pts/2,pts,1/dt);

%get "real" filter response
tf_filter_resp =  squeeze(freqresp(tf_filter,2*pi*freq));
tf_filt_rp = squeeze(freqresp(tf_filter,2*pi*drive_freq));
 

%retrieve plant using fft method
  tic;

WINDOW = hanning(nppts)';
WINDOW =tukeywin(nppts,0.5)';
fft_drive = fft(WINDOW.*drive);
fft_signal = fft(WINDOW.*signal);
good_pts = round(1+start_freq/df):round(delta_freq/df):round(1+stop_freq/df);
%%
% figure(4)
% plot(1:2500,abs(fft_drive(1:2500)),...
%      good_pts,abs(fft_drive(good_pts)),'r*')
% 
%  

 TF_B = fft_signal(good_pts)./ fft_drive(good_pts);
 fft_time = toc;
 disp(['The fft method took ',num2str(fft_time),' seconds to run']);

%%
figure(2)
subplot(311)
  HHH = loglog(freq,abs(TF),...
        freq,abs(tf_filter_resp(1,1,:)),...
        drive_freq,abs(tf_filt_rp),'r*',...
        drive_freq,abs(TF_B));  
    legend('tfestimate result','freqresp','freqresp at drive pts','fft method')
    title(['Number of averages is ',num2str(num_ave),',  Frequency Resolution is ',num2str(df*num_ave)] ,'fontsize',24,'color',[0.5 0.5 0 ]);
    set(HHH(4),'color',[1 0.7 0],'linewidth',2);
    set(gca,'XLim',[0.9*start_freq 1.1*stop_freq]);
     ylabel('Amplitude','fontsize',24,'color',[0.5 0 1]);
    grid on
subplot(312)
  HHH = semilogx(freq,rads*angle(TF),...
           freq,rads*angle(tf_filter_resp),...
           drive_freq,rads*angle(tf_filt_rp),'r*',...
            drive_freq,rads*angle(TF_B));  
        set(gca,'XLim',[0.9*start_freq 1.1*stop_freq],'ytick',-180:45:180);
         set(HHH(4),'color',[1 0.7 0],'linewidth',2);
         grid on
          ylabel('Phase','fontsize',24,'color',[0.5 0 1]);
         
         subplot(313)
         HHH= semilogx(freq,COH,'linewidth',2);
         grid on
             set(gca,'XLim',[0.9*start_freq 1.1*stop_freq]);
             legend('From mscohere');
             xlabel('Frequency','fontsize',24,'color',[0.5 0 1]);
             ylabel('Coherence','fontsize',24,'color',[0.5 0 1]);
         %%
 good_pts = 1+start_freq/delta_freq: 1+stop_freq/delta_freq ;        
 figure(5)        
 loglog (drive_freq, abs((tf_filt_rp -TF(good_pts))./tf_filt_rp),...
         drive_freq, abs((tf_filt_rp -transpose(TF_B))./tf_filt_rp),...
     'linewidth',2);
 grid on
   set(gca,'XLim',[0.9*start_freq 1.1*stop_freq]);
   legend('tfestimate error','fft error');
   title('Transfer Function Errors' ,'fontsize',24,'color',[0.5 0.5 0 ]);
      ylabel('Fracional Error','fontsize',24,'color',[0.5 0 1]);
          xlabel('Frequency','fontsize',24,'color',[0.5 0 1]);