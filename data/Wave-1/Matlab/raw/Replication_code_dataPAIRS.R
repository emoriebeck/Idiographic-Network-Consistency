###############################################################
################# General information #########################
###############################################################
#R-CODE for the manuscript BRINGMANN ET AL. 2016, Assessment
#Title: Assessing temporal emotion dynamics using networks

#The files needed are:
#  replication_code_data95.R
#  replication_code_data95.m
#  data_to_text.m
#  Data95.csv

#%####################################################################%#
### Before you start you have to install and load the libraries below ##
#%####################################################################%#
library("qgraph")#1.3.1

###Please make sure all files are in the same working directory 
##and that you have set your working directory to source file location###
setwd("~/Dropbox/network/Bringmann 2016 R code/centered")
getwd()
ls() #Here you can see which files are in your current working directory

#%###########################################################%#
### Data and estimating a multilevel model in Matlab ##########
#%###########################################################%#
formula_data<-paste(getwd(),"/esm_w1_centered.csv",sep="")
DataPAIRS<-read.csv(formula_data,sep=",")

#This data is analyzed in matlab. For the multilevel VAR code, see
#Replication_code_data95.m for further instructions.
#After the matlab code has run, you can run this R code.

#%###########################################################%#
### Population network fixed effects: Figure 2 ################
#%###########################################################%#
nv=15 # number of variables
fixedlist=list()
pvalueslist=list()
for (i in 1:nv){
  formula1=paste(getwd(),"/modelfixedcentered",i,".txt",sep="")
  fixed <-as.vector(unlist(read.table(formula1, quote="\"")))
  
  formula2=paste(getwd(),"/modelpvaluescentered",i,".txt",sep="")
  pvalues <-as.vector(unlist(read.table(formula2, quote="\"")))
  #save the innovations as a list
  fixedlist[[i]]<-(fixed)[-1]
  pvalueslist[[i]]<-(pvalues)[-1]
}

Labelz<-c("A_rude", "E_quiet", "C_lazy", 
          "N_relaxed", "N_depressed", "E_outgoing", 
          "A_kind", "C_reliable", "N_worried",
          "pos_emotion", "neg_emotion", "authentic", 
          "SE", "Happy", "Lonely")
FE<-cbind(unlist(fixedlist),unlist(pvalueslist))

E=cbind(from=rep(1:nv,nv),to=rep(1:nv,each=nv),weigth=unlist(FE[,1]))
edge.color <- qgraph:::addTrans(ifelse(FE[,1]>0, "green3", "red3"), ifelse(FE[,2]<0.05, 255, 0))
Network<-qgraph(E, layout="circle", curve = -1, cut = 0.05, esize = 10, 
                edge.color = edge.color,labels=Labelz,title="Dataset 1",lty=ifelse(E[,3]>0,1,5))

#%###########################################################%#
### The individual networks ###################################
#%###########################################################%#
#After you have done the analyses in Matlab, you can load in the edges of the individual networks (fixed effects + random effects).
#In this case you have 36 edges per individual. 

edges=list()
for (i in 1:nv){
  formula=paste(getwd(),"/modelrandomcentered",i,".txt",sep="")
  random <- read.csv(formula, header=FALSE)
  #save the edges as a list
  print(dim(random)[1])
  edges[[i]]<-random[,-1]}
dataPAIRSedges=matrix(unlist(edges),ncol=(dim(random)[1])) #The columns are the links in the network (36) and the rows are the individuals (95).

#These are the colnames of the edges of the network. 
#The first variable is the dependent and the second the independent
dataPAIRSedges_names <- NULL
for (i in 1:length(Labelz)){
  for (k in 1:length(Labelz))
    dataPAIRSedges_names <- c(dataPAIRSedges_names, paste(Labelz[i], Labelz[k], sep = "L"))
}
colnames(dataPAIRSedges)<-dataPAIRSedges_names



#%###########################################################%#
### Density: Table 1 ########################################
#%###########################################################%#
overalldensity<-apply(abs(dataPAIRSedges[,]),1,mean)
negdensityonly<-apply(abs(dataPAIRSedges[,c(1:4,7:10,13:16,19:22)]),1,mean)
posdensityonly<-apply(abs(dataPAIRSedges[,c(29,30,35,36)]),1,mean)

#Correlate the density results with neuroticism
cor.test(posdensityonly,DataPAIRS[1:266,15])
cor.test(negdensityonly,DataPAIRS[1:95,15])
cor.test(overalldensity,DataPAIRS[1:225,15])


#%###########################################################%#
### Centrality: Table 2 until 5 ########################################
#%###########################################################%#
mlVAR
Labelz<-c("A_rude", "E_quiet", "C_lazy", 
          "N_relaxed", "N_depressed", "E_outgoing", 
          "A_kind", "C_reliable", "N_worried",
          "pos_emotion", "neg_emotion", "authentic", 
          "SE", "Happy", "Lonely")
CENlist=list()
for (PP in 1:225){
  E=cbind(from=rep(1:nv,nv),to=rep(1:nv,each=nv),weigth=as.numeric(dataPAIRSedges[PP,1:225]))
  E=as.matrix(E)
   CENlist[[PP]]<- cbind(Labelz,centrality_auto(E)$node.centrality)
  
}

even_indexes<-seq(2,8,2)
odd_indexes<-seq(1,8,2)
CentralityPAIRS<-matrix(NA,nv,8)
output=matrix(NA,nv,95)
rownames(output)<-Labelz
colnames(CentralityPAIRS)<-c("Betweenness","p","Closeness","p","InStrength","p","OutStrength","p")
rownames(CentralityPAIRS)<-Labelz
for(i in 1:4){
  for (PP in 1:95){
    output[,PP]=CENlist[[PP]][,1+i]
    
  }
  
  for (j in 1:nv){
    #Correlate the centrality results with neuroticism
  
    CentralityPAIRS[j,odd_indexes[i]]<-cor(output[j,],DataPAIRS[1:95,15])
    CentralityPAIRS[j,even_indexes[i]]<-round(cor.test(output[j,],DataPAIRS[1:95,15])$p.value,4)
  }
}

CentralityPAIRS<-round(CentralityPAIRS,3)
CentralityPAIRS


#%###########################################################%#
### Self loops: Table 6 ########################################
#%###########################################################%#
angdensityself<-abs(dataPAIRSedges[,c(1)])
depdensityself<-abs(dataPAIRSedges[,c(8)])
anxdensityself<-abs(dataPAIRSedges[,c(22)])
saddensityself<-abs(dataPAIRSedges[,c(15)])

reldensityself<-abs(dataPAIRSedges[,c(29)])
hapdensityself<-abs(dataPAIRSedges[,c(36)])

#Correlate the self loops with neuroticism
cor.test(angdensityself,DataPAIRS[1:95,15]) 
cor.test(depdensityself,DataPAIRS[1:95,15])
cor.test(anxdensityself,DataPAIRS[1:95,15])
cor.test(saddensityself,DataPAIRS[1:95,15])

cor.test(reldensityself,DataPAIRS[1:95,15])
cor.test(hapdensityself,DataPAIRS[1:95,15])


