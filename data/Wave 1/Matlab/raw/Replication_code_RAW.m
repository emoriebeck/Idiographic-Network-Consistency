clear all;
clc
close all;

%%Before you run this script, you have to open the Data95.csv file in matlab
%%After opening the file, click on "import numeric matrix" and then on "import selection". 
%%In the workspace you now see Data95. Click on the data and save as Data95.mat.
%%Now you can run this matlab script.
load('esmW1Networks_pers.mat')  
nv = 9;
esmw1networks = esmw1networks(:,1:(nv+1));
indiv=esmw1networks(:,1);
indivindiv=unique(indiv);
obs = size(esmw1networks,1);
esmw1centered2 = [nan(length(indivindiv),size(esmw1networks,2)); esmw1networks];
esmw1networks = [esmw1networks; nan(length(indivindiv),size(esmw1networks,2))];
esmw1networks(obs+1:end,1) = indivindiv;
esmw1centered2(1:length(indivindiv),1) = indivindiv;
[~, order] = sort(esmw1networks(:,1));
esmw1networks = esmw1networks(order,:);
[~, order] = sort(esmw1centered2(:,1));
esmw1centered2 = esmw1centered2(order,:);
esmw1networks = [esmw1networks, esmw1centered2(:,2:(nv+1))];

idx=(esmw1networks==9999); %find nans and replcae them with NAN 
esmw1networks(idx)=NaN;



indiv=esmw1networks(:,1);
dataY=esmw1networks(:,2:(nv+1));
dataX=esmw1networks(:,(2+nv):(2*nv + 1));

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
    for iy=1:nv%size(dataY,2)
        iy
        y=dataY(:,iy);
        lme = fitlmematrix(X,y,Z,indiv,'FitMethod','REML');
       
        
        strName=['Modelraw' num2str(iy) '.mat'];
        save(strName,'lme');
        pvalues=lme.Coefficients.pValue;
        fixed=lme.Coefficients.Estimate;
        size(lme.randomEffects)
        random=reshape(lme.randomEffects, (nv+1),length(lme.randomEffects)/(nv+1))'...
            +repmat(lme.Coefficients.Estimate',length(lme.randomEffects)/(nv+1),1);
        realerror=sqrt(lme.MSE);
        Data_to_txt(['Modelfixedraw' num2str(iy) '.txt'],fixed)
        Data_to_txt(['Modelpvaluesraw' num2str(iy) '.txt'],pvalues)
        Data_to_txt(['Modelrandomraw' num2str(iy) '.txt'],random)
        ;
    end
    
  