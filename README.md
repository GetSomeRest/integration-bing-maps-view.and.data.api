#Integration with Microsoft Bing Maps and Autodesk View and Data API

##Description

This is a sample demoing the integration with Microsoft Bing Maps and Autodesk View and Data API. Main functions are as follows.

* Search locations with keywords and show the result onto Bing Maps.
* Specify a location where is associated with 3D model by right clicking on map.
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

* Get your consumer key and secret key for view and data API from http://developer.autodesk.com
* Set your consumer key and secret key for view and data API on the Credentials.cs file, replace the bucket name with your own. Bucket keys are unique within the data center or region in which they were created, best practice is the incorporate your company name or the consumer key into the bucket name. It must be between 3 to 128 characters long and contain only lowercase letters, numbers and the symbols . _ -
* Get your own credential key for Microsoft bing maps at https://www.bingmapsportal.com/
* Set credential key for Microsoft bing maps in Credentials.js
* Set the bucket prefix name in Credentials.js

## License

This sample is licensed under the terms of the [MIT License](http://opensource.org/licenses/MIT). Please see the [LICENSE](LICENSE) file for full details.

##Written by 

Toshiaki Isezaki
