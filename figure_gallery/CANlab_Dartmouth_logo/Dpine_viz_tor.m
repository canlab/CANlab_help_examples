D = imread('D-Pine_Black.jpg');
Dflat = ~any(D, 3);

[n, k] = size(Dflat);
t = 25;

% X = (1:n)';
% 
% for i = 1:(k-1)
%     X(:, end+1) = [X(2*i:end, 1); X(1:2*i-1, 1)];
%     
% end

X = zeros(n, k);
X(:, 101:300) = repmat((1:n)', 1, 200);
%X(:, k-99:k) = repmat((n:-1:1)', 1, 100);
X(:, 201:400) = repmat((n:-1:1)', 1, 200);

% X = X ./ norm(X);

%X = rand(n, k);

% Create rotation matrix
% -----------------------------------------------------

v = .99 .^ ([1:k]-1)'; % column

r = zeros(1, k); r(1) = 1;
V = toeplitz(r, v);

% V = V ./ repmat(sum(V), k, 1);

X = X * V;

% viz
% -----------------------------------------------------

create_figure('V, X', 1, 2);
imagesc(V);
axis tight; set(gca, 'YDir', 'Reverse')
colorbar

% Image X
subplot(1, 2, 2)
set(gca, 'YDir', 'Reverse')
imagesc(X)
axis tight; set(gca, 'YDir', 'Reverse')
axis off
%colorbar

% cm = colormap;
% cm(1, :) = 1;
% colormap(cm)
cm = colormap_tor([1 1 1], [1 1 0], [0.3909    0.8029    0.4354]);
colormap(cm)
drawnow

% Video

%M = [];
% M = getframe(gca);

obj = VideoWriter('canlab_dpine1.mp4', 'MPEG-4');
open(obj);


%% rotate
% -----------------------------------------------------

for i = 1:t
    
%     if mod(i, 15) == 0
%         X(:, 101:200) = repmat((1:n)', 1, 100);
%         X(:, 201:300) = repmat((n:-1:1)', 1, 100);
%     end

        X = X * V;
        %X = X ./ norm(X);
        
        Xd = X .* Dflat;
        
        cla
        imagesc(Xd)
        axis tight;
        axis off;
        
        drawnow
        
        %         M(end+1) = getframe(gca);
        currFrame = getframe(gca);
        writeVideo(obj,currFrame);
        
    end
    
    
% end


%%
% 
% 
%     for j = 1:7
%         X = X * inv(V);
%         colorbar
%         
%         cla
%         imagesc(X)
%         axis tight;
%         
%         drawnow
%         pause(.1)
%         
%     end
% 
%     V = V * V;
%     subplot(1, 2, 1);
%     imagesc(V);
%     colorbar
%     drawnow
%     subplot(1, 2, 2)
%     
% end % outer loop

%% Close Movie

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

