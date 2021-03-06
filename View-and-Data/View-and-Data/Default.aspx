﻿<%@ Page Title="Home Page" Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="View_and_Data._Default" %>

<html lang="en">
<head>
    <title>ADN Sample</title>
    <meta charset="utf-8">
    <link rel="stylesheet" href="https://developer.api.autodesk.com/viewingservice/v1/viewers/style.css?v=v1.2.17" type="text/css">
    <link rel="stylesheet" href="View-and-Data/jquery-ui.css">
    <style>
        .jquery-ui-accordion
        {
            border-style: none;
            background: #383838;
            background: #5d5d5d
        }
        .jquery-ui-accordion-title
        {
            border-style:outset;
            height: 15px;
            color: #ffffff;
            border-radius: 3px;
            background: #5d5d5d
        }
        .jquery-ui-accordion-contents
        {
            border-style: none;
            background: #383838
        }
        .jquery-ui-buttons
        {
            height: 30px;
            color: #ffffff;
            border-radius: 5px
        }
        .text-buttons
        {
            width: 100px;
            height: 30px;
            border-radius: 5px
        }
        .text-boxs
        {
            border-radius:3px
        }
        .canvas-areas
        {
            border-color: #f0f0f0;
            color: #f0f0f0;
            background: #5d5d5d;
            border-radius: 5px;
            background-color: #5d5d5d
        }
    </style>
    <script type="text/javascript" src="Credentials.js"></script>
    <script type="text/javascript" src="View-and-Data/jquery-1.11.1.min.js"></script>
    <script type="text/javascript" src="View-and-Data/jquery-ui.min.js"></script>
    <script type="text/javascript" src="https://developer.api.autodesk.com/viewingservice/v1/viewers/viewer3D.min.js?v=v1.2.17"></script>
    <script type="text/javascript" src="https://raw.githubusercontent.com/Developer-Autodesk/library-javascript-view-and-data-toolkit/master/dist/js/view-and-data-client-v1.js"></script>
    <script type="text/javascript" src="http://ecn.dev.virtualearth.net/mapcontrol/mapcontrol.ashx?v=7.0&mkt=en-US"></script>
    <script>
        var _viewer = null;
        var _myView = null;
        var _files = [];
        var _map;
        var _pushPin = null;
        var _urn;
        var _bucket;
        var _viewDataClient;

        // Launch viewer from paramters
        function initializeViewer() {
            var urn = Autodesk.Viewing.Private.getParameterByName("urn");
            var accessToken = Autodesk.Viewing.Private.getParameterByName("accessToken");
            if (accessToken == "") {
                $("#jquery-ui-accordion").accordion("option", "active", 0);
                getMap();
                return;
            } else {
                $("#jquery-ui-accordion").accordion("option", "active", 2);
            }

            var options = {};
            options.env = "AutodeskProduction";
            options.accessToken = accessToken;
            options.document = "urn:" + urn;

            var viewerElement = document.getElementById('viewer3d');
            //_viewer = new Autodesk.Viewing.Viewer3D(viewerElement, {});  // No Navigation control & Environment Light(need _viewer.impl.setLightPreset(1);)
            _viewer = new Autodesk.Viewing.Private.GuiViewer3D(viewerElement, {});
            Autodesk.Viewing.Initializer(options, function () {
                _viewer.initialize();
                _viewer.impl.setLightPreset(0);
                loadDocument(_viewer, options.document);
                _viewer.addEventListener(Autodesk.Viewing.SELECTION_CHANGED_EVENT, onSelected);
            });
        }

        // Launch viewer from Bing Maps
        function initializeViewerFromMap(urn, accessToken) {

            $("#jquery-ui-accordion").accordion("option", "active", 2);

            var itemList = document.getElementById("message");
            for (var index = itemList.length - 1; index >= 0; index--) {
                itemList[index].remove();
            }
            var textbox = document.getElementById("search");
            textbox.textContent = "";

            var options = {};
            options.env = "AutodeskProduction";
            options.accessToken = accessToken;
            options.document = "urn:" + urn;

            var viewerElement = document.getElementById('viewer3d');
            //_viewer = new Autodesk.Viewing.Viewer3D(viewerElement, {});  // No Navigation control & Environment Light(need _viewer.impl.setLightPreset(1);)
            _viewer = new Autodesk.Viewing.Private.GuiViewer3D(viewerElement, {}); // With default UI

            Autodesk.Viewing.Initializer(options, function () {
                _viewer.initialize();
                //_viewer.impl.setLightPreset(0);
                loadDocument(_viewer, options.document);
                _viewer.addEventListener(Autodesk.Viewing.SELECTION_CHANGED_EVENT, onSelected);
            });

        }

        // Load viewable
        function loadDocument(viewer, documentId) {
            // Find the first 3d geometry and load that.
            Autodesk.Viewing.Document.load(documentId, function (doc) {// onLoadCallback
                var geometryItems = [];
                if (geometryItems.length == 0) {
                    geometryItems = Autodesk.Viewing.Document.getSubItemsWithProperties(doc.getRootItem(), {
                        'type': 'geometry',
                        'role': '3d'
                    }, true);
                }
                if (geometryItems.length > 0) {
                    viewer.load(doc.getViewablePath(geometryItems[0]));
                }
            }, function (errorMsg) {// onErrorCallback
                console.log("Load Error: " + errorMsg);
            });
        }

        // Reset
        function action_reset() {
            _viewer.showAll();
            _viewer.setViewFromFile();
            var itemList = document.getElementById("message");
            for (var index = itemList.length - 1; index >= 0; index--) {
                itemList[index].remove();
            }
            var search = document.getElementById("search");
            search.value = "";
        }

        // Zoom In
        function action_zoomin() {
            _viewer.canvas.focus();
            console.log(_viewer.getActiveNavigationTool());
            _viewer.setActiveNavigationTool("dolly");
            var step = document.getElementById('step').value * -1.0;
            var cam = _viewer.getCamera();
            cam.translateX(0);
            cam.translateY(0);
            cam.translateZ(step);
            _viewer.impl.syncCamera();
            _viewer.setActiveNavigationTool("orbit");
        }

        // ↓ Zoom Out
        function action_zoomout() {
            _viewer.canvas.focus();
            _viewer.setActiveNavigationTool("dolly");
            var step = document.getElementById('step').value;
            var cam = _viewer.getCamera();
            cam.translateX(0);
            cam.translateY(0);
            cam.translateZ(step);
            _viewer.impl.syncCamera();
            _viewer.setActiveNavigationTool("orbit");
        }

        // Turn Right
        function action_turnright() {
            _viewer.canvas.focus();
            _viewer.setActiveNavigationTool("orbit");
            var step = document.getElementById('step').value * -1.0;
            var cam = _viewer.getCamera();
            cam.translateX(step);
            cam.translateY(0);
            cam.translateZ(0);
            _viewer.impl.syncCamera();
        }

        // Turn Left
        function action_turnleft() {
            _viewer.canvas.focus();
            _viewer.setActiveNavigationTool("orbit");
            var step = document.getElementById('step').value;
            var cam = _viewer.getCamera();
            cam.translateX(step);
            cam.translateY(0);
            cam.translateZ(0);
            _viewer.impl.syncCamera();
        }

        // Register View
        function action_register() {
            _myView = _viewer.getState();
        }

        // Restore View
        function action_restore() {
            _viewer.restoreState(_myView);
        }

        // Search
        function action_search() {
            var search = document.getElementById("search").value;
            _viewer.search(search, onSearchResult);
        }

        // Search callback
        function onSearchResult(idArray) {
            _viewer.isolateById(idArray);
        }

        // Selection callback
        function onSelected(event) {
            var dbIdArray = event.dbIdArray;
            if (dbIdArray.length > 0) {
                for (i = 0; i < dbIdArray.length; i++) {
                    var node = dbIdArray[i];
                    if (node != null) {
                        _viewer.getProperties(node, onGetPropsSuccess, onGetPropsError);
                    }
                }
            }
        }
        function onGetPropsSuccess(result) {
            // Clear listbox
            var itemList = document.getElementById("message");
            for (var index = itemList.length - 1; index >= 0; index--) {
                itemList[index].remove();
            }

            // Display properties
            for (var index = 0; index < result.properties.length; index++) {
                var prop = result.properties[index];
                var data = prop.displayName + ":" + prop.displayValue;
                itemList.add(new Option(data, data));
            }
        }
        function onGetPropsError(result) {
            var itemList = document.getElementById("message");
            var obj = itemList.add(new Option("Error", "Error"));
        }

        // File dialog
        function action_file_dialog() {
            var file = $("#upload")[0].files[0];
            if (file) {
                var fileName = file.name;
                var fileSize = file.size;
                var fileType = file.type;
                console.log('File Name : ' + fileName + '\nFile Size : ' + fileSize + ' bytes\nFile Type : ' + fileType);
            }
        }
        $(document).on("click", "[id^='jquery-ui-button-upload']", function () {
            var filedialog = document.getElementById('upload');
            filedialog.addEventListener("change", function (event) {
                _files = event.target.files;
                fileUpload();
            }, false);
            filedialog.click();
        });

        // Drop
        function onDrop(event) {
            _files = event.dataTransfer.files;
            if (_files.length > 1) {
                console.log('File must be one');
            } else {
                var fileName = _files[0].name;
                var fileSize = _files[0].size;
                var fileType = _files[0].type;
                console.log('File Name : ' + fileName + '\nFile Size : ' + fileSize + ' bytes\nFile Type : ' + fileType);
            }
            $('#droparea').css('background-color', '#5d5d5d');
            $('#progress').css('background-color', '#5d5d5d');
            event.preventDefault();
            fileUpload();
        }

        // Drag over
        function onDragOver(event) {
            $('#droparea').css('background-color', '#ff0000');
            $('#progress').css('background-color', '#ff0000');
            event.preventDefault();
        }

        // Drag leave
        function onDragLeave(event) {
            $('#droparea').css('background-color', '#5d5d5d');
            $('#progress').css('background-color', '#5d5d5d');
            event.preventDefault();
        }

        // File selection callback
        function onFileSelection(event) {
            alert(event.target.nativePath);
        }

        // jQuery UI button icons
        jQuery(function () {

            jQuery('#jquery-ui-accordion').accordion(
                {
                    //active: 2,
                    heightStyle: 'content',
                    icons: {
                        'header': 'ui-icon-plusthick',
                        'activeHeader': 'ui-icon-minusthick',
                    },
                }
            );

            jQuery('#jquery-ui-button-zoomin').button({
                icons: {
                    primary: 'ui-icon-carat-1-n',
                },
                text: false
            });

            jQuery('#jquery-ui-button-zoomout').button(
            {
                icons: {
                    primary: 'ui-icon-carat-1-s',
                },
                text: false
            });

            jQuery('#jquery-ui-button-turnright').button(
            {
                icons: {
                    primary: 'ui-icon-carat-1-e',
                },
                text: false
            });

            jQuery('#jquery-ui-button-turnleft').button(
            {
                icons: {
                    primary: 'ui-icon-carat-1-w',
                },
                text: false
            });

            jQuery('#jquery-ui-button-upload').button(
            {
                icons: {
                    primary: 'ui-icon-document',
                },
                text: false
            });

            jQuery('#jquery-ui-button-search').button(
            {
                icons: {
                    primary: 'ui-icon-search',
                },
                text: false
            });

            jQuery('#jquery-ui-button-map-search').button(
            {
                icons: {
                    primary: 'ui-icon-search',
                },
                text: false
            });
        });

        // Single file upload
        function fileUpload() {
            $("#progress").progressbar("option", "value", false);

            var token = getToken();
            if (token === '') {
                console.log('Access Token cannot be empty');
                console.log('Exiting ...');
                return;
            }

            var date = new Date();
            //var bucket = _bucket_prefix + "-" + date.getTime();
            var bucket = _bucket_prefix + "-" + _bing_maps_credential.toLowerCase();
            if (bucket === '') {
                console.log('Bucket name cannot be empty');
                console.log('Exiting ...');
                return;
            }

            if (_files.length === 0) {
                console.log('No file to upload');
                console.log('Exiting ...');
                return;
            }

            _viewDataClient = new Autodesk.ADN.Toolkit.ViewAndData.Client('https://developer.api.autodesk.com', 'GetAccessToken.ashx');
            _viewDataClient.onInitialized(function () {

                //… start using the client …
                _viewDataClient.getBucketDetails(
                    bucket,

                    //onSuccess
                    function (bucketResponse) {
                        console.log('Bucket details successful:');
                        console.log(bucketResponse);
                        uploadFiles(bucket, _files, token);
                    },

                    //onError
                    function (error) {
                        console.log("Bucket doesn't exist");
                        console.log("Attempting to create...");
                        createBucket(bucket, token);
                    });

            });
        }

        // Create bucket
        function createBucket(bucket, accessToken) {
            var bucketCreationData = {
                bucketKey: bucket,
                policyKey: 'transient',
                policy: 'transient'
            }

            _viewDataClient.createBucket(
                bucketCreationData,

                //onSuccess
                function (response) {
                    console.log('Bucket creation successful:');
                    console.log(response);
                    uploadFiles(bucket, _files, accessToken);
                },

                //onError
                function (error) {
                    console.log('Bucket creation failed:');
                    console.log(error);
                    console.log('Exiting ...');
                    return;
                });
        }

        // Files upload
        function uploadFiles(bucket, files, accessToken) {
            for (var i = 0; i < files.length; ++i) {
                var file = files[i];
                console.log('Uploading file: ' + file.name + ' ...');
                _viewDataClient.uploadFile(
                    file,
                    bucket,
                    file.name,

                    //onSuccess
                    function (response) {
                        console.log('File upload successful:');
                        console.log(response);
                        var fileId = response.objectId;
                        _viewDataClient.register(fileId,
                            function (registerResponse) {

                                console.log(registerResponse);

                                if (registerResponse.Result === "Success" || registerResponse.Result === "Created") {

                                    console.log("Registration result: " + registerResponse.Result);
                                    console.log('Starting translation: ' + fileId);

                                    checkTranslationStatus(
                                            fileId,
                                            1000 * 60 * 5, //5 mins timeout

                                            //onSuccess
                                            function (viewable) {
                                                console.log("Translation successful: " + response.file.name);
                                                console.log("Viewable: ");
                                                console.log(viewable);
                                                var fileId = _viewDataClient.fromBase64(viewable.urn);
                                                $("#progress").progressbar("option", "value", 0);
                                                if (_viewer) {
                                                    _viewer.uninitialize();
                                                    _viewer = null;
                                                }
                                                initializeViewerFromMap(viewable.urn, accessToken);
                                                addThumbnail(fileId, response.file.name, bucket, viewable.urn);
                                            });

                                }

                            });
                    },

                    //onError
                    function (error) {
                        $("#progress").progressbar("option", "value", 0);
                        console.log('File upload failed:');
                        console.log(error);
                    });
            }
            files = [];
        }

        // Transration state check
        function checkTranslationStatus(fileId, timeout, onSuccess) {
            var startTime = new Date().getTime();
            var timer = setInterval(function () {
                var dt = (new Date().getTime() - startTime) / timeout;
                if (dt >= 1.0) {
                    clearInterval(timer);
                } else {
                    _viewDataClient.getViewable(
                        fileId,
                        function (response) {
                            console.log('Translation Progess ' + fileId + ': ' + response.progress);
                            if (response.progress === 'complete') {
                                clearInterval(timer);
                                onSuccess(response);
                            }
                        },
                        function (error) {
                            $("#progress").progressbar("option", "value", 0);
                            console.log('Translation error : ');
                            console.log(error);
                        });
                }
            }, 2000);
        };

        // Thumbnail & floating info element set
        function addThumbnail(fileId, name, bucket, urn) {
            var parentNode = document.getElementById('thumbnail');
            var childNode = document.getElementById('generated_image');
            if (childNode) {
                parentNode.removeChild(childNode);
            }
            var img = document.createElement('img');
            img.id = "generated_image";
            img.width = 128;
            img.height = 128;
            parentNode.appendChild(img);

            _viewDataClient.getThumbnail(
               fileId,
               function (data) {
                   img.src = "data:image/png;base64," + data;

                   _bucket = bucket;
                   _urn = urn;
                   _map.entities.clear();
                   var location = _pushPin.getLocation();
                   var infobox = new Microsoft.Maps.Infobox(_pushPin.getLocation(), {
                       title: name,
                       width: 200,
                       height: 70
                   });
                   infobox.setOptions({
                       visible: true,
                       location: _pushPin.location,
                       actions: [{ label: 'View 3D Model', eventHandler: onViewModel }]
                   });

                   Microsoft.Maps.Events.addHandler(infobox, 'mouseenter', function () {
                       var point = _map.tryLocationToPixel(_pushPin.getLocation(), Microsoft.Maps.PixelReference.page);
                       var location = _map.tryPixelToLocation(point);
                       var image = document.getElementById("thumbnail");

                       var latitude = document.getElementById("latitude");
                       latitude.textContent = "Latitude:\n" + getRound10(location.latitude);

                       var longitude = document.getElementById("longitude");
                       longitude.textContent = "Longitude:\n" + getRound10(location.longitude);

                       var info = document.getElementById("pininfo");
                       info.style.top = point.y - 50 + "px";
                       info.style.left = point.x - 100 + "px";
                       info.style.display = "block";
                   });

                   Microsoft.Maps.Events.addHandler(infobox, 'mouseleave', function () {
                       var info = document.getElementById("pininfo");
                       info.style.display = "none";
                   });

                   _map.entities.push(infobox);
               },
               function (error) {
                   console.log('Error getting thumbnail for ' + fileId + ': ' + error);
               });
        };

        // Reload viewer
        function onViewModel() {
            $("#jquery-ui-accordion").accordion("option", "active", 2);
            var token = getToken();
            initializeViewerFromMap(_urn, token);
        }

        // Reset prpgress bar
        $(function () {
            $("#progress").progressbar({
                value: 0
            });
        });

        // Test getting token
        function action_test() {
            var accessToken = getToken();
            alert(accessToken);
        }

        // Get token
        function getToken() {
            var newToken;
            var xmlHttp = null;
            xmlHttp = new XMLHttpRequest();
            xmlHttp.open("GET", "GetAccessToken.ashx", false);
            xmlHttp.send(null);
            var data = xmlHttp.responseText;
            var newToken = JSON.parse(data).access_token;
            return newToken;
        }

        // Round value
        function getRound10(value) {
            var newValue;
            newValue = value * 1000000000;
            newValue = Math.round(newValue);
            newValue = newValue / 1000000000;
            return newValue;
        }

        // Get Bing Maps
        function getMap() {

            // Get your own credentials at https://www.bingmapsportal.com/
            var options = {
                credentials: _bing_maps_credential,
                mapTypeId: Microsoft.Maps.MapTypeId.road,
                center: new Microsoft.Maps.Location(37.0, -100.0),
                zoom: 2,
                enableSearchLogo: false,
                enableClickableLogo: false
            }

            _map = new Microsoft.Maps.Map(document.getElementById("maparea"), options);

            var location;
            Microsoft.Maps.Events.addHandler(_map, "mousedown", function (event) {
                if (event.isSecondary) {
                    event.handled = true;

                    _map.entities.clear();

                    var point = new Microsoft.Maps.Point(event.getX(), event.getY());
                    location = _map.tryPixelToLocation(point);

                    _pushPin = new Microsoft.Maps.Pushpin(location, { text: '!' });

                    Microsoft.Maps.Events.addHandler(_pushPin, "click", function (event) {
                        $("#jquery-ui-accordion").accordion("option", "active", 1);
                    });

                    _map.entities.push(_pushPin);
                }
            });

        }

        // Address Search on Bing Maps
        function action_map_search() {
            var addrval = $('#address').val();
            var requestUri =
              'http://dev.virtualearth.net/REST/v1/Locations/'
              + encodeURI(addrval) + '?output=json&key=' + _bing_maps_credential;
            $.ajax({
                url: requestUri,
                dataType: 'jsonp',
                jsonp: 'jsonp',
                beforeSend: function (xhr) {
                    console.log('changing map ...');
                },
                success: function (response) {
                    console.log('got location !');
                    if (response &&
                        response.resourceSets &&
                        response.resourceSets.length > 0 &&
                        response.resourceSets[0].resources &&
                        response.resourceSets[0].resources.length > 0) {
                        var bbox = response.resourceSets[0].resources[0].bbox;
                        var latitude = response.resourceSets[0].resources[0].point.coordinates[0];
                        var longitude = response.resourceSets[0].resources[0].point.coordinates[1];
                        _map.setView({
                            center: new Microsoft.Maps.Location(latitude, longitude),
                            zoom: 15
                        });
                    }
                },
                error: function () {
                    console.log('map search error:' + response.errorDetails[0]);
                }
            });
        }

    </script>
</head>
<body onload="initializeViewer()" style="background:#383838">
    <div id="jquery-ui-accordion">
        <div class="jquery-ui-accordion-title">Step 1</div>
        <div class="jquery-ui-accordion-contents">
            <div style="position:relative; top:0px; left:0%; height:580px; width:100%">
                <div class="canvas-areas" id="maparea" style="position:absolute; border-style:outset; top:0%; left:0%; height:100%; width:100%"></div>
                <input class="text-boxs" id="address" style="position:absolute; top:10px; left:50%; width:34%; height:25px" type="text" />
                <button class="jquery-ui-buttons" id="jquery-ui-button-map-search" style="position:absolute; top:10px; left:85%; width:30px" onclick="action_map_search()"></button>
                <div class="canvas-areas" id='pininfo' style="position:absolute; border-style:outset; height:250px; width:137px; display:none">
                    <div id='thumbnail' style="position:absolute; top:10px; left:5px; width: 130px; height:45px"></div>
                    <div id='latitude' style="position:absolute; top:150px; left:10px; width: 100px; height:5px; color:#ffffff"></div>
                    <div id='longitude' style="position:absolute; top:200px; left:10px; width: 130px; height:5px; color:#ffffff"></div>
                </div>
            </div>
        </div>
        <div class="jquery-ui-accordion-title">Step 2</div>
        <div class="jquery-ui-accordion-contents">
            <div class="canvas-areas" id="droparea" style="position:relative; border-style:dashed; top:0%; left:0%; width:100%; height:200px" ondragover="onDragOver(event)" ondrop="onDrop(event)" ondragleave="onDragLeave(event)">
                <label style="position:relative; top:50%; left:42%; color:#f0f0f0">Drop a file here, or</label>
                <button class="jquery-ui-buttons" id="jquery-ui-button-upload" style="position:relative; top:50%; left:42%; width:30px"></button>
                <input id="upload" type="file" style="display:none" onclick="action_file_dialog()" />
                <div id="progress" style="position:relative; top:80%; left:5%; width:90%; height:5px; border-style:none; background:#5d5d5d"></div>
            </div>
        </div>
        <div class="jquery-ui-accordion-title">Step 3</div>
        <div class="jquery-ui-accordion-contents">
            <div style="position:relative; top:0px; left:0%; height:700px; width:100%">
                <div class="canvas-areas" id="viewer3d" style="border-style:outset; position:absolute; top:0px; left:0%; height:85%; width:88%"></div>
                <div class="canvas-areas" id="controls" style="border-style:outset; position:absolute; top:0px; left:90%; height:85%; width:150px">
                    <button class="text-buttons" style="position:absolute; top:10px; left:25px" onclick="action_reset()">Reset</button>
                    <input class="text-boxs" id="step" style="position:absolute; top:83px; left:46px; width:50px; height:25px" size="5" maxlength="5" value="100" type="text" />
                    <button class="jquery-ui-buttons" id="jquery-ui-button-zoomin" style="position:absolute; top:50px; left:60px; width:30px" onclick="action_zoomin()"></button>
                    <button class="jquery-ui-buttons" id="jquery-ui-button-zoomout" style="position:absolute; top:120px; left:60px; width:30px" onclick="action_zoomout()"></button>
                    <button class="jquery-ui-buttons" id="jquery-ui-button-turnright" style="position:absolute; top:85px; left:110px; width:30px" onclick="action_turnright()"></button>
                    <button class="jquery-ui-buttons" id="jquery-ui-button-turnleft" style="position:absolute; top:85px; left:9px; width:30px" onclick="action_turnleft()"></button>
                    <button class="text-buttons" style="position:absolute; top:155px; left:25px" onclick="action_register()">Register</button>
                    <button class="text-buttons" style="position:absolute; top:190px; left:25px" onclick="action_restore()">Restore</button>
                    <select id="message" style="position:absolute; top:280px; left:10px; height:300px; width:130px; overflow:auto; border-style:outset; font-size:9pt" multiple="multiple"></select>
                    <input class="text-boxs" id="search" style="position:absolute; top:230px; left:12px; width:80px; height:25px" type="text" />
                    <button class="jquery-ui-buttons" id="jquery-ui-button-search" style="position:absolute; top:230px; left:105px; width:30px" onclick="action_search()"></button>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
