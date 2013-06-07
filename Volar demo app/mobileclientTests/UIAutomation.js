
var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();

UIATarget.onAlert = function onAlert(alert) {
	var title = alert.name();	UIALogger.logWarning("Alert with title '" + title + "' encountered!");	return false; // use default handler 
}

function testOrientation () {
	var testName = "Test Orientation";
	//set orientation to landscape left
	target.setDeviceOrientation(UIA_DEVICE_ORIENTATION_LANDSCAPELEFT);
	UIALogger.logMessage("Current orientation now " + app.interfaceOrientation());
	target.delay(2);
	target.captureScreenWithName("Landscape");

	//reset orientation to portrait
	target.setDeviceOrientation(UIA_DEVICE_ORIENTATION_PORTRAIT);
	UIALogger.logMessage("Current orientation now " + app.interfaceOrientation());
	target.delay(2);
	target.captureScreenWithName("Portrait");
	UIALogger.logPass(testName);
}

function testSchoolSelection () {
	var testName = "Test School Selection";
	var tableView = window.scrollViews()[0].tableViews()[0];
	
	//tableView.scrollToElementWithPredicate("name beginswith 'Henry'");

	//var cell = tableView.cells().firstWithPredicate("name beginswith 'Henry'");
	var cell = tableView.cells()[1];
	
	if (cell.isValid()) {
		cell.tap();
		target.delay(1);
		target.captureScreenWithName(testName);
		UIALogger.logPass(testName);
	}
	else {
		target.captureScreenWithName(testName);
		UIALogger.logFail(testName);
	}
}

function testSchoolSwipe () {
	var testName = "Test Swiping";
	target.delay(1);
	target.flickFromTo({x:300, y:200}, {x:50, y:200});
	target.delay(1);
	target.captureScreenWithName(testName + "flick 1");
	target.delay(1);
	target.flickFromTo({x:300, y:200}, {x:50, y:200});
	target.delay(1);
	target.captureScreenWithName(testName + "flick 2");
	UIALogger.logPass(testName);
}

function returnToSchoolList () {
	var testName = "Return to School List";
	var buttonName = app.navigationBar().buttons()[0].name();
	UIALogger.logMessage(buttonName);
	
	if ((buttonName != "Edit") && (buttonName != "Done")) {
		UIALogger.logMessage("Tapped button " + buttonName);
		app.navigationBar().buttons()[0].tap();
	}
	UIALogger.logPass(testName);
}

function selectBroadcast() {
	var testName = "Select Broadcast";
	var schoolPage = window.scrollViews()[0].scrollViews()[1];
	schoolPage.buttons()[0].tap();
	target.delay(2);
	UIALogger.logPass(testName);
}

function playBroadcast () {	
	var testName = "Play Broadcast";
	var tableView = window.tableViews()[0];
	var cell = tableView.cells()[1];
	
	if ((cell.isValid()) && (tableView.isValid())) {
		cell.tap();
		target.delay(5);
		target.captureScreenWithName(testName);
		UIALogger.logPass(testName);
	}
	else {
		target.captureScreenWithName(testName);
		UIALogger.logFail(testName);
	}
}


//Run tests

UIALogger.logStart("iHigh UI Testing");
target.logElementTree();
returnToSchoolList();
testSchoolSelection();
returnToSchoolList();
testSchoolSwipe();
testOrientation();
selectBroadcast();
playBroadcast();





