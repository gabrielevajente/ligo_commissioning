function result = autoquack_conversion_check(foton_filename, filters, print_option)
%autoquack_conversion_check  compare a matlab filter set to the converted foton files
% This is a helper function for autoquack.
% It can be called separately, but typically is called from autoquack
%    call as 
% result = autoquack_conversion_check(foton_filename, filters, print_all);
% foton_filename is the full path name of the foton file, as returned by
% get_filenames. e.g. '/opt/rtcds/stn/s1/chans/S1ISIITMX.txt'
%  (it should follow softlinks)
% filters is the filter datafile given to autoquack, see G1101???
% print_option: optional parameter, defaults to 'normal' if not specified
%   'normal' : only plots filters with differences greater than 1e-6
%   'verbose' : one plot per filter
%   'none':    no plots
%
%  result = 1 if no filters violate the threshold
%  result = 2 if there is a violation
% SVN $Id$

% PLAN:
%  load the foton data
%  for loop  through each filter in the original data
%     convert the sosdata to matlab filter
%     plot original vs. foton
%     calc a residual
%  end

% good conversion is that each point of freq resp is with 1e-6 of nominal

if nargin == 2
    print_option = 'normal';
end

if strncmpi(print_option, 'none',3)
    plot_level = 1;
elseif strncmpi(print_option, 'normal',3)
    plot_level = 2;
elseif strncmpi(print_option, 'verbose',3)
    plot_level = 3;
else
    disp('invalid print option, use ''none'', ''normal'', or ''verbose''')
    error('bad print option')
end

result = 1;

%%
foton_data = readFilterFile(foton_filename);
points_to_plot  = 1e4;
low_freq_end    = 0.01; %(Hz)
diff_threshold  = 1e-6;

%%

for nn = 1:length(filters)
    
    fieldname   = filters(nn).name;
    module      = filters(nn).subblock + 1;  % 0-9 vs 1-10;
    filt_struct = getfield(foton_data,fieldname);
    
    filt_name       = filt_struct(module).name;
    rate            = filt_struct(module).fs;
    sos_coef_matrix = filt_struct(module).soscoef;
    filt_obj        = dfilt.df2sos(sos_coef_matrix);
    
    freq      = logspace(log10(low_freq_end), log10((rate-1)/2), points_to_plot); 
             % dont plot the last point, it screws up the plotting range...
    
    [foton_resp] = freqz(filt_obj, freq, rate);
    
    % this is the one we gave to foton, originally
    orig_resp = squeeze(freqresp(filters(nn).value, 2*pi*freq));
    
    diff_resp = abs(foton_resp - orig_resp.') ./ abs(foton_resp + orig_resp.');
    
    if sum(diff_resp > diff_threshold) > 0
        % at least 1 of the diff_resp is > 0
        disp(['BAD - Filter ', fieldname, ' has issues in sect. ',num2str(module), ' : ',filt_name])
        result = 2;
        problem = 1;
    else
        disp(['  OK - Filter ', fieldname, ' sect. ',num2str(module), ' : ',filt_name])
        problem = 0;
    end

    if plot_level == 1
        plot_this_one = false;  % never make plots
    elseif plot_level == 2;
        if problem == 1
            plot_this_one = true;  % only plot the bad ones
        else
            plot_this_one = false;
        end
    elseif plot_level == 3
        plot_this_one = true;  % plot them all
    end
    

    
    %%%%%%           plot the 2 responses          %%%%%%
    if plot_this_one == true
        figure
        subplot(311)
        ll = loglog(...
            freq, abs(foton_resp),'b',...
            freq, abs(orig_resp),'r--');
        set(ll,'LineWidth',2);
        xlabel('freq (Hz)')
        ylabel('filter response (mag)')
        legend('foton filter','orig filter','Location','S')
        tt=title({['Foton filter ',fieldname],...
            ['module ',num2str(module),' of 10, named ', filt_name]});
        set(tt,'Interpreter','none');
        grid on
        axis tight
        
        subplot(312)
        ll = semilogx(...
            freq, 180/pi* angle(foton_resp),'b',...
            freq, 180/pi* angle(orig_resp),'r--');
        set(ll,'LineWidth',2);
        
        %ylim([-185,185])
        set(gca,'YTick',45*(-4:4))
        grid on
        axis([freq(1), freq(end), -185 185])
        
        
        subplot(313)
        ll = loglog(freq, diff_resp,...
            freq, diff_threshold * ones(size(freq)),'r--');
        if problem == 1
            axis tight
        else
             axis([freq(1), freq(end), 1e-20, 1e-5]);
        end
        set(ll,'LineWidth',2)
        grid on
        title('Difference = abs(Foton-Orig)./abs(Foton+Orig)');
        legend('difference','threshold')
        
        
        FillPage('t')
    end

   
end


