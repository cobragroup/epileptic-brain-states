% HEADER: 
% This script allows you to test model-, rat- and human-driven classification
% of epileptic brain states (interictal, preonset, onset and ictal)
% using prototype comparison. It looks at 'individualized' and 'generalized' 
% classification performance, where 'individualized' means the performance in
% the same dataset used for prototype generation and 'generalized' means
% the performance in a different dataset. During statistical testing in the
% end of the script, you can test the performance for different groups (e.g. 
% different species, for example testing generalized, model-driven classification 
% in the human data)
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
pars.testnumber=0;                  %use this index to try out and save different preprocessing strategies

%data selection
pars.cluster_datatype='sim';        %chose whether prototype dataset is 'sim' or 'real'
pars.dataset='model1';              %chose prototype dataset: 'model1';'human1';%'rat1'; 
pars.merge_types=true;              %visual assessment included 6 types, to reduce to the 4 Wendling types, you can merge subtypes here

%feature preprocessing
pars.findbestfeat=false;            %subselect features based on DaviesBouldin cluster criterion
pars.oldonly=false;                 %use Wendling 2005 features only
pars.pcafeat=true;                  %use PCA duirng feature preprocessing or not
pars.n_comp=4;                      %set number of PCA components (ignore if pars.pcafeat=false)

%prototype generation
pars.nclust=4;                      %chose number of clusters for prototype generation between 1 and 6
pars.labeling='sim';                %chose whether to use 'sim' or 'real' dataset for labeling
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% SCRIPT
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp(['RUNNING CLASSIFICATION FOR testnumber ',num2str(pars.testnumber),'...'])


%% generate prototypes
[prototypes, prototype_dataset, real_type] = generate_prototypes(pars, [PATH,'\vars\']);

%% classify data of the prototype dataset (individualized classification)

%classify
pred_type=classify_type(prototype_dataset.features,prototypes.centroids);

%assess classification performance 
n_surrogate=1000;
PERFORMANCE = get_classification_performance(pred_type,real_type,true);
PERFORMANCE_surrogate = get_classification_performance_surrogate(pred_type,real_type,n_surrogate);

[test_RECALL, test_PRECISION] = test_classification_performance(PERFORMANCE, PERFORMANCE_surrogate);

figure(2)
title(['INDIVIDUALIZED CLASSIFICATION in PROTOTYPE DATASET: ',pars.dataset])

disp(['INDIVIDUALIZED PERFORMANCE in prototype dataset: ',pars.dataset]);
disp(['RECALL = ',num2str(PERFORMANCE.meanRECALL)]);
disp(['p = ',num2str(test_RECALL.p_val)]);
disp(['PRECISION = ', num2str(PERFORMANCE.meanPRECISION)]);
disp(['p = ',num2str(test_PRECISION.p_val)]);

%% classify data of other datasets (generalized classification)
test={'self','model1','rat1','rat2','rat3','human1','human2','human3','human4'};
plot=false; %set to true, if you want to have results figures plotted for all test datasets
fprintf('\n');
disp('GENERALIZED PERFORMANCE in other datasets: ');

for i=2:length(test)
    clear dataset pred_type_comp real_type_comp
    
    %load data
    cd([PATH,'\vars\']);
    if i>2
        %LOAD REAL DATA
        load([test{i},'_features'],'featuresF0','typeF0','DATA','fs','datapars');
        dataset.features=featuresF0;
        dataset.datatype='real2';
        dataset.data=DATA;
        dataset.datapars=datapars;
        dataset.fs=fs;
        
        %merge real types (visual assessment allowed 6 types as opposed to 4 wendling types)
        if and(max(typeF0>4),pars.merge_types)
            typeF0(typeF0==5)=4; %type 5 is a subtype of ictal (late ictal)
            typeF0(typeF0==6)=1; %type 6 is a subtype of interictal (postictal)
        end
        real_type_comp=typeF0';
        clear 'featuresF0' 'typeF0' 'DATA' 'fs' 'datapars'
        
    else
        %LOAD SIM DATA
        load([test{i},'_features'],'featuresFS','typeFS','DATA','fs','simpars');
        dataset.features=featuresFS;
        dataset.datatype='sim';
        dataset.data=DATA;
        dataset.datapars=simpars;
        dataset.fs=fs;
        real_type_comp=typeFS';
        clear 'featuresFS' 'typeFS' 'DATA' 'fs' 'datapars'

    end
    
    %classify
    dataset.features=dataset.features(:,prototypes.featureind);%classify comp data and compare
    if pars.pcafeat==true
        dataset.features=dataset.features*prototypes.PCAcoeff; %TRANSFORMATION
        dataset.datapars.featurenames=prototypes.featurenames;
    end
    pred_type_comp=classify_type(dataset.features,prototypes.centroids);
    
    %assess classification performance
    n_surrogate=1000;
    disp(test{i});
    PERFORMANCE(i) = get_classification_performance(pred_type_comp,real_type_comp,true);
    PERFORMANCE_surrogate(i,:) = get_classification_performance_surrogate(pred_type_comp,real_type_comp,n_surrogate);

    [test_RECALL(i), test_PRECISION(i)] = test_classification_performance(PERFORMANCE(i), PERFORMANCE_surrogate(i,:));
    title(['CLASSIFICATION in DATASET: ',test{i}])

    %plot
    if and(i>2,plot)
        plot_clusterplots(dataset,pred_type_comp,real_type_comp,'real2')
    elseif and(i==2,plot)
        plot_clusterplots(dataset,pred_type_comp,real_type_comp,'sim')
    end
    
end
clear i

disp('GENERALIZED PERFORMANCE ACROSS DATASETS');
disp('RECALL mean and p-value for each dataset');
disp(test);
disp([PERFORMANCE.meanRECALL]);
disp([test_RECALL.p_val]);

disp('PRECISION mean and p-value for each dataset');
disp(test);
disp([PERFORMANCE.meanPRECISION]);
disp([test_PRECISION.p_val]);

%% save result
save([PATH,'/vars/RESULTS_test',num2str(pars.testnumber)],...
    'test','pars','PERFORMANCE','test_RECALL','test_PRECISION');


%% statistical group testing
test={'self','model1','rat1','rat2','rat3','human1','human2','human3','human4'};

%%test all
% PERFORMANCEtest=PERFORMANCE(2:end);
% PERFORMANCEtest_surrogate=PERFORMANCE_surrogate(2:end,:);

%%model only
% model=2;
% test=test(model); 
% PERFORMANCEtest=PERFORMANCE(model);
% PERFORMANCEtest_surrogate=PERFORMANCE_surrogate(model,:);

%%rats only
% rats=3:5;
% test=test(rats); 
% PERFORMANCEtest=PERFORMANCE(rats);
% PERFORMANCEtest_surrogate=PERFORMANCE_surrogate(rats,:);

%% humans only
humans=6:9;
test=test(humans); 
PERFORMANCEtest=PERFORMANCE(humans);
PERFORMANCEtest_surrogate=PERFORMANCE_surrogate(humans,:);

for i=1:1000
  RECALL_surrogate_mean(i)=mean([PERFORMANCEtest_surrogate(:,i).meanRECALL],'omitnan'); 
  PRECISION_surrogate_mean(i)=mean([PERFORMANCEtest_surrogate(:,i).meanPRECISION],'omitnan'); 
end

test_RECALL_group.test_mean=mean([PERFORMANCEtest.meanRECALL]);
test_RECALL_group.test_std=std([PERFORMANCEtest.meanRECALL]);
test_RECALL_group.perm_mean=mean(RECALL_surrogate_mean);
test_RECALL_group.perm_std=std(RECALL_surrogate_mean);
test_RECALL_group.p_val=(1+sum(RECALL_surrogate_mean>=test_RECALL_group.test_mean))/(length(RECALL_surrogate_mean)+1);

test_PRECISION_group.test_mean=mean([PERFORMANCEtest.meanPRECISION]);
test_PRECISION_group.test_std=std([PERFORMANCEtest.meanPRECISION]);
test_PRECISION_group.perm_mean=mean(PRECISION_surrogate_mean);
test_PRECISION_group.perm_std=std(PRECISION_surrogate_mean);
test_PRECISION_group.p_val=(1+sum(PRECISION_surrogate_mean>=test_PRECISION_group.test_mean))/(length(PRECISION_surrogate_mean)+1);

fprintf('\n');
fprintf('\n');

disp('GROUP-LEVEL TESTING ACROSS DATASETS');
disp('RECALL in selected group: ');
disp(test);
disp([PERFORMANCEtest.meanRECALL]);
disp('mean');
disp(test_RECALL_group.test_mean);
disp('std');
disp(test_RECALL_group.test_std);
disp('p val');
disp(test_RECALL_group.p_val);

disp('PRECISION in selected group: ');
disp(test);
disp([PERFORMANCEtest.meanPRECISION]);
disp('mean');
disp(test_PRECISION_group.test_mean);
disp('std');
disp(test_PRECISION_group.test_std);
disp('p val');
disp(test_PRECISION_group.p_val);

