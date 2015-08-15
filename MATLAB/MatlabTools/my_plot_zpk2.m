
function [] = my_plot_zpk2(X,Y,Color,lsize)

Y=squeeze(freqresp(Y,2*pi*X));

subplot(2,1,1)
loglog(X,abs(Y),'color',Color,'LineWidth',lsize)  %Plant
hold on
xlabel('Frequency (Hz)')
ylabel('Amplitude')
    
subplot(2,1,2)
% semilogx(X,unwrap(angle(Y))*180/pi,'k-','color',Color,'MarkerSize',msize)  %Plant
semilogx(X,angle(Y)*180/pi,'k-','color',Color,'LineWidth',lsize)  %Plant
hold on
xlabel('Frequency (Hz)')
ylabel('Phase')
    
 