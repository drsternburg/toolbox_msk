
function [epo,C,Ind] = proc_kmedoids(epo,ival,clab)

K = 2;

if nargin<2
    epo_ = proc_selectIval(epo,[epo.t(1) 0]);
else
    epo_ = proc_selectIval(epo,ival);
end
if ~exist('clab','var')
    clab = 'Cz';
end
chanind = util_chanind(epo,clab);

X = squeeze(epo_.x(:,chanind,:))';

[Ind,C,sumD,D] = kmedoids(X,K,'Distance','correlation','Algorithm','clara');

epo.y = zeros(3,length(epo.y));
epo.y(1,:) = ones(1,length(epo.y));
epo.y(2,Ind==1) = 1;
epo.y(3,Ind==2) = 1;
className = {epo.className{1},[epo.className{1} ' neg'],[epo.className{1} ' pos']};
epo.className = className;

epo_ = proc_selectClasses(epo,[2 3]);
epo_ = proc_average(epo_);
epo_ = proc_meanAcrossTime(epo_,[epo_.t(1) epo_.t(1)+1000]);
epo_ = proc_selectChannels(epo_,chanind);

if epo_.x(1,1,1) < epo_.x(1,1,2)
    C = flipud(C);
    Ind = abs(Ind-2)+1;
    epo.y = epo.y([1 3 2],:);
end










