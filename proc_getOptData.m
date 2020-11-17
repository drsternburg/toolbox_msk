
function opt2 = proc_getOptData(subj_code)

global BTB opt

ds_list = dir(BTB.RawDir);
ds_idx = strncmp(subj_code,{ds_list.name},6);
ds_name = ds_list(ds_idx).name;

optfilename = sprintf('%s%s/%s_%s_opt',BTB.RawDir,ds_name,opt.session_name,subj_code);

opt2 = load(optfilename);
opt2 = opt2.opt;