JSWSimpleJSONTable
============

JSWSimpleJSONTable is a subclass of UITableViewController that allows you to populate an entire table view using a JSON file, and not deal with UITableViews, delegates and data sources.  

The goal is to only need
````{"text":"Cell text","image":"imageName","action":"clickedCell","height":44}````
to populate a cell, instead of editing multiple methods in a UITableViewController. To add a row, you can simply add another line in the JSON file, and not worry about updating indices throughout the file.

JSWSimpleJSONTable supports customizing the following:
* text and detailText
* image
* method call when row is selected
* accessory
* height
* headers

The JSON file
=============
The JSON file is an array of dictionaries representing sections.
Each section is a dictionary with several options, and a key called "rows" that is an array of the rows in that section.
Each row is a dictionary with multiple keys.

Starting Out
============
Import the JSWSimpleJSONTable class into your project.
Subclass JSWSimpleJSONTable to create your delegate, and call   
````self = [super initWithStyle:style file:fileName delegate:self];`````  
You will put your methods and view customizations on the delegate.

##Keys
###Text
````{"text":"The title text"}````
###Detail Text
````{"detailText":"The subtitle"}````
###Image

````{"image":"imageFileName"}````  
This is called by ````[UIImage imagedNamed:]```` so you don't need the file extension.
###Methods
````{"action":"methodName"}````
You will need to add an action to your delegate's interface and implementation. You can't receive or return any objects. The above code will call the method ````-(void)methodName;````.
###Accessory
````{"accessory":"UITableViewCellAccessoryDisclosureIndicator"}````

###Height
````{"height":30,}````
Default is 44

##Notes
You can override any of the methods in JSWSimpleJSONTable by calling it from your delegate.
