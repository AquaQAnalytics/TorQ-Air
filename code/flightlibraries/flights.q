/
USAGE


The main function here is niceFlights[], taking as its arguments:
a dateTime (between yesterday and 5 days from now),
a three letter IATA airport code as a string
either "departures" or "arrivals"

example: niceFlights[.z.Z;"FRA";"departures"];


Currently throws error when no flights are available at an airport

\


numsyms:@[value;`numsyms;5];

syms:`.[`numsyms]#exec sym from ("* ";enlist ",") 0:hsym first .proc.getconfigfile["symconfig.csv"];
callstimestosyms:{[]
  0D+`time$3.6e+6%1000%2*`.[`numsyms]
	
	}



/- Load user authorization details from config
config:flip "|" vs ' read0 hsym `$getenv[`TORQHOME],"/appconfig/passwords/lufthansa.txt";
config: config[0]!config[1];

flights_per_request:"100";

client_secret: config "secret";
client_id: config "clientID";


/- Date time conversion
KDB2LH:{ ssr[16 # string .z.z;".";"-"]  };
LH2KDB:{  "Z"$(-1 _ x)  };

/- This will need to be renewed on an ongoing basis
/- Used bash here for a complex curl call
gen_key:{("\"" vs (system "bash code/flightlibraries/authtoken.sh ",client_id," ",client_secret)[0])[3]};
auth_key: gen_key[];

set_key:{ `auth_key set gen_key[]}

/- Generates url and headers for retrieving flight information
headers: ("Accept";"Authorization";"X-Originating-IP")!("application/json"; "Bearer ",auth_key; " " sv string `int$0x0 vs .z.a);
gen_reqUrl:{  [time;airport;typ]  "https://api.lufthansa.com/v1/operations/flightstatus/"
  ,typ,"/",airport,"/",KDB2LH[time],"?serviceType=passenger&limit=",flights_per_request  }

/- Extracting data from nested tables
extractTime:{[dat;status]  LH2KDB[((dat@status)`ScheduledTimeUTC)`DateTime]  }

niceDict:{ [ dat  ]  (`Airline`depAirport`depTime`arivTime`arivAirport`FlightNumber`Type`Registration`Status)!( (dat`OperatingCarrier)`AirlineID;
  (dat`Departure)`AirportCode ; extractTime[dat;`Departure]; extractTime[dat;`Arrival]; (dat`Arrival)`AirportCode  ;
  (dat`OperatingCarrier)`FlightNumber ; (dat`Equipment)`AircraftCode ; (dat`Equipment)`AircraftRegistration; (dat`FlightStatus)`Code   )}

extractFlights:{[time;airport;typ]  (((.req.get[ gen_reqUrl[time;airport;typ] ; headers]`FlightStatusResource)`Flights)`Flight)  };

niceFlights:{ [time;airport;typ] 
  a: niceDict'[extractFlights[time;airport;typ]]; 
  a:update `$Airline,`$depAirport,`$arivAirport,"J"$FlightNumber,`$Type,`$Status from a;
  `sym xcol a
 }


/- Streaming to tickerplant
sendtotp:{[sy]
  a:@[niceFlights[.z.Z;;"arrivals"];sy;"No flights"];
  d:@[niceFlights[.z.Z;;"departures"];sy;"No flights"];
  if[98h~type a;
    if [98h~type d;
      h:.servers.gethandlebytype[`tickerplant;`any];
      h(`.u.upd;`flights;value flip d except  raze (raze each prevdata)'[`$syms]);
      h(`.u.upd;`flights;value flip a except raze (raze each prevdata)'[`$syms]);
      `prevdata upsert select by airport from  ([]airport:`$sy; departures:enlist d; arrivals:enlist a)
      ]
      ]


 }

flightbysym:{[]
  {sendtotp[x]}'[`.[`syms]]
 }

prevdata:([airport:`$()]; departures:([]sym:`symbol$(); depAirport :`symbol$();depTime :`datetime$();arivTime :`datetime$(); arivAirport: `symbol$(); FlightNumber:`long$(); Type:`symbol$(); Registration:"C"$(); Status:`symbol$()); arrivals:([]sym:`symbol$(); depAirport :`symbol$();depTime :`datetime$();arivTime :`datetime$(); arivAirport: `symbol$(); FlightNumber:`long$(); Type:`symbol$(); Registration:"C"$(); Status:`symbol$()));



.servers.startup[]
.servers.CONNECTIONS:`tickerplant;
.timer.repeat[.proc.cp[];0Wp;callstimestosyms[];(`flightbysym;`);"Publish Feed"];
.timer.repeat[.proc.cp[];0Wp;1D00:00:00.000;(`set_key;`);"Generating new auth key"];
