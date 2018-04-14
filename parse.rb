require 'json'
require 'mqtt'


topic = 'spottracker'
config = JSON.parse(File.read('config.json'))

# {"response":{"errors":{"error":{"code":"E-0160","text":"Feed Not Found","description":"Feed with Id: FEED_ID_HERE not found."}}}}
# {"response":{"errors":{"error":{"code":"E-0195","text":"No Messages to display","description":"No displayable messages found found for feed: 0qqmIQchj3xuLgpqK3TvQd5rG57qu98NT"}}}}
  
feed = "https://api.findmespot.com/spot-main-web/consumer/rest-api/2.0/public/feed/#{config['id']}/message.json"

results = JSON.parse(File.read('message.json'))

MQTT::Client.connect(config['mqtt_server']) do |c|
  results['response']['feedMessageResponse']['messages']['message'].each do |result|
    message = {
      _type: "location",
      lat:result['latitude'],
      lng: result['longitude'],
      tst: result['unixTime'],
      alt: result['altitude']
    }
    payload = JSON.generate(message)
    c.publish("owntracks/#{topic}/device", payload)
  end
end