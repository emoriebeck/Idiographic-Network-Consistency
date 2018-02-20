library(qgraph)

#simulate mediated data
N <- 100                        # sample size
X <- rnorm(N, 175, 7)           # 100 samples with M=175, SD=7
M <- -(0.7*X + rnorm(N, 0, 5))  # make m, scale-related to X
Y <- 0.4*M + rnorm(N, 0, 5)     # make Y, scale-realted to M
dfMed <- data.frame(X, M, Y)    # create a data frame
cors <- cor_auto(dfMed)         # correlation matrix
qgraph(cors,                    # plot the network
       graph = "glasso", 
       sampleSize = 100)


par(mfrow = c(1,2))
qgraph(matrix(c(1, 0, .2,0, 1, -.1, .2, -.1, 1), nrow =3, 
       dimnames = list(c("warm", "symp", "sociable"), 
                       c("warm", "symp", "sociable"))),
       nodeNames = c("Feel Warm Toward Others", 
                     "Feel Sympathetic Toward Others", 
                     "Feel like being sociable"),
       groups = list(warm = 1, symp = 2, around = 3),
       color = RColorBrewer::brewer.pal(5,"Set3"),
       node.width = 2, label.font = 2, legend.cex = .4,
       mar = rep(10,4), legend = F,
       labels = c("warm", "sympathy", "sociable"), GLratio = 2)
title("Contemporaneous / Undirected")

qgraph(matrix(c(.18, 0, .2,.25, .08, 0, .2, .1, .23), nrow =3, 
              dimnames = list(c("warm", "symp", "sociable"), 
                              c("warm", "symp", "sociable"))),
       nodeNames = c("Feel Warm Toward Others", 
                     "Feel Sympathetic Toward Others", 
                     "Enjoy Being Around Others"),
       groups = list(warm = 1, symp = 2, around = 3),
       color = RColorBrewer::brewer.pal(5,"Set3"),
       node.width = 2, label.font = 2, legend.cex = .4,
       mar = rep(10,4), legend = F, directed = T,
       labels = c("warm", "sympathy", "sociable"), GLratio = 2)
title("Temporal / Directed")
