/* Include Libraries */
const express = require('express');
const bodyParser = require('body-parser')
const app = express();
const path = require('path');
const fs = require('fs');
const { uuid } = require('uuidv4');
const { exec } = require('child_process');
const Logger = require('./logger/logger.js');
const xmlParser = require('xml2json');


/* Create Folders to avoid write errors to non existent folders */
if (!fs.existsSync(path.join(__dirname,'logs'))) {
	fs.mkdirSync(path.join(__dirname,'logs'));
}
if (!fs.existsSync(path.join(__dirname,'exports'))) {
	fs.mkdirSync(path.join(__dirname,'exports'));
}


/* Global Logging for messages */
const logger = new Logger();
logger.on('message', data => {
	const loggingText = `${data.date}: ${data.message}`;
	fs.appendFile(path.join(__dirname,'logs','server.log'), loggingText + '\n' , err => {
		if(err) throw err; // beim loggen darf das Backend beendet werden!
	});
	console.log(loggingText);
});

/* Global Logging for requests */
logger.on('request', data => {
	const loggingText = `${data.date} [${data.type}]: ${data.message}`;
	fs.appendFile(path.join(__dirname,'logs','requests.log'), loggingText + '\n' , err => {
		if(err) throw err; // beim loggen darf das Backend beendet werden!
	});
	console.log(loggingText);
});


/* include Body Parser */
app.use(
	bodyParser.urlencoded({
	  extended: true
	})
  );
app.use(bodyParser.json());


/* Start Server */
app.listen(8080, '0.0.0.0', () => {
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
	exec(`D:/Progress/OpenEdge/bin/_progres -p pa/ermittleZeichnungen.p -pf config/pa.pf -b -param "${req.body.id}","${req.body.rueckmeldeNummer}","${req.body.artikel}","${path.join(__dirname,'exports')}"`,
    (error, stdout, stderr) => {
    if (error) {
      logger.log(`error: ${error.message}`);
      res.statusCode = 400;
	  res.end(`${error.message}`);
	  return;
    }
    if (stderr) {
		logger.log(`error: ${stderr}`);
		res.statusCode = 400;
		res.end(`${stderr}`);
		return;
    }
    if(stdout != "") {
		res.statusCode = 400;
		res.end(`${stdout}`)
		return;
    }
    
    /* file was successfully written */
    fs.readFile(path.join(__dirname, 'exports', req.body.id + '.xml'), (err, data) => {
      if(err) {
		logger.log(`xml-read-error: ${err}`);
		res.end(`${err}`);
		return;
	  }  
      res.end(xmlParser.toJson(data));
    });			
	});
});


/* Endpoint: [Download] - für download der DMS Dokumente */
	app.get('/download', function (req, res) {
		/* Download Path zum DMS zusammenbauen */
		const volume = req.query.volume;
		const container = req.query.container; 
		const file = req.query.file;
		const extension = req.query.extension;
		const queryString = `${volume}\\dms\\${container}\\${file}.pa`;

		/* Save new information to logging */
		Object.assign(req.body, {id: uuid()});
		Object.assign(req.body, {downloadPath: queryString});
		Object.assign(req.body, {downloadExt: extension});

		/* Log the information */
		logger.log('New Request "/download!" assigned ID=' + req.body.id);
		logger.request(req.method, JSON.stringify(req.body));


		res.download('\\\\31VS-PA-DBS\\dms\\test\\' + queryString, `${file}.${extension}`);
	});
