
function [fv,memo] = proc_features(cnt,mrk,proc,type,memo)

switch type
    case 'train'
        fv = proc_segmentation(cnt,mrk,proc.ival{1});
        [fv,memo] = proc_chain(fv,proc.train);
    case 'apply'
        fv = proc_segmentation(cnt,mrk,proc.ival{2});
        fv = proc_chain(fv,proc.apply,memo);
end