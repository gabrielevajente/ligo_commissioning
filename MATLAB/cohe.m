function c = cohe(darm, x)
    np = 2048;
    [c,f] = mscohere(darm, x, hanning(np), np/2, np, 2048);
    c = sqrt(mean(c(f>50 & f<300).^2));
end