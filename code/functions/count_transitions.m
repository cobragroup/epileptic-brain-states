function [n_per_type,transitions_abs]=count_transitions(type_list)
    
n_per_type=zeros(1,max(type_list));
transitions_abs=zeros(max(type_list));

for i=1:length(type_list)-1
    
    t1=type_list(i);
    t2=type_list(i+1);
    
    n_per_type(t1)=n_per_type(t1)+1;
    transitions_abs(t1,t2)=transitions_abs(t1,t2)+1;
end

% transitions_abs(n_per_type==0,:)=NaN;
% transitions_abs(:,n_per_type==0)=NaN;

end