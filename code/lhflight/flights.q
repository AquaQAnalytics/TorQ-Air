/
USAGE

The main function here is niceFlights[], taking as its arguments:
a dateTime (between yesterday and 5 days from now),
a three letter IATA airport code as a string
either "departures" or "arrivals"

example: niceFlights[.z.Z;"FRA";"departures"];

\

// The amount of syms from "symconfig.csv" that you want to include
numSyms:@[value;`numSyms;5];

syms:numSyms#exec sym from ("* ";enlist ",") 0:hsym first .proc.getconfigfile["symconfig.csv"];
callsTimesToSyms:{[]
  0D+`time$3.6e+6%1000%2*numSyms
 }

/- Load user authorization details from config
config:(!).("S*";"|")0:hsym first .proc.getconfigfile["lufthansa.txt"];

flightsPerRequest: 100;

clientSecret: config[`secret];
clientId: config[`clientID];


/- Date time conversion
KDB2LH:{ ssr[16 # string .z.z;".";"-"]  };
LH2KDB:{  "Z"$(-1 _ x)  };

/- This will need to be renewed on an ongoing basis
/- Used bash here for a complex curl call
genKey:{
	url:"https://api.lufthansa.com/v1/oauth/token";
	body:.url.enc `client_id`client_secret`grant_type!(config[`clientID];config[`secret];"client_credentials");
	headers:(enlist "Content-Type")!(enlist "application/x-www-form-urlencoded");
	.req.post[url;headers;body][`access_token]
	};
authKey: genKey[];

setKey:{ `authKey set genKey[]}

/- Generates url and headers for retrieving flight information
headers: ("Accept";"Authorization";"X-Originating-IP")!("application/json"; "Bearer ",authKey; " " sv string `int$0x0 vs .z.a);
genReqUrl:{  [time;airport;typ]  "https://api.lufthansa.com/v1/operations/flightstatus/"
  ,typ,"/",airport,"/",KDB2LH[time],"?",.url.enc[`serviceType`limit!("passenger";flightsPerRequest)]  }

/- Extracting data from nested tables
extractTime:{[dat;status]  LH2KDB[((dat@status)`ScheduledTimeUTC)`DateTime]  }

niceDict:{ [ dat  ]  (`Airline`depAirport`depTime`arivTime`arivAirport`FlightNumber`Type`Registration`Status)!( (dat`OperatingCarrier)`AirlineID;
  (dat`Departure)`AirportCode ; extractTime[dat;`Departure]; extractTime[dat;`Arrival]; (dat`Arrival)`AirportCode  ;
  (dat`OperatingCarrier)`FlightNumber ; (dat`Equipment)`AircraftCode ; (dat`Equipment)`AircraftRegistration; (dat`FlightStatus)`Code   )}

extractFlights:{[time;airport;typ]  (((.req.get[ genReqUrl[time;airport;typ] ; headers]`FlightStatusResource)`Flights)`Flight)  };

niceFlights:{ [time;airport;typ] 
  a: niceDict'[extractFlights[time;airport;typ]]; 
  a:update `$Airline,`$depAirport,`$arivAirport,"J"$FlightNumber,`$Type,`$Status from a;
  `sym xcol a
 }


/- Streaming to tickerplant
sendToTp:{[sy]
  a:@[niceFlights[.z.Z;;"arrivals"];sy;"No flights"];
  d:@[niceFlights[.z.Z;;"departures"];sy;"No flights"];
  if[98h~type a;
    if [98h~type d;
      h:.servers.gethandlebytype[`tickerplant;`any];
      h(`.u.upd;`flights;value flip d except raze raze each prevdata);
      h(`.u.upd;`flights;value flip a except raze raze each prevdata);
      `prevdata upsert select by airport from  ([]airport:`$sy; departures:enlist d; arrivals:enlist a)
        ]
      ]
 }

flightBySym:{sendToTp'[`.[`syms]]}

prevdata:([airport:`$()]; departures:([]sym:`symbol$(); depAirport :`symbol$();depTime :`datetime$();arivTime :`datetime$(); arivAirport: `symbol$(); FlightNumber:`long$(); Type:`symbol$(); Registration:"C"$(); Status:`symbol$()); arrivals:([]sym:`symbol$(); depAirport :`symbol$();depTime :`datetime$();arivTime :`datetime$(); arivAirport: `symbol$(); FlightNumber:`long$(); Type:`symbol$(); Registration:"C"$(); Status:`symbol$()));

.servers.startup[]
.servers.CONNECTIONS:`tickerplant;
.timer.repeat[.proc.cp[];0Wp;callsTimesToSyms[];(`flightBySym;`);"Publish Feed"];
.timer.repeat[.proc.cp[];0Wp;1D00:00:00.000;(`setKey;`);"Generating new auth key"];
