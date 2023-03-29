function PERFORMANCE_surrogate=get_classification_performance_surrogate(real_type,pred_type,n_surrogates)
% markov chain permutations of predicted type

[n_per_type,transitions_abs]=count_transitions(real_type);

%exclude states that do not occur
transitions_abs=transitions_abs(n_per_type~=0,:);
transitions_abs=transitions_abs(:,n_per_type~=0);

%generate markov chain object
mc = dtmc(transitions_abs);

%simulate chains with length same as and initial state distribution of real_type
surrogates = simulate(mc,length(real_type)-1,'X0',n_per_type(n_per_type~=0)*100);
%actual number of surrogates will be more than n_surrogate, it is a pool
%to draw from with different initial type following the type distribution in real_type

%shuffle randomly
surrogates=surrogates(:,randperm(length(surrogates)));

%get classification performance per surrogate
for s=1:n_surrogates
    PERFORMANCE_surrogate(s) = get_classification_performance(pred_type,surrogates(:,s),false);
end
end
