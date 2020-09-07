
function iart = rej_excessVarTrials(fv)

whisker_perc = [10 95];
whisker_length = 3;
vfv = proc_variance(fv);
v = squeeze(vfv.x);
perc = stat_percentiles(v(:),whisker_perc);
thresh = perc(2) + whisker_length*diff(perc);
iart = logical(sum(v>thresh));