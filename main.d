import std.digest.crc, std.file, std.stdio, std.zip, std.regex, std.xml;

int main(string[] args){
    string fileName = args.length > 1 ? args[1] : "moby-dick.epub";

    ZipArchive zip;
    try{
        zip = new ZipArchive(read(fileName));
    }
    catch(Exception e){
        writeln("Problem opening ", fileName);
        writeln(e.msg);
        return 1;
    }
    writeln("Archive: ", fileName);
    writefln("%-10s  %-8s  Name", "Length", "CRC-32");

    //would be better to use mimetype - but will have to do for now
    auto xmlRegex = regex(r"\.xml$");

    foreach(string name, ArchiveMember am; zip.directory){
        // print some data about each member
        writefln("%10s  %08x  %s", am.expandedSize, am.crc32, name);
        assert(am.expandedData.length == 0);
        // decompress the archive member
        zip.expand(am);
        assert(am.expandedData.length == am.expandedSize);
        
        if(matchFirst(name, xmlRegex)){
            string rawXML = cast(string) am.expandedData;
            //writeln(rawXML);
        }
    }
    return 0;
}