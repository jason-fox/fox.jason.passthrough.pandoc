/*
 *  This file is part of the DITA Passthrough Plug-in project.
 *  See the accompanying LICENSE file for applicable licenses.
 */

//
//	Converts a value to relative path
//
//	@param  src -   The value to convert
//	@param  to -  The property to set
//

var src = attributes.get("src");
var temp = project.getProperty("args.input.dir")
var relative = src.replace(temp, '');

project.setProperty(attributes.get("to"), relative);