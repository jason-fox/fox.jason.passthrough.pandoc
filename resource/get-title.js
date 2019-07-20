/*
 *  This file is part of the DITA-OT Pandoc Plug-in project.
 *  See the accompanying LICENSE file for applicable licenses.
 */

//
//	Converts a file path into a document title
//
//	@param  path -   The filename to convert
//	@param  to -  The property to set
//
var name = attributes.get("path").replace(/_/g," ");

if(name.contains("/")) {
	name = name.substring(name.lastIndexOf("/") + 1, name.length());
	if(name.contains(".")) {
		name = name.substring(0, name.lastIndexOf("."));
	}
}

project.setProperty(
  attributes.get("to"),
  name
);