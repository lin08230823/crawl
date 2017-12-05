#coding:utf-8;
import sys
reload(sys)
sys.setdefaultencoding('utf-8')
import requests
from lxml import etree

url = 'https://jandan.net/duan'
data_all = ''
for i in range(3):
    print(url)
    req = requests.get(url,headers={'user-agent':'chrome'})
    html = req.text

    tree = etree.HTML(html)
    result = tree.xpath('//li//div[@class="text"]')

    for div in result:
        author = div.xpath('../div[@class="author"]/strong/text()')
        data_all += (author[0] + ':\n')
        content = div.xpath('p/text()')
        for p in content:
            data_all += p
        data_all += '\n\n'
        print data_all

    current_page = tree.xpath('//span['
                              '@class="current-comment-page"]/text()')
    next_page = int(current_page[0].strip('[]')) - 1
    url = 'https://jandan.net/duan/page-%d' % next_page

with open('jokess.txt','w') as f:
    f.write(data_all)
