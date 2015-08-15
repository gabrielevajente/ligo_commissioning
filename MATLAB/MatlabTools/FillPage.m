function []=FillPage(orient);
%FillPage   sets the current figure to fill an 8.5x11 page
%   call as FillPage('tall') or FillPage('wide')
%   BTL April 13, 2005
%   mod June 6, 2005 to be case insensitive and accept a single letter
%     eg FillPage('T') or FillPage('wide as a whale')
%
% $Id: FillPage.m 125 2008-07-31 15:49:03Z seismic $

if nargin ~= 1
    disp('  call FillPage with an argument, either FillPage(''wide'') or FillPage(''tall'')  ')
    return
end

if strncmpi(orient,'tall',1)   %just match first letter, ignore case
    set(gcf,'PaperOrientation','portrait')
    set(gcf,'PaperPosition', [0.1 0.1 8.3 10.8])
elseif strncmpi(orient,'wide',1)
    set(gcf,'PaperOrientation','landscape')
    set(gcf,'PaperPosition', [0.1 0.1 10.8 8.3])
else
    disp('  call FillPage with an argument, either FillPage(''wide'') or FillPage(''tall'')  ')
end

