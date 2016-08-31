f1 = create_figure('tsplot');

% x predictor, y time, z data
tlen = 5;

% Bottom
h1 = drawbox(0, 1, 0, tlen, 'k');

% Top
h2 = drawbox(0, 1, 0, tlen, 'k');
set(h2, 'Zdata', [1 1 1 1], 'FaceColor', 'k', 'FaceAlpha', 0)

% Back vertical
h3 = fill3([0 0 0 0], [0 0 tlen tlen], [0 1 1 0], 'g');
set(h3, 'FaceColor', [.9 .9 1]);

% Back Panel
h4 = fill3([0 0 1 1], [tlen tlen tlen tlen] , [0 1 1 0], 'k');
set(h4, 'FaceAlpha', .5);

% Front Panel
h4 = fill3([0 0 1 1], [0 0 0 0] , [0 1 1 0], 'k');
set(h4, 'FaceAlpha', 0, 'LineWidth', 2);

set(gca, 'XLim', [-1 2], 'YLim', [-1 2]);
xlabel('Predictor'); ylabel('Time'), zlabel('Data')

view(30, 15)

axis equal
axis vis3d

view(0, 0)

%% Generate data

t = 0:.1:(tlen - .1);
pred = .2 + zeros(1, length(0:.1:.9));
pred = [pred pred+.6 pred pred+.6 pred];

data = pred + .3 * (rand(1, length(pred)) - .5);

color = linspace(0, 1, length(t));

%% Plot it
mov = movie_tools('still',[],1);

hp = plot3(pred, t, data, 'go', 'LineWidth', 2);

mov = movie_tools('still',mov,1);

%% Rotate and Plot 3-D data
mov = movie_tools('rotate',30,15,mov,1);
mov = movie_tools('rotate',90,0,mov,1);

%% Plot data
for i = 1:length(t)
    
    plot3(pred(i), t(i), data(i), 'o', 'MarkerFaceColor', [color(i) 0 0]);
    
    %pause(.05)
    
    mov(end+1) = getframe(f1);
end

plot3(0 * pred, t, data, 'k-', 'LineWidth', 2);

mov = movie_tools('still',mov,1);

%% Plot predicted
mov = movie_tools('rotate',30,15,mov,1);

plot3(pred, t, 0 * data, 'b-');

for i = 1:length(t)
    
    % 3-D
    plot3(pred(i), t(i), data(i), 'g+');
    
    % pred
    plot3(pred(i), t(i), 0 + .01, 'bo', 'MarkerFaceColor', 'g');
    
    % lines
    lh1 = plot3([pred(i) pred(i)], [t(i) t(i)], [0 data(i)], 'r');
    lh2 = plot3([0 pred(i)], [t(i) t(i)], [data(i) data(i)], 'r');
    
    mov(end+1) = getframe(f1);
    
    delete(lh1);
    delete(lh2);
    
end

mov = movie_tools('still',mov,1);

%% plot beta plane

X = [pred' ones(length(t), 1)];
b = pinv(X) * data';

h3 = fill3([0 1 1 0], [0 0 tlen tlen], [0 b(1) b(1) 0], 'r', 'FaceAlpha', 1);

mov = movie_tools('still',mov,1);

mov = movie_tools('transparent',1,.5,h3,mov,1);

mov = movie_tools('still',mov,1);

mov = movie_tools('rotate',15,11,mov,1);

fit= X * b;
% now plot fit on back panel
plot3(0 * pred, t, fit, 'b-', 'LineWidth', 2);



%% timeseries view
mov = movie_tools('rotate',90,0,mov,1);
mov = movie_tools('still',mov,1);


%% data view
mov = movie_tools('rotate',0,0,mov,1);
mov = movie_tools('still',mov,1);

mov = movie_tools('rotate',26,13,mov,1);
mov = movie_tools('still',mov,2);
%%
movie2avi(mov, 'fmri_regression.avi', 'fps', 10);
