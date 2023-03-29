% HEADER: 
% This script generates and preprocesses the simulated model data. 
% It uses the model parameters from Wendling 2005 to generate N interations of 
% each of the four types of activity (interictal, preonset, onset and ictal) 
% and calculates the chosen features on each generated segment of data. 
% As the model has noise, the resulting time series and calculated features
% will vary each time you run this script.
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
PATH='...';                           %folder with subfolders /code and /vars        
addpath(genpath([PATH,'\code\']));    %code
cd([PATH,'\vars\']);                  %variables


%% SET PARAMETERS

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
simpars.modelnum=2;     %you can use this index to play with different model settings

% sim pars
fs=512;                 %sampling frequency of the model
simpars.segmlength=5;   %in seconds
simpars.noise=[];       %[] will generate random noise with mean 90, std 30, 0 will have no noise
simpars.Nit=100;        %number of iterations per type

% activity types taken from Wendling 2005
type = {'intICTAL-like','preONSET-like','ONSET-like','ICTAL-like'};
simpars.aVals = [3.5      4.6     7.7     8.7  ];
simpars.bVals = [13.2     20.4    4.3     11.4 ];
simpars.gVals = [10.76    11.48   15.1     2.1 ];

% features selected based on literature
simpars.N_features=11;               %if you want to change the features, you need to change the calc_feat function, too
simpars.featurenames=  {'b0power', 'b1power', 'b2power', 'b3power', ...
    'b4power', 'alphdiff', 'spikeabs', 'sigmean', 'sigvar', 'autocorrel','linelen'};
simpars.normalizefeatures=true;      %this will normalize the features so that they all equally contribute
simpars.featureind=1:simpars.N_features;
simpars.oldfeatures=[1:4,6];        %these are the features described in Wendling 2005
simpars.newfeatures=[5,7:simpars.N_features];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% SCRIPT
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp(['RUNNING SIMULATION AND FEATURE CALCULATION FOR model',num2str(simpars.modelnum),'...'])


%% calculate features for Wendling type segments across 100 iterations
Nsegm=length(type)*simpars.Nit;
featuresFS=zeros(simpars.Nit*length(type),11);
k=0;
for activity=1:length(type)
    for iteration=1:simpars.Nit
        k=k+1;
        %simulate
        figure; d=Wendl2005model(simpars.segmlength,fs,simpars.aVals(activity),simpars.bVals(activity),...
            simpars.gVals(activity),simpars.noise,0); 
        close 
        DATA(k,:)=d;
        
        %calculate features 
        featuresFS(k,:)=calc_feat(d,fs); 
        clear d
        
        %note down real type
        typeFS(k)=activity;
    end
end
clear k iteration activity

%% normalize features
if simpars.normalizefeatures
    featuresFS_raw=featuresFS;
    featuresFS=((featuresFS)-mean(featuresFS,1))./std(featuresFS,[],1);
end

%% save model features
cd([PATH,'\vars\'])
save(['model',num2str(modelnum),'_features'],'featuresFS_raw','featuresFS',...
                'DATA','typeFS','fs','Nsegm','simpars')