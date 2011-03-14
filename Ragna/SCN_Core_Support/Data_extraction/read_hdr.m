function hdr = read_hdr(name,varargin)
global SPM_scale_factor

if nargin > 1, 
	dtype = varargin{1};
else
	dtype = 'n';
end

% list of datatypes to try if the first fails.
dtstring = {'l' 'b'};

% function hdr = read_hdr(name,[opt] datatype)
% Luis hernandez
% last edit 12-9-01 by tor wager
%
% Loads the analyze format header file from a file 'name' 
%
% The function returns a structure defined as 
% hdr = struct(...
%      'sizeof_hdr', fread(pFile, 1,'int32'),...
%      'pad1', setstr(fread(pFile, 28, 'char')),...
%      'extents', fread(pFile, 1,'int32'),...
%      'pad2', setstr(fread(pFile, 2, 'char')),...
%      'regular',setstr(fread(pFile, 1,'char')), ...
%      'pad3', setstr(fread(pFile,1, 'char')),...
%      'dims', fread(pFile, 1,'int16'),...
%      'xdim', fread(pFile, 1,'int16'),...
%      'ydim', fread(pFile, 1,'int16'),...
%      'zdim', fread(pFile, 1,'int16'),...
%      'tdim', fread(pFile, 1,'int16'),...
%      'pad4', setstr(fread(pFile,20, 'char')),...
%      'datatype', fread(pFile, 1,'int16'),...
%      'bits', fread(pFile, 1,'int16'),...
%      'pad5', setstr(fread(pFile, 6, 'char')),...
%      'xsize', fread(pFile, 1,'float'),...
%      'ysize', fread(pFile, 1,'float'),...
%      'zsize', fread(pFile, 1,'float'),...
%      'pad6', setstr(fread(pFile, 48, 'char'))...
%      'glmax', fread(pFile, 1,'int32'),...
%      'glmin', fread(pFile, 1,'int32'),... 
%      'descrip', setstr(fread(pFile, 80,'char')),...
%	'aux_file'        , setstr(fread(pFile,24,'char'))',...
%	'orient'          , fread(pFile,1,'char'),...
%	'origin'          , fread(pFile,5,'int16'),...
%	'generated'       , setstr(fread(pFile,10,'char'))',...
%	'scannum'         , setstr(fread(pFile,10,'char'))',...
%	'patient_id'      , setstr(fread(pFile,10,'char'))',...
%	'exp_date'        , setstr(fread(pFile,10,'char'))',...
%	'exp_time'        , setstr(fread(pFile,10,'char'))',...
%	'hist_un0'        , setstr(fread(pFile,3,'char'))',...
%	'views'           , fread(pFile,1,'int32'),...
%	'vols_added'      , fread(pFile,1,'int32'),...
%	'start_field'     , fread(pFile,1,'int32'),...
%	'field_skip'      , fread(pFile,1,'int32'),...
%	'omax'            , fread(pFile,1,'int32'),...
%	'omin'            , fread(pFile,1,'int32'),...
%	'smax'            , fread(pFile,1,'int32'),...
%	'smin'            , fread(pFile,1,'int32') );


   warning off
   % Read in Headerfile into the hdrstruct
   [pFile,messg] = fopen(name,'r',dtype);
   if pFile == -1
      %msgbox(messg); 
      errordlg(['File not found! ' name])
      return;
   end
   
   
   hdr = struct(...
      'sizeof_hdr', fread(pFile, 1,'int32'),...
      'pad1', setstr(fread(pFile, 28, 'char')),...
      'extents', fread(pFile, 1,'int32'),...
      'pad2', setstr(fread(pFile, 2, 'char')),...
      'regular',setstr(fread(pFile, 1,'char')), ...
      'pad3', setstr(fread(pFile,1, 'char')),...
      'dims', fread(pFile, 1,'int16'),...
      'xdim', fread(pFile, 1,'int16'),...
      'ydim', fread(pFile, 1,'int16'),...
      'zdim', fread(pFile, 1,'int16'),...
      'tdim', fread(pFile, 1,'int16'),...
      'pad4', setstr(fread(pFile,20, 'char')),...
      'datatype', fread(pFile, 1,'int16'),...
      'bits', fread(pFile, 1,'int16'),...
      'pad5', setstr(fread(pFile, 6, 'char')),...
      'xsize', fread(pFile, 1,'float'),...
      'ysize', fread(pFile, 1,'float'),...
      'zsize', fread(pFile, 1,'float'),...
      'pad6', setstr(fread(pFile, 48, 'char')),...
      'glmax', fread(pFile, 1,'int32'),...
      'glmin', fread(pFile, 1,'int32'),... 
      'descrip', setstr(fread(pFile, 80,'char')),...
       'aux_file'        , setstr(fread(pFile,24,'char'))',...
       'orient'          , fread(pFile,1,'char'),...
       'origin'          , fread(pFile,5,'int16'),...
       'generated'       , setstr(fread(pFile,10,'char'))',...
       'scannum'         , setstr(fread(pFile,10,'char'))',...
       'patient_id'      , setstr(fread(pFile,10,'char'))',...
       'exp_date'        , setstr(fread(pFile,10,'char'))',...
       'exp_time'        , setstr(fread(pFile,10,'char'))',...
       'hist_un0'        , setstr(fread(pFile,3,'char'))',...
       'views'           , fread(pFile,1,'int32'),...
       'vols_added'      , fread(pFile,1,'int32'),...
       'start_field'     , fread(pFile,1,'int32'),...
       'field_skip'      , fread(pFile,1,'int32'),...
       'omax'            , fread(pFile,1,'int32'),...
       'omin'            , fread(pFile,1,'int32'),...
       'smax'            , fread(pFile,1,'int32'),...
       'smin'            , fread(pFile,1,'int32') ... 
       );
    
    % this is where SPM hides its scaling factor when it writes floating point images in 
    % byte format to save space.  Those crafty guys ...
    fseek(pFile, 112, 'bof');
    hdr.SPM_scale = fread(pFile, 1, 'float');
	warning on
    % if ~(hdr.SPM_scale == 1) & ~(hdr.SPM_scale ~= 0) ,disp(['SPM scale factor is ' num2str(hdr.SPM_scale)]),end

   fclose(pFile);

   if hdr.datatype <= 64
	% ok

   elseif nargin == 1				% only run the 1st time through.
	j = 0;
	while hdr.datatype > 64
		j = j+1;

		% exit the loop if end of string
		if j > length(dtstring), 
			break, 
		end

		dtype = dtstring{j};
		hdr = read_hdr(name,dtype);
		
	end

   end


return


