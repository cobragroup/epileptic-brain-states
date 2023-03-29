function CLASSIFICATION_PERFORMANCE = get_classification_performance(pred_type,real_type,printflag)

if printflag
    figure;
    set(gcf,'Position',[80.2000  112.2000  727.2000  624.0000]);
    cm=confusionchart(real_type,pred_type,'RowSummary','row-normalized','ColumnSummary','column-normalized')';
else
   cm.NormalizedValues=confusionmat(real_type,pred_type);
end

CLASSIFICATION_PERFORMANCE.cm= cm.NormalizedValues;
CLASSIFICATION_PERFORMANCE.recall=(diag(cm.NormalizedValues)./sum(cm.NormalizedValues,2,'omitnan'))';
CLASSIFICATION_PERFORMANCE.precision=(diag(cm.NormalizedValues)./sum(cm.NormalizedValues,1,'omitnan')')';
CLASSIFICATION_PERFORMANCE.meanRECALL=mean(CLASSIFICATION_PERFORMANCE.recall,'omitnan');
CLASSIFICATION_PERFORMANCE.meanPRECISION=mean(CLASSIFICATION_PERFORMANCE.precision,'omitnan');

if printflag
disp('CLASSIFICATION PERFORMANCE');
disp(CLASSIFICATION_PERFORMANCE);
end

end
