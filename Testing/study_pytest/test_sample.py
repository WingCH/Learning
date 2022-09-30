# brew install allure
# pip install allure-pytest
# pytest --alluredir=./allure-results
# allure serve ./allure-results
# pytest -s test_sample.py
import time

import pytest

#
# def func(x):
#     return x + 1
#
#
# def test_answer():
#     assert func(3) == 4
#
#
# # https://learning-pytest.readthedocs.io/zh/latest/doc/fixture/rename.html
# @pytest.fixture(name='age')
# def calculate_average_age():
#     return 28
#
#
# def test_age(age):
#     assert age == 28
#
#
# # https://learning-pytest.readthedocs.io/zh/latest/doc/fixture/parametrize.html
# @pytest.mark.parametrize('passwd',
#                          ['123456',
#                           'abcdefdfs',
#                           'as52345fasdf4'])
# def test_passwd_length(passwd):
#     assert len(passwd) >= 8

# @pytest.mark.usefixtures
# def test_func1():
#     assert 1 == 1
#
#
# @pytest.mark.skip
# def test_func2():
#     assert 1 != 1


# @pytest.fixture()
# def postcode():
#     return '010'
#
#
# def test_postcode(postcode):
#     assert postcode == '010'

# @pytest.fixture()
# def db():
#     print('Connection successful')
#
#     yield
#
#     print('Connection closed')
#
#
# def search_user(user_id):
#     d = {
#         '001': 'xiaoming'
#     }
#     return d[user_id]
#
#
# def test_search(db):
#     assert search_user('001') == 'xiaoming'


DATE_FORMAT = '%Y-%m-%d %H:%M:%S'


@pytest.fixture(scope='session', autouse=True)
def timer_session_scope():
    start = time.time()
    print('\nstart: {}'.format(time.strftime(DATE_FORMAT, time.localtime(start))))

    yield

    finished = time.time()
    print('finished: {}'.format(time.strftime(DATE_FORMAT, time.localtime(finished))))
    print('Total time cost: {:.3f}s'.format(finished - start))


@pytest.fixture(autouse=True)
def timer_function_scope():
    start = time.time()
    yield
    print(' Time cost: {:.3f}s'.format(time.time() - start))


def test_1():
    time.sleep(1)


def test_2():
    time.sleep(2)
