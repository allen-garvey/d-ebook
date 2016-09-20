module converters.util;

import std.file;
import std.zip;
import std.digest.crc;
import std.stdio;

//potentially throws exception if file doesn't exist
//or is not properly zip-encoded
ZipArchive zip_archive_from_file(string fileName){
    ZipArchive zip = new ZipArchive(read(fileName));
    return zip;
}

void expand_archive_member(ZipArchive zip, ref ArchiveMember am)
in{
	assert(am.expandedData.length == 0);
}
body{
    // decompress the archive member
    zip.expand(am);
    assert(am.expandedData.length == am.expandedSize);
}

string get_expanded_archive_member_contents(ArchiveMember am){
	return cast(string) am.expandedData;
}


//Expands all ArchiveMembers in ZipArchive
//and prints out file stats
void expand_zip_archive(ZipArchive zip){
    foreach(string fileName, ArchiveMember am; zip.directory){
        expand_archive_member(zip, am);
    }
}

//Prints out all the file names in zip archive
void print_zip_archive(ZipArchive zip, string sourceFileName){
	writeln("Archive: ", sourceFileName);
	writefln("%-10s  %-8s  Name", "Length", "CRC-32");

    foreach(string fileName, ArchiveMember am; zip.directory){
    	// print some data about each member
    	writefln("%10s  %08x  %s", am.expandedSize, am.crc32, fileName);
    }
}


bool is_file_in_archive(ZipArchive zip, string fileName){
	ArchiveMember[string] zipFileNames = zip.directory;
    return (fileName in zipFileNames) !is null;
}

//print ZipArchive ArchiveMember contents for debugging
void print_archive_member(ZipArchive zip, string fileName){
	ArchiveMember am = zip.directory[fileName];
    string fileContents = get_expanded_archive_member_contents(am);
    writeln(fileContents);
}






