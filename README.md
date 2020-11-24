# TorQ-Air

TorQ-Air is a data-capture and analytics application built on top of the [TorQ framework](https://aquaqanalytics.github.io/TorQ/). It sources data from the [Lufthansa developer API](https://developer.lufthansa.com/page) and captures it within a TorQ stack. There are also five different [Kx Dashboards](https://code.kx.com/dashboards/) setups provided, which can be imported into any dashboards session and connected to the TorQ stack. 

This package includes:  

 - A feed handler for the Lufthansa API
 - 5 data dashboards for visualization
 - Realtime analytics through Kx Dashboards
 

### Installation

Requires kdb+. For Linux users, TorQ-Air can be very quickly installed with our [installation script](https://www.aquaq.co.uk/q/torq-installation-script/) by running
```  
wget https://raw.githubusercontent.com/AquaQAnalytics/TorQ-Air/master/installlatest.sh
bash installatest.sh
```
Otherwise, you may install TorQ-Air by
1. Downloading the [main TorQ codebase]
2. Downloading the [latest TorQ-Air release]
3. Extract the contents of the TorQ folder into your deploy folder, then likewise with TorQ-Air. 

### Quick Setup Guide



#### Dashboards
