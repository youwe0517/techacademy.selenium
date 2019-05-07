require 'selenium-webdriver'
d = Selenium::WebDriver.for :chrome
d.get('https://techacademy.jp/magazine/19893')



id =  d.find_element(:xpath, '//*[@class="content col-md-9 col-sm-9 animated fadeInUp"]').find_element(:class, 'post').attribute("id")
xpath = '//*[@id="' + id + '"]/div[1]/div[1]/span[5]/iframe'
d.switch_to.frame(d.find_element(:xpath, xpath))
Hatebu =  d.find_element(:class, 'count').text

puts Hatebu