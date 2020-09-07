
function H = plot_meanPlusShading(x,y,s,c)

x = x(:);
y = y(:);

sz = size(s);
if any(sz==1)
    s = [y-s(:) y+s(:)];
end

patch([x;flipud(x)],[s(:,1);flipud(s(:,2))],c,'FaceAlpha',.2,'EdgeColor',c,'EdgeAlpha',.2,'LineWidth',.1)
hold on
H = plot(x,y,'LineWidth',1.5,'color',c);