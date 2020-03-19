function [fv, memo]= proc_chain(fv, proc, memo)

if nargin<3
  memo= cell(2, 0);
end

for k= 1:length(proc)
  procline= proc{k};
  isvar= cellfun(@ischar, procline);
  nVars= min(find(~isvar))-1;
  vars= procline(1:nVars);
  vals= cell(1, nVars);
  cmd= replace_vars(procline(nVars+1:end), memo);
  [fv, vals{:}]= cmd{1}(fv, cmd{2:end});
  memo= cat(2, memo, cat(1, vars, vals));
end


function cmd= replace_vars(cmd, memo)

for n= 1:length(cmd)
  if ischar(cmd{n}) && cmd{n}(1)=='$'
    varname= cmd{n}(2:end);
    idx= strmatch(varname, memo(1,:), 'exact');
    if isempty(idx)
      error('variable %s not defined in opt.Proc', varname);
    end
    cmd{n}= memo{2,idx};
  end
end
