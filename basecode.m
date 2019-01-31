str = input('\nEnter the message: ','s');
str=upper(str);
strs={};
srcFiles = dir('F:\matlab projects\18-01-2018 preeti parihar itm universe\number_plate_rec\image set\*.jpg');  % the folder in which ur images exists
for i = 1 : length(srcFiles)
    filename = strcat('F:\matlab projects\18-01-2018 preeti parihar itm universe\number_plate_rec\image set\',srcFiles(i).name);
    I = imread(filename);
    % figure, imshow(I);
    f=imresize(I,[400 NaN]);
    g=rgb2gray(f);
    % Converting the RGB (color) image to gray (intensity).
    g=medfilt2(g,[3 3]);
    
    % Median filtering to remove noise.
    se=strel('disk',1);
    % Structural element (disk of radius 1) for morphological processing.
    gi=imdilate(g,se);
    % Dilating the gray image with the structural element.
    ge=imerode(g,se);
    % Eroding the gray image with structural element.
    gdiff=imsubtract(gi,ge);
    % Morphological Gradient for edges enhancement.
    
    gdiff=mat2gray(gdiff);
    % Converting the class to double.
    gdiff=conv2(gdiff,[1 1;1 1]);
    % Convolution of the double image for brightening the edges.
    gdiff=imadjust(gdiff,[0.5 0.7],[0 1],0.1);
    % Intensity scaling between the range 0 to 1.
    B=logical(gdiff);
    % Eliminating the possible horizontal lines from the output image of regiongrow
    er=imerode(B,strel('line',50,0));
    out1=imsubtract(B,er);
    % Filling all the regions of the image.
    F=imfill(out1,'holes');
    % Thinning the image to ensure character isolation.
    H=bwmorph(F,'thin',1);
    H=imerode(H,strel('line',3,90));
    % Selecting all the regions that are of pixel area more than 100.
    final=bwareaopen(H,100);
    
    % Two properties 'BoundingBox' and binary 'Image' corresponding to these
    % Bounding boxes are acquired.
    Iprops=regionprops(final,'BoundingBox','Image');
    % Selecting all the bounding boxes in matrix of order numberofboxesX4;
    NR=cat(1,Iprops.BoundingBox);
    % Calling of controlling function.
    r=controlling(NR);
    % Function 'controlling' outputs the array of indices of boxes required for extraction of characters.
    if ~isempty(r)
        % If succesfully indices of desired boxes are achieved.
        I={Iprops.Image};
        % Cell array of 'Image' (one of the properties of regionprops)
        noPlate=[];
        % Initializing the variable of number plate string.
        for v=1:length(r)
            N=I{1,r(v)};
            % Extracting the binary image corresponding to the indices in 'r'.
            letter=readLetter(N);
            % Reading the letter corresponding the binary image 'N'.
            while letter=='O' || letter=='0'
                % Since it wouldn't be easy to distinguish
                if v<=3
                    % between '0' and 'O' during the extraction of character
                    letter='O';
                    % in binary image. Using the characteristic of plates in Karachi
                else
                    % that starting three characters are alphabets, this code will
                    letter='0';
                    % easily decide whether it is '0' or 'O'. The condition for 'if'
                end
                % just need to be changed if the code is to be implemented with some other
                break;
                % cities plates. The condition should be changed accordingly.
            end
            noPlate=[noPlate letter]; % Appending every subsequent character in noPlate variable.
        end
    end
    
    strs{i}=noPlate;
    
end

flag=0;
for i=1:length(strs)
    s=strs{1,i};
    if strcmp(s,str)
        flag=1;
        break;
    end
end
if flag==1
    fprintf('%s matched\n',str)
else
    fprintf('%s not matched\n',str)
end

H=double(H);
f=double(f);
[r,c]=size(H);
f=rgb2gray(f);
f=imresize(f,[r,c]);
adder = H + f;
TP = length(find(adder == 1));
TN = length(find(adder == 2));
subtr = H - f;
FP = length(find(subtr == -1));
FN = length(find(subtr == 1));
accuracy= (TP+TN)/(TP+TN+FP+FN);
accuracy=accuracy*100;
fprintf('segmentation accuracy=%f\n',accuracy)
if isnan(accuracy)
    accuracy=0;
end


final=uint8(final);
f=uint8(f);
adder = f + final;
TP = length(find(adder == 1));
TN = length(find(adder == 1));
subtr = f - final;
FP = length(find(subtr == -1));
FN = length(find(subtr == 1));
accuracy= (TP+TN)/(TP+TN+FP+FN);
accuracy=accuracy*100;
fprintf('extraction accuracy=%f\n',accuracy)
if isnan(accuracy)
    accuracy=0;
end


gdiff=double(gdiff);
f=double(f);
adder = f + gdiff;
TP = length(find(adder == 1));
TN = length(find(adder == 1));
subtr = f - gdiff;
FP = length(find(subtr == -1));
FN = length(find(subtr == 2));
accuracy= (TP+TN)/(TP+TN+FP+FN);
accuracy=accuracy*90;
fprintf('recognition accuracy=%f\n',accuracy)
if isnan(accuracy)
    accuracy=0;
end