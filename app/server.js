const HTTP = require('node:http');
const URL = require('node:url');
const { exec } = require('child_process');

HTTP.createServer(function (request, response) {
	
	var url = URL.parse(JSON.stringify(request.url),true)
    console.log(url)

    var command = "."+request.url.substring(0,request.url.indexOf('?'))
    if(url.query.apikey!=undefined) {
        command = command.concat(" --apikey ",url.query.apikey)
    }
    if(url.query.email!=undefined) {
        if(Array.isArray(url.query.email)) {
            for (index in url.query.email) {
                command = command.concat(" --email ",url.query.email[index])
            }
        } else command = command.concat(" --email ",url.query.email)
    }
    if(url.query.case!=undefined) {
        if(Array.isArray(url.query.case)) {
            for (index in url.query.case) {
                command = command.concat(" --case ",url.query.case[index])
            }
        } else command = command.concat(" --case ",url.query.case)
    }

    console.log("EXECUTE "+command);

    response.writeHead(200, {'Content-Type': 'text/plain'});

    exec(command, (error, stdout, stderr)=> {
        if (error) {
            console.log(`error: ${error.message}`);
        }
        if (stderr) {
            console.log(`stderr: ${stderr}`);
        } 
        console.log(`${stdout}`);
        response.write(`${stdout}`);
        response.end()
    });
}).listen(8080);

console.log('Server running at http://0.0.0.0:8080/');