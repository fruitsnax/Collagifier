clc; clear all; close all;
%% Import lib Photos
block = 100; %Play with this for quality and runtime
n = 69; % Number of photos
lib = [];
for i = 1:n
    name = strcat(num2str(i), '.jpg');
    img = imread(name);
    img = imresize(img, [block, block]);
    lib = [lib, img];
end
%% Import orig Photo
orig = imread('orig2.jpg'); %Photo to collage over
origw = 12800; %Set these to 10x photo dimensions to start with
origh = 8600;
orig = imresize(orig, [origh, origw]);
old = orig;
image(orig)

% For each px block
uses = zeros(1, n);
for h = 0:(origh/block - 1) %rows 
    for w = 0:(origw/block - 1) %columns
        A = orig(block*h+1:block*(h+1), block*w+1:block*(w+1), :);
        
        max = 0;
        maxUse = 500; %Max uses for each photo. Increase if using a small photo library
        m = 0; %block replaced
        i = 1;
        while i <= n %for each input picture in lib
            B = lib(:, block*(i-1)+1:block*i, :);
            sc = score(A, B, block);
            if sc > max %If replace               
                m = i;
                max = sc;
                orig(block*h+1:block*(h+1), block*w+1:block*(w+1), :) = B;
            end
            i = i + 1;
        end
        uses(1, m) = uses(1, m) + 1;
        if uses(1, m) > maxUse %If used maxUse times
            uses(m) = []; %= [uses(1, 1:m-1), uses(1, m:n)];
            left = lib(:, 1:block*(m-1) , :);
            right = lib(:, block*m + 1:block*n, :);
            lib = [left, right];
            n = n-1;
        end
    end
end
figure()
image(orig);

%% Adjust

for h = 0:(origh/block - 1) %rows
    for w = 0:(origw/block - 1) %columns
        A = old(block*h+1:block*(h+1), block*w+1:block*(w+1), :); %Old
        B = orig(block*h+1:block*(h+1), block*w+1:block*(w+1), :); %New
        for c = 1:3
            T = mean(mean(A)) - mean(mean(B));
            B(:, :, c) = B(:, :, c) + T(1, 1, c);
        end
        orig(block*h+1:block*(h+1), block*w+1:block*(w+1), :) = B;
    end
end

figure()
image(orig)
imwrite(orig, 'collage.jpg')

%% Compression SVD
%[u, s, v] = svd(orig(:, :, 1), 'econ')

%% Functions
function [out] = score(A, B, block)
but = 0;
for i = 1:3
    but = but + mean(abs(mean(A(:,:,i)) - mean(B(:,:,i))));
end
out = 1/but;
end
