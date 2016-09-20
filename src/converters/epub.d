module converters.epub;

import std.digest.crc, std.file, std.stdio, std.zip, std.regex, std.xml;
import std.path;
import converters.util;

bool epub_to_mobi(ZipArchive zip){



	return true;
}

//looks for mimetype "application/epub+zip"
//All ArchiveMembers in ZipArchive should already be expanded
bool is_epub_archive(ZipArchive zip){
    if(!is_file_in_archive(zip, "mimetype")){
    	return false;
    }
    ArchiveMember mimetypeFileArchive = zip.directory["mimetype"];
    string fileContents = get_expanded_archive_member_contents(mimetypeFileArchive);
    //remove blank lines and whitespace
    auto whiteSpaceRegex = regex(r"\s", "g");
    fileContents = replaceAll(fileContents, whiteSpaceRegex, "");
    auto mimetypeRegex = regex(r"^\s*application/epub\+zip\s*$");
    if(!matchFirst(fileContents, mimetypeRegex)){
        return false;
    }

    return true;
}

//returns whether epub is encrypted
bool is_epub_encrypted(ZipArchive zip){
	return is_file_in_archive(zip, buildPath("META-INF", "encryption.xml"));
}

//returns filename of file with Epub Open Packaging Format Metadata
//by extracting <rootfile full-path=""> from META-INF/container.xml
string get_opf_filename(ZipArchive zip){
	string containerPath = buildPath("META-INF", "container.xml");
	assert(is_file_in_archive(zip, containerPath));
	string containerXmlString = get_expanded_archive_member_contents(zip.directory[containerPath]);

	//check for xml well-formedness
	check(containerXmlString);
	auto xml = new DocumentParser(containerXmlString);

	string opfPath = "";
	xml.onStartTag["rootfile"] = (ElementParser xml){
		 if(xml.tag.attr["media-type"] == "application/oebps-package+xml" && "full-path" in xml.tag.attr){
		 	opfPath = buildNormalizedPath(xml.tag.attr["full-path"]);
		 }
		 //xml.parse(); //self-closing tag, so no need to parse
	};
	xml.parse();

	return opfPath;
}









