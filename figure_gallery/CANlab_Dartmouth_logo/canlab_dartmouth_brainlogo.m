% This video was uploaded and converted to .gif with Giphy:
% https://giphy.com/create/gifmaker
%
% https://media.giphy.com/media/ybSv8dGOxnVZ45TsR4/giphy.gif

myfile = which('canlab_dartmouth_brainlogo.m')
mypath = fileparts(myfile);
cd(mypath)

D = imread('D-Pine_Black.jpg');
Dflat = any(D, 3);                   % flatten
Df = uint8(repmat(Dflat, 1, 1, 3));

[n, k] = size(Dflat);

t = 25;

% C is the colored image that will appear in the tree portion of Dpine
C = imread('New_hampshire_colors.jpg');
C = imresize(C,[n k]);

C = C .* Df;

% Make black areas white
C(:, :, 1) = C(:, :, 1) + uint8(~Dflat) .* 256;
C(:, :, 2) = C(:, :, 2) + uint8(~Dflat) .* 256;
C(:, :, 3) = C(:, :, 3) + uint8(~Dflat) .* 256;

f1 = create_figure('D');
imagesc(C)
set(gca, 'YDir', 'Reverse')
axis image; axis tight; axis off

saveas(gcf, 'Canlab_Dpine_forest_white.png');
% saveas(gcf, 'Dpine_trees_black.svg');

%% Save brain surface figure to load and integrate

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

%% Brain D, colors in tree

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
axis image
axis off

saveas(gcf, 'CANlab_forest_brain.png');

%% Brain D, white background

f3 = figure('Color', 'w'); % target figure
axis off; axis image; axis vis3d

% load, mask

S = imread('tmp-sur.png');  % S is the brain image

S = imresize(S,[n k]);

% Mask
D = imread('D-Pine_Black.jpg');
Dflat = any(D, 3);                   % flatten
Df = uint8(repmat(~Dflat, 1, 1, 3));
S = Df .* S;

% Make black areas white
S(:, :, 1) = S(:, :, 1) + uint8(Dflat) .* 256;
S(:, :, 2) = S(:, :, 2) + uint8(Dflat) .* 256;
S(:, :, 3) = S(:, :, 3) + uint8(Dflat) .* 256;

figure(f3);
image(S)
axis image
axis off

saveas(gcf, 'CANlab_D_brain_white.png');


%% White D, brain in tree

f3 = figure('Color', 'w'); % target figure
axis off; axis image; axis vis3d

% load, mask

S = imread('tmp-sur.png');

S = imresize(S,[n k]);

% Mask
Df = uint8(repmat(Dflat, 1, 1, 3));
S = Df .* S;

% Combine with C
C2 = C;

wh = S ~= 0;
C2(wh) = S(wh);

figure(f3);
image(C2)
axis image
axis off

saveas(gcf, 'CANlab_D_brain_white_reverse.png');

%% Brain in tree, colors in D

f3 = figure('Color', 'w'); % target figure
axis off; axis image; axis vis3d

% load, mask

S = imread('tmp-sur.png');
[n, k] = size(Dflat);

S = imresize(S,[n k]);

D = imread('D-Pine_RGB.png');
Dflat = any(D, 3);

% Mask
Df = uint8(repmat(~Dflat, 1, 1, 3));
S = Df .* S;

% Add green
S(:, :, 1) = S(:, :, 1) + D(:, :, 1) .* uint8(Dflat);
S(:, :, 2) = S(:, :, 2) + D(:, :, 2) .* uint8(Dflat);
S(:, :, 3) = S(:, :, 3) + D(:, :, 3) .* uint8(Dflat);

% [whi, whj] = ind2sub(size(Dflat), find(Dflat(:)));
% S(whi, whj, 2) = 105;
% S(whi, whj, 3) = 65;

figure(f3);
image(S)
axis image
axis off

saveas(gcf, 'CANlab_D_brain_green_reverse.png');

%% Brain in D, colors in tree

f3 = figure('Color', 'w'); % target figure
axis off; axis image; axis vis3d

% load, mask

S = imread('tmp-sur.png');

S = S + 50; % brighten the whole thing

[n, k] = size(Dflat);

S = imresize(S,[n k]);

D = imread('D-Pine_RGB.png');
Dflat = ~any(D, 3);

% Mask
Df = uint8(repmat(~Dflat, 1, 1, 3));
S = Df .* S;

% Add green
S(:, :, 1) = S(:, :, 1) + uint8(Dflat) .* 0;
S(:, :, 2) = S(:, :, 2) + uint8(Dflat) .* 105;
S(:, :, 3) = S(:, :, 3) + uint8(Dflat) .* 65;

% [whi, whj] = ind2sub(size(Dflat), find(Dflat(:)));
% S(whi, whj, 2) = 105;
% S(whi, whj, 3) = 65;

figure(f3);
image(S)
axis image
axis off

han = text(1200, 1600, 'CANlab', 'FontSize', 24, 'Color', [.85 .85 .85]);

saveas(gcf, 'CANlab_Dbrain_logo.png');

