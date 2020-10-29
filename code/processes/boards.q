

/////////////////////////////////////////

\d .boards

replay:@[value;`replay;1b];                                             // whether or not to replay the log file (becomes 0b once log is replayed)
subscribeto:@[value;`subscribeto;`];                                    // tables to subscribe to
subscribetosyms:@[value;`subscribetosyms;`];                            // syms to subscribe to 


upd:{[t;x] t insert x}


// function for subscribing to the tickerplant
sub:{[]
  if[count s:.sub.getsubscriptionhandles[`tickerplant;();()!()];
    .lg.o[`subscribe;"Available tickerplant found, attempting to subscribe"];
    subinfo: .sub.subscribe[.boards.subscribeto;.boards.subscribetosyms;1b;.boards.replay;first s];
    @[`.boards;;:;]'[key subinfo;value subinfo]]
 }




\d .







.servers.startup[]
.servers.CONNECTIONS:`tickerplant;


// assigning update and eod functions
upd:.boards.upd;

// connecting to tickerplant
.servers.CONNECTIONS:`tickerplant;
.servers.startupdepcycles[`tickerplant;10;0W]

// subscribe to the quotes table
.boards.sub[];

