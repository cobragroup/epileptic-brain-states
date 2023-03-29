% HEADER: 
% This script preprocesses the real data. It removes line noise in human
% data, segments all data into 5sec (can be set differently below)
% segments, calculates chosen features and allows visual labeling via prompt
% input. 
% 
%
% YOU DO NOT NEED TO RUN THIS SCRIPT IN ODER TO TRY OUT THE CLASSIFICATION 
% PIPELINE UNLESS YOU WANT TO CHANGE PARAMETERS. RESULTING DATA VARIABLES 
% ARE ALREADY CONTAINED IN THE GITHUB REPOSITORY \VARS FOLDER.
%
%
% %% IF YOU HAVE ANY QUESTIONS, DO NOT HESITATE TO ASK THE AUTHOR OF THIS SCRIPT:
% %% Isa Dallmer-Zerbe
% %% Institute of Computer Science
% %% The Czech Academy of Sciences
% %% Prague
% %% dallmer-zerbe@cs.cas.cz 

clear; close all; clc

%% SET PATHS

PATH='...';                           %folder with subfolders /data, /code, /vars        
PATHIN=[PATH,'\data\'];               %raw data
PATHOUT=[PATH,'\vars\'];              %preprocessed data - features
addpath(genpath([PATH,'\code\']));    %code
cd(PATHIN);


%% SET PARAMETERS

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
datapars.segmlength=5;                %in seconds

%visual type labeling
datapars.label=false;                 %chose whether you want to newly visually label the data
datapars.types={'intICTAL-pre','preONSET','ONSET','SEIZ-early','SEIZ-late',...
    'intICTAL-post'};                 %you can change the types you want to label, but I have not tried this yet

%features
datapars.N_features=11;               %if you want to change the features, you need to change the calc_feat function, too
datapars.featurenames=  {'b0power', 'b1power', 'b2power', 'b3power', ...
    'b4power', 'alphdiff', 'spikeabs', 'sigmean', 'sigvar', 'autocorrel','linelen'};
datapars.normalizefeatures=true;      %this will normalize the features so that they all equally contribute
datapars.featureind=1:datapars.N_features;
datapars.oldfeatures=[1:4,6];         %these are the features described in Wendling 2005
datapars.newfeatures=[5,7:datapars.N_features];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% SCRIPT
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('RUNNING DATA SEGMENTATION AND FEATURE CALCULATION FOR real data...')

files=dir('*.mat');
for f=1:length(files)
    disp(files(f).name(1:end-4))
    close all
    clear data fs featuresF0 typeF0 DATA datalength Nsegm
    
    %% LOAD DATA
    cd(PATHIN);
    load(files(f).name)
    
    %% REPLACE NANS
    data(isnan(data))=mean(data,'omitnan'); 
    
    %% CENTER AND FLIP DATA
    data=data-mean(data);
    data=-data;
    
    %% FILTER 50Hz (HUMANS ONLY)
    if strcmp(data_type,'human SEEG')
        data=filt50Hz(data,fs);
    end
    
    %% DATA SEGMENTATION and calculate F0 FEATURE VECTORS FOR EACH SEGMENT
    
    %initialize vars
    datalength=length(data)/fs; %in seconds
    Nsegm=floor(datalength/datapars.segmlength);
    featuresF0=zeros(Nsegm,datapars.N_features);
   
    timeind=1;
    for segm=1:Nsegm        
        %select data
        d=double(data(timeind:timeind+datapars.segmlength*fs-1));
        DATA(segm,:)=d;
        
        %calculate features
        featuresF0(segm,:)=calc_feat(d,fs);
        
        %prepare next iteration
        timeind=timeind+datapars.segmlength*fs;
        clear d
    end
    clear segm timeind
    
    % normalize features
    if datapars.normalizefeatures
        featuresF0_raw=featuresF0;
        featuresF0=(featuresF0-mean(featuresF0,'omitnan'))./std(featuresF0,'omitnan');
    end
    
    
    %% VISUAL TYPE LABELING OF DATA
    
    if datapars.label
        [datafig, typeF0] = visual_labeling(data,fs,datapars,data_info);
    else      
        %load type label from old file
        cd(PATHOUT);
        load([files(f).name(1:end-4),'_features'],'typeF0')
        if size(typeF0,2)~=Nsegm
            error('mismatch segments in new and old files')
        end
    end
    
    cd(PATHOUT);
    save([files(f).name(1:end-4),'_features'],'featuresF0_raw','featuresF0',...
        'DATA','typeF0','fs','Nsegm','datapars')
    
end


%% stitch patient seiz files together to have one file per patient

seiz_files=dir('*seiz*_features.mat');

sub='';
for f=1:length(seiz_files) %ASSUMES THAT FILES OF THE SAME PATIENT APPEAR CONSECUTIVELY IN seiz_files 
    x=strsplit(seiz_files(f).name,'_');
    x=x{1};
    if strcmp(sub,x)
         ATTACH=load(seiz_files(f).name);
         featuresF0_raw=[featuresF0_raw;ATTACH.featuresF0_raw];
         featuresF0=(featuresF0_raw-mean(featuresF0_raw))./std(featuresF0_raw);
         DATA=[DATA;ATTACH.DATA];
         typeF0=[typeF0,ATTACH.typeF0];
         Nsegm=[Nsegm,ATTACH.Nsegm];
         clear ATTACH
    else
        if f>1
            save([sub,'_features'],'featuresF0_raw','featuresF0',...
                'DATA','typeF0','fs','Nsegm','datapars')
            clearvars -except x sub seiz_files f PATH
        end
        sub=x;
        disp(['stitch: ',sub])
        clearvars -except sub seiz_files f PATH
        load(seiz_files(f).name);
    end
end

