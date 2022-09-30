# brew install allure
# pip install allure-pytest
# pytest --alluredir=./allure-results
# allure serve ./allure-results

def func(x):
    return x + 1


def test_answer():
    assert func(3) == 4
