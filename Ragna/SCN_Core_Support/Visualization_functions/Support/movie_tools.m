function mov = movie_tools(meth,varargin)
% Make a movie of a rotating brain
% mov = movie_tools('rotate',targetaz,targetel,mov,movlength)
%
% Examples:
%
% mov = movie_tools('rotate',135,30)
% mov = movie_tools('rotate',250,30,mov)
%
% mov = movie_tools('rotate',targetaz,targetel,mov,movlength,starttranspval,endtranspval,handles_for_trans)
% mov = movie_tools('rotate',270,30,mov,3,.05,.8,p9); % with transparency
% Batch mode:
% mov = movie_tools('batch360.1');
% mov = movie_tools('right2left');
%
% mov = movie_tools('transparent',startt,endt,handles,mov,movlength)
% mov = movie_tools('transparent',1,.15,p10,mov,2.5);
%
% Add still frames
% mov = movie_still('still',mov,1);
% mov = movie_still('still',mov,movlength);
%
% zoom
% mov = movie_tools('zoom',.8,mov,1);
%
%
% add lines that trace over time
% mov = movie_tools('lines',startcoords,endcoords,mov,color,bendval,movlength,startt,endt,handles,targetaz,targetel);
% mov2 = movie_tools('lines',x,y,[],[],[0 -.1 0],2,[],[],[],[],[]);
%
% tor wager, may 06
% updated sept 06

mov = [];
movlength = 3; % in s

global FRAMESTYLE

FRAMESTYLE = 'matlab'; % 'matlab' or 'avi', hard-coded here

switch meth
    % Batch-mode: pre-set movies

    case'batch360.1'
        axis vis3d, axis image
        view(0,90); axis off; %set(gcf,'Color','w');
        mov = movie_tools('rotate',135,30,mov);
        mov = movie_tools('rotate',250,30,mov);
        mov = movie_tools('rotate',360,90,mov);

        if strcmp(FRAMESTYLE, 'avi'), mov = close(mov); end
        return

    case 'right2left'
        axis vis3d, axis image
        view(240,30)
        mov = movie_tools('rotate',90,5,mov);

        % command modes

    case 'rotate'
        targetaz = varargin{1};
        targetel = varargin{2};
        startt = []; endt = []; handles = [];
        if length(varargin) > 2, mov = varargin{3}; end
        if length(varargin) > 3, movlength = varargin{4}; end
        if length(varargin) > 4, startt = varargin{5}; end
        if length(varargin) > 5, endt = varargin{6}; end
        if length(varargin) > 6, handles = varargin{7}; end
        mov = movie_rotation(targetaz,targetel,mov,movlength,startt,endt,handles);


    case 'transparent'
        startt = varargin{1};
        endt = varargin{2};
        if length(varargin) > 2, handles = varargin{3}; end
        if length(varargin) > 3, mov = varargin{4}; end
        if length(varargin) > 4, movlength = varargin{5}; end

        mov = movie_transparent(startt,endt,handles,mov,movlength);

    case 'zoom'
        myzoom = varargin{1};
        if length(varargin) > 1, mov = varargin{2}; end
        if length(varargin) > 2, movlength = varargin{3}; end

        mov = movie_zoom(myzoom,mov,movlength);


    case 'still'
        if length(varargin) > 0, mov = varargin{1}; end
        if length(varargin) > 1, movlength = varargin{2}; end

        mov = movie_still(mov,movlength)


    case 'lines'
        % notes: this can be used to do combos of any of rotation,
        % transparency, and lines

        % defaults
        mov = []; color = 'k'; bendval = 0;
        startt = 1; endt1 = 1; handles = [];
        targetaz = []; targetel = [];

        startcoords = varargin{1};
        endcoords = varargin{2};
        if length(varargin) > 2, mov = varargin{3}; end
        if length(varargin) > 3, color = varargin{4}; end
        if length(varargin) > 4, bendval = varargin{5}; end
        if length(varargin) > 5, movlength = varargin{6}; end

        if length(varargin) > 6, startt = varargin{7}; end
        if length(varargin) > 7, endt = varargin{8}; end
        if length(varargin) > 8, handles = varargin{9}; end

        if length(varargin) > 9, targetaz = varargin{10}; end
        if length(varargin) > 10, targetel = varargin{11}; end

        mov = movie_lines(startcoords,endcoords,mov,color,bendval,movlength,startt,endt,handles,targetaz,targetel);

    otherwise
        error('Unknown method')

end


return



% ------------------------------------------------------------
% rotation
% ------------------------------------------------------------

function mov = movie_rotation(targetaz,targetel,mov,movlength,varargin)

if nargin < 4, movlength = 3; end  % in s

[mov,nframes,axh,az,el] = setup_movie(mov,movlength);

% setup optional transparency
dotrans = 0;
if length(varargin) > 0 && ~isempty(varargin{1})
    dotrans = 1;
    startt = varargin{1};
    endt = varargin{2};
    handles = varargin{3};
    mytrans = linspace(startt,endt,nframes);
end

myaz = linspace(az,targetaz,nframes);
myel = linspace(el,targetel,nframes);

for i = 1:nframes

    mov = add_a_frame(mov,axh);
    view(myaz(i),myel(i));

    if dotrans
        set(handles,'FaceAlpha',mytrans(i));
    end

end

mov = add_a_frame(mov,axh);

return



% ------------------------------------------------------------
% still
% ------------------------------------------------------------

function mov = movie_still(mov,movlength)

if nargin < 2, movlength = 3; end  % in s

[mov,nframes,axh,az,el] = setup_movie(mov,movlength);
for i = 1:nframes
    mov = add_a_frame(mov,axh);
end
return



% ------------------------------------------------------------
% transparency
% ------------------------------------------------------------

function mov = movie_transparent(startt,endt,handles,mov,movlength)

if nargin < 4, movlength = 3; end  % in s


[mov,nframes,axh,az,el] = setup_movie(mov,movlength);

mytrans = linspace(startt,endt,nframes);

for i = 1:nframes

    mov = add_a_frame(mov,axh);
    set(handles,'FaceAlpha',mytrans(i));

end

mov = add_a_frame(mov,axh);

return


% ------------------------------------------------------------
% zoom
% ------------------------------------------------------------

function mov = movie_zoom(myzoom,mov,movlength)

if nargin < 3, movlength = 3; end  % in s


[mov,nframes,axh,az,el] = setup_movie(mov,movlength);

myzoom = 1 + ( (myzoom-1) ./ nframes);

for i = 1:nframes

    mov = add_a_frame(mov,axh);
    camzoom(myzoom);

end

mov = add_a_frame(mov,axh);

return



% ------------------------------------------------------------
% lines (and rotate and transparency)
% ------------------------------------------------------------
function mov = movie_lines(startcoords,endcoords,mov,color,bendval,movlength,startt,endt,handles,targetaz,targetel)


[mov,nframes,axh,az,el] = setup_movie(mov,movlength);

if isempty(targetaz), targetaz = az; end
if isempty(targetel), targetel = el; end

% set up rotation
% ---------------------------------
myaz = linspace(az,targetaz,nframes);
myel = linspace(el,targetel,nframes);

% set up transparency
% ---------------------------------
if ~isempty(startt)
    dotrans = 1;
    mytrans = linspace(startt,endt,nframes);
else
    dotrans = 0;
end

% set up lines
% ---------------------------------
if isempty(color), color = 'k'; end


% get entire path
for i = 1:size(startcoords,1)   % coords are one triplet per row.  each row is a graphic line

    out{i} = nmdsfig_tools('connect3d',startcoords(i,:),endcoords(i,:),color,4,bendval,nframes);
    delete(out{i}.h);  % we will draw this piece by piece later
end


% make each frame
% ---------------------------------
lineh = [];
hold on

for i = 1:nframes

    mov = add_a_frame(mov,axh);
    view(myaz(i),myel(i));

    if dotrans
        set(handles,'FaceAlpha',mytrans(i));
    end

    % draw all lines up to point specified for this frame
    if ishandle(lineh), delete(lineh); lineh = []; end

    for n = 1:length(out)
        h = plot3(out{n}.xcoords(1:i),out{n}.ycoords(1:i),out{n}.zcoords(1:i),color,'LineWidth',3);

        h2 = plot3(out{n}.xcoords(i),out{n}.ycoords(i),out{n}.zcoords(i),'*','Color',[1 .8 0],'MarkerFaceColor',[1 1 0],'MarkerSize',12);
        lineh = [lineh h h2];
    end


end

mov = add_a_frame(mov,axh);


return




function [mov,nframes,axh,az,el] = setup_movie(mov,movlength)

global FRAMESTYLE

switch(FRAMESTYLE)
    case 'avi' % write to avi format directly
        axh = gca;
    case 'matlab' % matlab movie format
        axh = gcf; % we need whole figure; pixel dims cannot change
end

fps = 10;
nframes = movlength .* fps;

switch(FRAMESTYLE)
    case 'avi' % write to avi format directly
        if isempty(mov)
            mov = avifile('mymovie.avi','Quality',75,'Compression','None','Fps',fps);
        end

    case 'matlab' % matlab movie format
        % do nothing; matlab movie fmt
end

% add to existing
%O = struct('add2movie',[],'zoom',1,'azOffset',[],'elOffset',[],'timecourse',[],'fps',5,'length',6);

%axis vis3d, axis image

[az,el]=view;

return



function mov = add_a_frame(mov,H)

global FRAMESTYLE





switch(FRAMESTYLE)
    case 'avi'
        lightRestoreSingle(H);
        drawnow

        try
            mov = addframe(mov,H);
        catch
            disp('Cannot write frame.  Failed to set stream format??')
            mov = close(mov);
        end

    case 'matlab'
        lightRestoreSingle(gca);

        % make current to avoid including extra junk occluding your figure
        figure(gcf); %get(H, 'parent'));
        drawnow
        
        if isempty(mov)
            mov = getframe(H);
        else
            mov(end+1) = getframe(H);
        end

    otherwise
        error('Unknown FRAMESTYLE in movie_tools.m');
end

return