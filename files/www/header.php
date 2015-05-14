<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8" />
	 <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">

	<title>Cyborg Unplug Configuration</title>
	<link rel="stylesheet" href="style.css"/>
	<script src="jquery-1.11.1.min.js"></script>
	<script> 
		var $checkboxes;
		function chooser() {         
		    var choices = $checkboxes.map(function() {
		        if(this.checked) return this.id;
		    }).get().join(' ');
		    document.getElementById("checkList").value = choices;
		}
		$(function() {
		    $checkboxes = $('input:checkbox').change(chooser);
	
			$('.navLink').on('click', function(e){
			    e.preventDefault();
			    var targetDiv = $($(this).attr('href'));
			    if(!targetDiv.is(':visible')){
			        $('.page').slideUp(100);
			        targetDiv.slideDown(100);
			    }
			    else{
			        $('.page').slideUp(0);
			    }
			});
		});
	</script>
</head>
<body>
	<div id="container">
		<img src="img/logo.png" alt="unplug" title="" width="510" height="166" id="logo" />