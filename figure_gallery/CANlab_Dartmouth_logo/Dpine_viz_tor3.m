% This video was uploaded and converted to .gif with Giphy:
% https://giphy.com/create/gifmaker
%
% https://media.giphy.com/media/ybSv8dGOxnVZ45TsR4/giphy.gif

D = imread('D-Pine_Black.jpg');
Dflat = any(D, 3);

Df = uint8(repmat(Dflat, 1, 1, 3));

[n, k] = size(Dflat);
t = 25;

C = imread('New_hampshire_colors.jpg');
C = imresize(C,[n k]);

C = C .* Df;

f1 = create_figure('D');
imagesc(C)
set(gca, 'YDir', 'Reverse')
axis image; axis tight; axis off

% saveas(gcf, 'Dpine_trees_black.png');
% saveas(gcf, 'Dpine_trees_black.svg');

%%
han = surface_cutaway;

delete(han(13)) % extra surface

han(13) = addbrain('hires right');

camzoom(.4)

set(han([6 13]), 'FaceAlpha', .8); % left hires

view(0, 90);
[az, el] = view;
lightRestoreSingle

axis vis3d

f2 = gcf;

%% 

obj = VideoWriter('canlab_dpine3.mp4', 'MPEG-4');
open(obj);


%%

f3 = figure('Color', 'w'); % target figure
axis off; axis image; axis vis3d

for i = 1:40
    
    figure(f2); % brain figure
    
%     view(az + 2*i, el + .5 * i);
%     campan(5 -.2 * i, 4-.1 * i);
    
    camzoom(1.05);
    set(han([6 13]), 'FaceAlpha', .8 - i/50);

    if i > 20
        set(han([1:5 7:12 14]), 'FaceAlpha', .8 - i/60);
    end
    
    %lightRestoreSingle;
    
    drawnow
    
    % Save as image, load, mask
    
    saveas(gcf, 'tmp-sur.png');
    S = imread('tmp-sur.png');
    
    S = imresize(S,[n k]);
    
    % Mask
    Df = uint8(repmat(~Dflat, 1, 1, 3));
    S = Df .* S;
    
    %figure; image(S)
    
    % Combine with C
    C2 = C;
    
    %wh = all((S ~= 0) & (S ~= 1), 3);
    %wh = all((S ~= 0), 3);
    
    wh = S ~= 0;
    C2(wh) = S(wh);
    
    figure(f3);
    image(C2)
    axis off
    
    currFrame = getframe(f3);
    writeVideo(obj,currFrame);
       
end

%%

close(obj);


