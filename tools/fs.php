<?php

/************

fs.php: file system related tools shell scripts written in php

*************/

define('FILE_APPEND', 1);

class fs {

function preg_match_file($pattern, $filename, &$matches) {
	ob_start();
	readfile($filename);
	$data = ob_get_contents();
	ob_end_clean();
	$status = preg_match($pattern,$data,$matches);
	return $status;
}

function write_map(&$array, $filename) {
	fs::write_array($array,$filename, true);
}

function read_map($filename, $strip=false) {
	$ret = fs::read_array($filename,true);
	if ($strip)
		$ret = array_map(create_function('$arg','return trim($arg,"\" \n");'),$ret); 
	return $ret;
}

function write_array(&$array, $filename, $writekeys=false) {
	$out = fopen($filename, 'w');
	if ($out === false) die("Could not open $filename\n");
	if ($writekeys) {
		foreach($array as $key => $value) {
			fwrite($out, "$key=$value\n");
		}
	}
	else {
		foreach($array as $value) {
		fwrite($out, "$value\n");
		}
	}
	fclose($out);
}
                                                    
function read_array($filename, $writekeys=false) {
	$data = file($filename);
	if (!$writekeys) {
		foreach($data as $i) {
			$array[] = trim($i);
		}
		return $array;
	}
	else {
		$array = array();
		foreach($data as $i) {
			list($key,$value) = explode('=',trim($i));
			$key = trim($key); $value = trim($value);
			if ($key != '' && $value != '')
				$array[$key] = $value;
		}
		return $array;
	}
	# remove comments
	$array = preg_replace('/^#.*$/', '', $array);
	return $array;
}
	
function preg_replace_file($search, $replace, $files) {
	if (!is_array($files)) $files = array($files);

	foreach($files as $file) {
		$data = file($file);
		$data = preg_replace($search, $replace, $data);
		$fp = fopen($file, 'w');
		fwrite($fp, join('', $data));
		fclose($fp);
	}
}

function put($filename, $content, $flags = 0) {
	$flag = ($flags & FILE_APPEND) ? 'a' : 'w';
	if ($flag == 'w' && file_exists($filename)) 
		unlink($filename); // in case immutable invert link
	if (!($file = fopen($filename, $flag)))
		return false;
	$n = fwrite($file, $content);
	fclose($file);
	return $n ? $n : false;
}

function append($filename, $content) {
	if (!($file = fopen($filename, 'a')))
		return false;
	$n = fwrite($file, $content);
	fclose($file);
	return $n ? $n : false;
}

} // end class

$fs = new fs();

?>