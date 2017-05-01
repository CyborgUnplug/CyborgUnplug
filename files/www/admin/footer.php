			<footer>
				<ul>
					<li><img src="/img/little-snipper-outline.svg" class="little-snipper"></li>
					<li>Little Snipper (world)</li>
					<li>ID: 0017A5EFB512</li>
					<li>Version: 12345678</li>
			</footer>
		</div>
	</body>
	<script src="/admin/js/zepto-1.2.0.min.js"></script>
	<script src="/admin/js/app.js"></script>
	<script>
	$(document).ready(function() {
		var status_data = localStorage.getItem('status_data')
		if (status_data) {
			updateStatus(JSON.parse(status_data))
		}

		var auto_refresh = setInterval(function() {
			$.getJSON('status.php', function(response) {
				console.log(response)
				localStorage.setItem('status_data', JSON.stringify(response))
				updateStatus(response)
			})
		}, 5000)
	})
	</script>
</html>
