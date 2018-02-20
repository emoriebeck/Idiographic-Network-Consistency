clear all;
clc
close all;

%%Before you run this script, you have to open the Data95.csv file in matlab
%%After opening the file, click on "import numeric matrix" and then on "import selection". 
%%In the workspace you now see Data95. Click on the data and save as Data95.mat.
%%Now you can run this matlab script.
load('esmw1dblcentered.mat')  
indiv=esmw1dblcentered(:,1);
indivindiv=unique(indiv);
obs = size(esmw1dblcentered,1);
esmw1dblcentered2 = [nan(length(indivindiv),size(esmw1dblcentered,2)); esmw1dblcentered];
esmw1dblcentered = [esmw1dblcentered; nan(length(indivindiv),size(esmw1dblcentered,2))];
esmw1dblcentered(obs+1:end,1) = indivindiv;
esmw1dblcentered2(1:length(indivindiv),1) = indivindiv;
[~, order] = sort(esmw1dblcentered(:,1));
esmw1dblcentered = esmw1dblcentered(order,:);
[~, order] = sort(esmw1dblcentered2(:,1));
esmw1dblcentered2 = esmw1dblcentered2(order,:);
esmw1dblcentered = [esmw1dblcentered, esmw1dblcentered2(:,2:16)];

idx=(esmw1dblcentered==9999); %find nans and replcae them with NAN 
esmw1dblcentered(idx)=NaN;



indiv=esmw1dblcentered(:,1);
dataY=esmw1dblcentered(:,2:16);
dataX=esmw1dblcentered(:,17:31);

%% group center
indivindiv=unique(indiv)


% for i =1:length(indivindiv)
%     idxTemp=find(indiv==indivindiv(i));
%     nanmean(dataX(idxTemp,:))
%     dataX(idxTemp,:)= dataX(idxTemp,:)-repmat(nanmean(dataX(idxTemp,:)),length(idxTemp),1);
%     nanmean(dataX(idxTemp,:))
% end

%%

dataX=[ones(size(dataX,1),1), dataX]; %add intercept
    
%% fit all models and save them (takes a while)

X=dataX;
Z=dataX;

%%With this code you save your results
    for iy=1:size(dataY,2)
        iy
        y=dataY(:,iy);
        lme = fitlmematrix(X,y,Z,indiv,'FitMethod','REML');
       
        
        strName=['Modeldblcentered' num2str(iy) '.mat'];
        save(strName,'lme');
        pvalues=lme.Coefficients.pValue;
        fixed=lme.Coefficients.Estimate;
        size(lme.randomEffects)
        random=reshape(lme.randomEffects, 16,length(lme.randomEffects)/16)'...
            +repmat(lme.Coefficients.Estimate',length(lme.randomEffects)/16,1);
        realerror=sqrt(lme.MSE);
        Data_to_txt(['Modelfixeddblcentered' num2str(iy) '.txt'],fixed)
        Data_to_txt(['Modelpvaluesdblcentered' num2str(iy) '.txt'],pvalues)
        Data_to_txt(['Modelrandomdblcentered' num2str(iy) '.txt'],random)
        ;
    end
    
  