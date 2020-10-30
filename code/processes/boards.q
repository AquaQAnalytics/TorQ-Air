

/////////////////////////////////////////

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
// lots of code duplication here, needs refactoring
coords: ("SSS"; enlist ",") 0: `:docs/allAirportCoords.csv;
coords: `depAirport xcol coords;

getDeps:{select Airline:sym, depAirport, depTime:"u"$depTime, arivTime: "u"$arivTime, arivAirport, FlightNumber  from flights where depAirport=x, depTime > .z.z}
getArivs:{select Airline:sym, depAirport, depTime:"u"$depTime, arivTime: "u"$arivTime, arivAirport, FlightNumber  from flights where arivAirport=x, arivTime > .z.z}

ndept:{[airport; n] (distinct getDeps[airport])[n]}
nariv:{[airport; n] (distinct getArivs[airport])[n]}


nallDep:{[n]
  u:string n; 
  (`depAirport;(`$u,"Airline");  (`$u,"depTime"); (`$u,"arivTime"); (`$u,"arivAirport"); (`$u,"FlightNumber"))
     xcol select Airline, depTime, arivTime, arivAirport, FlightNumber by depAirport from ndept[;n]'[allSyms] 
 }


// The "Departing airport" and "Arriving Airport" are swapped here so the LJ will work and data will be placed properly on the map
// The q on the end of the names is to distinguish them from the departures when doing the html tables. 
nallAriv:{[n]
  u:string n;
  (`depAirport;(`$u,"Airlineq");  (`$u,"depTimeq"); (`$u,"arivTimeq"); (`$u,"arivAirportq"); (`$u,"FlightNumberq"))
     xcol select Airline, depTime, arivTime, depAirport, FlightNumber by arivAirport from nariv[;n]'[allSyms]
 }


prepDep:{ `coords set (value `coords) lj nallDep[x] }
prepAriv:{ `coords set (value `coords) lj nallAriv[x] }

final:();
allSyms:();

calcBoards:{
  `allSyms set (value flip key select by depAirport from flights)[0];
  prepDep'[0 1 2 3 4];
  prepAriv'[0 1 2 3 4];
  
  `final set 0!coords;

  `final set  update color: `$"#ff0000" from final;	

  }





////////// Tickerplant stuff
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
