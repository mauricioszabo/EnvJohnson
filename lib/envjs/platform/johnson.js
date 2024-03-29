var __context__ = __this__;

var Envjs = Envjs || require('envjs/platform/core').Envjs;

Envjs.platform       = "Johnson SpiderMonkey";
Envjs.revision       = Ruby.Config.CONFIG.ruby_version;

Ruby.ARGV.shift();
Envjs.argv = [];

Envjs.exit = function(){ exitNow = true; };

/*
 * Envjs johnson-env.1.3.pre03 
 * Pure JavaScript Browser Environment
 * By John Resig <http://ejohn.org/> and the Envjs Team
 * Copyright 2008-2010 John Resig, under the MIT License
 */

//CLOSURE_START
(function(){





/**
 * @author john resig
 */
// Helper method for extending one object with another.
function __extend__(a,b) {
    for ( var i in b ) {
        if(b.hasOwnProperty(i)){
            var g = b.__lookupGetter__(i), s = b.__lookupSetter__(i);
            if ( g || s ) {
                if ( g ) { a.__defineGetter__(i, g); }
                if ( s ) { a.__defineSetter__(i, s); }
            } else {
                a[i] = b[i];
            }
        }
    } 
    return a;
}

Envjs.log = function(msg){
	Ruby.puts(msg);
}

Envjs.lineSource = function(e){
    return "(line ?)";
};

Envjs.readConsole = function(){
     return Ruby.$stdin.gets();
};

Envjs.prompt = function(){
    Ruby.$stdout.write(Envjs.CURSOR+' ');
    Ruby.$stdout.flush;
};

//No REPL for
Envjs.repl = function(){
    console.log('Envjs REPL Not Available');
};
(function(){
    
var log = Envjs.logger('Envjs.Platform.Johnson');

Envjs.eval = function(context, source, name){
    if(context == __this__){
        return global.evaluate( source, name );
    }else{
		var abc = new Ruby.Johnson.Runtime()
		log.debug('evaluating in framed context %s %s', context, abc);
	    return context.evaluate( source, name );
    }
};

})();
/**
 * synchronizes thread modifications
 * @param {Function} fn
 */	
var	lock = new Ruby.Mutex();

//NOTES:
//context['sync'] = lambda{|wrapper| 
//    Proc.new{|*args|lock.synchronize {wrapper['fn'].call(*args)}} 
//}
//context['sync']      = lambda{|fn| Proc.new{|*args| fn.call(*args) }}
Envjs.sync = function(fn){
    //console.log('syncing js fn %s', fn);
    var wrapper = {fn:fn};
	//return lock.synchronize(fn)
    return fn;
};

//NOTES:
//context['spawn']    = lambda{|wrapper| Thread.new {wrapper['fn'].call} }
//context['spawn']     = lambda{|wrapper| wrapper['fn'].call }
 Envjs.spawn = function(fn){
     //console.log('spawning js fn %s', fn);
     var wrapper = {fn:fn};
     return fn();
 };

/**
 * sleep thread for specified duration
 * @param {Object} milliseconds
 */
Envjs.sleep = function(milliseconds){
	return Ruby.sleep(1.0*milliseconds/1000.0);
};
(function(){
    
var log = Envjs.logger('Envjs.Platform.Johnson');

//Since we're running in spydermonkey I guess we can safely assume
//java is not 'enabled'.  I'm sure this requires more thought
//than I've given it here
Envjs.javaEnabled 	 = false;

Envjs.homedir        = Ruby.ENV.HOME
Envjs.tmpdir         = Ruby.ENV.TMPDIR;
Envjs.os_name        = Ruby.Config.CONFIG.host_os;
Envjs.os_arch        = Ruby.Config.CONFIG.host_cpu;
Envjs.os_version     = "";//part of os_arch
Envjs.lang           = Ruby.ENV.LANG;

Envjs.gc = function(){ Ruby.Johnson.Runtime.gc(); };

/**
 * Makes an object window-like by proxying object accessors
 * @param {Object} scope
 * @param {Object} parent
 */
Envjs.proxy = function(scope, parent) {
    try{
        if(scope == __this__){
            return scope;
        }else{
            return new Ruby.Johnson.Runtime();
        }
    }catch(e){
        console.log('failed to init standard objects %s %s \n%s', scope, parent, e);
    }
};

})();(function(){
    
var log = Envjs.logger('Envjs.XMLHttpRequest.Johnson');

/**
 * Get 'Current Working Directory'
 */
Envjs.getcwd = function() {
    return Ruby.ENV['PWD'];
};

/**
 * Used to read the contents of a local file
 * @param {Object} url
 */
Envjs.readFromFile = function( url ){
	if(/^file\:\/\//.test(url))
		url = url.substring(7,url.length);
    log.debug('reading file %s', url);
    var file = Ruby.File.open(url, 'r'),
        data = file.read();
    return data;
};

Envjs.writeToFile = function(text, url){
    var file = Ruby.File.open(url, 'w');
	log.debug('writing to file %s', url);
	file.write(text);
	return;
};

/**
 * Used to write to a local file
 * @param {Object} text
 * @param {Object} suffix
 */
Envjs.writeToTempFile = function(text, suffix){
    // Create temp file.
    var temp = Envjs.tmpdir+"."+(new Date().getTime())+(suffix||'.js');
    log.debug("writing text to temp url : %s ", temp);
    Envjs.writeToFile(text, temp);
    return temp;
};


/**
 * Used to read the contents of a local file
 * @param {Object} url
 */
Envjs.readFromFile = function( url ){
	if(/^file\:\/\//.test(url))
		url = url.substring(7,url.length);
	log.debug('reading file %s', url);
    var file = Ruby.File.open(url, 'r'),
		data = file.read();
	return data;
};
    

/**
 * Used to delete a local file
 * @param {Object} url
 */
Envjs.deleteFile = function(url){
    return ;//TODO
};

/**
 * establishes connection and calls responsehandler
 * @param {Object} xhr
 * @param {Object} responseHandler
 * @param {Object} data
 */
Envjs.connection = function(xhr, responseHandler, data){
    var url = xhr.url,
		urlparts = Envjs.urlsplit(xhr.url),
        connection,
		request,
		headers,
        header,
        length,
        binary = false,
        name, value,
        contentEncoding,
        responseXML,
        i;
       
    if ( /^file\:/.test(url) ) {
	//console.log('establishing file connection');
        Envjs.localXHR(url, xhr, connection, data);
    } else {
        log.debug('establishing http connection %s', xhr.url);
        path = urlparts.path+(urlparts.query?'?'+urlparts.query:'');
        connection = urlparts.hostname+path;
    }

    if(connection){
        [response, headers] = HTTPConnection.go(connection, path);
		
        try{
            // Stick the response headers into responseHeaders
			var keys = headers.keys();
            for (var i = 0;i<keys.length;i++) {
				header = keys[i];
				log.debug('response header [%s] = %s', header, headers[header]);
                xhr.responseHeaders[header] = headers[header];
            }
        }catch(e){
            log.error('failed to load response headers \n%s',e);
        }

        xhr.readyState = 4;
        xhr.status = parseInt(response.code,10) || undefined;
        xhr.statusText = response.message || "";
		log.info('%s %s %s %s', xhr.method, xhr.status, xhr.url, xhr.statusText);
        contentEncoding = xhr.getResponseHeader('content-encoding') || "utf-8";
        responseXML = null;
        
        try{
            //console.log('contentEncoding %s', contentEncoding);
            if( contentEncoding.toLowerCase() == "gzip" ||
                contentEncoding.toLowerCase() == "decompress"){
                //zipped content
                binary = true;
				//TODO
				log.debug('TODO: handle gzip compression');
                xhr.responseText = response.body;
            }else{
                //this is a text file
                xhr.responseText = response.body+'';
            }
        }catch(e){
            log.warn('failed to open connection stream \n%s, %s %s %s',
            	xhr.status, xhr.url, e.toString(), e
			);
        }
    }
    
    if(responseHandler){
        log.debug('calling ajax response handler');
        if(!xhr.async){
			log.debug('calling sync response handler directly');
			responseHandler();
		}else{
			log.debug('using setTimeout for async response handler');
			setTimeout(responseHandler, 1);
		}
    }
};

})(/*Envjs.XMLHttpRequest.Johnson*/);
/**
 * @author john resig & the envjs team
 * @uri http://www.envjs.com/
 * @copyright 2008-2010
 * @license MIT
 */
//CLOSURE_END
}());
