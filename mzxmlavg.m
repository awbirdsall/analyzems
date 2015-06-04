function avgspec = mzxmlavg(mzxmlfn,varargin)
% MZMLWORKUP Calculate average spectrum from mzXML file.
%   Input: mzxmlfn, path to mzXML file
%   Input: vargin, options to plot spectrum: (1) 'disp' to display, or (2)
%   'save','output.png' to save png file.
%   Output: avgspec, 2-column array of m/z and intensity values of average
%   spectrum
% Sample usage:
% Create average spectrum and save output to csv, no plot:
% >> avgspec = mzxmlavg('filename.mzXML');
% >> csvwrite('output.csv',avgspec);
% Display plot without saving output:
% >> mzxmlavg('file.mzXML','disp');

mzxml_struct=mzxmlread(mzxmlfn);
[peaks, time] = mzxml2peaks(mzxml_struct);
clear mzxml_struct time;
% peaks: cell array of peak lists. Each peak list is
% two-column matrix of m/z and intensities
% time: "retention time" of each peak list in peaks
[cmz, aligned_peaks] = mspalign(peaks,'EstimationMethod','regression');
% cmz: vector of "common" mz values
% aligned_peaks: cell array like peaks, but with corrected m/z in first
% column
% using 'regression' rather than 'histogram' to avoid undersampling problem
% unclear if mspalign even necessary -- spot check shows all input peaks
% have the same m/z values

% calculate average spectrum by adding up each aligned spectrum, dividing
% by number of spectra
average_intensity = zeros(size(aligned_peaks{1},1),1);
% add spectrum for each instantaneous peak
numrows = size(aligned_peaks,1);
for row_idx = 1:numrows
    average_intensity = average_intensity + aligned_peaks{row_idx}(:,2);
end
average_intensity = average_intensity/size(aligned_peaks,1);

avgspec = [cmz',average_intensity];

% if toggled 'disp' or 'save', create output plot to display or save
if (nargin==2)&&(strcmp(varargin,'disp'))
    clf
    plotms(avgspec(:,1),avgspec(:,2),mzxmlfn)
elseif (nargin==3)&&(strcmp(varargin{1},'save'))
    % Create a figure with visibility off
    figure('Visible','off');
    plotms(avgspec(:,1),avgspec(:,2),mzxmlfn)
    print(gcf,'-dpng',varargin{2});
elseif nargin==1
else
    warning('improperly formatted call to mzxmlavg, no figure created')
end
end