function [minerrtype, minerr] = classify_type(X,centroids)
% INPUT:
% X(Nsegm,Nfeat) contains calculcated and preprocessed features for N segm of data 
% centroids(Ntype,Nfeat) contains centroids from clustering features from some sample of data

if size(X,2)~=size(centroids,2)
    error('different amount of features in X and in centroids!');
end

%% find closest centroid for each segm in X
err=zeros(size(centroids,1),size(X,1),size(X,2));
for t=1:size(centroids,1)
    err(t,:,:)=abs(X-centroids(t,:)); 
end
%err(Ntype,Nsegm,Nfeat) contains the distance per feature for each segm of data in X to each type centroid in centroids

errsum=sum(err,3);
%errsum(Ntype,Nsegm) contains summed distance across features for each segm of data in X to each type centroid in centroids

[minerr,minerrtype]=min(squeeze(errsum),[],1,'omitnan'); %min over DIM 1 - type of activity 
%minerr(Nsegm) contains the value of minimal summed feature distance per segm of data
%minerrtype(Nsegm) contains the type of minimal summed feature distance per segm of data


%% transpose for convenience
minerr=minerr'; 
minerrtype=minerrtype';

end