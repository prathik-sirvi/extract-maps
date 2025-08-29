<?php

if ($argc !== 3) {

    echo "Enter source map file path: ";
    $mapFile = trim(fgets(STDIN));
  
    echo "Enter output folder path: ";
    $outputFolder = rtrim(trim(fgets(STDIN)), '/');

} else {

    $mapFile = $argv[1];

    $outputFolder = rtrim($argv[2], '/');

}

if (file_exists($mapFile)) {

    $json = json_decode(file_get_contents($mapFile));
    $files = [];

    foreach ($json->sources as $index => $source) {

        $dir = dirname($outputFolder . '/' . $source);

        if (!is_dir($dir)) {

            mkdir($dir, 0755, true);

        }
      
        $data = explode('/', $source);
        $filename = end($data);
        file_put_contents($dir . '/' . $filename, $json->sourcesContent[$index]);
        $files[] = $dir . '/' . $filename;

    }

    echo "<pre>All Source codes have been extracted from map file:\n";

    print_r($files);

} else {

    echo "Error: File '{$mapFile}' not found.\n";

}

