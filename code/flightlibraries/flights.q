/
USAGE


The main function here is niceFlights[], taking as its arguments:
a dateTime (between yesterday and 5 days from now),
a three letter IATA airport code as a string
either "departures" or "arrivals"

example: niceFlights[.z.Z;"FRA";"departures"];


Currently throws error when no flights are available at an airport

\

/- load ReQ library
config:flip "|" vs ' read0 hsym `$getenv[`TORQHOME],"/appconfig/passwords/lufthansa.txt";
config: config[0]!config[1];

client_secret: config "secret";
client_id: config "clientID";


/- Date time conversion
KDB2LH:{ ssr[16 # string .z.z;".";"-"]  };
LH2KDB:{  "Z"$(-1 _ x)  };

/- This will need to be renewed on an ongoing basis
/- Used bash here for a complex curl call
gen_key:{("\"" vs (system "bash code/flightlibraries/authtoken.sh ",client_id," ",client_secret)[0])[3]};
auth_key: gen_key[];

/- Generates url and headers for retrieving flight information
headers: ("Accept";"Authorization";"X-Originating-IP")!("application/json"; "Bearer ",auth_key; " " sv string `int$0x0 vs .z.a);
gen_reqUrl:{  [time;airport;typ]  "https://api.lufthansa.com/v1/operations/flightstatus/",typ,"/",airport,"/",KDB2LH[time],"?serviceType=passenger"  }

/- Extracting data from nested tables
extractTime:{[dat;status]  LH2KDB[((dat@status)`ScheduledTimeUTC)`DateTime]  }

niceDict:{ [ dat  ]  (`depAirport`depTime`arivTime`arivAirport`Airline`FlightNumber`Type`Registration`Status)!((dat`Departure)`AirportCode ;
	 extractTime[dat;`Departure]; extractTime[dat;`Arrival]; (dat`Arrival)`AirportCode ; (dat`OperatingCarrier)`AirlineID ;
	 (dat`OperatingCarrier)`FlightNumber ; (dat`Equipment)`AircraftCode ; (dat`Equipment)`AircraftRegistration; (dat`FlightStatus)`Code   )}

extractFlights:{[time;airport;typ]  (((.req.get[ gen_reqUrl[time;airport;typ] ; headers]`FlightStatusResource)`Flights)`Flight)  };

niceFlights:{ [time;airport;typ] 
  a: niceDict'[extractFlights[time;airport;typ]]; 
  a:update `$depAirport,`$arivAirport,`$Airline,"J"$FlightNumber,`$Type,`$Registration,`$Status from a;
  `sym xcol a
 }


/- Streaming to tickerplant
sendtotp:{[]
  h:.servers.gethandlebytype[`tickerplant;`any];
  h(`.u.upd;`flights;value flip niceFlights[.z.Z;"FRA";"departures"]);
  h(`.u.upd;`flights;value flip niceFlights[.z.Z;"FRA";"arrivals"]);
 }

.servers.startup[]
.servers.CONNECTIONS:`tickerplant;
.timer.repeat[.proc.cp[];0Wp;0D00:01:00.000;(`sendtotp;`);"Publish Feed"];

