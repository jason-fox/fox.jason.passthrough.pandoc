/*
 *  This file is part of the DITA Passthrough Plug-in project.
 *  See the accompanying LICENSE file for applicable licenses.
 */

//
//	Converts a value to relative path
//
//	@param  path -   The relative path of the file
//	@param  href -  The relative path of the image
//

var path = attributes.get("path");
var href = attributes.get("href");

var hrefElements = href.split('/');
var pathElements = path.split('/');
var fullPath = [];

for each (var elem in pathElements) {
	if (elem !== ''){
		fullPath.push(elem)
	}
}


for each (var elem in hrefElements) {
	if (elem === ''){
	} else if (elem === '..'){
		fullPath.pop()
	} else {
		fullPath.push(elem)
	}
}

project.setProperty(attributes.get("to"), fullPath.join('/'));