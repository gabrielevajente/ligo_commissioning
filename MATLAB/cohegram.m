function [C,T,F] = cohegram(x, y, npt, noverlap, naver, fs)
    win = hanning(npt);
    
    nstep = npt - noverlap;
    segs = 1:nstep:length(x)-npt;
    nsegs = length(segs);

    fftx = zeros(npt/2+1, nsegs);
    ffty = zeros(npt/2+1, nsegs);
    for i=1:numel(segs)
        fx = fft(x(segs(i):segs(i)+npt-1) .* win);
        fy = fft(y(segs(i):segs(i)+npt-1) .* win);
        fftx(:,i) = fx(1:npt/2+1);
        ffty(:,i) = fy(1:npt/2+1);
    end
    csd = conj(fftx) .* ffty;
    psdx = abs(fftx).^2;
    psdy = abs(ffty).^2;

    % average
    average = ones(naver,1);
    csda = zeros(size(csd));
    psdxa = zeros(size(csd));
    psdya = zeros(size(csd));

    for i=1:npt/2+1
        csda(i,:) = conv(csd(i,:), average, 'same');
        psdxa(i,:) = conv(psdx(i,:), average, 'same');
        psdya(i,:) = conv(psdy(i,:), average, 'same');
    end

    C = abs(csda).^2 ./ (psdxa .* psdya);
    F = linspace(0, fs/2, npt/2+1);
    T = segs/fs;
end