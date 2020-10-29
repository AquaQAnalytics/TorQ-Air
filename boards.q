a: ("SSS"; enlist ",") 0: `:docs/allAirportCoords.csv;

system "l hdb";

allSyms:(value flip key select by depAirport from flights)[0];


// not including Type, registration or status for now

getDeps:{select Airline:sym, depAirport, depTime:"u"$depTime, arivTime: "u"$arivTime, arivAirport, FlightNumber  from flights where depAirport=x}
getArivs:{select Airline:sym, depAirport, depTime:"u"$depTime, arivTime: "u"$arivTime, arivAirport, FlightNumber  from flights where arivAirport=x}

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



a: `depAirport xcol a;

prepDep:{ `a set (value `a) lj nallDep[x] }
prepAriv:{ `a set (value `a) lj nallAriv[x] }

prepDep'[0 1 2 3 4];
prepAriv'[0 1 2 3 4];

final: 0!a;

update color: `$"#ff0000" from `final;


save `:/home/cthackray/lufthansa/deploy/final.csv;


