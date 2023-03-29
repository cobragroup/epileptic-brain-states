function [X,N_features,featurenames,featureind,coeff]= preprocess_features(X,pars)

N_features=length(X.datapars.featurenames);
featureind=1:X.datapars.N_features;
featurenames=X.datapars.featurenames;

if pars.oldonly %use only WENDLING 2005 features
    featurenames=X.datapars.featurenames(X.datapars.oldfeatures);
    N_features=length(featurenames);
    featureind=X.datapars.oldfeatures;
    X.features=X.features(:,X.datapars.oldfeatures);
end

if pars.findbestfeat %preselect features based on DaviesBouldin clustering criterion
    bestfset_i=[];
    bestval=0;
    bestval_i=0.1;
    bestpars.nclust_i=0;
    while bestval_i>bestval
        bestval=bestval_i;
        bestfset=bestfset_i;
        bestpars.nclust=bestpars.nclust_i;
        for f=1:N_features
            if ~isempty(bestfset)
                if ismember(f,bestfset); continue; end
            end
            
            eva = evalclusters(X.features(:,[bestfset f]),'kmeans','DaviesBouldin','KList',pars.nclust); %CalinskiHarabasz or Silhouette
            maxval(f)=max(eva.CriterionValues);
            pars.nclust_i(f)=eva.OptimalK;
            
            clear eva
        end
        if bestval_i<max(maxval)
            [~,f]=max(maxval);
            bestval_i=maxval(f);
            bestfset_i=[bestfset f];
            bestpars.nclust_i=pars.nclust_i(f);
        end
        clear maxval pars.nclust_i f
        disp(['best f after this iteration: ' num2str(bestfset_i),...
            ', with val: ', num2str(bestval_i), ', and N clust:', num2str(bestpars.nclust_i)]);
    end
    disp(['RESULT: f Set: ' num2str(bestfset),...
        ', with val: ', num2str(bestval), ', and N clust:', num2str(bestpars.nclust)]);
    
    X.features=X.features(:,bestfset);
    pars.nclust=bestpars.nclust;
    featurenames=X.datapars.featurenames(bestfset);
    N_features=length(featurenames);
    featureind=featureind(bestfset);
end

if pars.pcafeat==true %PCA on features to reduce redundant information and dimensionality
    [coeff,score,~,~,explained,~] = pca(X.features, 'NumComponents',pars.n_comp);
    
    figure;
    set(gcf,'Position',[777.0000   98.6000  727.2000  624.0000]);
    
    imagesc(coeff);
    set(gca,'YTick',0.5:1:length(featurenames)-0.5);
    yticklabels(featurenames);
    xlabel('PCA component');
    set(gca,'XTick',1:pars.n_comp,'XTick',1:N_features);
    set(gca,'XTick',1:pars.n_comp);
    
    c=colorbar;
    c.Title.String='PCA coeff';
    title(['explained var = ' num2str(sum(explained(1:pars.n_comp)))]);
    
    disp('explained variance');
    disp(explained');
    
    X.features=score;
    pcnames={'PC1','PC2','PC3','PC4','PC5','PC6'};
    featurenames=pcnames(1:pars.n_comp);
    X.datapars.featurenames=pcnames(1:pars.n_comp);
    N_features=pars.n_comp;
    clear pcnames
else
    coeff=1;
end

end
