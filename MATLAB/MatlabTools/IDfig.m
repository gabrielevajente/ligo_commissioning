function tt = IDfig(extra_message)
% IDfig puts the name of the calling function and the date on the right side of a figure
% there must be a current axis, and it must be called from an m-file
% replaces IDplot, which has a name conflict with something in the sys-ID
% toolbox. BTL July 17, 2007.
%
% if called with an input string, that string will be appended to the message,
% eg IDfig('data from tf_120104_1.mat')
%
% if called with an output argument, it returns the handle to the text object it created
% 
% the tex interpreter is turned off, so that the _ characters don't result in subscripts
% BTL, Dec 12, 2004
%
% $Id: IDfig.m 125 2008-07-31 15:49:03Z seismic $

ax = axis;

% figure out the name of the function which called this one
[st,ii] = dbstack;
if length(st)<2
    shortname = 'workspace';
else
    longname = st(2).name;
    index1=max(find(longname == '\'));   % the last \ in the name
	if isempty(index1)
		shortname = longname;   % now compatible with v7 (doesn't return full path)
	else
		shortname = longname(index1+1:end);
	end
end

if nargin == 0
    bonus = [];
else
    bonus = [' ',extra_message];
end

thing=text(ax(2),ax(3),['created by ',shortname,' on ',date,bonus],'VerticalAlignment','top','Rotation',90,'FontSize',7,'Interpreter','none');

if nargout == 1
    tt = thing;
end
