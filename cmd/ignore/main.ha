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


// Loop over every single $entry in current dir:
//     if entry.name == "." || entry.name == "..": continue;
//     if entry.ftype isdir: continue;
//     if d.name has not org extension: continue;
//     now there are only .org files to check
//     if entry is not project:
//             append to files
fn getfiles(iter: *fs::iterator, files: *[]str) void = {
	for(const d => fs::next(iter)!) {
		if(d.name == "." || d.name == "..") { continue; };
		if(fs::isdir(d.ftype)){ continue; };
		if(!isorg(d.name)){ continue; };
		if(!isproject(fh)){
			append(*files, d.name);
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

};



fn printslice(lines: []str) void = {
	for (let line .. lines) {
		fmt::println(line)!;
	};
};
