import string
import paho.mqtt.client as mqtt
import time
from datetime import date, datetime

estado = 0
limite = 255
temperatura = 0

def on_connect(client, userdata, flags, rc):
    cliente.connected_flag = True
    print("Conectado com codigo "+str(rc))
    cliente.subscribe([("Sensor", 1), ("Estado", 1), ["Limite", 1]])

def pub(topico, valor):
    cliente.publish(topico, valor, 1)

def on_message_sensor(client, userdata, msg):
    dataatual = datetime.today()
    nomearq = dataatual.strftime("%d-%m-%Y")
    arquivo = open("./" + nomearq + ".txt", "a+")
    msg.payload = int(float(msg.payload))
    arquivo.write("[" + str(dataatual.hour) + ":" + str(dataatual.minute) + "] " + str(msg.payload))
    arquivo.write('\n')
    global temperatura
    global estado
    print(str(temperatura))
    print(str(estado))
    print(str(limite))
    if msg.payload != temperatura:
        temperatura = msg.payload
    if temperatura > limite and estado == 0:
        cliente.publish("Ativacao", 1)


def on_message_estado(client, userdata, msg):
    msg.payload = int(msg.payload)
    global estado
    if msg.payload != estado:
        estado = msg.payload


def on_message_limite(client, userdata, msg):
    msg.payload = int(msg.payload)
    global limite
    if msg.payload != limite:
        limite = msg.payload


def on_message(client, userdata, msg):
    print(msg.topic+" "+str(msg.payload))


def on_publish(client, userdata, msg):
    print(str(msg)+" publicada.")


def on_subscribe(client, userdata, topico, qos):
    print("Inscrito.")


cliente = mqtt.Client()

cliente.username_pw_set("qfhgblyb:qfhgblyb", "th1iCzYBv6wGuBUhxgzbZdhJXwDzRw5F")

cliente.on_connect = on_connect

cliente.message_callback_add("Sensor", on_message_sensor)

cliente.message_callback_add("Estado", on_message_estado)

cliente.message_callback_add("Limite", on_message_limite)

cliente.on_message = on_message

cliente.on_publish = on_publish

cliente.on_subscribe = on_subscribe

time.sleep(5)

print("Conectando")

cliente.connected_flag = False

cliente.connect("jackal.rmq.cloudamqp.com", 1883, 300)

run = True
while run:
    cliente.loop()


while not cliente.connected_flag:
    print("Esperando conexao")
    time.sleep(0.5)


def get_temperatura():
    global temperatura
    return temperatura


def get_estado():
    global estado
    return estado


def get_limite():
    global limite
    return limite
