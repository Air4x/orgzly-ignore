use bufio;
use encoding::utf8;
use fmt;
use fs;
use io;
use os;
use strings;


// ottiene la lista dei file da ignorare e li inserisce in .orgzlyignore
// usage: ignore TAG IGNORE-FILE
export fn main() void = {
	
	// cli interface
	if(len(os::args) < 3) {
		print_usage();
		fmt::fatalf("Non enough args provided");
	};
	let tag = strings::dup(os::args[1]);
	let ignore_file = strings::dup(os::args[2]);
	let files: []str = [];
	let iter = match(getdiriter()) {
		case let i: *fs::iterator =>
		     yield i;
		case let err: fs::error =>
		     fmt::fatal("Error in opening current dir: {}", fs::strerror(err));
	};
	defer fs::finish(iter); // gestione memoria
	getfiles(iter, &files, tag); // ottiene i files
	printslice(files);
	// write files to the ignore-file
	write_to_ignore_file(ignore_file, files);
};

fn getdiriter() (*fs::iterator | fs::error)= {
	let cwd = strings::dup(os::getcwd());
	return os::iter(cwd);
};

fn getfiles(iter: *fs::iterator, files: *[]str, tag: str) void = {
	for(const d => fs::next(iter)!) {
		if(d.name == "." || d.name == "..") { continue; };
		if(fs::isdir(d.ftype)){ continue; };
		if(!isorg(d.name)){ continue; };
		if(!isproject(d.name, tag)){
			append(files, d.name);
		};
	};
};


fn isorg(filename: str) bool = {
	let s = strings::dup(filename);
	defer free(s);
	let parts = strings::split(s, ".");
	defer free(parts);
	return parts[len(parts)-1] == "org";
};

fn isproject(filename: str, tag: str) bool = {
	let fh = os::open(filename)!;
	defer io::close(fh)!;
	let found: bool = false;
	let line: str = "";
	for(true){
		line = match(bufio::read_line(fh)) {
			case io::EOF =>
			break;
			case let buf: []u8 =>
				yield strings::fromutf8(buf)!;
			case io::error =>
				os::exit(1);
		};
		if(strings::contains(line, "#+filetags:")
		   && strings::contains(line, tag)) {
			found = true;
			break;
		};
	};
	return found;
};



fn write_to_ignore_file(ignore_file: str, files: []str) void = {
	let fh = os::open(ignore_file, fs::flag::WRONLY)!;
	defer io::close(fh)!;
	let newline = strings::toutf8("\n");
	for(let file .. files) {
		io::write(fh, strings::toutf8(file))!;
		io::write(fh, newline)!;
	};
};



fn printslice(lines: []str) void = {
	for (let line .. lines) {
		fmt::println(line)!;
	};
};

fn print_usage() void = {
	fmt::println("USAGE: ignore TAG IGNORE_FILE")!;
	fmt::println("TAG\tTag to be searched in the #+filetags field")!;
	fmt::println("IGNORE_FILE\tFile to write all the non projects files")!;
};
