var http        = require("http"),
    fs          = require("fs"),
    path        = require("path");

var server  = http.createServer(function(req, res){
  fs.readFile(getFileName(req.url), getEncodeType(req.Url), function(err, data){
    if(err){
      res.writeHead(500);
      return res.end("Error loading " + req.url);
    }
    res.writeHead(200, {"Content-Type": getContentType(req.url)});
    res.end(data);
  });
}).listen(process.env.PORT || 8080);

function getContentType(reqUrl){
    var extname = path.extname(reqUrl);
    switch(extname){
        case ".css":
            return "text/css";
        case ".js":
            return "text/javascript";
        case ".html":
            return "text/html";
        case ".jpg":
            return "image/jpeg";
    }
}

function getEncodeType(reqUrl){
    var extname = path.extname(reqUrl);
    switch(extname){
        case ".css":
        case ".js":
        case ".html":
            return "utf-8";
        case ".jpg":
        case ".png":
            return "binary";
    }
}

function getFileName(reqUrl){
    return "./public" + ((reqUrl == "/") ? "/index.html" : reqUrl);
}