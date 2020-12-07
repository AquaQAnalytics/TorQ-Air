# TorQ-Air

TorQ-Air is a data-capture and analytics application built on top of the [TorQ framework](https://github.com/AquaQAnalytics/TorQ/releases). It sources data from the [Lufthansa developer API](https://developer.lufthansa.com/page) and captures it within a TorQ stack. There are also four example [Kx Dashboards](https://code.kx.com/dashboards/) setups provided, which can be imported into any dashboards session and connected to the TorQ stack.

This package includes:

 - A feed handler for the Lufthansa API
 - 4 data dashboards for visualization
 - Realtime analytics through Kx Dashboards

### Installation

Requires kdb+. For Linux users, TorQ-Air can be very quickly installed with our [installation script](https://www.aquaq.co.uk/q/torq-installation-script/) by running
```
wget https://raw.githubusercontent.com/AquaQAnalytics/TorQ-Air/master/installlatest.sh
bash installlatest.sh
```
Otherwise, you may install TorQ-Air by
1. Downloading the [main TorQ codebase](https://github.com/AquaQAnalytics/TorQ/releases)
2. Downloading the [latest TorQ-Air release](https://github.com/AquaQAnalytics/TorQ-Air/releases)
3. Extract the contents of the TorQ folder into your deploy folder, then likewise with TorQ-Air.

### Quick Setup Guide

Note: If you encounter any problems during setup, our extended setup guide in `/docs` will likely have a solution. 

Firstly, users should register for a free API key from the [Lufthansa API website](https://developer.lufthansa.com/member/register). Then enter your Key/ID and secret into `/appconfig/lufthansa.json` as below
```
{
 "client_id":"agazjqhyx7xxpfp9j6Kh4d2u",
 "client_secret":"NZzhf4jfWFzsTFX8qWex"
}
```
Then in `/appconfig/settings/lhflight.q`, edit the `syms` variable to be a list of three letter IATA codes of airports that you want TorQ-Air to track. You may also use a single backtick \` to instead use the full list of [all airports served by Lufthansa](https://en.wikipedia.org/wiki/List_of_Lufthansa_destinations). Note that by default your API key has a maximum of 1,000 requests per hour, so the more airports are selected, the less frequents updates will be.

Finally start the stack, which on linux can be achieved with `./torq.sh start all`

### Dashboards

In order to connect the dashboards we must first install [Kx dashboards](https://code.kx.com/dashboards/gettingstarted/) on the same machine as our TorQ stack.

Place `boards.json` and `rdb.json` into `/dash/data/connection`, inside the Kx dashboards installation. 

Start the dashboards process as per the installation instructions and then connect via your browser. Then, open the editor via `Users -> Open Editor`, then `Demo -> Manage Dashboards -> Import`, where you can select one of the numbered slides provided in the `/dashboards` folder to import. Select that dashboard from the menu in the top left to view.
