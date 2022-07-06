import 'dart:io';
import 'package:estufa_app/thermometer_widget.dart';
import 'package:estufa_app/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //Conexão MQTT
  Future<MqttClient> connect() async {
    MqttServerClient client = MqttServerClient.withPort(
        'jackal.rmq.cloudamqp.com', 'flutter_client', 1883);

    client.logging(on: true);
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onUnsubscribed = onUnsubscribed;
    client.onSubscribed = onSubscribed;
    client.onSubscribeFail = onSubscribeFail;
    client.pongCallback = pong;

    final connMess = MqttConnectMessage()
        .withClientIdentifier("flutter_client")
        .authenticateAs("edwogfqz:edwogfqz", "3CNvgOXydn4AcDNzUcQi8WJX12geu3bJ")
        //.authenticateAs('username', 'password')

        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMess;
    //client.keepAlivePeriod = 60;

    try {
      print('Connecting');
      await client.connect();
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
    }

    if (client.connectionStatus.state == MqttConnectionState.connected) {
      print('EMQX client connected');
      client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        //Callback
        final MqttPublishMessage message = c[0].payload;
        final payload =
            MqttPublishPayload.bytesToStringAsString(message.payload.message);

        if (c[0].topic == 'Estado') {
          onMessageEstado(payload);
        }
        if (c[0].topic == 'Limite') {
          onMessageLimite(payload);
        }
        if (c[0].topic == 'Sensor') {
          onMessageSensor(payload);
        }
        print('Received message:$payload from topic: ${c[0].topic}>');
      });

      client.published.listen((MqttPublishMessage message) {
        print('published');
        final payload =
            MqttPublishPayload.bytesToStringAsString(message.payload.message);
        print(
            'Published message: $payload to topic: ${message.variableHeader.topicName}');
      });
    } else {
      print(
          'EMQX client connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
      showError(context: context);
      exit(-1);
    }

    return client;
  }

  void onConnected() {
    setState(() {
      connected = true;
    });

    print('Connected');
    showSuccess(context: context);
  }

  void onDisconnected() {
    setState(() {
      connected = false;
    });
    print('Disconnected');
  }

  void onSubscribed(String topic) {
    print('Subscribed topic: $topic');
  }

  void onSubscribeFail(String topic) {
    print('Failed to subscribe topic: $topic');
  }

  void onUnsubscribed(String topic) {
    print('Unsubscribed topic: $topic');
  }

  void pong() {
    print('Ping response client callback invoked');
  }

  //Publica mensagem
  void publish(String message, String topic, MqttClient client) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client?.publishMessage(topic, MqttQos.atLeastOnce, builder.payload);
  }

  MqttClient client;
  double temp = 20;
  int estado = 0;
  double limite = 255;
  bool connected = false;
  TextEditingController tempController = new TextEditingController();

  /*  void initState() {
    super.initState();
    //temp = 20;
    /* WidgetsBinding.instance.addPostFrameCallback((_) => () {
          /* connect().then((value) {
            client = value;
          });
          client?.subscribe('Sensor', MqttQos.atLeastOnce);
          client?.subscribe('Estado', MqttQos.atLeastOnce);
          client?.subscribe('Limite', MqttQos.atLeastOnce); */
        });

    */
  } */

  @override //construção da página
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 154, 196, 105),
            toolbarHeight: MediaQuery.of(context).size.height * 0.06,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    connected
                        ? Icon(
                            Icons.wind_power_outlined,
                            color: Theme.of(context).primaryColor,
                            size: 40,
                          )
                        : Icon(
                            Icons.mode_fan_off_outlined,
                            color: Theme.of(context).primaryColor,
                            size: 40,
                          ),
                    estado == 1
                        ? Icon(
                            CupertinoIcons.wind,
                            color: Theme.of(context).primaryColor,
                            size: 40,
                          )
                        : Icon(
                            CupertinoIcons.zzz,
                            color: Theme.of(context).primaryColor,
                            size: 40,
                          )
                  ],
                )),
              ],
            )),
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20.0),
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
          child: SingleChildScrollView(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  espaco(),
                  espaco(),
                  SizedBox(
                    child: ThermometerWidget(
                      borderColor: Colors.red,
                      innerColor: Colors.green,
                      indicatorColor: Colors.red,
                      temperature: temp,
                    ),
                  ),
                  espaco(),
                  espaco(),
                  espaco(),
                  botao('ESTADO DO ATUADOR', () {
                    ativar();
                  }),
                  espaco(),
                  botao('MUDAR LIMITE', () {
                    mudarLimite();
                  }),
                  espaco(),
                  botao('CONECTAR', () {
                    //conecta e se inscreve nas filas
                    showProcessing(context: context);
                    connect().then((value) {
                      client = value;
                      client?.subscribe('Sensor', MqttQos.atLeastOnce);
                      client?.subscribe('Estado', MqttQos.atLeastOnce);
                      client?.subscribe('Limite', MqttQos.atLeastOnce);
                    });
                  }),
                ],
              ),
            ),
          ),
        ));
  }

  //Função mudar limite do atuador
  mudarLimite() {
    TextEditingController limiteController = new TextEditingController();
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(
            'O limite atual é $limite',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Form(
              child: Column(
                children: <Widget>[
                  Text(
                    'Deseja mudar o limite do atuador?',
                    style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.05,
                    child: TextFormField(
                      keyboardType: TextInputType.numberWithOptions(),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.zero),
                        ),
                        labelText: 'Novo Limite',
                      ),
                      controller: limiteController,
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  button('CONFIRMAR', Colors.green, 0.6, 0.05, () {
                    publish(limiteController.text, "Limite", client);

                    Navigator.of(_).pop();
                  }, context),
                  SizedBox(
                    height: 10.0,
                  ),
                  button('CANCELAR', Colors.red, 0.6, 0.05, () {
                    Navigator.of(_).pop();
                  }, context),
                ],
              ),
            ),
          ),
          actions: <Widget>[],
        );
      },
    );
  }

  //Função ativar o atuador
  ativar() {
    //print("\nEstado: $estado");
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(
            estado == 0 ? 'ATUADOR DESATIVADO' : 'ATUADOR ATIVADO',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Form(
              child: Column(
                children: <Widget>[
                  Text(
                    estado == 0
                        ? 'Deseja ativar o atuador?'
                        : 'Deseja desativar o atuador?',
                    style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  button('CONFIRMAR', Colors.green, 0.6, 0.05, () {
                    estado == 0
                        ? publish('1', "Ativacao", client)
                        : publish('0', "Ativacao", client);

                    Navigator.of(_).pop();
                  }, context),
                  SizedBox(
                    height: 10.0,
                  ),
                  button('CANCELAR', Colors.red, 0.6, 0.05, () {
                    Navigator.of(_).pop();
                  }, context),
                ],
              ),
            ),
          ),
          actions: <Widget>[],
        );
      },
    );
  }

//funções do callback
  void onMessageEstado(String payload) {
    setState(() {
      estado = int.parse(payload);
    });
    print("estate: $estado");
  }

  void onMessageLimite(String payload) {
    setState(() {
      limite = double.parse(payload);
    });
  }

  void onMessageSensor(String payload) {
    print('\n$payload');

    write(payload);

    setState(() {
      tempController.text = payload;
      temp = double.parse(payload);
    });

    if (temp > limite && estado == 0) {
      publish("1", "Ativacao", client);
    }
    print(temp);
  }

  //Widgets

  Widget espaco() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.03,
    );
  }

  Widget botao(String texto, Function onpressed, {int i = 0}) {
    return Container(
      width: 1 * MediaQuery.of(context).size.width,
      height: 0.07 * MediaQuery.of(context).size.height,
      child: ElevatedButton(
        child: Text(
          texto,
          style: TextStyle(
              color: i == 0 ? Theme.of(context).primaryColor : Colors.grey,
              fontSize: 24),
        ),
        onPressed: onpressed,
        style: ElevatedButton.styleFrom(
          primary: Color.fromARGB(255, 154, 196, 105),
          elevation: 5,
          shape: const BeveledRectangleBorder(),
        ),
      ),
    );
  }
}

//Escrever no arquivo
write(String text) async {
  final Directory directory = await getExternalStorageDirectory();
//  print("------------------------");
//  print(directory);
  String day = DateFormat("yyyy-MM-dd").format(DateTime.now());
  String tdata = DateFormat("HH:mm:ss").format(DateTime.now());
  final File file = File('${directory.path}/$day.txt');

  String t = tdata + ' - ' + text + '\n';
  await file.writeAsString(t, mode: FileMode.append);
}
