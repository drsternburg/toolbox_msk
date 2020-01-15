
function trial_mrk = mrk_getTrialMarkers(mrk,must_contain)
% Returns the cell trial_mrk that in each entry contains the marker indices
% of single trials, relative to the complete set of markers.

mrk = mrk_sortChronologically(mrk);
ci_ts = find(strcmp(mrk.className,'trial start'));
ci_te = find(strcmp(mrk.className,'trial end'));

% extract markers
idx = 1;
trial_mrk = [];
n_trial = 0;
while idx<length(mrk.time)
    if find(mrk.y(:,idx))==ci_ts
        event_idx = [];
        class_idx = [];
        while 1
            event_idx = [event_idx idx];
            class_idx = [class_idx find(mrk.y(:,idx))];
            if find(mrk.y(:,idx))==ci_te
                break
            end
            idx = idx+1;
        end
        n_trial = n_trial+1;
        trial_mrk{n_trial} = event_idx;
    end
    idx = idx+1;
end

if nargin>1
    trial_mrk = select_trials(trial_mrk,mrk,must_contain);
end


function trial = select_trials(trial,mrk,must_contain)

Nt = length(trial);
keep = [];
for jj = 1:Nt
    mrk2 = mrk_selectEvents(mrk,trial{jj});
    if ismember(must_contain,mrk2.className)
        keep = [keep jj];
    end
end
trial = trial(keep);