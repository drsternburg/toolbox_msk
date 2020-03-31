
function [cnt,mrk,mnt] = proc_loadDataset(subj_code,phase_name)

global BTB opt

if iscell(phase_name)
    if length(phase_name)>1
        N = length(phase_name);
        cnt = cell(N,1);
        mrk = cell(N,1);
        mnt = cell(N,1);
        for jj = 1:N
            [cnt{jj},mrk{jj},mnt{jj}] = proc_loadDataset(subj_code,phase_name{jj});
        end
        fprintf('Concatenating phases...\n')
        [cnt,mrk] = proc_appendCnt(cnt,mrk);
        mnt = mnt{1};
        return
    else
        phase_name = phase_name{1};
    end
end

ds_list = dir(BTB.MatDir);
ds_idx = strncmp(subj_code,{ds_list.name},6);
ds_name = ds_list(ds_idx).name;

filename_eeg = sprintf('%s_%s_%s',opt.session_name,phase_name,subj_code);
filename_eeg = fullfile(ds_name,filename_eeg);
filename_mrk = sprintf('%s%s_mrk.mat',BTB.MatDir,filename_eeg);

fprintf('Loading data set %s, %s...\n',ds_name,phase_name)

[cnt,mrk,mnt] = file_loadMatlab(filename_eeg);

load(filename_mrk)

mnt.scale_box = [];
mnt = mnt_scalpToGrid(mnt);