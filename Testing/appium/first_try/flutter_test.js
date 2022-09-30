// https://appium.github.io/appium/docs/en/2.0/quickstart/test-js/
const {remote} = require('webdriverio');
const assert = require('assert');
const {byValueKey} = require('appium-flutter-finder');

// capabilities : https://appium.io/docs/en/writing-running-appium/caps/index.html
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
// const capabilities = {
//   'appium:platformName': 'Android',
//   'appium:automationName': 'Flutter',
//   'appium:deviceName': 'Android',
//   'appium:appPackage': 'com.example.study_flutter_integration_test',
//   'appium:appActivity': 'com.example.study_flutter_integration_test.MainActivity',
// };

const capabilities = {
    'appium:platformName': 'iOS',
    'appium:automationName': 'Flutter',
    'appium:deviceName': 'iPhone 13 Pro',
    'appium:bundleId': 'com.example.studyFlutterIntegrationTest',
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
        // this will throw error if not found counterText after 1 second
        const result = await driver.execute('flutter:waitFor', counterTextFinder, 1)

        assert.strictEqual(await driver.getElementText(counterTextFinder), '0');
        await driver.elementClick(buttonFinder);
        await driver.touchAction({
            action: 'tap',
            element: {elementId: buttonFinder}
        });

        assert.strictEqual(await driver.getElementText(counterTextFinder), '2');
    } finally {
        await driver.pause(1000);
        await driver.deleteSession();
    }
}

runTest().catch(console.error);
