
addpath('../../')

refTf = DttData('a-pit.xml');
tfChanA = 'H1:ALS-Y_WFS_A_AUTOC_PIT_CTRL_IN2(REF1)';
tfChanB = 'H1:ALS-Y_WFS_A_AUTOC_PIT_CTRL_IN1(REF1)';
cohChanA = 'H1:ALS-Y_WFS_A_AUTOC_PIT_CTRL_EXC(REF0)';
cohChanB = 'H1:ALS-Y_WFS_A_AUTOC_PIT_CTRL_IN1(REF0)';

dttTimeSeriesFromPS = DttData('test.xml');
tsChan = 'C1:ALS-BEATX_FINE_I_ERR_DQ[0][0](REF0)';
psChan = 'C1:ALS-BEATX_FINE_I_ERR_DQ(REF1)';

refFft = DttData('fftRefs.xml');
fftTfChanA = 'H1:LSC-DARM_IN1_DQ(REF0)';
fftTfChanB = 'H1:LSC-DARM_OUT_DQ(REF0)';
% fftTfChanA = 'H1:LSC-DARM_IN1_DQ';
% fftTfChanB = 'H1:LSC-DARM_OUT_DQ';
fftCohChanA = 'H1:LSC-DARM_IN1_DQ(REF1)';
fftCohChanB = 'H1:LSC-DARM_OUT_DQ(REF1)';
% fftCohChanA = 'H1:LSC-DARM_IN1_DQ';
% fftCohChanB = 'H1:LSC-DARM_OUT_DQ';
%%
% get tf data
[fTf, tf] = refTf.transferFunction(tfChanA,tfChanB);
figure(122)
loglog(fTf,abs(tf))

% get coh data 
[fCoh, coh] = refTf.coherence(cohChanA,cohChanB);
figure(213)
semilogx(fCoh,coh)
%%
% get time data
[tTs, ts] = dttTimeSeriesFromPS.timeSeries(tsChan);
figure(444)
plot(tTs,ts)


% get power spec data
[fPs, ps] = dttTimeSeriesFromPS.powerSpectrum(psChan);
figure(443)
loglog(fPs,ps)
%%
% get FFT TF data
[fFftTf, fftTf] = refFft.transferFunction(fftTfChanA,fftTfChanB);
figure(2322)
loglog(fFftTf,abs(fftTf))
 
% get FFT coh data
[fFftCoh, fftCoh] = refFft.coherence(fftCohChanA,fftCohChanB);
figure(22331)
semilogx(fFftCoh,fftCoh)