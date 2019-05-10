require 'selenium-webdriver'
require 'open-uri'
require 'csv'

bom = %w(EF BB BF).map { |e| e.hex.chr }.join
csv_file = CSV.generate(bom) do |csv|
    csv << ["Image"]
end

opt = {}
opt['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/XXXXXXXXXXXXX Safari/XXXXXX Vivaldi/XXXXXXXXXX'

File.open("result.csv", "w") do |file|
    file.write(csv_file)
end

FileUtils.mkdir_p("./images") unless FileTest.exist?("./images")

d = Selenium::WebDriver.for :chrome
wait = Selenium::WebDriver::Wait.new(:timeout => 10)

d.get('https://techacademy.jp/magazine/20558')

image_url = d.find_element(:class, 'post-header').find_element(:class, 'eyecatch').attribute("style").match(%r{https?://[\w_.!*\/')(-]+}).to_s
open("./images/test.jpg", 'wb') do |output|
    open(image_url,opt) do |data|
        output.write(data.read)
    end
end

CSV.open("result.csv", "a") do |file|
    file << [".jpg"]
end
