# python test.py
import unittest
from appium import webdriver
from appium.webdriver.common.appiumby import AppiumBy
from appium_flutter_finder.flutter_finder import FlutterElement, FlutterFinder

capabilities = dict(
    platformName='Android',
    automationName='Flutter',
    deviceName='Android',
    appPackage='com.example.study_flutter_integration_test',
    appActivity='com.example.study_flutter_integration_test.MainActivity',
)

appium_server_url = 'http://localhost:4723'


class TestAppium(unittest.TestCase):

    def setUp(self) -> None:
        self.driver = webdriver.Remote(appium_server_url, capabilities)

    def tearDown(self) -> None:
        if self.driver:
            self.driver.quit()

    def test_tap_increment(self) -> None:
        finder = FlutterFinder()
        text_finder = finder.by_value_key('counterX')

        # this will throw error if not found counterText after 1 second
        self.driver.execute_script("flutter:waitFor", text_finder, 1)

        text_element = FlutterElement(self.driver, text_finder)
        self.assertEqual(text_element.text, '0')

        button_finder = finder.by_value_key('increment')
        button_element = FlutterElement(self.driver, button_finder)
        button_element.click()
        self.assertEqual(text_element.text, '1')


if __name__ == '__main__':
    unittest.main()
