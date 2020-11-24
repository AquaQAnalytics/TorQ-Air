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
1. Downloading the [main TorQ codebase](https://github.com/AquaQAnalytics/TorQ/tree/master)
2. Downloading the [latest TorQ-Air release](https://github.com/AquaQAnalytics/TorQ-Air)
3. Extract the contents of the TorQ folder into your deploy folder, then likewise with TorQ-Air. 

### Quick Setup Guide

Firstly, users should register for a free API key from the [Lufthansa API website](https://developer.lufthansa.com/member/register). Then enter your Key/ID and secret into `/appconfig/lufthansa.json` as below
```
{
 "client_id":"agazjqhyx7xxpfp9j6Kh4d2u",
 "client_secret":"NZzhf4jfWFzsTFX8qWex"
}
```
Then in `/appconfig/settings/lhflight.q`, edit the `syms` variable to be a list of three letter IATA codes of airports that you want TorQ-Air to track, for example:  
``` syms:`FRA`MUC`VIE`ZRH ```  
You may also use \` to instead use the full list of [all airports served by Lufthansa](https://en.wikipedia.org/wiki/List_of_Lufthansa_destinations). Note that by default your API key has a maximum of 1,000 requests per hour, so the more airports are selected, the less frequents updates will be. 

Finally, change `KDBBASEPORT` in `setenv.sh` to an unused port and start the stack, which on linux can be achieved with `./torq.sh start all`

### Dashboards

In order to connect the dashboards we must first install [Kx dashboards](https://code.kx.com/dashboards/gettingstarted/), preferably on the same machine as our TorQ stack. Start the process as per the installation instructions and then connect via your browser. 

We'll then need to edit what ports are used in the dashboards to reflect the baseport your chose for the TorQ stack. Linux users can do this by running the provided `baseport.sh` script with `bash baseport.sh x y`, where `x` is the baseport and `y` is the path to the the dashboards folder. Non-linux users can do a manual search and replace both in the dashboard file itself and in `/dash/data/connections` for HDBPORT and RDBPORT, replacing them with 

Finally, after connecting to dashboards, open the editor via `Users -> Open Editor`, then `Demo -> Manage Dashboards -> Import`, where you can select one of the dashboards provided to import. Select that dashboard from the menu in the top left. 






