/* Cases:
  // pathEndsWithExtension - do not modify
  url.com/index.html      -> url.com/index.html
  url.com/index.js        -> url.com/index.js
  url.com/index.css       -> url.com/index.css
  url.com/foo/index.html  -> url.com/foo/index.html
  url.com/foo/image.jpeg  -> url.com/foo/image.jpeg
  
  // pathEndsWithSlash - do not modify (cloudfront/s3 will take care of this)
  url.com/foo/            -> url.com/foo/

  // pathHasNoSlash - do not modify (cloudfront/s3 will take care of this)
  url.com                 -> url.com

  // else - append `/index.html`
  url.com/foo             -> url.com/foo/index.html
  */
 var modifyUri = uri => {
  console.log("uri", uri);

  var uriSplit = uri.split("/");
  var uriSplitLast = uriSplit[uriSplit.length - 1];
  // console.log("uriSplit", uriSplit);
  // console.log("uriSplitLast", uriSplitLast);


  //if only one item, the string did not contain a slash
  var pathHasNoSlash = uriSplit.length <= 1;
  // console.log("pathHasNoSlash", pathHasNoSlash);

  //if the last item is empty, the string ended with a slash
  var pathEndsWithSlash = uriSplitLast === "";
  // console.log("pathEndsWithSlash", pathEndsWithSlash);

  // if the last item ends with `.*`, the string ended with an extension
  var pathEndsWithExtension = /\..*/.test(uriSplitLast);
  // console.log("pathEndsWithExtension", pathEndsWithExtension);

  // if the path has no slash
  // or if the path ends with extension
  // or if the path ends with a slash
  //   do not modify
  if (pathHasNoSlash || pathEndsWithExtension || pathEndsWithSlash){
    return uri;
  }
  
  //otherwise, append `/index.html`
  uri = `${uri}/index.html`;
  return uri;
};


/* Test
var uris = [
	"url.com/index",
  "url.com/index.html",
  "url.com/index.js",
  "url.com/index.css",
  "url.com/foo/index.html",
  "url.com/foo/image.jpeg",
  "url.com/foo/",
  "url.com",
  "url.com/foo"
];

uris.forEach(uri => {
	var newUri = modifyUri(uri);
  console.log(`${uri} - ${newUri}`);
});
*/

function handler (event) {
  var request = event.request;
  var newUri = modifyUri(request.uri);

  console.log(`Modifying: ${request.uri} - ${newUri}`);
  
  request.uri = newUri;
  return request;
};