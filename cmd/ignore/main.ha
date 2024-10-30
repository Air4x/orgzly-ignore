use bufio;
use encoding::utf8;
use fmt;
use fs;
use io;
use os;
use strings;


// ottiene la lista dei file da ignorare e li inserisce in .orgzlyignore

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
	getfiles(iter, files); // ottiene i files
	printslice(files);
};

fn getdiriter() (*fs::iterator | fs::error)= {
	let cwd = strings::dup(os::getcwd());
	return os::iter(cwd);
};

// loop over every file:
//     open a file
//     read line
//     if line contains #+filetags:
//     then if line contains Progetti:
//          then nothing()
//     else add to file_to ignore

fn getfiles(iter: *fs::iterator, files: *[]str) void = {
	for(const d => fs::next(iter)!) {
		if(d.name == "." || d.name == "..") { continue; };
		if(fs::isdir(d.ftype)){ continue; };
		let fh = os::open(d.name)!;
		defer io::close(fh)!;
		if(!isproject(fh)){
			append(*files, d.name);
		};
	};
};


fn isproject(fh: io::handle) bool = {
	for(true) {
		let line = match(bufio::read_line(fh)) {
		case let l: []u8 =>
			yield strings::fromutf8(l)!;
		case io::EOF =>
				break;
		};
		let line = strings::fromutf8(line)!;
		if(strings::contains(line, "#+filetags:") && strings::contains(line, "Progetti")) {
			return true;
		};
	};
	return false;
};



fn printslice(lines: []str) void = {
	for (let line .. lines) {
		fmt::println(line)!;
	};
};
