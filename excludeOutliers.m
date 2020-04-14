
function T = excludeOutliers(T,P,verbose)

if nargin<3
    verbose = true;
end

Ns = length(unique(T.Subj));
Np = length(P);
for si = 1:Ns
    for pi = 1:Np
        ind1 = T.Subj==si;
        x = T.(P{pi})(ind1);
        ind2 = (x>mean(x)+std(x)*2.5)|(x<mean(x)-std(x)*2.5);
        if verbose
            fprintf('Subj:%d,Pred:%s,Excluded=%d\n',si,P{pi},sum(ind2))
        end
        x(ind2) = NaN;
        T.(P{pi})(ind1) = x;
    end
end