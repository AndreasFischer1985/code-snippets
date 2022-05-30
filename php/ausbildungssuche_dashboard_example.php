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
if(isset($_GET['type']) & $_GET['type']==='token'){
    header('Content-Type: application/json'); 
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
    if(isset($_GET['type']) & $_GET['type']==='search'){
        header('Content-Type: application/json'); 
        echo $searchdata;
    } else if(!isset($_GET['type'])|(isset($_GET['type']) & $_GET['type']==='html')) {

        // HTML-response:
        //---------------
        header('Content-Type: text/html'); 
        echo "
            <html>
            <script src='https://cdn.jsdelivr.net/npm/chart.js/dist/chart.min.js'></script>
            <body style='background-color:black;'>
            <h1 style='color:white'>Dashboard Ausbildungssuche ".htmlspecialchars($_SERVER['QUERY_STRING'])."</h1>
            <h2 style='color:white'>".date("l jS \of F Y h:i:s A")."</h2>	        
            <div style='width:300; height:300; display: background-color: black;'>
	        <canvas id='myChart' style='max-width:100%; max-height:100%;'></canvas>
	        </div>
            <script>

                // Doughnut-Chart with text in center
                //-----------------------------------

                Chart.defaults.font.size = 8;
                var ctx = document.getElementById('myChart').getContext('2d');
                const myChart = new Chart(ctx, {
                    type: 'doughnut',
                    plugins: [{
                        beforeDraw: function(chart) {
                            if (chart.config.options.elements.center) {
                                var ctx = chart.ctx;
                                var centerConfig = chart.config.options.elements.center;
                                var fontStyle = centerConfig.fontStyle || 'Arial';
                                var txt = centerConfig.text;
                                var color = centerConfig.color || '#000';
                                var maxFontSize = centerConfig.maxFontSize || 75;
                                var sidePadding = centerConfig.sidePadding || 20;
                                var sidePaddingCalculated = (sidePadding / 100) * (chart._metasets[chart._metasets.length-1].data[0].innerRadius * 2)
                                ctx.font = '30px ' + fontStyle;
                                var stringWidth = ctx.measureText(txt).width;
                                var elementWidth = (chart._metasets[chart._metasets.length-1].data[0].innerRadius * 2) - sidePaddingCalculated;            
                                var widthRatio = elementWidth / stringWidth;
                                var newFontSize = Math.floor(30 * widthRatio);
                                var elementHeight = (chart._metasets[chart._metasets.length-1].data[0].innerRadius * 2);
                                var fontSizeToUse = Math.min(newFontSize, elementHeight, maxFontSize);
                                var minFontSize = centerConfig.minFontSize;
                                var lineHeight = centerConfig.lineHeight || 25;
                                var wrapText = false;
                                if (minFontSize === undefined) {
                                    minFontSize = 20;
                                }
                                if (minFontSize && fontSizeToUse < minFontSize) {
                                    fontSizeToUse = minFontSize;
                                    wrapText = true;
                                }
                                ctx.textAlign = 'center';
                                ctx.textBaseline = 'middle';
                                var centerX = ((chart.chartArea.left + chart.chartArea.right) / 2);
                                var centerY = ((chart.chartArea.top + chart.chartArea.bottom) / 2);
                                ctx.font = fontSizeToUse + 'px ' + fontStyle;
                                ctx.fillStyle = color;
                                if (!wrapText) {
                                    ctx.fillText(txt, centerX, centerY);
                                    return;
                                }
                                var words = txt.split(' ');
                                var line = '';
                                var lines = [];
                                for (var n = 0; n < words.length; n++) {
                                    var testLine = line + words[n] + ' ';
                                    var metrics = ctx.measureText(testLine);
                                    var testWidth = metrics.width;
                                    if (testWidth > elementWidth && n > 0) {
                                        lines.push(line);
                                        line = words[n] + ' ';
                                    } else {
                                        line = testLine;
                                    }
                                }
                                centerY -= (lines.length / 2) * lineHeight;
                                for (var n = 0; n < lines.length; n++) {
                                    ctx.fillText(lines[n], centerX, centerY);
                                    centerY += lineHeight;
                                }
                                ctx.fillText(line, centerX, centerY);
                            }
                        }
                    }],
                    data: {
                        labels: ['BAY', 'BAW', 'BER', 'BRA', 'BRE', 'HAM','HES','MBV','NDS','NRW','RPF','SAA','SAC','SAN','SLH','THÜ'],
                        datasets: [{
                            label: '# of Votes',
                            data: ["
                                .json_decode($searchdata, true)['aggregations']['REGIONEN']['BAY'].","
                                .json_decode($searchdata, true)['aggregations']['REGIONEN']['BAW'].","
                                .json_decode($searchdata, true)['aggregations']['REGIONEN']['BER'].","
                                .json_decode($searchdata, true)['aggregations']['REGIONEN']['BRA'].","
                                .json_decode($searchdata, true)['aggregations']['REGIONEN']['BRE'].","
                                .json_decode($searchdata, true)['aggregations']['REGIONEN']['HAM'].","
                                .json_decode($searchdata, true)['aggregations']['REGIONEN']['HES'].","
                                .json_decode($searchdata, true)['aggregations']['REGIONEN']['MBV'].","
                                .json_decode($searchdata, true)['aggregations']['REGIONEN']['NDS'].","
                                .json_decode($searchdata, true)['aggregations']['REGIONEN']['NRW'].","
                                .json_decode($searchdata, true)['aggregations']['REGIONEN']['RPF'].","
                                .json_decode($searchdata, true)['aggregations']['REGIONEN']['SAA'].","
                                .json_decode($searchdata, true)['aggregations']['REGIONEN']['SAC'].","
                                .json_decode($searchdata, true)['aggregations']['REGIONEN']['SAN'].","
                                .json_decode($searchdata, true)['aggregations']['REGIONEN']['SLH'].","
                                .json_decode($searchdata, true)['aggregations']['REGIONEN']['THÜ']."],"
                            ."backgroundColor: [
                                'rgba(255,   0,   0, 0.6)',
                                'rgba(255,  96,   0, 0.6)',
                                'rgba(255, 191,   0, 0.6)',
                                'rgba(233, 255,   0, 0.6)',
                                'rgba(128, 255,   0, 0.6)',
                                'rgba( 32, 255,   0, 0.6)',
                                'rgba(  0, 255,  64, 0.6)',
                                'rgba(  0, 255, 159, 0.6)',
                                'rgba(  0, 255, 255, 0.6)',
                                'rgba(  0, 159, 255, 0.6)',
                                'rgba(  0,  64, 255, 0.6)',
                                'rgba( 32,   0, 255, 0.6)',
                                'rgba(128,   0, 255, 0.6)',
                                'rgba(223,   0, 255, 0.6)',
                                'rgba(225,   0, 191, 0.6)',
                                'rgba(255,   0,  96, 0.6)'
                            ],
                            borderColor: [
                                'rgba(255,   0,   0, 1.0)',
                                'rgba(255,  96,   0, 1.0)',
                                'rgba(255, 191,   0, 1.0)',
                                'rgba(233, 255,   0, 1.0)',
                                'rgba(128, 255,   0, 1.0)',
                                'rgba( 32, 255,   0, 1.0)',
                                'rgba(  0, 255,  64, 1.0)',
                                'rgba(  0, 255, 159, 1.0)',
                                'rgba(  0, 255, 255, 1.0)',
                                'rgba(  0, 159, 255, 1.0)',
                                'rgba(  0,  64, 255, 1.0)',
                                'rgba( 32,   0, 255, 1.0)',
                                'rgba(128,   0, 255, 1.0)',
                                'rgba(223,   0, 255, 1.0)',
                                'rgba(225,   0, 191, 1.0)',
                                'rgba(255,   0,  96, 1.0)'                            ],
                            borderWidth: 1
                        }]
                    },
                    options: {
                        responsive: true,
    	                plugins:{
		                    legend: { display: true, position: 'right', labels: {boxWidth:2} }
	                    },
                        elements: {
                            center: {
                                text: '".json_decode($searchdata, true)['aggregations']['ANZAHL_GESAMT']['COUNT']."',
                                color: '#FF6384', 
                                fontStyle: 'Arial', 
                                sidePadding: 20, // 20 percent 
                                minFontSize: 1, // px
                                lineHeight: 25 // px
                            }
                        }
                    }
                    });

            </script>
            </body>
            </html>
        ";
    }

}
?>


