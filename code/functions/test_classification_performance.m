function [test_RECALL, test_PRECISION] = test_classification_performance(PERFORMANCE, PERFORMANCE_surrogate)

% disp('RECALL: DIAGONAL ./ SUM TRUE PER TYPE');

test_RECALL.test_val=PERFORMANCE.meanRECALL;
test_RECALL.mean=mean([PERFORMANCE_surrogate.meanRECALL],'omitnan');
test_RECALL.std=std([PERFORMANCE_surrogate.meanRECALL],'omitnan');
test_RECALL.p_val=(1+sum([PERFORMANCE_surrogate.meanRECALL]...
    >=test_RECALL.test_val))/(1+length([PERFORMANCE_surrogate.meanRECALL]));

% disp(test_RECALL);


% disp('PRECISION: DIAGONAL ./ SUM PRED PER TYPE');

test_PRECISION.test_val=PERFORMANCE.meanPRECISION;
test_PRECISION.mean=mean([PERFORMANCE_surrogate.meanPRECISION],'omitnan');
test_PRECISION.std=std([PERFORMANCE_surrogate.meanPRECISION],'omitnan');
test_PRECISION.p_val=(1+sum([PERFORMANCE_surrogate.meanPRECISION]...
    >=test_PRECISION.test_val))/(1+length([PERFORMANCE_surrogate.meanPRECISION]));

% disp(test_PRECISION);

end