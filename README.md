### R package: atsd

This repository contains the **atsd R package**. This package provides functionality 
to communicate with 
the [Axibase Time Series Database](http://axibase.com/axibase-time-series-database/) (ATSD).
ATSD is a non-relational clustered database used for storing performance measurements 
from IT infrastructure resources, such as servers, network devices, storage systems, and applications.

The **source** folder contains the **atsd** package source code, and its documentation.

The **compiled** folder contains binary packages for linux and windows,
and the installation instruction.

For more documentation and usage examples view [atsd_package.md](atsd_package.md), 
[usage_example.md](usage_example.md)
and [forecast_and_save_series_example.md](forecast_and_save_series_example.md).

### Overview

The **atsd** package provides functions for retrieving time-series and related 
meta-data such as entities, metrics, and tags from ATSD:

- [set_connection()](#set_connection), 
  [save_connection()](#save_connection),
  [show_connection()](#show_connection) - used to manage the connection with ATSD.
  Set up and store the url, user name, and password. Configure cryptographic protocol 
  and enforce SSL certificate validation in the case of https connection.
- [query()](#query) - get historical data and forecasts from ATSD.
- [get_metrics()](#get_metrics) - get information for metrics collected by ATSD.
- [get_entities()](#get_entities) - get information for entities collected by ATSD.
- [get_series_tags()](#get_series_tags) - get unique time series tags for the metric.
- [to_zoo()](#to_zoo) - converts a time-series data frame to a `zoo` object for manipulating irregular time-series with built-in functions in the zoo package.


### Installation

Stable release available via [CRAN](http://cran.r-project.org/web/packages/atsd/index.html). 
Install in R as:
```
install.packages("atsd")
```

To install the alpha version from github:
```
install.packages("devtools")
library(devtools)
install_github("axibase/atsd-api-r/source")
```

The **atsd** package requires **RCurl**, **httr**, and **zoo** packages to be installed. 
You could review installed packages with the `library()` command. 
If **RCurl**, **httr**, or **zoo** are not installed, install them as follows:
`install.packages(c("RCurl", "httr", "zoo"))`.

### Getting Started

To start using the package, load it into R with the command `library(atsd)`.

To view the complete package documentation, type `help(package = "atsd")`.

The package vignette contains detailed documentation and usage examples.
To view the vignette type, enter `browseVignettes(package = "atsd")`.

To get help for a particular function or package, type `?` followed by the function (package) name. For example,
`?atsd`, `?set_connection`, `?query`, `?get_metrics`, `?get_entities` etc.

### Deinstallation

To detach the package from the current R session: 
`detach("package:atsd", unload = TRUE)`.

To uninstall the package completely:
`remove.packages("atsd", .libPaths())`.

### License

The **atsd** package is licensed under
[Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0).

### Usage examples

View the usage examples of the **atsd** package in [usage_example.md](usage_example.md)
and [forecast_and_save_series_example.md](forecast_and_save_series_example.md).
