
function H = holm_bonferroni(p,alph)

if nargin<2
    alph = 0.05;
end
[ps,si] = sort(p);
Np = length(p);
H = zeros(Np,1);
m = Np;
for kk = 1:Np
    calph = alph/m;
    if ps(kk)<calph
        H(si(kk)) = 1;
        m = m-1;
    else
        break
    end
end