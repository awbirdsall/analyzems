function ioncts = monitorions(mz,ints,times,ions,peak_tol)
% extract change of selected ions with time from mzxmlavg_batch output and
% plot
% Sample usage:
% >> [mz,ints] = mzxmlavg_batch(files);
% >> ioncts = monitorions(mz,ints,times,ions,0.5);

ioncts={};
for ion_idx=1:length(ions)
    ioncts{ion_idx}=zeros(size(ints,1),2);
    for spec_idx=1:size(ints,1)
        % find peak value near request m/z ion to monitor
        peaklist=mspeaks(mz,ints(spec_idx,:)');
        peak_mz = peaklist(abs(peaklist(:,1)-ions(ion_idx))<peak_tol,1);
        % stupid fallback if more than one peak is within peak_tol: choose
        % first peak and print a warning.
        if size(peak_mz,1)>1
            peak_mz = peak_mz(1);
            warning(['ambiguous peak for ',num2str(ions(ion_idx)),' m/z in spectrum ', num2str(spec_idx),'. Consider changing peak_tol.'])
        end
        % look up intensity of that peak, assuming spacing between m/z
        % values of greater than 0.06 m/z
        peak_int_idx = abs(mz-peak_mz)<0.03;
        peak_int = ints(spec_idx,peak_int_idx);
        ioncts{ion_idx}(spec_idx,:)=[times(spec_idx),peak_int];
        clear peaklist peak_mz peak_int_idx peak_int
    end
    figure
    ionarray=ioncts{ion_idx};
    plot(ionarray(:,1),ionarray(:,2))
    title(['change in ',num2str(ions(ion_idx)),' m/z signal with time'])
    xlabel('time (min)')
    ylabel('intensity')
end
end