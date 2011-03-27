#!/usr/bin/php4 -q
<?php

require_once('fs.php');

$domain="lists.riseup.net";
$home="/home/sympa";
$inc = "$home/etc/inc";
$directory_file="$inc/directory";
$headerfile = "$inc/header";
$footerfile = "$inc/footer";
$doc_root="$home/etc/";

$lists = array(); // listname -> status, visibility, subscribe, subject, subscribers, traffic.
$listsbytopic = array();

$topicconf = file("$home/etc/topics.conf");
$topics = array(); // map name -> title
while(count($topicconf)) {
	$str = array_pop($topicconf);
	if (preg_match("/^title /",$str))
		$topics[trim(array_pop($topicconf))] = trim(substr($str,6));
}

$ls=split("\n",trim(`ls -1 $home/expl/`));
foreach($ls as $list) {
	$conf = "$home/expl/$list/config";
	#$list = basename(dirname($conf));
	if (!is_file($conf)) continue;
	$data = array('status'=>'open','visibility'=>'anyone','subscribe'=>'verified','subject'=>'no subject','topics'=>'');
	$strs = split("\n",trim(`grep "^status\|^visibility\|^subscribe\|^subject\|^topics" $conf`));
	foreach($strs as $str) {
		preg_match('/^(\w*)\s*(.*)$/',$str,$matches);
		$data[$matches[1]] = trim($matches[2]);
	}
	$data['topics'] = preg_split('/[\s,]/',$data['topics']);
	$lists[$list]=$data;
	foreach($data['topics'] as $topic) {
		$listsbytopic[$topic][$list] = &$lists[$list];
	}
}	

exit

//// build topic pages ///////

$header = "
<html>
  <link rel='stylesheet' type='text/css'  href='/style.css' />
  <title>lists.riseup.net</title>
</head>
<body>
";
$header .= file_get_contents($headerfile);
$footer = file_get_contents($footerfile);
$footer = str_replace("\n", "  ", $footer);
$footer = preg_replace("'<FORM.*</FORM>'m", "", $footer);
$footer .= "\n</body></html>";
foreach($listsbytopic as $topic => $lists) {
	$html=$header;
	$html .= "<div class=dirnav><a href='/www'>Lists</a> > <a href='/directory/$topic/'>$topics[$topic]</a></div>\n";
	foreach($lists as $list => $data) {
		if ($data['status']!='open' || $data['visibility']!='anyone') 
			continue;
		$html.="<div class=dirlist><a href='/www/info/$list'>$list</a> $data[subject]</div>\n";
	}
	$html .= $footer;
	if (!is_dir("$doc_root/directory/$topic/")) mkdir("$doc_root/directory/$topic/");
	$fs->put("$doc_root/directory/$topic/index.html", $html);
}

// build directory ///////////////////

unset($topics['xother']);
asort($topics);
$rows = count($topics)/2;
$html = "<table border='0' width='100%'><tr>\n";
$html .= "<td width='50%' NOWRAP valign=top>\n";
$i=0;
foreach($topics as $name => $title) {
	$html .= "<li><a HREF='/directory/$name/' class='topic'>$title (" . count($listsbytopic[$name]) . ")</a></li>\n";
	if ($i==$rows-1) {
		$html .= "</td><td width='50%' NOWRAP valign=top>\n";
	}
	$i++;
}
$html .= "</tr></table>\n";
$fs->put($directory_file,$html);
return;

?>
