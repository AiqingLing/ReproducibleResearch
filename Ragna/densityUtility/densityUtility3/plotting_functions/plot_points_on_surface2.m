function plot_points_on_surface2(XYZ,varargin)
% function plot_points_on_surface2(XYZ,varargin)
%
% This function plots a 3-column vector of xyz points (coordinates from
% studies) on a glass brain.  Four different views are created in 2
% figures.
%
% An optional 2nd argument is a color, or list of colors.
% An optional 3rd argument is a vector of integers to classify the points
% into groups.  Each group gets a color in the colors vector.
% Opt 4th argument is cell array of letter/number codes to use as markers
% If 4th argument is entered, then peaks within 12 mm with the same text code
% (i.e., study or contrast code) are averaged together for clarity of
% display
% a 5th argument suppresses the use of text labels, but leaves the
% averaging
%
% examples:
% plot_points_on_surface2(XYZ,color);
% plot_points_on_surface2(XYZ,color,[],letter);    % with letters!!  (cell
% array)
%
% Do nearby-averaging based on study ID; xyzem = [x y z]
% plot_points_on_surface2(xyzem,{'ro'},[],EMDB.Study,1);
%
% Select only some Emotions, and plot those in different colors
% [ind,nms,condf] = string2indicator(DB.Emotion);
% condf = indic2condf(ind(:,[2 3 4 5 7])); colors = {'ro' 'gv' 'md' 'ys' 'b^'};
% plot_points_on_surface2(DB.xyz,colors,condf,DB.Contrast,1);
% myp = findobj(gcf,'Type','Patch');
% set(myp,'FaceColor',[.85 .6 .5])
% for i = 1:6, subplot(3,2,i); axis off; end
%
% Make a legend for this figure
% nms = nms([2 3 4 5 7]);
% makelegend(nms,colors,1);
% scn_export_papersetup(200);
% saveas(gcf,'all_surf_emotion_pts_legend','png')

%f1 = figure('Color', 'w'); 
f1 = create_figure('Surface Point Plot');

current_position = get(f1, 'Position');
set(f1, 'Position', [current_position(1:2) 1024 1280]);
set(gca,'FontSize',18);
hold on;

surfdist = 22;      % distance from surface to extract

% --------------------------------
% set up colors
% --------------------------------

colors = {'ro' 'go' 'bo' 'yo' 'co' 'mo' 'ko' 'r^' 'g^' 'b^' 'y^' 'c^' 'm^' 'k^'};

if length(varargin) > 0, colors = varargin{1};  end
if length(varargin) > 1, classes = varargin{2};  else classes = ones(size(XYZ,1),1);  end

if isempty(classes), classes = ones(size(XYZ,1),1); end
if ~iscell(colors), colors = {colors}; end
if isempty(colors), colors = {'ro' 'go' 'bo' 'yo' 'co' 'mo' 'ko' 'r^' 'g^' 'b^' 'y^' 'c^' 'm^' 'k^'};  end

% if we enter a vector of colors for each point, set up classes and colors
if length(colors) == size(XYZ,1)
    classes = zeros(size(colors));
    coltmp = unique(colors);
    
    for i = 1:length(coltmp)
        wh = find(strcmp(colors,coltmp{i}));
        classes(wh) = i;
    end
    colors = coltmp';
elseif length(colors) > 1 && length(colors) < length(unique(classes(classes~=0)))
    error('There seem to be too few colors in your input.')
end

% --------------------------------
% set up text
% --------------------------------
if length(varargin) > 2, textcodes = varargin{3}; 
    
    % make textcodes into cell, if not
    % This is for averaging nearby by textcode, if the study/contrast
    % grping is not a cell array of strings.
    if ~iscell(textcodes), tmp={};
        for i = 1:size(textcodes,1), tmp{i} = num2str(textcodes(i));  end
        textcodes = tmp';
    end
    
    % if plotting text codes, make white
    if length(varargin) < 4, for i = 1:length(colors), colors{i}(2) = '.'; end, end
    
    disp(['Averaging nearby points within 12 mm with the same text code.']);
    
    % average nearby coordinates together!  12 mm
    [XYZ,textcodes,order] = average_nearby_xyz(XYZ,12,textcodes);
    classes = classes(order);
    
    % second pass, 8 mm
    [XYZ,textcodes,order] = average_nearby_xyz(XYZ,8,textcodes);
    classes = classes(order);
else
    textcodes = [];
    disp('Plotting all peaks; no averaging.');
end

if length(varargin) > 3, disp(['Not plotting text codes.']), textcodes = [];  end

% --------------------------------
% make figures -- plot points
% --------------------------------

XYZ_orig = XYZ;     % original;
textcodes_orig = textcodes;
classes_orig = classes;

for i = 1:6 % for each view
    subplot(3,2,i);
    
    XYZ = XYZ_orig;
    textcodes = textcodes_orig;
    classes = classes_orig;
    
    switch i
        case 1
            % top view, add to z
            wh = find(XYZ(:,3) <= 0);
            XYZ(wh,:) = [];
            XYZ(:,3) = XYZ(:,3) + surfdist;
            if ~isempty(textcodes), textcodes(wh) = []; end
            classes(wh) = [];
        case 2
            % bottom view
            wh = find(XYZ(:,3) >= 0);
            XYZ(wh,:) = [];
            XYZ(:,3) = XYZ(:,3) - surfdist;
            if ~isempty(textcodes), textcodes(wh) = []; end
            classes(wh) = [];
        case 3
            % left view
            wh = find(XYZ(:,1) >= 0);
            XYZ(wh,:) = [];
            XYZ(:,1) = XYZ(:,1) - surfdist;
            if ~isempty(textcodes), textcodes(wh) = []; end
            classes(wh) = [];
        case 4
             % right view
             wh = find(XYZ(:,1) <= 0);
            XYZ(wh,:) = [];
            XYZ(:,1) = XYZ(:,1) + surfdist;
            if ~isempty(textcodes), textcodes(wh) = []; end
            classes(wh) = [];
        case 5
            % front view
            %wh = find(XYZ(:,2) <= 0);
            %XYZ(wh,:) = [];
            %XYZ(:,2) = XYZ(:,2) + surfdist;
            %if ~isempty(textcodes), textcodes(wh) = []; end
            %classes(wh) = [];
            
            % right medial
            wh = find(~(XYZ(:,1) >= 0 & XYZ(:,1) <= 16));

             XYZ(wh,:) = [];
            XYZ(:,1) = XYZ(:,1) - 2.*surfdist;
            if ~isempty(textcodes), textcodes(wh) = []; end
            classes(wh) = [];
        case 6            
            % back view
            %wh = find(XYZ(:,2) >= 0);
            %XYZ(wh,:) = [];
            %XYZ(:,2) = XYZ(:,2) - surfdist;
            %if ~isempty(textcodes), textcodes(wh) = []; end
            %classes(wh) = [];
            
            % left medial
            wh = find(~(XYZ(:,1) <= 0 & XYZ(:,1) >= -16));
             XYZ(wh,:) = [];
            XYZ(:,1) = XYZ(:,1) + 2.*surfdist;
            if ~isempty(textcodes), textcodes(wh) = []; end
            classes(wh) = [];
    end
    
    hold on;
    if isempty(textcodes)
        % plot points
        for clas = 1:max(classes)

            h = plot3(XYZ(classes==clas,1),XYZ(classes==clas,2),XYZ(classes==clas,3), ...
            ['w' colors{clas}(2)],'MarkerFaceColor',colors{clas}(1),'MarkerSize',8);
        end

    else
        for j = 1:length(textcodes)
            % text labels
            pt(j) = text(XYZ(j,1),XYZ(j,2),XYZ(j,3),...
            textcodes{j},'Color',colors{classes(j)}(1),'FontSize',12,'FontWeight','bold');
        end
    end

    drawnow
end


% --------------------------------
% make figures -- add brains
% --------------------------------


for i = 1:6 % for each view
    subplot(3,2,i);
    
    
    
        switch i
        case 1
            % top view, add to z
            p(i) = addbrain('hires'); set(p,'FaceAlpha',1); drawnow;
            view(0,90); [az,el] = view; h(i) = lightangle(az,el); set(gca,'FontSize',18)
            material dull
        case 2
            % bottom view
            p(i) = addbrain('hires'); set(p,'FaceAlpha',1); drawnow;
            view(0,270); [az,el] = view; h(i) = lightangle(az,el); set(gca,'FontSize',18)
            set(gca,'YDir','Reverse')
            material dull
        case 3
            % left view
            p(i) = addbrain('hires'); set(p,'FaceAlpha',1); drawnow;
            view(270,0); [az,el] = view; h(i) = lightangle(az,el); set(gca,'FontSize',18)
            material dull
        case 4
             % right view
             p(i) = addbrain('hires'); set(p,'FaceAlpha',1); drawnow;
            view(90,0); [az,el] = view; h(i) = lightangle(az,el); set(gca,'FontSize',18)
            material dull
        case 5
            % front view
            %view(180,0); [az,el] = view; h(i) = lightangle(az,el); set(gca,'FontSize',18)

            % right medial
            p(i) = addbrain('hires right'); set(p,'FaceAlpha',1, 'FaceColor', [.5 .5 .5]); drawnow;
            view(270,0); [az,el] = view; h(i) = lightangle(az,el); set(gca,'FontSize',18)
            material dull
            set(gco,'FaceColor',[.5 .5 .5])
            camzoom(.8)

        case 6            
            % back view
            %view(0,0); [az,el] = view; h(i) = lightangle(az,el); set(gca,'FontSize',18)
            
            % left medial
            view(90,0); [az,el] = view; h(i) = lightangle(az,el); set(gca,'FontSize',18)
            p(i) = addbrain('hires left'); set(p,'FaceAlpha',1, 'FaceColor', [.5 .5 .5]); drawnow;
            material dull
           
        end
    
        camzoom(1.3)
        axis image;
        lightRestoreSingle(gca);
        scn_export_papersetup(900);
        
% %         if i==6
% %         	camzoom(.9)
% %             camzoom(.95)
% %         end
end





