function [mz,intensities] = mzxmlavg_batch(files)
% calculate average spectrum for each mzXML file given and align their m/z.
% Sample usage:
% >> fns = {'file1.mzXML','file2.mzXML'};
% >> [mz,intensities] = mzxmlavg_batch(fns);

%files = dir('*.mzXML'); % alt strategy to scrape all mzXML files in folder

% make specscell as container of mzxmlavg array for each file
specscell={};
for k = 1:length(files)
    disp(['processing mzXML file ',num2str(k),' of ',num2str(length(files))])
    specscell{k} = mzxmlavg(files{k});
end

% given specscell, use msresample to make array of intensities along
% resampled mz that is consistent across all scans
resamplepts = 8500;
intensities=zeros(size(specscell,2),resamplepts);
for i=1:size(specscell,2)
    [mz,intout]=msresample(specscell{i}(:,1),specscell{i}(:,2),8500,'range',[50,600],'RangeWarnOff',true);
    intensities(i,:)=intout';
end
disp('finished processing mzXML files')
clear specscell intout resamplepts
end