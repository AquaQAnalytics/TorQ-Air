#Extended Setup

## Port in use

If the default ports (24025-24035) are in use, then proceed as follows:

1. Change the `BASEPORT` variable in `setenv.sh` to a free port.
2. Run the `setup_dashboards.sh` script from the folder in which it's in, providing your new baseport as the argument.
3. Move across `rdb.json` and `boards.json` to the `/dash/data/connections` folder inside the Kx dashboards installation.
4. Start Kx dashboards as usual, connect through your browser and import the dashboards as per the readme.
