\d .boards

/- enable / disable tickerplant replay
replay:@[value;`replay;1b];

/- tables to subscribe to
subscribeto:@[value;`subscribeto;`];

/- syms to subscribe to
subscribetosyms:@[value;`subscribetosyms;`];

upd:{[t;x] t insert x}

/- function for subscribing to the tickerplant
sub:{[]
  if[count s:.sub.getsubscriptionhandles[`tickerplant;();()!()];
    .lg.o[`subscribe;"Available tickerplant found, attempting to subscribe"];
    .boards,:.sub.subscribe[.boards.subscribeto;.boards.subscribetosyms;1b;.boards.replay;first s]];
 }

\d .

/- loading airport / airline data
airportData:.[0:;(("SSSSFF"; enlist ","); first .proc.getconfigfile["airportData.csv"]); {.lg.e[`airlineData;"Failed to load aiportData.csv"]}];
codes:(!) . .[0:;(("SS";":"); first .proc.getconfigfile["allAirlineCodes.txt"]); {.lg.e[`airlineCodes;"Failed to load allAirlineCodes.txt"]}];

/- Retrieving airport data
coords:`depAirport xcol select airportCode, latitude, longitude from airportData;
airports:exec airportCode!airport from airportData;

final:();

/- For direction takes `depAirport or `arivAirport
getRaw:{[direction;airport]
  time:$[direction~`depAirport;`depTime;`arivTime];
  tab:$[airport~`;flights;?[`flights;enlist (=;direction;enlist airport);0b;()]];
  tab:?[tab; enlist (>;time;.z.p);0b;()];
  distinct select Airline:codes[sym], depAirport, depTime:"u"$depTime, arivTime:"u"$arivTime, arivAirport, flightNumber from tab
 }

/- Renames the columns as necessary so they're all unique and can be lj'ed onto final
/- requests the nth departure / arrival as necessary from all syms
nallDep:{[n]
  tab:1!select depAirport, Airline, depTime, arivTime, arivAirport, flightNumber from getRaw[`depAirport;`] where i=({y@x}[n];i) fby depAirport;
  (`depAirport,`$string[n],/:("Airline";"depTime";"arivTime";"arivAirport";"flightNumber")) xcol tab
 }

/- The "Departing airport" and "Arriving Airport" are swapped here so the LJ will work and data will be placed properly on the map
/- The q on the end of the names is to distinguish them from the departures when doing the html tables in kx dashboards. 
nallAriv:{[n]
  tab:1!select  arivAirport,Airline, depTime, arivTime, depAirport, flightNumber from getRaw[`arivAirport;`] where i=({x@y}[;n];i) fby arivAirport;
  (`depAirport,`$string[n],/:("Airlineq";"depTimeq";"arivTimeq";"arivAirportq";"flightNumberq")) xcol tab 
 }

resetFinal:{`final set coords}

/- adds a set of columns representing the nth arrival / departure to the 
addFlight:{`final set (lj/)(value`final;nallDep x;nallAriv x)}

/- adds color coding to airports depending on how busy they are
calcColors:{
  symsInUse:exec sym from final;
  counts:count getRaw'[`depAirport`arivAirport]'[symsInUse];

  /- Color codes airports red, yellow or green depending on how busy they are (in Kx dashboards)
  c:`s#0 6 16!`$("#39a105";"#d48c19";"#ff0000"); 
  `final set update color:c[counts] from final;
 }

/- actually calculates departures and arrival boards
calcBoards:{
  resetFinal[];
  addFlight'[til 5];
  `final set update sym:depAirport, depAirport:airports[depAirport] from 0!final;
  calcColors[];
 }

/- Tickerplant stuff
.servers.startup[]
.servers.CONNECTIONS:`tickerplant;

/- assigning update and eod functions
upd:.boards.upd;

/- connecting to tickerplant
.servers.CONNECTIONS:`tickerplant;
.servers.startupdepcycles[`tickerplant;10;0W]

/- subscribe to the quotes table
.boards.sub[];
.timer.repeat[.proc.cp[];0Wp;0D00:01:00.000;(`calcBoards;`);"Calculate Boards"];
