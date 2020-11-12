
syms:$[.lhflight.syms~`; 
  exec airportCode from .[0:;(("* ";enlist ",");hsym first .proc.getconfigfile["airportData.csv"]);{.lg.e[`loadingSyms;"Error loading syms from disk"]}];
  string .lhflight.syms
 ];

/- Adjusts time between airport calls to stay within 1000 / hour total API calls
callsTimesToSyms:{[]
  0D+`time$3.6e+6%1000%2*count syms
 }

/- Load user authorization details from config
config:@[{.j.k read1 hsym first x};.proc.getconfigfile["lufthansa.json"];{.lg.e[`config;"lufthansa.json failed to load"]}];

flightsPerRequest: 100;

/- Date time conversion
KDB2LH:{ssr[16#string .z.z;".";"-"]};
LH2KDB:{"Z"$-1_x};

/- This will need to be renewed on an ongoing basis
genKey:{
  url:.lhflight.apiurl,"/oauth/token";
  body:.url.enc @[config;`grant_type;:;"client_credentials"];
  keyHeaders:(enlist "Content-Type")!(enlist "application/x-www-form-urlencoded");
  .req.post[url;keyHeaders;body][`access_token]
 };

setKey:{
  .[set;(`authKey;genKey[]);{.lg.e[`setKey;"Failed to generate authKey"]}];
  if[(authKey~"") or (10h<>type authKey);setKey[];.lg.e[`setKey;"authKey malformed"]];
  `headers set ("Accept";"Authorization";"X-Originating-IP")!("application/json";"Bearer ",authKey; " " sv string `int$0x0 vs .z.a);
 };

genReqUrl:{[time;airport;typ] 
  .lhflight.apiurl,"/operations/flightstatus/",typ,"/",airport,"/",
  KDB2LH[time],"?",.url.enc[`serviceType`limit!("passenger";flightsPerRequest)]  
 }

/- Extracting data from nested tables
extractTime:{[dat;status]
  LH2KDB dat[status][`ScheduledTimeUTC]`DateTime
 }

niceDict:{[dat] (!). flip (
  (`Airline;dat[`OperatingCarrier]`AirlineID);
  (`depAirport;dat[`Departure]`AirportCode);
  (`depTime;extractTime[dat;`Departure]);
  (`arivTime;extractTime[dat;`Arrival]);
  (`arivAirport;dat[`Arrival]`AirportCode);
  (`flightNumber;dat[`OperatingCarrier]`FlightNumber);
  (`aircraftType;dat[`Equipment]`AircraftCode);
  (`registration;dat[`Equipment]`AircraftRegistration);
  (`status;dat[`FlightStatus]`Code))
 }

extractFlights:{[time;airport;typ]
  .req.get[genReqUrl[time;airport;typ];headers][`FlightStatusResource;`Flights;`Flight]
 };

niceFlights:{[time;airport;typ] 
  a:niceDict'[extractFlights[time;airport;typ]]; 
  a:@[a;`Airline`depAirport`arivAirport`aircraftType`status;`$];
  `sym xcol update"J"$flightNumber from a
 }

/- Streaming to tickerplant
sendToTp:{[sy]
  a:@[niceFlights[.z.Z;;"arrivals"];sy;"No flights"];
  d:@[niceFlights[.z.Z;;"departures"];sy;"No flights"];
  if[(98h~type a) and 98h~type d;
      h:.servers.gethandlebytype[`tickerplant;`any];
      h(`.u.upd;`flights;value flip d except raze raze each prevdata);
      h(`.u.upd;`flights;value flip a except raze raze each prevdata);
      `prevdata upsert select by airport from ([] airport:`$sy; departures:enlist d; arrivals:enlist a)
    ]
 }

prevdata:([airport:`$()]; departures:([] sym:`symbol$(); depAirport:`symbol$(); depTime:`datetime$(); arivTime:`datetime$(); arivAirport:`symbol$(); 
  flightNumber:`long$(); aircraftType:`symbol$(); registration:(); status:`symbol$()); arrivals:([] sym:`symbol$(); depAirport:`symbol$();
  depTime:`datetime$(); arivTime:`datetime$(); arivAirport:`symbol$(); flightNumber:`long$();aircraftType:`symbol$(); registration:(); status:`symbol$()));

setKey[];
.servers.startup[]
.servers.CONNECTIONS:`tickerplant;
.timer.repeat[.proc.cp[];0Wp;1D00:00:00.000;(`setKey;`);"Generating new auth key"];
.timer.repeat[.proc.cp[];0Wp;callsTimesToSyms[];({sendToTp'[syms]};`);"Publish Feed"];

