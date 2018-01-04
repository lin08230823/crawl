# -*- coding:utf-8 -*-
from bs4 import BeautifulSoup
from selenium import webdriver
import threading
import requests
import time
def download(link,name):
    req = requests.get(link)
    with open('pics/' + name, 'wb') as f:
        f.write(req.content)
        print(name,'下载完成')
def crawl():
    for i in range(5):
        driver = webdriver.PhantomJS()
        url = 'http://zu.sh.fang.com/'

        driver.get(url)
        driver.find_element_by_id('input_key').send_keys('闵行')
        driver.find_element_by_id('rentid_39').click()

        soup = BeautifulSoup(driver.page_source,'lxml')
        items = soup.find_all('dl',class_='list hiddenMap rel')
        for item in items:

            address = item.find('p',class_="gray6 mt20").get_text()
            print(address)
            price = item.find('p',class_="mt5 alingC").get_text()
            price = price.replace('/','-')
            print(price)
            link = 'http://zu.sh.fang.com/' + item.find('p',class_='title').find('a').get('href')
            print(link)
            pic_link = item.find('img',class_="b-lazy").get('data-src')
            print(pic_link)
            filename = address + price + '.' + pic_link.split('.')[-1]
            t = threading.Thread(target=download,args=(pic_link,filename))
            print('开始下载',filename)
            t.start()
            if threading.active_count()>3:
                time.sleep(3)
        driver.find_element_by_link_text('下一页').click()

if __name__ == '__main__':
    crawl()
