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
	let files: []str = [];
	let iter = match(getdiriter()) {
		case let i: *fs::iterator =>
		     yield i;
		case let err: fs::error =>
		     fmt::fatal("Error in opening current dir: {}", fs::strerror(err));
	};
	defer fs::finish(iter); // gestione memoria
	fmt::println("Directory corrente: {}", strings::dup(os::getcwd()))!;
	getfiles(iter, &files); // ottiene i files
	printslice(files);
	// write files to the ignore-file
};

fn getdiriter() (*fs::iterator | fs::error)= {
	let cwd = strings::dup(os::getcwd());
	return os::iter(cwd);
};

fn getfiles(iter: *fs::iterator, files: *[]str) void = {
	for(const d => fs::next(iter)!) {
		if(d.name == "." || d.name == "..") { continue; };
		if(fs::isdir(d.ftype)){ continue; };
		if(!isorg(d.name)){ continue; };
		if(!isproject(d.name)){
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

fn isproject(filename: str) bool = {
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
		   && strings::contains(line, "Progetti")) {
			found = true;
			break;
		};
	};
	return found;
};


fn printslice(lines: []str) void = {
	for (let line .. lines) {
		fmt::println(line)!;
	};
};
