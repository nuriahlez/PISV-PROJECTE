% Irina Moreno 1565215 & Núria Hernández 1565995
% PSIV - PROJECTE 

% medium
% p1 = "C:\Users\irina\Desktop\UNI\2n\Processament de Senyals, Imatge i Video\proj\medium\set1\cam_1\";
% p2 = "C:\Users\irina\Desktop\UNI\2n\Processament de Senyals, Imatge i Video\proj\medium\set1\cam_2\";
% p3 = "C:\Users\irina\Desktop\UNI\2n\Processament de Senyals, Imatge i Video\proj\medium\set1\cam_3\";
% 
% v1 = deteccio(p1, 3, 'detecció_moviment1');
%
% v2 = deteccio(p2, 3, 'detecció_moviment2');
% 
% v3 = deteccio(p3, 3, 'detecció_moviment3');

%easy
p1 = "C:\Users\irina\Desktop\UNI\2n\Processament de Senyals, Imatge i Video\proj\easy\set1\cam_1\";
p2 = "C:\Users\irina\Desktop\UNI\2n\Processament de Senyals, Imatge i Video\proj\easy\set1\cam_2\";
p3 = "C:\Users\irina\Desktop\UNI\2n\Processament de Senyals, Imatge i Video\proj\easy\set1\cam_3\";

v1 = deteccio(p1, 1, 'detecció_moviment1');

v2 = deteccio(p2, 1, 'detecció_moviment2');

v3 = deteccio(p3, 1, 'detecció_moviment3');


function video = deteccio(path, num, nom)

    files = dir(path + "*.jpg");
    fotos_ = files(1:1500);
    s = size(fotos_);
    num_obj = num;

    fotos = zeros(288,384,s(1), 'uint8');
    fotos_color = zeros(288,384,3,s(1), 'uint8');

    for i=1:s(1)
        im_color = imread(path + fotos_(i).name);
        im_gray = rgb2gray(im_color);
        fotos(:,:,i) = im_gray;
        fotos_color(:,:,:,i) = im_color;
    end

    mitjana = mean(fotos,3);

    video = VideoWriter(path + nom);
    open(video);

    thr = 25;
    max_obj = 1;

    for n=1:s(1)
        f = fotos(:,:,n);

        resta = abs(uint8(mitjana) - f);
        comp = double(resta) > thr;
        
        % comp = bwmorph(comp,'majority');
        comp = medfilt2(comp);
        comp = imfill(comp, 'holes');
        % comp = imopen(comp, strel('disk', 1));

        img = fotos_color(:,:,:,n);
        colors = ('grycwm');

        [etiquetes,num_elements] = bwlabel(comp);
        propietats = regionprops(etiquetes, 'all');
        areas_grans = find([propietats.Area]>600);

        for i=1:num_elements
            if (num_obj > 1)
                for x=1:size(areas_grans,2)
                    % r = rectangle('Position',propied(s(x)).BoundingBox,'EdgeColor',colors(x),'LineWidth',2);
                    % r;
                   
                    strmax = ['Objecte ',num2str(x)];
                    pos = [propietats(areas_grans(x)).Centroid(1), propietats(areas_grans(x)).Centroid(2)];
                    if (x > max_obj)
                        max_obj = x;
                    end
                    
                    % t = text(pos(1), pos(2),strmax,'HorizontalAlignment','left', 'Color',colors(x));
                    % t;
                    
                    img = insertShape(img, 'Rectangle', propietats(areas_grans(x)).BoundingBox,'Color',colors(x),'LineWidth', 2);
                    img = insertText(img, pos, strmax,'TextColor',colors(x), 'BoxColor', 'white');
                    writeVideo(video, img);
                    % figure(1);
                    % imshow(img, []);
                end

            else
                 ROI = bwconvhull(comp);
                 stats = regionprops(ROI, 'BoundingBox','MajorAxisLength','MinorAxisLength', 'Centroid');
                 
                 % r = rectangle('Position', stats.BoundingBox,'EdgeColor',colors(x),'LineWidth', 2);
                 % r;
                 
                 strmax = 'Objecte 1';
                 pos = [stats.Centroid(1),stats.Centroid(2)];

                 % t = text(pos(1), pos(2),strmax,'HorizontalAlignment','left', 'Color',colors(x));
                 % t;
                 
                 img = insertShape(img, 'Rectangle', stats.BoundingBox,'Color','green','LineWidth', 2);
                 img = insertText(img, pos, strmax,'TextColor','green', 'BoxColor', 'white');
                 writeVideo(video, img);
                 % figure(1);
                 % imshow(img, []);
            end
        end
    end
    
    fprintf("Número d'objectes: %d\n", max_obj);

    close(video);
end

%{
--------FLUX ÒPTIC-------

opticFlow = opticalFlowHS;

h = figure;
movegui(h);
hViewPanel = uipanel(h,'Position',[0 0 1 1],'Title','Optical Flow Vectors');
hPlot = axes(hViewPanel);

for i=1:s(1)
    frameRGB = fotos_color(:,:,:,i);
    frameGray = fotos(:,:,i);

    flow = estimateFlow(opticFlow,frameGray);
    imshow(frameRGB)
    hold on
    plot(flow,'DecimationFactor',[5 5],'ScaleFactor',60,'Parent',hPlot);
    hold off
    pause(10^-3)
end
%}
