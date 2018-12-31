% This video was uploaded and converted to .gif with Giphy:
% https://giphy.com/create/gifmaker
%
% https://media.giphy.com/media/cI4WhBFPtnwhMoXAuD/giphy.gif

D = imread('D-Pine_Black.jpg');
Dflat = any(D, 3);

Df = uint8(repmat(Dflat, 1, 1, 3));

[n, k] = size(Dflat);
t = 25;

C = imread('../New_hampshire_colors.jpg');
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

set(han(6), 'FaceAlpha', 1);
delete(han(13)) % extra surface

camzoom(1.2)
%camdolly(1.4, 0, 0)
%campan(5, 5)

[az, el] = view;

axis vis3d

colormap bone

f2 = gcf;

%% 

obj = VideoWriter('canlab_dpine2.mp4', 'MPEG-4');
open(obj);


%%

f3 = figure('Color', 'w'); % target figure
axis off; axis image; axis vis3d

for i = 1:70
    
    figure(f2); % brain figure
    
    view(az + 2*i, el + .5 * i);
    campan(5 -.2 * i, 4-.1 * i);
    
    set(han(6), 'FaceAlpha', 1 - i/100);

    lightRestoreSingle;
    
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


%% Nuts

f2 = figure;

for i = 1:70
    
    view(az + 2*i, el + .5 * i);
    campan(5 -.2 * i, 4-.1 * i);
    
    lightRestoreSingle;
    
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
    
    figure(f2);
    image(C2)
    
end


% 
%%


% obj = VideoWriter('canlab_dpine1.mp4', 'MPEG-4');
% open(obj);
% 
% figure('Color', 'w'); axis off
% 
% for i = 1:length(M)
%     
%     movie(M(i))
%     drawnow
%     
%     currFrame = getframe(gcf);
%     writeVideo(obj,currFrame);
%     
% end

close(obj);

