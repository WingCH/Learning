// https://appium.github.io/appium/docs/en/2.0/quickstart/test-js/
const { remote } = require('webdriverio');
const assert = require('assert');
const { byValueKey } = require('appium-flutter-finder');

/*
Appium Inspector does not support 'appium:automationName': 'Flutter', so use `UiAutomator2`
{
  "appium:platformName": "Android",
  "appium:automationName": "UiAutomator2",
  "appium:deviceName": "Android",
  "appium:appPackage": "com.example.study_flutter_integration_test",
  "appium:appActivity": "com.example.study_flutter_integration_test.MainActivity"
}
*/
const capabilities = {
  'appium:platformName': 'Android',
  'appium:automationName': 'Flutter',
  'appium:deviceName': 'Android',
  'appium:appPackage': 'com.example.study_flutter_integration_test',
  'appium:appActivity': 'com.example.study_flutter_integration_test.MainActivity',
};

const wdOpts = {
  host: process.env.APPIUM_HOST || 'localhost',
  port: parseInt(process.env.APPIUM_PORT, 10) || 4723,
  logLevel: 'info',
  capabilities,
};

async function runTest() {
  const counterTextFinder = byValueKey('counter');
  const buttonFinder = byValueKey('increment');

  const driver = await remote(wdOpts);
  try {
    assert.strictEqual(await driver.getElementText(counterTextFinder), '0');
    await driver.elementClick(buttonFinder);
    await driver.touchAction({
      action: 'tap',
      element: { elementId: buttonFinder }
    });

    assert.strictEqual(await driver.getElementText(counterTextFinder), '3');
  } finally {
    await driver.pause(1000);
    await driver.deleteSession();
  }
}

runTest().catch(console.error);
