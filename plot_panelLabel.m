
function plot_panelLabel(label)

xlim = get(gca,'xlim');
xpos = get(get(gca,'ylabel'),'pos');
xpos = mean([xlim(1) xpos(1)]);
% xpos = xlim(1)-diff(xlim)*.05;

ylim = get(gca,'ylim');
if strcmp(get(gca,'YDir'),'reverse')
    ypos = ylim(1)-diff(ylim)*.05;
else
    ypos = ylim(2)+diff(ylim)*.05;
end

text(xpos,ypos,label,'FontSize',13,'FontWeight','bold','HorizontalAlignment','center')