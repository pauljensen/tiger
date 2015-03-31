library(ggplot2)
library(reshape2)

data <- read.csv("simulation_data.csv")

data$organism <- factor(data$organism, levels=c("P. aeruginosa iMO1086", 
                                                "S. cerevisiae iND750",
                                                "L. major iAC560",
                                                "C. reinhardtii iRC1086"))

long <- melt(data,measure.vars=c("ncols","nrows"))
long <- transform(long, variable=as.character(variable))
long$variable[long$variable == "ncols"] <- "Number of variables"
long$variable[long$variable == "nrows"] <- "Number of constraints"

p <- ggplot(long, aes(x=organism, y=value)) + theme_classic() + 
           facet_grid(. ~ variable) + 
           xlab("") + ylab("") + 
           geom_bar(aes(fill=model),
                    colour="black", 
                    stat="identity",
                    position=position_dodge()) +
           theme(axis.text.x = element_text(size=10, angle=45,
                                            hjust=1, vjust=1))
print(p)
