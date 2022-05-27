<?php

// POST-request:
//--------------
$url = 'https://rest.arbeitsagentur.de/oauth/gettoken_cc';
$data = array(
    'client_id' => '1c852184-1944-4a9e-a093-5cc078981294', 
    'client_secret' => '777f9915-9f0d-4982-9c33-07b5810a3e79', 
    'grant_type' => 'client_credentials');
$options = array(
    'http' => array(
        'method'  => 'POST',
        'content' => http_build_query($data)
    )
);
$context  = stream_context_create($options);
$tokendata = file_get_contents($url, false, $context);
header('Content-Type: application/json'); 
if(isset($_GET['token']) & $_GET['token']==='TRUE'){
	echo $tokendata;
} else {
    // GET-request:
    //-------------
    $url = 'https://rest.arbeitsagentur.de/infosysbub/absuche/pc/v1/ausbildungsangebot?'.$_SERVER['QUERY_STRING'];
    $options = array(
        'http' => array(
            'header'  => "OAuthAccessToken:".json_decode($tokendata, true)['access_token']." \r\n",
            'method'  => 'GET'    
        )
    );
    $context  = stream_context_create($options);
    $searchdata = file_get_contents($url, false, $context);
    echo $searchdata;
}
?>
