% Creates images for each capital letter in the alphabet for several fonts
% (there should be more fonts too). All images are cropped and skeletonized
% to give reasonably uniform images

% These images are run through compute_features(), which produces a column
% vector of feature values. These are all compiled together and stored in a
% file, which can be loaded in ocr_train() or nprtool.
function produce_data()
crop_size = [32 32];

letters = 'A':'Z';
fonts = {'courier','times new roman', 'arial'};

data_sample_inputs = [];
data_sample_outputs = [];

images = zeros(crop_size(1),crop_size(2),length(fonts),length(letters));
for i=1:length(letters)
    images(1:crop_size(1),1:crop_size(2),1:length(fonts),i) = letterimages(letters(i));
    for j=1:length(fonts)
        in_col = compute_features(images(1:crop_size(1),1:crop_size(2),j,i));
        data_sample_inputs = [data_sample_inputs in_col];
        
        out_col = zeros(length(letters),1);
        out_col(i) = 1;
        data_sample_outputs = [data_sample_outputs out_col];
    end
end

save('nndata', 'data_sample_inputs', 'data_sample_outputs');


% Creates bunch of images for some letter
    function list = letterimages(letter)
        dim = [100 70];
        
        list = zeros(crop_size(1),crop_size(2),length(fonts));
        
        for ii=1:length(fonts)
            imshow(ones(dim));
            drawnow
            text('units','pixels','position',[5 dim(2)-20],'fontsize',40,'fontname',char(fonts(ii)),'string',letter)
            tim = getframe();
            tim2 = frame2im(tim);
            tim2 = double(tim2(1:dim(1),1:dim(2),1))/-255.0+1.0;
            tim2 = preprocess_image(tim2);
            list(1:crop_size(1),1:crop_size(2),ii) = tim2;
        end
    end
end
