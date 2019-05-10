require 'selenium-webdriver'
require 'open-uri'
require 'csv'


bom = %w(EF BB BF).map { |e| e.hex.chr }.join
csv_file = CSV.generate(bom) do |csv|
    csv << ["Title", "Url", "Hatebu", "Image"]
end

opt = {}
opt['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/XXXXXXXXXXXXX Safari/XXXXXX Vivaldi/XXXXXXXXXX'

File.open("result.csv", "w") do |file|
    file.write(csv_file)
end

FileUtils.mkdir_p("./images") unless FileTest.exist?("./images")

d = Selenium::WebDriver.for :chrome
wait = Selenium::WebDriver::Wait.new(:timeout => 10)

d.get('https://techacademy.jp/magazine/category/programming')

urls = []
loop do 
    wait.until { d.find_elements(:class, 't1').size > 0 }
    d.find_elements(:class, 't1').each do |t1|
    urls << t1.find_element(:class, 'entry-title').find_element(:tag_name, 'a').attribute("href")
    end

    break

    if d.find_elements(:xpath, '//*[@class="next page-numbers"]').size > 0
        wait.until { d.find_elements(:xpath, '//*[@class="next page-numbers"]').size > 0 }
        d.find_element(:xpath, '//*[@class="next page-numbers"]').click
    else
        break
    end
end

i = 1

urls.each do |url|
    d.get(url)
    title = d.title
    page_url = d.current_url
    id =  d.find_element(:xpath, '//*[@class="content col-md-9 col-sm-9 animated fadeInUp"]').find_element(:class, 'post').attribute("id")
    xpath = '//*[@id="' + id + '"]/div[1]/div[1]/span[5]/iframe'
    d.switch_to.frame(d.find_element(:xpath, xpath))
    hatebu =  d.find_element(:class, 'count').text
    d.switch_to.default_content
    image_url = d.find_element(:class, 'post-header').find_element(:class, 'eyecatch').attribute("style").match(%r{https?://[\w_.!*\/')(-]+}).to_s
    open("./images/#{i}.jpg", 'wb') do |output|
        open(image_url,opt) do |data|
            output.write(data.read)
        end
    end

    i += 1

    CSV.open("result.csv", "a") do |file|
        file << [title, page_url, hatebu, "#{i}.jpg"]
    end
end

sleep 1

