function ioncts = plotionsfromfiles(files,times,ions)
% automated plotting of change in ions over time given list of files,
% reaction times corresponding to those files, and ions to monitor. Returns
% cell array of data used to create plots.
% Sample usage:
% >> fns = {'file_0.mzXML','file_10.mzXML','file_20.mzXML','file_30.mzXML'};
% >> rxntimes = [0,10,20,30];
% >> ions = [77, 119, 343];
% >> ioncts = plotions(fns,rxntimes,ions);

[mz,ints] = mzxmlavg_batch(files);
ioncts = monitorions(mz,ints,times,ions,0.5); % could try tweaking 0.5 value for tolerance
clear mz ints

end