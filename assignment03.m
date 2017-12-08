clc;close all;clear;
indices = [02,03,05,06,07,09,10];
for k = 1:numel(indices) 
Irgb = imread(['rotor' sprintf('%2.2d', indices(k)) '.jpg']);
Ihsv = rgb2hsv(Irgb);
I = Ihsv(:,:,3);
hold on

area = 0;
air = 0;
BW = edge(I,'canny', [0.1 0.5], 0.7);
% BW = edge(I,'canny');
% imshow(BW, 'border', 'tight')
% SEO = strel('disk', 4);
% IOpen = imopen(BW, SEO);
% figure
% imshow(IOpen, 'border', 'tight')
SE1 = strel('line', 5,0);
SE2 = strel('line', 5,90);
IDil = imdilate(BW, [SE1, SE2]);
% figure
% imshow(IDil, 'border', 'tight')

BWFill = imfill(IDil, 'holes');
% figure
% imshow(BWFill, 'border', 'tight')

SEO = strel('disk', 15);
IOpen = imopen(BWFill, SEO);
figure
imshow(IOpen, 'border', 'tight')

[labels, number] = bwlabel(IOpen, 8);
Istats = regionprops(labels, 'basic', 'Centroid');

[values, index] = sort([Istats.Area], 'descend');
[maxVal, maxIndex] = max([Istats.Area]);
% Istats = regionprops('table',labels,'Centroid',...
%     'MajorAxisLength','MinorAxisLength');


% centers = Istats.Centroid;
% diameters = mean([Istats.MajorAxisLength Istats.MinorAxisLength],2);
% radii = diameters/2;
% hold on
% viscircles(centers,radii);
% hold off
center = [(Istats(maxIndex).BoundingBox(1)+Istats(maxIndex).BoundingBox(3)/2) ...
    (Istats(maxIndex).BoundingBox(2)+Istats(maxIndex).BoundingBox(4)/2)];
radius = max(Istats(maxIndex).BoundingBox(3)/2, Istats(maxIndex).BoundingBox(4)/2);
viscircles(center,5);
viscircles(center, radius);
rectangle('Position', [Istats(maxIndex).BoundingBox], 'LineWidth', 3, 'EdgeColor', 'r');

for x = 1:480
    for y = 1:480
        if(hypot(abs(center(1)-x), abs(center(2)-y)) < radius)
            if(BWFill(x, y) == 1)
                area = area+1;
            else
                air = air+1;
            end
        end
    end
end
TotalArea(k) = area;
TotalAir(k) = air;
Ratio(k) = air/area;
end
figure(1);close;
Table = table(TotalArea, TotalAir, Ratio);


filename = 'Table.xlsx';
writetable(Table,filename,'Sheet',1,'Range','A1')