
%% load embedding

load('SocialMedia_word2vec_tfidf_150kit_tsne.mat'); % load x (the embedding 2d locations from tsne)
x = mappedX;
clear ydata
x = bsxfun(@minus, x, min(x));
x = bsxfun(@rdivide, x, max(x));

%% load validation image filenames

fs = textread('aux_data/SocialMedia_word2vec_filelist_nowords.txt', '%s','bufsize',10000);

N = length(fs);

%% Raul: Shuffle data
ix = randperm(N);
x = x(ix,:);
fs = fs(ix);


%% create an embedding image

S = 4000; % size of full embedding image
G = zeros(S, S, 3, 'uint8');
s = 50; % size of every single image

Ntake = 150000;
word_img_coords = {'A' 'A' 'A' 'A' 'A' 'A' 'A' 'A' 'A' 'A' 'A' 'A' 'A' 'A' 'A' 'A' 'A' 'A' 'A' 'A' 'A' 'A' 'A' 'A' 'A' 'A' 'A' 'A' 'A' 'A' 'A' 'A' 'A' 'A'};
c = 0;
for i=1:Ntake
    
    if mod(i, 100)==0
        fprintf('%d/%d...\n', i, Ntake);
    end
    
    % location
    a = ceil(x(i, 1) * (S-s)+1);
    b = ceil(x(i, 2) * (S-s)+1);
    a = a-mod(a-1,s)+1;
    b = b-mod(b-1,s)+1;
    %im_name = strcat('../../datasets/WebVision/test_images_256/', fs{i});
    im_name = strcat('../../datasets/SocialMedia/img_resized_1M/cities_instagram/', fs{i});

    if findstr(fs{i},'word_images') == 1        
        c = c + 1;
        im_name = strcat(fs{i});      
        coords = strcat(int2str(a),int2str(b));
        if length(find(cellfun('length',regexp(word_img_coords,coords)) == 1)) > 0
            disp('Moving word image')
            a = a + s;
            coords = strcat(int2str(a),int2str(b));
        end
        
        if length(find(cellfun('length',regexp(word_img_coords,coords)) == 1)) > 0
            a = a - s;
            b = b + s;
            coords = strcat(int2str(a),int2str(b));
        end
        if length(find(cellfun('length',regexp(word_img_coords,coords)) == 1)) > 0
            a = a + s;
            coords = strcat(int2str(a),int2str(b));
        end
        if length(find(cellfun('length',regexp(word_img_coords,coords)) == 1)) > 0
            a = a - 2*s;
            b = b - s;
            coords = strcat(int2str(a),int2str(b));
        end
        if length(find(cellfun('length',regexp(word_img_coords,coords)) == 1)) > 0
            a = a + s;
            b = b - s;
            coords = strcat(int2str(a),int2str(b));
        end
        
        
        word_img_coords{c} = coords;   

    end

    % if G(a,b,1) ~= 0
    if sum(G(a+3:a+s-3, b+3:b+s-3, :)) ~=0
        % If the image is a word image, don't continue
        if findstr(fs{i},'word_images') == 1
            disp(fs{i})
        else
            continue % spot already filled
        end
    end
    I = imread(im_name);
    if size(I,3)==1, I = cat(3,I,I,I); end
    I = imresize(I, [s, s]);
    
    G(a:a+s-1, b:b+s-1, :) = I;
    
end

imshow(G);

%%
imwrite(G, 'cnn_embed_2k.jpg', 'jpg');

%% average up images
% % (doesnt look very good, failed experiment...)
% 
% S = 1000;
% G = zeros(S, S, 3);
% C = zeros(S, S, 3);
% s = 50;
% 
% Ntake = 5000;
% for i=1:Ntake
%     
%     if mod(i, 100)==0
%         fprintf('%d/%d...\n', i, Ntake);
%     end
%     
%     % location
%     a = ceil(x(i, 1) * (S-s-1)+1);
%     b = ceil(x(i, 2) * (S-s-1)+1);
%     a = a-mod(a-1,s)+1;
%     b = b-mod(b-1,s)+1;
%     
%     I = imread(fs{i});
%     if size(I,3)==1, I = cat(3,I,I,I); end
%     I = imresize(I, [s, s]);
%     
%     G(a:a+s-1, b:b+s-1, :) = G(a:a+s-1, b:b+s-1, :) + double(I);
%     C(a:a+s-1, b:b+s-1, :) = C(a:a+s-1, b:b+s-1, :) + 1;
%     
% end
% 
% G(C>0) = G(C>0) ./ C(C>0);
% G = uint8(G);
% imshow(G);

%% do a guaranteed quade grid layout by taking nearest neighbor
% 
% S = 2000; % size of final image
% G = zeros(S, S, 3, 'uint8');
% s = 50; % size of every image thumbnail
% 
% xnum = S/s;
% ynum = S/s;
% used = false(N, 1);
% 
% qq=length(1:s:S);
% abes = zeros(qq*2,2);
% i=1;
% for a=1:s:S
%     for b=1:s:S
%         abes(i,:) = [a,b];
%         i=i+1;
%     end
% end
% %abes = abes(randperm(size(abes,1)),:); % randperm
% 
% for i=1:size(abes,1)
%     a = abes(i,1);
%     b = abes(i,2);
%     %xf = ((a-1)/S - 0.5)/2 + 0.5; % zooming into middle a bit
%     %yf = ((b-1)/S - 0.5)/2 + 0.5;
%     xf = (a-1)/S;
%     yf = (b-1)/S;
%     dd = sum(bsxfun(@minus, x, [xf, yf]).^2,2);
%     dd(used) = inf; % dont pick these
%     [dv,di] = min(dd); % find nearest image
% 
%     used(di) = true; % mark as done
%     im_name = strcat('../../datasets/WebVision/test_images_256/', fs{i});
%     I = imread(im_name);
%     if size(I,3)==1, I = cat(3,I,I,I); end
%     I = imresize(I, [s, s]);
% 
%     G(a:a+s-1, b:b+s-1, :) = I;
% 
%     if mod(i,100)==0
%         fprintf('%d/%d\n', i, size(abes,1));
%     end
% end
% 
% %imshow(G);
% 
% %%
% imwrite(G, 'cnn_embed_full_2k.jpg', 'jpg');
