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
figure('Color', 'w');

han = addbrain('hires');

set(han, 'FaceAlpha', .05); % left hires

view(0, 90);
[az, el] = view;
lightRestoreSingle

axis vis3d

hh = lightangle(0, 90);

camdolly(.1, 0, 0)
f2 = gcf;

saveas(gcf, 'tmp-sur.png');

%%

f3 = figure('Color', 'w'); % target figure
axis off; axis image; axis vis3d

% load, mask

S = imread('tmp-sur.png');

S = imresize(S,[n k]);

% Mask
Df = uint8(repmat(~Dflat, 1, 1, 3));
S = Df .* S;

% Combine with C
C2 = C;

wh = S ~= 0;
C2(wh) = S(wh);

figure(f3);
image(C2)
axis off


