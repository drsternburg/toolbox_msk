
function [cnt,mrk,mnt] = proc_convertBVData(subj_code,phase_name,do_car,excl_badchans)

global opt BTB

if ~exist('do_car','var')
    do_car = true;
end

if ~exist('excl_badchans','var')
    excl_badchans = false;
end

ds_list = dir(BTB.RawDir);
ds_idx = strncmp(subj_code,{ds_list.name},6);
ds_name = ds_list(ds_idx).name;
filename = fullfile(ds_name,sprintf('%s_%s_%s',opt.session_name,phase_name,subj_code));

if excl_badchans
    hdr = file_readBVheader(filename);
    if isfield(hdr,'impedances')
        noninfclab = ['not' hdr.clab(isinf(hdr.impedances))];
    else
        noninfclab = '*';
    end
else
    noninfclab = '*';
end

% read raw data
[cnt,mrk] = file_readBV(filename,'fs',opt.acq.fs,'filt',opt.acq.filt,'clab',noninfclab);

% define markers
mrk = mrk_defineClasses(mrk,opt.mrk.def);
mrk = rmfield(mrk,'event');

% rename marker from old data sets
ci = logical(strcmp(mrk.className,'button press'));
if any(ci)
    mrk.className{ci} = 'pedal press';
end

% set montage
mnt = mnt_setElectrodePositions(cnt.clab);
mnt.scale_box = [];
mnt = mnt_scalpToGrid(mnt);

% perform CAR
if do_car
    rrclab = util_scalpChannels(cnt);
    cnt = proc_commonAverageReference(cnt,rrclab,rrclab);
    fprintf('Performing CAR...\n')
end

% save
if nargout==0
    file_saveMatlab(filename,cnt,mrk,mnt);
    fprintf('File %s successfully converted and saved.\n',filename)
end

% remove trailing pedal presses and save new marker file
remove_trailing_pps(filename,mrk)


function remove_trailing_pps(filename,mrk)

global BTB

filename = fullfile(BTB.MatDir,[filename '_mrk']);

% remove trailing PPs
ci_bp = find(strcmp(mrk.className,'pedal press'));
remove = [];
for ii = 1:length(mrk.time)-1
    if find(mrk.y(:,ii))==ci_bp && find(mrk.y(:,ii+1))==ci_bp
        remove = [remove ii+1];
    end
end
mrk = mrk_selectEvents(mrk,'not',remove,'RemoveVoidClasses',0);
fprintf('%d trailing pedal presses removed.\n',numel(remove))

% save new marker struct
save(filename,'mrk')




