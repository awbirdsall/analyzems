function plotms(mz,int,varargin)
% given mz and int vectors, plot mass spectrum with x and y axis labels.
% Optional third argument is used in title label
% Sample usage:
% >>avgspec = mzxmlavg('file.mzXML')
% >>figure
% >>plotms(avgspec(:,1),avgspec(:,2),'file.mzXML data')

stem(mz,int,'marker','none')
if nargin == 3
    title(['average spectrum of ',varargin{1}])
end
xlabel('m/z')
ylabel('intensity')
end