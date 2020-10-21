/
USAGE

Enter the aircraft registration and its current airport.

leave the process running and it will track each flight update and 
save it to a flat csv table. 

\

/- User config
registration:"";
startAirport: "";


system "l flights.q";

/- get this from database.q when that gets made
travelLog:([] depAirport:"C"$(); depTime:"C"$(); arivTime:"z"$(); arivAirport:"z"$();
   Airline:"C"$(); FlightNumber:"C"$(); Type:"C"$(); Registration:"C"$(); Status:"C"$() );

travelLog: select from (niceFlights[.z.Z;startAirport;"departures"]) where Registration like registration;

/- change to TorQ logging
if[ 0 = count travelLog; 0N!"Could not find flight at starting Airport"; exit 1];

nextAirport: first exec arivAirport from travelLog;

save `travelLog.csv;


ping:{

  nxt: select from (niceFlights[.z.Z;nextAirport;"departures"]) where Registration like registration;
  if[ 0 < count nxt; `travelLog set distinct (value `travelLog),nxt; `nextAirport set last exec arivAirport from (value `travelLog); save `travelLog.csv ];
  travelLog

 };

\t 60000

.z.ts: ping;












