const odbc = require('odbc');
var express = require('express');
const bodyParser = require('body-parser')
var app = express();

app.use(express.static('\\\\192.168.60.59\\Users\\mmaier\\Desktop\\Aeschlimann\\demo-dms'));

app.use(
	bodyParser.urlencoded({
	  extended: true
	})
  )
  
app.use(bodyParser.json())

const connectionString = "DSN=PAVAR;PWD=compakt";
odbc.connect(connectionString, (error, connection) => {
	if (error) {
		console.log(error);
	}

	/* Start Server */
	app.listen(8080, function () {
		console.log('[SERVER]  Server listening on port 8080!');
	});


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

	app.get('/download', function (req, res) {
		res.download('\\\\192.168.60.59\\Users\\mmaier\\Desktop\\Aeschlimann\\demo-dms\\test.pa', 'test.txt');
	});

});


