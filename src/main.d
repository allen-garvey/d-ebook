import std.file, std.stdio, std.zip, std.regex, std.xml;
import std.path;
import converters.util;
import converters.epub;

int main(string[] args){
    if(args.length < 2){
        writeln("No filename given to convert");
        return 1;
    }
    string sourceFileName = args[1];
    if(!exists(sourceFileName)){
        writeln("File with name ", sourceFileName, " could not be found");
        return 1;
    }

    ZipArchive zip;
    try{
        zip = zip_archive_from_file(sourceFileName);
    }
    catch(Exception e){
        writeln("Problem unzipping ", sourceFileName);
        writeln(e.msg);
        return 1;
    }
    
    expand_zip_archive(zip);

    //Check that is epub
    if(!is_epub_archive(zip)){
        writeln("Source file mimetype is not of type epub");
        return 1;
    }

    if(is_epub_encrypted(zip)){
        writeln("Source epub file is encrypted- this utility only handles unencrypted files");
        return 1;
    }

    print_zip_archive(zip, sourceFileName);
    
    //writeln("Container:");
    //print_archive_member(zip, buildPath("META-INF", "container.xml"));
    writeln("OPF Contents");
    print_archive_member(zip, get_opf_filename(zip));
    //writeln(get_opf_filename(zip));
    return 0;
}