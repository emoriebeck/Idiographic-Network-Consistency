clear all;
clc
close all;

%%Before you run this script, you have to open the Data95.csv file in matlab
%%After opening the file, click on "import numeric matrix" and then on "import selection". 
%%In the workspace you now see Data95. Click on the data and save as Data95.mat.
%%Now you can run this matlab script.
load('esmw4centered.mat')  
indiv=esmw4centered(:,1);
indivindiv=unique(indiv);
obs = size(esmw4centered,1);
esmw4centered2 = [nan(length(indivindiv),size(esmw4centered,2)); esmw4centered];
esmw4centered = [esmw4centered; nan(length(indivindiv),size(esmw4centered,2))];
esmw4centered(obs+1:end,1) = indivindiv;
esmw4centered2(1:length(indivindiv),1) = indivindiv;
[~, order] = sort(esmw4centered(:,1));
esmw4centered = esmw4centered(order,:);
[~, order] = sort(esmw4centered2(:,1));
esmw4centered2 = esmw4centered2(order,:);
esmw4centered = [esmw4centered, esmw4centered2(:,2:16)];

idx=(esmw4centered==9999); %find nans and replcae them with NAN 
esmw4centered(idx)=NaN;



indiv=esmw4centered(:,1);
dataY=esmw4centered(:,2:16);
dataX=esmw4centered(:,17:31);

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
       
        
        strName=['Model' num2str(iy) '.mat'];
        save(strName,'lme');
        pvalues=lme.Coefficients.pValue;
        fixed=lme.Coefficients.Estimate;
        size(lme.randomEffects)
        random=reshape(lme.randomEffects, 16,length(lme.randomEffects)/16)'...
            +repmat(lme.Coefficients.Estimate',length(lme.randomEffects)/16,1);
        realerror=sqrt(lme.MSE);
        realerror=sqrt(lme.MSE);
        Data_to_txt(['Modelfixedcentered' num2str(iy) '.txt'],fixed)
        Data_to_txt(['Modelpvaluescentered' num2str(iy) '.txt'],pvalues)
        Data_to_txt(['Modelrandomcentered' num2str(iy) '.txt'],random)
        ;
    end
    
  