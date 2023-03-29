function [datafig, typeF0] = visual_labeling(data,fs,datapars,data_info)

%% PLOT DATA
datafig=figure('name', ['Data snippet in ',num2str(datapars.segmlength),'sec segments']);
set(gcf,'Position',1.0e+03 *[ 0.0002    0.3354    1.5336    0.4200 ]);

timeind=1;
for segm=1:floor(length(data)/fs/datapars.segmlength)
    %select data
    d=double(data(timeind:timeind+datapars.segmlength*fs-1));
    xlim([1 length(data)]);
        
    %plot signal
    figure(datafig)
    hold on
    plot(timeind:timeind+datapars.segmlength*fs-1,d);
    
    %prepare next iteration
    timeind=timeind+datapars.segmlength*fs;
    clear d   
end

if isfield(data_info,'seiz_ind')
    l=get(gca,'YLim');
    line([data_info.seiz_ind data_info.seiz_ind],l, 'LineWidth', 2, 'Color', 'b');
    if isfield(data_info,'seiz_end_ind')
        line([data_info.seiz_end_ind data_info.seiz_end_ind],l, 'LineWidth', 2, 'Color', 'b');
    end
end

box on; 
xlim([1 length(data)]);
xticks(datapars.segmlength*fs/2:datapars.segmlength*fs:length(data));
xticklabels(1:floor(length(data)/fs/datapars.segmlength));
set(gca,'XGrid','on')
xlabel('segm (#)');
ylabel('mV');
%legend({'segm 1','segm 2','segm 3','segm 4',...
%   'etc'},'Location','eastoutside');
clear segm timeind


%% VISUAL EXPERT LABELING

segm_all_labeled=false;
    while ~segm_all_labeled
        typeF0=NaN(1,floor(length(data)/fs/datapars.segmlength));

        % expert input
        display(datapars.types',['These are the pars.types with numbers ', num2str(1:length(datapars.types)),': ']);
        type_ind=struct([]);
        for t=1:length(datapars.types)
            type_ind{t}=input(['\n Type ', num2str(t),', ' datapars.types{t}, ...
                ' segments: enter array of segm indices or first segm of this type, if continuous!: ']);
        end

        % continuous type labeling
        x=cellfun(@length, type_ind)==1; %expert input for a given type was first segm index only
        new_type_type=find(x);
        new_type_ind=[type_ind{x}];
        for i=1:length(new_type_type)-1
            typeF0(new_type_ind(i):new_type_ind(i+1)-1)=new_type_type(i);
        end
        typeF0(new_type_ind(end):end)=new_type_type(end);
        clear new_type_ind new_type_ind i x

        %single segment type labeling
        x=cellfun(@length, type_ind)>1; %expert input for type was an array of segm indices
        new_type_type=find(x);
        new_type_ind=type_ind(x);
        for i=1:length(new_type_type)
            typeF0(new_type_ind{i})=new_type_type(i);
        end
        clear new_type_ind new_type_ind i x

        %check that all segments have been labeled
        x=isnan(typeF0);
        if sum(x)>0
            y=input(['\n segments: ', num2str(find(x)), ...
                ' have not been labeled, enter "NOW" for labeling' ...
                'them individually now, any other input will make you repeat all labeling once again.']);
            if strcmpi(y,'NOW')
                display(datapars.types',['These are the pars.types with numbers ', num2str(1:length(datapars.types)),': ']);
                typeF0(x)= input(['\n enter labels of segments: ', num2str(find(x)), ...
                    ' now: ']);
                x=isnan(typeF0);
            end
        end
        if sum(x)==0
            segm_all_labeled=true;
        end
    end

end