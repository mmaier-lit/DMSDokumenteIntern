/* Includes */
const odbc = require('odbc');
const express = require('express');
const bodyParser = require('body-parser')
const app = express();


/* Statische Dateien des DMS einbinden: Über Netzfreigabe verfügbar machen */
app.use(express.static('\\\\192.168.60.59\\Users\\mmaier\\Desktop\\Aeschlimann\\demo-dms'));

/* Body Parser einbinden */
app.use(
	bodyParser.urlencoded({
	  extended: true
	})
  );
app.use(bodyParser.json());

/* DSN vom Kunden für pA-Database */
const connectionString = "DSN=PAVAR;PWD=compakt";

odbc.connect(connectionString, (error, connection) => {
	if (error) {
		console.log(error);
	}

	/* Start Server */
	app.listen(8080, function () {
		console.log('[SERVER]  Server listening on port 8080!');
	});

	/* Endpoint: [ermittleZeichnungen] */
	app.post('/ermittleZeichnungen', function (req, res) {
		let time = Date.now();
		console.log(req.body);
		console.log('[SERVER]  Request  --> /ermittleZeichnungen!');
		connection.query(`select * from pp_zeichnung where rueckmeldeNr = ${req.body.rueckmeldeNr}`, function (err, rows, moreResultSets) {

			if (err) {
				return console.log(err);
			}
			res.send(rows);
		});
		time = Date.now() - time;
		console.log('[SERVER]  Response <-- /ermittleZeichnungen! (' + time + 'ms)');
	});

	/* Endpoint: [Download] - für download der DMS Dokumente */
	app.get('/download', function (req, res) {
		/* TODO: auf Post umstellen Angabe zur richtigen Zeichnung mitgeben */
		res.download('\\\\192.168.60.59\\Users\\mmaier\\Desktop\\Aeschlimann\\demo-dms\\test.pa', 'test.txt');
	});

});


