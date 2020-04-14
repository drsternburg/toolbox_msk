
function ind = isoutl(x,f,direction)

mn = nanmean(x);
sd = nanstd(x);

switch direction
    case 'lo'
        ind = x<mn-sd*f;
    case 'hi'
        ind = x>mn+sd*f;
    case 'lohi'
        ind = (x<mn-sd*f|x>mn+sd*f);
end