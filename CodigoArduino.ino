#include <ESP8266WiFi.h>
#include <PubSubClient.h>

#define pinoPOT A0

const char* ssid = "Daniele"; //Nome da rede Wifi
const char* password = "Halloween007"; //Senha da rede Wifi
const char* mqtt_server = "jackal.rmq.cloudamqp.com"; 
const char* mqtt_user = "edwogfqz:edwogfqz";
const char* mqtt_pass= "3CNvgOXydn4AcDNzUcQi8WJX12geu3bJ";
char estadoLED[1];

WiFiClient espClient;
PubSubClient client(espClient);

void setup_wifi() {
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
  }
}

void callback(char* topic, byte* message, unsigned int length) {
  String messageTemp; 
  for (int i = 0; i < length; i++) {
    messageTemp += (char)message[i];
  }
  if (String(topic) == "Ativacao") {
    if(messageTemp == "1"){
      digitalWrite(LED_BUILTIN, LOW);
      estadoLED[0] = '1';
      client.publish("Estado", estadoLED); 
    }
    else if(messageTemp == "0"){
      digitalWrite(LED_BUILTIN, HIGH);
      estadoLED[0] = '0';
      client.publish("Estado", estadoLED); 
    }
  }
}
void reconnect() {
  while(!client.connected()){
    if(client.connect("arduino", mqtt_user, mqtt_pass)) {
      client.subscribe("Ativacao");
    }else{
      delay(5000);
    }
  }
}
void setup() {
  Serial.begin(4800);
  pinMode(pinoPOT, INPUT);
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, HIGH);
  setup_wifi();
  client.setServer(mqtt_server, 1883);
  client.setCallback(callback);
}
void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();
  float dadoSensor;
  char result[4];
  dadoSensor =  map(analogRead(pinoPOT), 0, 1023, 0, 255);
  dtostrf(dadoSensor, 4, 4, result);
  delay(5000);
  client.publish("Sensor", result);
}
