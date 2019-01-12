xBF = spm_get_bf(struct('dt', 1, 'name', 'hrf (with time and dispersion derivatives)'));

% A canonical response
hrf = xBF.bf * [1 0 0]';  %[.6 -.6 -1]';
create_figure('hrf');
plot(hrf, 'ko:', 'MarkerSize', 6, 'MarkerFaceColor', [.4 .4 .4], 'LineWidth', 2);

set(gca, 'YColor', 'w', 'FontSize', 18);
xlabel('Time');

%% A non-canonical response
hrf = xBF.bf * [.25 -1 0]';  %[.6 -.6 -1]';
create_figure('hrf');
plot(hrf, 'ko:', 'MarkerSize', 6, 'MarkerFaceColor', [.4 .4 .4], 'LineWidth', 2);

set(gca, 'YColor', 'w', 'FontSize', 18);
xlabel('Time');

%% Fit
canon = xBF.bf(:, 1) ./ max(xBF.bf(:, 1)); % Max 1 so we can compare beta to amplitude
bhat = pinv([canon, ones(size(canon))]) * hrf;
plot([canon, ones(size(canon))] * bhat, 'b', 'LineWidth', 3);

% Loss of effect due to mismodeling

percent_loss = 100 * (max(hrf) - bhat(1)) ./ max(hrf);
fprintf('%3.0f%% loss\n', percent_loss);

%% Movie

create_figure('hrf');
set(gca, 'YLim', [-.1 0.25], 'XLim', [0 20]);
set(gca, 'YColor', 'w', 'FontSize', 18);
xlabel('Time');

c = linspace(1, 0, 5);
d = linspace(0, -1, 5);
percent_loss = zeros(length(c), length(d), length(d));

cm = colormap_tor([1 .9 0], [1 .5 .2]);


obj = VideoWriter('SPM_3bf_canonical_plus.mp4', 'MPEG-4');
open(obj);


for i = 1:length(c)
    
    for j = 1:length(d)
        
        for k = 1:length(d)
            
            hrf = xBF.bf * [c(i) d(j) d(k)]';
            
            
            han = plot(hrf, 'o-', 'Color', [.7 .3 0], 'MarkerSize', 6, 'MarkerFaceColor', [.4 .4 .4], 'LineWidth', 2);
            
            drawnow;
            
            wh = randperm(length(cm));
            mycolor = cm(wh(1), :);
            
            set(han, 'LineWidth', 0.5, 'Marker', 'none', 'Color', mycolor);
            
            bhat = pinv([canon, ones(size(canon))]) * hrf;
            
            percent_loss(i, j, k) = 100 * (max(hrf) - bhat(1)) ./ max(hrf);
            
            currFrame = getframe(gcf);
            writeVideo(obj,currFrame);
    
        end
        
    end
    
end

close(obj);

% This video was uploaded and converted to .gif with Giphy:
% https://giphy.com/create/gifmaker
%
% https://media.giphy.com/media/ybSv8dGOxnVZ45TsR4/giphy.gif

%% Test for selected value

i = 4; j = 5; k = 1;
[c(i) d(j) d(k)]

hrf = xBF.bf * [c(i) d(j) d(k)]';
han = plot(hrf, 'bo-', 'MarkerSize', 6, 'MarkerFaceColor', [.4 .4 .4], 'LineWidth', 2);
bhat = pinv([canon, ones(size(canon))]) * hrf;
percent_loss(i, j, k) = 100 * (max(hrf) - bhat(1)) ./ max(hrf);
percent_loss(i, j, k)

%% Map

n = length(d);

create_figure('percent_loss', 1, n);

for i = 1:n
    
    subplot(1, n, i);
    image(percent_loss(:, :, i));
    colorbar
    
end

%viz(percent_loss)
colormap(colormap_tor([1 1 1], [1 0 0]))

