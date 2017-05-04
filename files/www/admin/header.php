<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
	<title><?php if ($page_title) { echo $page_title . " - Little Snipper"; } else { ?>Little Snipper by Cyborg Unplug<?php } ?></title>
	<link rel="stylesheet" href="/css/base.css">
	<link rel="stylesheet" href="/css/style.css">
	<link rel="stylesheet" href="/css/flags.min.css">
    <link type="image/ico" rel="icon" href="/img/little-snipper-36.png">
	<link rel="manifest" href="/manifest.json">
</head>
<body>
	<div id="container">
		<header id="header">
			<a href="index.php" id="logo">
				<img src="/img/logo.png" alt="Cyborg Unplug">
			</a>
			<div id="header-buttons">
				<form action="index.php" id="home">
					<button name="home" type="submit" value="home">
						<i class="icon-home"></i>
						Home
					</button>
				</form>
				<form method="get" action="/admin/wifi.php">
					<button type="submit" id="your-wifi" class="wifi-off">
						<i class="icon-wifi-off"></i>
						<span>Unavailable</span>
					</button>
				</form>
				<form method="get" action="/admin/cgi-bin/config.cgi">
					<button name="reboot" type="submit" value="reboot">
						<i class="icon-reboot"></i>
						Reboot
					</button>
				</form>
				<form action="/admin/configure.php">
					<button name="configure" type="submit" value="settings">
						<i class="icon-settings"></i>
						Settings
					</button>
				</form>
			</div>
			<div class="clearfix"></div>
			<div id="status-bar">
				<div id="status">
					<div id="status-type" class="status-section">
						<span id="status_icon" class="waiting">
							<i class="icon-connecting"></i>
						</span>
						<span id="status_message">
							Getting network status...
						</span>
					</div>
					<div id="status-route" class="status-section">
						<span class="flag"></span>
						<span class="country"></span>
					</div>
				</div>
			</div>
		</header>
