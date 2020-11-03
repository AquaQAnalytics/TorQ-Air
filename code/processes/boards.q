
\d .boards

replay:@[value;`replay;1b];                                             // whether or not to replay the log file (becomes 0b once log is replayed)
subscribeto:@[value;`subscribeto;`];                                    // tables to subscribe to
subscribetosyms:@[value;`subscribetosyms;`];                            // syms to subscribe to 


// needs to be improved to get rid of old data
upd:{[t;x] t insert x}


// function for subscribing to the tickerplant
sub:{[]
  if[count s:.sub.getsubscriptionhandles[`tickerplant;();()!()];
    .lg.o[`subscribe;"Available tickerplant found, attempting to subscribe"];
    subinfo: .sub.subscribe[.boards.subscribeto;.boards.subscribetosyms;1b;.boards.replay;first s];
    @[`.boards;;:;]'[key subinfo;value subinfo]]
 }

\d .

// calculating boards
coords: ("SSS"; enlist ",") 0: `:docs/allAirportCoords.csv;
coords: `depAirport xcol coords;

//Retrieves Airline Codes for translation later
codes: ("SS"; ":") 0: `:docs/allAirlineCodes.txt;
codes: (string codes[0])!(string codes[1]);

// Get airports codes as a dictionary
airports: ("  SS"; enlist ",") 0: `:docs/allAirportCodes.csv;
airports: ( airports`code)!(airports`Airport);

final:();
allSyms: key airports;

// For direction takes `depAirport or `arivAirport
getRaw:{ [direction;airport]
  tab:?[`flights; enlist (=;direction;enlist airport); 0b; ()];
  distinct select Airline:`$codes[string sym], depAirport, depTime:"u"$depTime, arivTime: "u"$arivTime,arivAirport, FlightNumber from tab where arivTime > .z.z
 }

// select a particular flight, used for departure board entries
nflight:{ [direction;airport; n] (getRaw[direction;airport])[n]  }


// Renames the columns as necessary so they're all unique and can be lj'ed onto final
// requests the nth departure / arrival as necessary from all syms
nallDep:{[n]
  u:string n; 
  tab: select Airline, depTime, arivTime, arivAirport, FlightNumber by depAirport from nflight[`depAirport;;n]'[allSyms]; 
  (`depAirport;(`$u,"Airline");  (`$u,"depTime"); (`$u,"arivTime"); (`$u,"arivAirport"); (`$u,"FlightNumber")) xcol tab
 }

// The "Departing airport" and "Arriving Airport" are swapped here so the LJ will work and data will be placed properly on the map
// The q on the end of the names is to distinguish them from the departures when doing the html tables in kx dashboards. 
nallAriv:{[n]
  u:string n;
  tab:select  Airline, depTime, arivTime, depAirport, FlightNumber by arivAirport from nflight[`arivAirport;;n]'[allSyms];
  (`depAirport;(`$u,"Airlineq");  (`$u,"depTimeq"); (`$u,"arivTimeq"); (`$u,"arivAirportq"); (`$u,"FlightNumberq")) xcol tab 
 }

resetFinal:{ `final set coords }

// adds a set of columns representing the nth arrival / departure to the 
addFlight:{
  `final set (value `final) lj nallDep[x];
  `final set (value `final) lj nallAriv[x];
 }

// adds color coding to airports depending on how busy they are
calcColors:{
  symsInUse: exec sym from final;
  counts: {count getRaw[`depAirport;x]}'[symsInUse] + {count getRaw[`arivAirport;x]}'[symsInUse];
  colors: { $[x > 5; $[ x>15;`$"#ff0000"; `$"#d48c19"]; `$"#39a105"] }'[counts];
  `final set update color: colors from final;
 }

// actually calculates departures and arrival boards
calcBoards:{
  resetFinal[];
  addFlight'[ til 5];
  `final set 0!final;
  `final set  update sym:depAirport, depAirport: airports[depAirport] from final;
  calcColors[];	
  }

// Tickerplant stuff
.servers.startup[]
.servers.CONNECTIONS:`tickerplant;


// assigning update and eod functions
upd:.boards.upd;

// connecting to tickerplant
.servers.CONNECTIONS:`tickerplant;
.servers.startupdepcycles[`tickerplant;10;0W]

// subscribe to the quotes table
.boards.sub[];
.timer.repeat[.proc.cp[];0Wp;0D00:01:00.000;(`calcBoards;`);"Calculate Boards"];
