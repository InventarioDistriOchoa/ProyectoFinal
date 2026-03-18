<?php
session_start();
session_destroy();
header('Location: index.php?cerrada=1');
exit();
?>
