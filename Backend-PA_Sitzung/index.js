/* Includes */
const express = require('express');
const bodyParser = require('body-parser')
const app = express();
const path = require('path');
const fs = require('fs');
const { uuid } = require('uuidv4');
const { exec } = require('child_process');
const Logger = require('./logger/logger.js')


/* Create Folders to avoid write errors to non existent folders */
fs.mkdirSync(path.join(__dirname,'logs'));
fs.mkdirSync(path.join(__dirname,'exports'));


/* Global Logging */
const logger = new Logger();
logger.on('message', data => {
	const loggingText = `${data.date}: ${data.message}`;
	fs.appendFile(path.join(__dirname,'logs','server.log'), loggingText + '\n' , err => {
		if(err) throw err;
	});
	console.log(loggingText);
});

logger.on('request', data => {
	const loggingText = `${data.date} [${data.type}]: ${data.message}`;
	fs.appendFile(path.join(__dirname,'logs','requests.log'), loggingText + '\n' , err => {
		if(err) throw err;
	});
	console.log(loggingText);
});


/* Body Parser einbinden */
app.use(
	bodyParser.urlencoded({
	  extended: true
	})
  );
app.use(bodyParser.json());


/* Start Server */
app.listen(8080, () => {
	logger.log('Serverstart: Server is now listening on port 8080!');
});


/* Endpoint: [ermittleZeichnungen] */
app.post('/ermittleZeichnungen', (req, res) => {
    /* create new uuid */
	Object.assign(req.body, {id: uuid()});

	/* Log the information */
	logger.log('New Request "/ermittleZeichnungen!" assigned ID=' + req.body.id);
	logger.request(req.method, JSON.stringify(req.body));

	/* Run pA Script */
	exec(`D:/Progress/OpenEdge/bin/_progres -p pa/ermittleZeichnungen.p -pf config/pa.pf -b -param ${req.body.id},${req.body.rueckmeldeNummer},${req.body.artikel},${path.join(__dirname,'exports')}`,
		(error, stdout, stderr) => {
			if (error) {
				logger.log(`error: ${error.message}`);
				res.end("bad" + error);
			}
			if (stderr) {
				logger.log(`stderr: ${stderr}`);
				res.end("bad" + stderr);
			}
			res.end("ok" + stdout);
	});
});
