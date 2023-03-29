function plot_clusterplots(X,kclust,real_type,datatype)
%plots classification result figures

%1) gplotmatrix
figure('name',[datatype,': g plot real']);
set(gcf,'Position',[80.2000  112.2000  727.2000  624.0000]);
gplotmatrix(X.features,[],kclust,[],[],5,[],[],X.datapars.featurenames);

if strcmp(datatype,'sim')
    %2) sim: true vs classified
    figure('name',datatype)
    set(gcf,'Position',[777.0000   98.6000  727.2000  624.0000]);
    imagesc([kclust(1:100),kclust(101:200),kclust(201:300),kclust(301:400)]);
    set(gca, 'XTick', 1:4)
    title('featurs clustering type match');
    xlabel('activity type with given ABG');
    ylabel('iteration');
    cb=colorbar;
    cb.Ticks=1:4;
    set(cb,'Ticks',1:1:4)
    
elseif or(strcmp(datatype,'real'),strcmp(datatype,'real2'))
    % 2) real generalized: data segment examples of each class
    figure('name',datatype)
    set(gcf,'Position',[777.0000   98.6000  727.2000  624.0000]);
    k=0;
    for c=unique(kclust)'
        %time series
        k=k+1;
        subplot(max(kclust),3,k:k+1)
        if and(nargin>8, sum(and(kclust==c,real_type==c))>0)
        plot(0:1/X.fs:length(X.data(find(and(kclust==c,real_type==c),1,'first'),:))...
            /X.fs-1/X.fs,X.data(find(and(kclust==c,real_type==c),1,'first'),:));
        else
            plot(0:1/X.fs:length(X.data(find(kclust==c,1,'first'),:))...
            /X.fs-1/X.fs,X.data(find(kclust==c,1,'first'),:));
        end
        title(['exemplary time series for type ',num2str(c)]);
        set(gca,'XTick',0:1:length(X.data(1,:))/X.fs, 'XGrid','on')
        ylabel('mV');
        k=k+2;
        subplot(max(kclust),3,k)
        if and(nargin>8,sum(and(kclust==c,real_type==c))>0)
            [pxx,f]=periodogram(X.data(find(and(kclust==c,real_type==c),1,'first'),:) ,[],X.fs,X.fs);
        else
            [pxx,f]=periodogram(X.data(find(kclust==c,1,'first'),:) ,[],X.fs,X.fs);   
        end
        %periodogram
        pxxnorm=pxx(2:end)./f(2:end);
        plot(f(2:end),pxxnorm ); xlim([0 70]); ylabel('pxx (mV^2/Hz)'); 
        set(gca,'XTick',0:10:70)
        title('Periodogram PSD'); grid on;
    end
    xlabel('Frequency (Hz)')
    clear k 
    if strcmp(X.datatype,'real')
        % 3) real prototype dataset: time series with underlayed classification result 
        figure();
        plot_datafig(X.data,X.fs,featuresF0,X.datapars);
        set(gcf,'Position',[777.0000   98.6000  727.2000  624.0000]);
        data = reshape(X.data',[1,numel(X.data)]);
        sp4=subplot(4,1,4);
        imagesc([1 length(X.features)],[min(data) max(data)],kclust');
        ylim([min(data) max(data)]);
        xlabel('Time (segm)');
        c=colorbar('Location','eastoutside');
        c.Title.String='type';
        colormap(parula(max(kclust)));
        hold on
        plot(0:length(X.features)/length(data):length(X.features)-length(X.features)/...
            length(data),data,'LineWidth',.1,'Color',[0.8500 0.3250 0.0980])
        set(gca, 'YDir','normal')
    end 
end

%4) scatter plot for PC1 to PC3
% figure('name',datatype);
% set(gcf,'Position',[80.2000  112.2000  727.2000  624.0000]);
% scatter3(X.features(:,1),X.features(:,2),X.features(:,3),[],kclust,'filled')
% xlabel(X.datapars.featurenames(1));
% ylabel(X.datapars.featurenames(2));
% zlabel(X.datapars.featurenames(3));
% title(datatype)
 
end