clear all;
clc
close all;

%%Before you run this script, you have to open the Data95.csv file in matlab
%%After opening the file, click on "import numeric matrix" and then on "import selection". 
%%In the workspace you now see Data95. Click on the data and save as Data95.mat.
%%Now you can run this matlab script.
load('esmw1standardized.mat')  
indiv=esmw1standardized(:,1);
indivindiv=unique(indiv);
obs = size(esmw1standardized,1);
esmw1centered2 = [nan(length(indivindiv),size(esmw1standardized,2)); esmw1standardized];
esmw1standardized = [esmw1standardized; nan(length(indivindiv),size(esmw1standardized,2))];
esmw1standardized(obs+1:end,1) = indivindiv;
esmw1centered2(1:length(indivindiv),1) = indivindiv;
[~, order] = sort(esmw1standardized(:,1));
esmw1standardized = esmw1standardized(order,:);
[~, order] = sort(esmw1centered2(:,1));
esmw1centered2 = esmw1centered2(order,:);
esmw1standardized = [esmw1standardized, esmw1centered2(:,2:16)];

idx=(esmw1standardized==9999); %find nans and replcae them with NAN 
esmw1standardized(idx)=NaN;



indiv=esmw1standardized(:,1);
dataY=esmw1standardized(:,2:16);
dataX=esmw1standardized(:,17:31);

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
       
        
        strName=['Modelstandarized' num2str(iy) '.mat'];
        save(strName,'lme');
        pvalues=lme.Coefficients.pValue;
        fixed=lme.Coefficients.Estimate;
        size(lme.randomEffects)
        random=reshape(lme.randomEffects, 16,length(lme.randomEffects)/16)'...
            +repmat(lme.Coefficients.Estimate',length(lme.randomEffects)/16,1);
        realerror=sqrt(lme.MSE);
        Data_to_txt(['Modelfixedstandarized' num2str(iy) '.txt'],fixed)
        Data_to_txt(['Modelpvaluesstandarized' num2str(iy) '.txt'],pvalues)
        Data_to_txt(['Modelrandomstandarized' num2str(iy) '.txt'],random)
        ;
    end
    
  