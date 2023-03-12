const HTTP = require('node:http');
const { exec } = require('child_process');

HTTP.createServer(function (request, response) {
	
    console.log("EXECUTE");
   
	response.writeHead(200, {'Content-Type': 'text/plain'});

    exec("./addUserToCaseWatchlist.sh", (error, stdout, stderr)=> {
        if (error) {
            console.log(`error: ${error.message}`);
        }
        if (stderr) {
            console.log(`stderr: ${stderr}`);
        } 
        console.log(`stdout: ${stdout}`);
        response.write(`stdout: ${stdout}`);
        response.end()
    });
}).listen(8080);

console.log('Server running at http://0.0.0.0:8080/');