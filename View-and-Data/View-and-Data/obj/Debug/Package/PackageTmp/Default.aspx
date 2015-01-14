<%@ Page Title="Home Page" Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="View_and_Data._Default" %>

<html lang="en">
<head>
    <title>ADN Japan Sample</title>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="icon" href="../../favicon.ico">
    <link rel="stylesheet" href="View-and-Data/jquery-ui.css">
    <link rel="stylesheet" href="https://developer.api.autodesk.com/viewingservice/v1/viewers/style.css" type="text/css">
    <script type="text/javascript" src="View-and-Data/jquery-1.11.1.min.js"></script>
    <script type="text/javascript" src="View-and-Data/jquery-ui.min.js"></script>
    <script type="text/javascript" src="https://rawgit.com/Developer-Autodesk/library-javascript-view.and.data.api/master/js/Autodesk.ADN.Toolkit.ViewData.js"></script>
    <script src="https://developer.api.autodesk.com/viewingservice/v1/viewers/viewer3D.min.js"></script>
    <script type="text/javascript" src="http://ecn.dev.virtualearth.net/mapcontrol/mapcontrol.ashx?v=7.0&mkt=ja-JP"></script>
    <script>
        var viewer;
        var thisView = [];
        var files = [];

        // 10/10/2014 Autodesk.ViewingServices.Private.getParameterByName was gone ?
        // Get argument to html document by name 
        function getArgumentByName(name) //courtesy Artem
        {
            name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
            var regexS = "[\\?&]" + name + "=([^&#]*)";
            var regex = new RegExp(regexS);
            var results = regex.exec(window.location.href);
            if (results == null)
                return "";
            else
                return decodeURIComponent(results[1].replace(/\+/g, " "));
        }

        function initializeViewer() {
            var urn = Autodesk.Viewing.Private.getParameterByName("urn");
            var accessToken = Autodesk.Viewing.Private.getParameterByName("accessToken");
            //var urn = getArgumentByName("urn");
            //var accessToken = getArgumentByName("accessToken");
            if (accessToken == "") {
                //document.getElementById('jquery-ui-accordion').active = 0;
                $("#jquery-ui-accordion").accordion("option", "active", 0);
                return;
            } else {
                $("#jquery-ui-accordion").accordion("option", "active", 2);
            }

            var options = {};
            options.env = "AutodeskProduction";
            options.accessToken = accessToken;
            options.document = "urn:" + urn;

            var viewerElement = document.getElementById('viewer3d');
            //viewer = new Autodesk.Viewing.Viewer3D(viewerElement, {});  // コントロール & 環境光なし（need viewer.impl.setLightPreset(1);）
            viewer = new Autodesk.Viewing.Private.GuiViewer3D(viewerElement, {});
            Autodesk.Viewing.Initializer(options, function () {
                viewer.initialize();
                loadDocument(viewer, Autodesk.Viewing.Private.getAuthObject(), options.document);
                viewer.addEventListener(Autodesk.Viewing.SELECTION_CHANGED_EVENT, onSelected);
            });
        }

        function initializeViewer2(urn, accessToken) {

            $("#jquery-ui-accordion").accordion("option", "active", 2);

            var itemList = document.getElementById("message");
            for (var index = itemList.length - 1; index >= 0; index--) {
                itemList[index].remove();
            }

            var options = {};
            options.env = "AutodeskProduction";
            options.accessToken = accessToken;
            options.document = "urn:" + urn;

            var viewerElement = document.getElementById('viewer3d');
            //viewer = new Autodesk.Viewing.Viewer3D(viewerElement, {});  // コントロール & 環境光なし（need viewer.impl.setLightPreset(1);）
            viewer = new Autodesk.Viewing.Private.GuiViewer3D(viewerElement, {});
            Autodesk.Viewing.Initializer(options, function () {
                viewer.initialize();
                loadDocument(viewer, Autodesk.Viewing.Private.getAuthObject(), options.document);
                viewer.addEventListener(Autodesk.Viewing.SELECTION_CHANGED_EVENT, onSelected);
            });
        }

        function loadDocument(viewer, auth, documentId, initialItemId) {
            // Find the first 3d geometry and load that.
            Autodesk.Viewing.Document.load(documentId, auth, function (doc) {// onLoadCallback
                var geometryItems = [];
                geometryItems = Autodesk.Viewing.Document.getSubItemsWithProperties(doc.getRootItem(), { 'type': 'geometry', 'role': '3d' }, true);
                if (geometryItems.length > 0) {
                    viewer.load(doc.getViewablePath(geometryItems[0]));
                }
            }, function (errorMsg) {// onErrorCallback
                console.log("ロードエラー : " + errorMsg);
            });
        }

        // Reset
        function action_reset() {
            viewer.showAll();
            // viewer.initialize();
            viewer.setViewFromFile();
            var num = viewer.getNavigationMode();
            console.log("NavigationMode = " + num);
            var itemList = document.getElementById("message");
            for (var index = itemList.length - 1; index >= 0; index--) {
                itemList[index].remove();
            }
        }

        // Zoom In
        function action_zoomin() {
            viewer.canvas.focus();
            viewer.setNavigationMode(2); // Zoom
            var step = document.getElementById('step').value * -1.0;
            var cam = viewer.getCamera();
            cam.translateX(0);
            cam.translateY(0);
            cam.translateZ(step);
            viewer.impl.syncCamera();
            viewer.impl.applyCamera(cam);
        }

        // ↓ Zoom Out
        function action_zoomout() {
            viewer.canvas.focus();
            viewer.setNavigationMode(2); // Zoom
            var step = document.getElementById('step').value;
            var cam = viewer.getCamera();
            cam.translateX(0);
            cam.translateY(0);
            cam.translateZ(step);
            viewer.impl.syncCamera();
            viewer.impl.applyCamera(cam);
        }

        // Turn Right
        function action_turnright() {
            viewer.canvas.focus();
            viewer.setNavigationMode(0); // Orbit
            var step = document.getElementById('step').value * -1.0;
            var cam = viewer.getCamera();
            //var vecz = new THREE.Vector3(1, 0, 0);
            //cam.translateOnAxis(vecz, step);
            cam.translateX(step);
            cam.translateY(0);
            cam.translateZ(0);
            viewer.impl.syncCamera();
            viewer.impl.applyCamera(cam);
        }

        // Turn Left
        function action_turnleft() {
            viewer.canvas.focus();
            viewer.setNavigationMode(0); // Orbit
            var step = document.getElementById('step').value;
            var cam = viewer.getCamera();
            cam.translateX(step);
            cam.translateY(0);
            cam.translateZ(0);
            viewer.impl.syncCamera();
            viewer.impl.applyCamera(cam);
        }

        // Register View
        function action_register() {
            var cam = viewer.getCamera();
            thisView[0] = cam.aspect;
            thisView[1] = cam.fov;
            thisView[2] = cam.position.clone();
            thisView[3] = viewer.impl.controls.getLookAtPoint().clone();
        }

        // Restore View
        function action_restore() {
            viewer.impl.camera.aspect = thisView[0];
            viewer.impl.camera.fov = thisView[1];
            viewer.impl.controls.setViewpoint(thisView[2], thisView[3]);
            //viewer.impl.applyCamera(cam);
        }

        // Search
        function action_search() {
            var search = document.getElementById("search").value;
            viewer.search(search, onSearchResult);
        }

        // Search callback
        function onSearchResult(idArray) {
            viewer.isolateById(idArray);
        }

        // Selection callback
        function onSelected(event) {
            var dbIdArray = event.dbIdArray;
            if (dbIdArray.length > 0) {
                for (i = 0; i < dbIdArray.length; i++) {
                    var dbId = dbIdArray[i];
                    var node = viewer.model.getNodeById(dbId);
                    if (node != null) {
                        var text = "[" + dbId + "]";
                        var itemList = document.getElementById("message");
                        var obj = itemList.add(new Option(text, text));
                    }
                }
            }
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
                files = event.target.files;
                fileUpload();
            }, false);
            filedialog.click();
        });

        // Drop
        function onDrop(event) {
            files = event.dataTransfer.files;
            if (files.length > 1) {
                console.log('File must be one');
            } else {
                var fileName = files[0].name;
                var fileSize = files[0].size;
                var fileType = files[0].type;
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
        });

        // File upload
        function fileUpload() {
            $("#progress").progressbar("option", "value", false);

            var token = getToken();
            if (token === '') {
                console.log('Access Token cannot be empty');
                console.log('Exiting ...');
                return;
            }

            var date = new Date();
            var bucket = "adn-japan" + "-" + date.getTime();
            if (bucket === '') {
                console.log('Bucket name cannot be empty');
                console.log('Exiting ...');
                return;
            }

            if (files.length === 0) {
                console.log('No file to upload');
                console.log('Exiting ...');
                return;
            }

            viewDataClient = new Autodesk.ADN.Toolkit.ViewData.AdnViewDataClient('https://developer.api.autodesk.com', token);
            viewDataClient.getBucketDetailsAsync(
                bucket,

                //onSuccess
                function (bucketResponse) {
                    console.log('Bucket details successful:');
                    console.log(bucketResponse);
                    uploadFiles(bucket, files, token);
                },

                //onError
                function (error) {
                    console.log("Bucket doesn't exist");
                    console.log("Attempting to create...");
                    createBucket(bucket, token);
            });
        }

        function createBucket(bucket, accessToken) {
            var bucketCreationData = {
                bucketKey: bucket,
                servicesAllowed: {},
                policy: 'transient'
            }

            viewDataClient.createBucketAsync(
                bucketCreationData,

                //onSuccess
                function (response) {
                    console.log('Bucket creation successful:');
                    console.log(response);
                    uploadFiles(response.key, files, accessToken);
                },

                //onError
                function (error) {
                    console.log('Bucket creation failed:');
                    console.log(error);
                    console.log('Exiting ...');
                    return;
            });
        }

        function uploadFiles(bucket, files, accessToken) {
            for (var i = 0; i < files.length; ++i) {
                var file = files[i];
                console.log('Uploading file: ' + file.name + ' ...');
                viewDataClient.uploadFileAsync(
                    file,
                    bucket,
                    file.name,

                    //onSuccess
                    function (response) {
                        console.log('File upload successful:');
                        console.log(response);
                        var fileId = response.objects[0].id;
                        var registerResponse = viewDataClient.register(fileId);
                        if (registerResponse.Result === "Success") {
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
                                    var fileId = viewDataClient.fromBase64(viewable.urn);
                                    $("#progress").progressbar("option", "value", 0);
                                    addThumbnail(fileId, response.file.name);
                                    initializeViewer2(viewable.urn, accessToken);
                            });
                        }
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

        function checkTranslationStatus(fileId, timeout, onSuccess) {
            var startTime = new Date().getTime();
            var timer = setInterval(function () {
                var dt = (new Date().getTime() - startTime) / timeout;
                if (dt >= 1.0) {
                    clearInterval(timer);
                } else {
                    viewDataClient.getViewableAsync(
                        fileId,
                        function (response) {
                            console.log('Translation Progess ' + fileId + ': ' + response.progress);
                            if (response.progress === 'complete') {
                                clearInterval(timer);
                                onSuccess(response);
                            }
                        },
                        function (error) {
                    });
                }
            }, 2000);
        };

        function addThumbnail(fileId, name) {
            $("#jquery-ui-accordion").accordion("option", "active", 0);
            var parentNode = document.getElementById('thumbnails');
            var childNode = document.getElementById('generated_image');
            if (childNode) {
                parentNode.removeChild(childNode);
            }
            var img = document.createElement('img');
            img.id = "generated_image";
            img.width = 128;
            img.height = 128;
            parentNode.appendChild(img);
            viewDataClient.getThumbnailAsync(
               fileId,
               function (data) {
                   img.src = "data:image/png;base64," + data;
               },
               function (error) {
                   console.log('Error getting thumbnail for ' + fileId + ': ' + error);
           });
        };

        $(function () {
            $("#progress").progressbar({
                value: 0
            });
        });

        function action_test() {
            var accessToken = getToken();
            alert(accessToken);
        }

        function getToken() {
            var newToken;
            //$.ajax({
            //    url: "GetAccessToken.ashx",
            //    type: 'GET',
            //    cache: false,
            //    dataType: 'json',
            //    success: function (data) {
            //        newToken = JSON.parse(data).access_token;
            //    }
            //});

            //$.ajax({
            //    url: "GetAccessToken.ashx",
            //    type: "GET",
            //    cache: false,
            //    dataType: "json"
            //}).then(function (data) {
            //    if (data.success) {
            //        newToken = JSON.parse(data).access_token;
            //    }
            //});

            var xmlHttp = null;
            xmlHttp = new XMLHttpRequest();
            //xmlHttp.open( "GET", "https://adn-japan.azurewebsites.net/GetAccessToken.ashx", false );
            xmlHttp.open( "GET", "GetAccessToken.ashx", false );
            xmlHttp.send( null );
            var data= xmlHttp.responseText;
            var newToken = JSON.parse(data).access_token;
            return newToken;
        }
    </script>
</head>
<body onload="initializeViewer()" style="background:#383838">
    <div id="jquery-ui-accordion" style="border-style:none; background:#383838">
        <div class="jquery-ui-accordion-title" style="border-style:outset; height:15px; color:#ffffff; border-radius:3px; background:#5d5d5d">Step 1</div>
        <div class="jquery-ui-accordion-contents" style="border-style:none; background:#383838">
            <div id="maparea" style="position:relative; border-color:#f0f0f0; top:0%; left:0%; width:100%; height:200px; color:#f0f0f0; background:#5d5d5d; border-radius:5px;">
                <button id="test" style="position:absolute; top:10%; left:50%; width:30px; height:30px; color:#ffffff; border-radius: 5px; display:none" onclick="action_test()"></button>
                <label style="position:relative; top:50%; left:45%; color:#f0f0f0">Place holder</label>
                <div id="thumbnails"></div>
            </div>
        </div>
        <div class="jquery-ui-accordion-title" style="border-style:outset; height:15px; color:#ffffff; border-radius:3px; background:#5d5d5d">Step 2</div>
        <div class="jquery-ui-accordion-contents" style="border-style:none; background:#383838">
            <div id="droparea" style="position:relative; border-style:dashed; border-color:#f0f0f0; top:0%; left:0%; width:100%; height:200px; color:#f0f0f0; background:#5d5d5d; border-radius:5px;" ondragover="onDragOver(event)" ondrop="onDrop(event)" ondragleave="onDragLeave(event)">
                <label style="position:relative; top:50%; left:42%; color:#f0f0f0">Drop a file here, or</label>
                <button id="jquery-ui-button-upload" name="jquery-ui-button-upload" style="position:relative; top:50%; left:42%; width:25px; height:25px; color:#ffffff; border-radius: 5px;"></button>
                <input id="upload" type="file" style="display:none" onclick="action_file_dialog()" />
                <div id="progress" style="position:relative; top:80%; left:5%; width:90%; height:5px; border-style:none; background:#5d5d5d"></div>
            </div>
        </div>
        <div class="jquery-ui-accordion-title" style="border-style:outset; height:15px; color:#ffffff; border-radius:3px; background:#5d5d5d">Step 3</div>
        <div class="jquery-ui-accordion-contents" style="border-style:none; background:#383838">
            <div style="position:relative; top:0px; left:0%; height:700px; width:100%">
                <div id="viewer3d" style="border-style:outset; position:absolute; top:0px; left:0%; height:85%; width:88%; border-radius:3px; background-color:#5d5d5d"></div>
                <div id="controls" style="border-style:outset; position:absolute; top:0px; left:90%; height:85%; width:150px; border-radius:3px; background-color:#5d5d5d">
                    <button style="position:absolute; top:10px; left:25px; width:100px; height:30px; border-radius: 5px;" onclick="action_reset()">Reset</button>
                    <input id="step" style="position:absolute; top:83px; left:48px; width:50px; height:25px; border-radius:3px" size="5" maxlength="5" value="100" type="text" />
                    <button id="jquery-ui-button-zoomin" style="position:absolute; top:50px; left:65px; width:25px; height:25px; color:#ffffff; border-radius: 5px;" onclick="action_zoomin()"></button>
                    <button id="jquery-ui-button-zoomout" style="position:absolute; top:120px; left:65px; width:25px; height:25px; color:#ffffff; border-radius: 5px;" onclick="action_zoomout()"></button>
                    <button id="jquery-ui-button-turnright" style="position:absolute; top:85px; left:120px; width:25px; height:25px; color:#ffffff; border-radius: 5px;" onclick="action_turnright()"></button>
                    <button id="jquery-ui-button-turnleft" style="position:absolute; top:85px; left:4px; width:25px; height:25px; color:#ffffff; border-radius: 5px;" onclick="action_turnleft()"></button>
                    <button style="position:absolute; top:155px; left:25px; width:100px; height:30px; border-radius: 5px;" onclick="action_register()">Register</button>
                    <button style="position:absolute; top:190px; left:25px; width:100px; height:30px; border-radius: 5px;" onclick="action_restore()">Restore</button>
                    <select id="message" style="position:absolute; top:280px; left:10px; height:30%; width:130px; overflow:auto; border-style:outset" multiple="multiple"></select>
                    <input id="search" style="position:absolute; top:230px; left:10px; width:80px; height:25px; border-radius: 3px;" type="text" />
                    <button id="jquery-ui-button-search" style="position:absolute; top:230px; left:110px; width:30px; height:30px; color:#ffffff; border-radius: 5px;" onclick="action_search()"></button>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
