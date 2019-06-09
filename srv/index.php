<!DOCTYPE html>
<html>
<head>
<title>Caddy</title>
<style>
    body {
        text-align: center;
        font-family: Tahoma, Geneva, Verdana, sans-serif;
    }
</style>
</head>
<body>
<h1>Caddy web server.</h1>
<p>If you see this page, Caddy container works.</p>

<p>More instructions about this image is <a href="//github.com/DeftWork/caddy-docker" target="_blank">here</a>.<p>
<p>More instructions about Caddy is <a href="//caddyserver.com/docs" target="_blank">here</a>.<p>
<?php
// Muestra toda la información, por defecto INFO_ALL
phpinfo();
// Muestra solamente la información de los módulos.
// phpinfo(8) hace exactamente lo mismo.
phpinfo(INFO_MODULES);
?>
</body>
</html>