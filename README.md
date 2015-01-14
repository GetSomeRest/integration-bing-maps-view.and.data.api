#Integration with Microsoft Bing Maps and Autodesk View and Data API

##Description

*This sample is part of the [Developer-Autodesk/Autodesk-View-and-Data-API-Samples](https://github.com/Developer-Autodesk/autodesk-view-and-data-api-samples) repository.*

This is a sample demoing the integration with Microsoft Bing Maps and Autodesk View and Data API. Main functions are as follows.

* Search locations with keywords and show the result onto Bing Maps.
* Specify a location where is associted with 3D model.
* Get access token via ASP.NET
* Upload a file and get translation.
* Get thumbnail and reflect it to maps.
* Load it in custom viewer. 
* Control views on viewer.

##Dependencies

This sample uses the following libraries.

* jQuery UI - v1.11.1
* Microsoft Bing Maps AJAX Control 7.0
* Autodesk View and Data API JavaScript Wrapper Library(https://github.com/Developer-Autodesk/library-javascript-view.and.data.api) 

##Setup/Usage Instructions

* Get your consumer key and secret key for view and data api from http://developer.autodesk.com
* Set your consumer key and secret key for view and data api on the SecretConstants.cs file
* Get your own credential key for microsoft bing maps at https://www.bingmapsportal.com/
* Set your own credential key at https://www.bingmapsportal.com/
* Set credential key for microsoft bing maps in BingMaps-Credentials.js
* Set the bucket prefix name in BingMaps-Credentials.js

## License

This sample is licensed under the terms of the [MIT License](http://opensource.org/licenses/MIT). Please see the [LICENSE](LICENSE) file for full details.

##Written by 

Toshiaki Isezaki
