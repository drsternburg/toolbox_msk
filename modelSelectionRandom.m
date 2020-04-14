
function modelSelectionRandom(T,resp_var,rand_var,do_interact)

if nargin<4
    do_interact = 1;
end
if nargin<3
    rand_var = 'Subj';
end

expl_var = setxor({resp_var,rand_var},T.Properties.VariableNames);
Ne = length(expl_var);

%%
interact  = [];
kk = 1;
for ii = 1:Ne
    for jj = ii+1:Ne
        interact{kk} = sprintf('%s:%s',expl_var{ii},expl_var{jj});
        kk = kk+1;
    end
end

%%
if do_interact
    formula_fixed = sprintf('%s~1%s%s',resp_var,catterms(expl_var,'+'),...
                                                catterms(interact,'+'));
else
    formula_fixed = sprintf('%s~1%s',resp_var,catterms(expl_var,'+'));
end

%%
for ii = 1:Ne
    formula_base = sprintf('%s + (1|%s)',formula_fixed,rand_var);
    formula_test = sprintf('%s + (1+%s|%s)',formula_fixed,expl_var{ii},rand_var);
    fprintf('Testing random effects: %s... ',expl_var{ii})
    lme_base = fitlme(T,formula_base,'FitMethod','REML');
    lme_test = fitlme(T,formula_test,'FitMethod','REML');
    table = compare(lme_base,lme_test);
    fprintf('%0.6f\n',table.pValue(2))
end

%%
function s = catterms(terms,link)
N = length(terms);
s = [];
for ii = 1:N
    s = sprintf('%s%s%s',s,link,terms{ii});
end

