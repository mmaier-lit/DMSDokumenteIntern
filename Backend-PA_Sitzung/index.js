/* Includes */
const express = require('express');
const bodyParser = require('body-parser')
const app = express();
const path = require('path');
const fs = require('fs');
const { uuid } = require('uuidv4');
const Logger = require('./logger/logger.js')


/* Use Command Execution and overrite it with sync callback */
const exec = require('child_process').exec;

function os_func() {
    this.execCommand = function(cmd, callback) {
        exec(cmd, (error, stdout, stderr) => {
            if (error) {
                console.error(`exec error: ${error}`);
                return;
            }

            callback(stdout);
        });
    }
}
var os = new os_func();

/* Global Configurations */


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
	os.execCommand(`D:/Progress/OpenEdge/bin/_progres -p pa/test.p -pf config/pa.pf -b -param ${req.body.id},${req.body.rueckmeldeNummer},${req.body.artikel}`, returnvalue => {
		res.end("ok");
	});
});
