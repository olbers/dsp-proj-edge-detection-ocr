% Creates images for each capital letter in the alphabet for several fonts
% (there should be more fonts too). All images are cropped and skeletonized
% to give reasonably uniform images

% These images are run through compute_features(), which produces a column
% vector of feature values. These are all compiled together and stored in a
% file, which can be loaded in ocr_train() or nprtool.
function produce_data()
clc
crop_size = [20 20];

letters = 'A':'Z';
fonts = {'times new roman','courier', 'arial', 'helvetica', 'calibri'};
font_sizes = [12 14 16 18 32 40];

data_sample_inputs = [];
data_sample_outputs = [];

dim = [120 100];

for i=1:length(letters)
    this_letter = [];
    for j=1:length(fonts)
        for k=1:length(font_sizes)
            im = letterimages(char(letters(i)), char(fonts(j)), font_sizes(k));
            
            in_col = compute_features(im);
            data_sample_inputs = [data_sample_inputs in_col];
            this_letter = [this_letter in_col];
            
            out_col = zeros(length(letters),1);
            out_col(i) = 1;
            data_sample_outputs = [data_sample_outputs out_col];
        end
    end
    
    char(letters(i))
    this_letter
end
%data_sample_inputs

save('nndata', 'data_sample_inputs', 'data_sample_outputs');


% Creates bunch of images for some letter
    function tim2 = letterimages(letter, fontname, fontsize)
        imshow(ones(dim));
        drawnow
        text('units','pixels','position',[5 dim(2)-20],'fontsize',fontsize,'fontname',fontname,'string',letter)
        tim = getframe();
        tim2 = double(tim.cdata(2:dim(1)+1,2:dim(2)+1,1));
        tim2 = floor(tim2 ./ 255.0);
        tim2 = tim2 * -1.0 + 1.0;
    end
end
