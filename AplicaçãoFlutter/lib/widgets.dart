import 'package:flutter/material.dart';

Widget button(String texto, Color color, double width, double height,
    Function onpressed, BuildContext context) {
  return Container(
    width: width * MediaQuery.of(context).size.width,
    height: height * MediaQuery.of(context).size.height,
    child: ElevatedButton(
      child: Text(
        texto,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      onPressed: onpressed,
      style: ElevatedButton.styleFrom(
        primary: color,
        elevation: 5,
        shape: const BeveledRectangleBorder(
            //borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
      ),
    ),
  );
}

//Mensagens na base da tela
void showProcessing({BuildContext context}) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        "Conectando...",
        textAlign: TextAlign.center,
      ),
      backgroundColor: const Color(0xFF243656),
      duration: Duration(seconds: 3),
    ),
  );
}

void showSuccess({BuildContext context}) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        "Conexão realizada com sucesso...",
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.green,
    ),
  );
}

void showError({BuildContext context}) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        "Conexão não realizada...",
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.red,
    ),
  );
}
