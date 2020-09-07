
function T = standardizePredictors(T,P)

if ischar(P)
    P = {P};
end
Ns = length(unique(T.Subj));
Np = length(P);
for si = 1:Ns
    for pi = 1:Np
        x = T.(P{pi})(T.Subj==si);
        mu = nanmean(x);
        sigma = nanstd(x);
        T.(P{pi})(T.Subj==si) = (x-mu)/sigma;
    end
end