# Replication code for External Impacts of Local Energy Policy: The Case of Renewable Portfolio Standards
## Journal of the Association of Environmental and Resource Economists
### Alex Hollingsworth (hollinal@indiana.edu) and Ivan Rudik (irudik@cornell.edu)

<a href="url"><img src="https://github.com/hollina/external-impacts-rps/blob/master/figure_3.png" align="left" height="500" width="500" ><figcaption>Fig.3 - Increases in nonhydro US renewable production are closely associated with increases in total US renewable energy credit (REC) demand, 1993–2013. The dashed line is a 45 degree line. We exclude hydroelectric power from total quantity of renewables supplied since many RPSs do not allow hydroelectric power generated from sources built prior to the implementation of the RPS to count toward the RPS.</figcaption></a>
<br/><br/>
This repository contains all files and datasets necessary to replicate figures and tables. The vast majority of the code is in Stata but some of the figures were made in R. 

There are three main folders. **code** contains the code, **data** contains the data, and **output** is where the output is stored.

To replicate the results set the `root_path` global in **hollingsworth_rudik_results.do** to the path of your cloned repository. For your first run set the `install_stata_packages` global equal to 1 to install all necessary packages. For the R code (**hollingsworth_rudik_results_r.r**) to run as is, you will need RStudio. Otherwise you must hardcode in your file paths.
