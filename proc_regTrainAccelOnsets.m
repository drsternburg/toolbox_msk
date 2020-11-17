
function mrk = proc_regTrainAccelOnsets(subj_code,phase_name,excl_outl)

global opt BTB

if nargin==2
    excl_outl = 1;
end

[cnt,mrk_orig] = proc_loadDataset(subj_code,phase_name);

% mrk_orig = mrk_selectClasses(mrk_orig,'not','movement onset');
% must_contain = 'pedal press';
% trial = mrk_getTrialMarkers(mrk_orig,must_contain);
% mrk_orig = mrk_selectEvents(mrk_orig,[trial{:}]);
% mrk = mrk_selectClasses(mrk_orig,{'trial start','pedal press'});

mrk = mrk_selectClasses(mrk_orig,'not','movement onset');
must_contain = 'pedal press';
trial = mrk_getTrialMarkers(mrk,must_contain);
mrk = mrk_selectEvents(mrk_orig,[trial{:}]);
mrk = mrk_selectClasses(mrk,{'trial start','pedal press'});

cnt = proc_selectChannels(cnt,'M*');
dt = 1000/cnt.fs;

%% train online detector
mrk_train = mrk;
mrk_train.time(logical(mrk.y(1,:))) = mrk_train.time(logical(mrk_train.y(1,:)))+opt.cfy_acc.offset;
fv = proc_segmentation(cnt,mrk_train,opt.cfy_acc.ival_fv);
fv = proc_variance(fv);
fv = proc_logarithm(fv);
fv = proc_flaten(fv);
loss = crossvalidation(fv,@train_RLDAshrink,'SampleFcn',@sample_leaveOneOut);
fprintf('xval accuracy: %3.3f%%\n',(1-loss)*100)
opt.cfy_acc.C = train_RLDAshrink(fv.x,fv.y);

%% find single-trial onsets with cross-validated detector
Nt = sum(mrk.y(1,:));
i_trial = reshape(1:Nt*2,2,Nt);

t_onset = nan(Nt,1);
for jj = 1:Nt
    
    i_trial_ = i_trial(:,setdiff(1:Nt,jj));
    mrk_train = mrk_selectEvents(mrk,i_trial_(:));
    mrk_train.time(logical(mrk_train.y(1,:))) = mrk_train.time(logical(mrk_train.y(1,:)))+opt.cfy_acc.offset; 
    fv = proc_segmentation(cnt,mrk_train,opt.cfy_acc.ival_fv);
    fv = proc_variance(fv);
    fv = proc_logarithm(fv);
    fv = proc_flaten(fv);
    C = train_RLDAshrink(fv.x,fv.y);
    
    mrk_trial = mrk_selectEvents(mrk,i_trial(:,jj));
    T = [mrk_trial.time(1)+opt.cfy_acc.offset mrk_trial.time(2)];
    t = T(2);
    while t >=T(1)
        fv = proc_segmentation(cnt,t,opt.cfy_acc.ival_fv);
        fv = proc_variance(fv);
        fv = proc_logarithm(fv);
        fv = proc_flaten(fv);
        cout = apply_separatingHyperplane(C,fv.x(:));
        if cout<0
            t_onset(jj) = t;
            break
        end
        t = t-dt;
    end
    
end

%% assign registered movement onsets
ind_invalid = find(isnan(t_onset));
mrk_pp = mrk_selectClasses(mrk,'pedal press');
mrk_pp = mrk_selectEvents(mrk_pp,'not',ind_invalid);
mrk_mo.time = t_onset;
mrk_mo.y = ones(1,length(t_onset));
mrk_mo.className = {'movement onset'};
mrk_mo = mrk_selectEvents(mrk_mo,'not',ind_invalid);
mrk = mrk_mergeMarkers(mrk_pp,mrk_mo);
mrk = mrk_sortChronologically(mrk);
fprintf('%d Movement onsets assigned to %d trials.\n',Nt-length(ind_invalid),Nt)

%% exclude outliers
t_mo2pp = mrk.time(logical(mrk.y(1,:))) - mrk.time(logical(mrk.y(2,:)));
if excl_outl
    ind_excl = (t_mo2pp>mean(t_mo2pp)+std(t_mo2pp)*3)|...
        (t_mo2pp<mean(t_mo2pp)-std(t_mo2pp)*3);
    n_excl = sum(ind_excl);
    t_mo2pp(ind_excl) = [];
    ind_excl = [find(ind_excl)*2 find(ind_excl)*2-1];
    mrk = mrk_selectEvents(mrk,'not',ind_excl);
    fprintf('%d Movement onsets excluded as outliers.\n',n_excl)
end

%% insert new markers
mrk = mrk_selectClasses(mrk,'movement onset');
mrk = mrk_mergeMarkers(mrk_orig,mrk);
mrk = mrk_sortChronologically(mrk);

%% plots
fig_init(10,20);
clrs = lines;

subplot(4,1,1)
if verLessThan('matlab', '8.4')
    hist(t_mo2pp)
else
    histogram(t_mo2pp)
end

epo = proc_segmentation(cnt,mrk_selectClasses(mrk,'movement onset'),[-1000 1000]);
epo = proc_baseline(epo,500,'beginning');
for jj = 1:3
    subplot(4,1,jj+1)
    plot(epo.t,squeeze(squeeze(epo.x(:,jj,:))),'color',clrs(jj,:))
    title(epo.clab{jj})
end

%% save new marker struct
ds_list = dir(BTB.MatDir);
ds_idx = strncmp(subj_code,{ds_list.name},6);
ds_name = ds_list(ds_idx).name;
filename = fullfile(ds_name,sprintf('%s_%s_%s',opt.session_name,phase_name,subj_code));
filename = fullfile(BTB.MatDir,[filename '_mrk']);
save(filename,'mrk')













