
function cout = proc_slidingClassi(cnt,mrk,proc,C)

n_trial = sum(mrk.y(1,:));
i_trial = reshape(1:length(mrk.time),3,n_trial);

%%
cout = cell(n_trial,1);
h = waitbar(0,'Computing sliding classifier output...');
for ii = 1:n_trial

    if nargin==3
        %% train
        mrk_train = mrk_selectEvents(mrk,'not',i_trial(:,ii));
        mrk_train = mrk_selectClasses(mrk_train,'trial start','movement onset');
        fv = proc_segmentation(cnt,mrk_train,proc.ival);
        fv = proc_chain(fv,proc.train);
        C = train_RLDAshrink(fv.x,fv.y);
    end
    
    %% apply
    mrk_apply = mrk_selectEvents(mrk,i_trial(:,ii));
    t_ts = mrk_apply.time(1);
    t_eo = mrk_apply.time(2);
    t_te = mrk_apply.time(3);
    ival = [t_ts t_te]-t_eo;
    
    mrk_eo = mrk_selectEvents(mrk_apply,2);    
    
    epo = proc_segmentation(cnt,mrk_eo,ival);
    cout{ii} = proc_applySlidingClassi(epo,proc,C);
    
    %%
    waitbar(ii/n_trial,h);
    
end
close(h)
