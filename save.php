<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $data = $_POST["location"] . "\n";
    file_put_contents("data.txt", $data, FILE_APPEND);
}
?>
