################################################################################################
################################################################################################
# HOLLINGSWORTH AND RUDIK (hollinal@indiana.edu, irudik@cornell.edu)
# EXTERNAL IMPACTS OF LOCAL ENERGY POLICY: THE CASE OF RENEWABLE PORTFOLIO STANDARDS
# JOURNAL OF THE ASSOCIATION OF ENVIRONMENTAL AND RESOURCE ECONOMISTS
# VERSION: JANUARY 2018

# DESCRIPTION:
# THIS FILE MAKES FIGURES 2, 5, AND A3

# INSTRUCTIONS:
# RUN THIS FILE TO REPLICATE THE ABOVE FIGURES
# MUST BE RUN IN RSTUDIO TO USE DYNAMIC FILEPATHS
################################################################################################
################################################################################################

# Libraries
library(foreign)
library(ggplot2)

# Get current path for the repo
dir_path <- dirname(rstudioapi::getSourceEditorContext()$path)
setwd(dir_path)

##Import the state level dataset. Old means old version of Stata (to be compatible with R), not an old set of data.
data_stata  <- read.dta("data/data_for_r_figures.dta")


## Figure 2
prim_rps <- ggplot(data_stata, aes(year, rps_primary*100)) + 
  geom_line(aes(colour = state)) + geom_point(size=1.25) + theme_minimal() +
  guides(fill=FALSE) + labs(x = "Year", y="Primary RPS (%)") +
  theme(legend.position="none", panel.spacing = unit(1.5, "lines"),
        axis.title.x = element_text(vjust=-0.25),
        axis.title.y = element_text(vjust=1),
        panel.grid.minor.x = element_blank(), panel.grid.minor.y = element_blank(),
        axis.title=element_text(size=15),axis.text=element_text(size=15),
        panel.grid.major.x = element_blank(), panel.grid.major.y = element_blank(),
        axis.ticks.x=element_line(size = 0), axis.ticks.y=element_line(size = 0)) +
  geom_text(data=subset(data_stata, rps_primary > .19 & year == 2013),
            aes(label=state_name,size=4), vjust =-.75,hjust = 1,position="dodge") +
  theme(panel.border = element_rect(colour = "black", fill=NA, size=.25)) +
  scale_y_continuous(breaks = c(0,10,20,30,40), limits=c(0,40)) +
  scale_x_continuous(breaks=c(1993,1997,2001,2005,2009,2013))
ggsave(file=file.path(dir_path,"output/prim_rps.pdf"),width = 8, height = 8)


## Figure 5A
in_rps <- ggplot(data_stata, aes(year, in_state_demand_na/1e6)) + 
  geom_line(aes(colour = state)) + geom_point(size=1.25) + theme_minimal() +
  guides(fill=FALSE) + labs(x = "Year", y="In-State REC Demand (TWh)") +
  theme(legend.position="none", panel.spacing = unit(1.5, "lines"),
        axis.title.x = element_text(vjust=-0.25),
        axis.title.y = element_text(vjust=1),
        panel.grid.minor.x = element_blank(), panel.grid.minor.y = element_blank(),
        axis.title=element_text(size=15),axis.text=element_text(size=15),
        panel.grid.major.x = element_blank(),  panel.grid.major.y = element_blank(),
        axis.ticks.x=element_line(size = 0), axis.ticks.y=element_line(size = 0)) +
  geom_text(data=subset(data_stata,  in_state_demand_na/1e6 > 14 & year == 2013),
            aes(label=state_name,size=4) ,vjust =-.75,hjust = 1, position="dodge") +
  theme(panel.border = element_rect(colour = "black", fill=NA, size=.25)) +
  scale_y_continuous(breaks = c(0,10,20,30,40,50,60), limits=c(0,60)) +
  scale_x_continuous(breaks=c(1993,1997,2001,2005,2009,2013))
ggsave(file=file.path(dir_path,"/output/instate_demand.pdf"),width = 8, height = 8)


## Figure 5B
out_of_state_rec <- ggplot(data_stata, aes(year, out_state_demand_na/1e6)) + 
  geom_line(aes(colour = state)) + geom_point(size=1.25) + theme_minimal() +
  guides(fill=FALSE) + labs(x = "Year", y="Out-of-State REC Demand (TWh)") +
  theme(legend.position="none", panel.spacing = unit(1.5, "lines"),
        axis.title.x = element_text(vjust=-0.25),
        axis.title.y = element_text(vjust=1),
        panel.grid.minor.x = element_blank(), panel.grid.minor.y = element_blank(),
        axis.title=element_text(size=15),axis.text=element_text(size=15),
        panel.grid.major.x = element_blank(),  panel.grid.major.y = element_blank(),
        axis.ticks.x=element_line(size = 0), axis.ticks.y=element_line(size = 0)) +
  theme(panel.border = element_rect(colour = "black", fill=NA, size=.25)) +
  scale_y_continuous(breaks = c(0,20,40,60,80,100,120)) +
  geom_text(data=subset(data_stata, out_state_demand_na/1e6 > 80 & year == 2013),
            aes(label=state,size=3),size=4,hjust = -.2,position="dodge") +
  scale_x_continuous(breaks=c(1993,1997,2001,2005,2009,2013))
ggsave(file=file.path(dir_path,"/output/out_of_state_rec.pdf"),width = 8, height = 8)


## Figure A3
ggplot(data_stata, aes(x=pred_out_state_demand_na_sys/1e6, y=out_state_demand_na/1e6)) + 
 labs(x = "Instrument for Out-of-State REC Demand (TWh)", y="Actual Out-of-State REC Demand (TWh)") + 
 theme_minimal() + guides(fill=FALSE) + geom_point( size=2,colour="grey27",alpha=1)  +
 theme(legend.position="none", panel.spacing = unit(1.5, "lines"), 
       axis.title.x = element_text(vjust=-0.25),
       axis.text=element_text(size=15),axis.title.y = element_text(vjust=1),
       panel.grid.minor.x = element_blank(), panel.grid.minor.y = element_blank(),
       panel.grid.major.x = element_blank(), panel.grid.major.y = element_blank(),
       axis.ticks.x=element_line(size = 0), axis.ticks.y=element_line(size = 0)) +
 theme(panel.border = element_rect(colour = "black", fill=NA, size=.25)) +
 scale_x_continuous(limits=c(0,130), breaks = c(0,25,50,75,100,125,150)) + 
 scale_y_continuous(limits=c(0,130), breaks = c(0,25,50,75,100,125,150))
ggsave(file=file.path(dir_path,"/output/instrument_fit.pdf"),width = 7, height = 7)