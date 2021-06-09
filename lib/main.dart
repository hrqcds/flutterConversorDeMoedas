import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "dart:convert";

void main() async {
  runApp(MaterialApp(
    title: "Conversor de Moedas",
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
            hintStyle: TextStyle(color: Colors.amber))),
  ));
}

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

  void _realChanged(String text) {
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    double dolar = double.parse(text);

    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.amber,
          title: Text(
            "\$Conversor\$",
            style: TextStyle(color: Colors.black, fontSize: 25),
          ),
          centerTitle: true,
        ),
        body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                    child: Text(
                  "Carregando Dados",
                  style: TextStyle(color: Colors.amber, fontSize: 25),
                  textAlign: TextAlign.center,
                ));
              default:
                if (snapshot.hasError) {
                  return (Center(
                      child: Text(
                    "Carregando Dados",
                    style: TextStyle(color: Colors.amber, fontSize: 25),
                    textAlign: TextAlign.center,
                  )));
                } else {
                  dolar = snapshot.data["USD"]["buy"];
                  euro = snapshot.data["EUR"]["buy"];
                  return (SingleChildScrollView(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.monetization_on,
                          size: 150,
                          color: Colors.amber,
                        ),
                        buildTextField(
                            "Reais", "R\$", realController, _realChanged),
                        buildTextField(
                            "Dolares", "US\$", dolarController, _dolarChanged),
                        buildTextField(
                            "Euros", "€", euroController, _euroChanged),
                      ],
                    ),
                  ));
                }
            }
          },
        ));
  }
}

Widget buildTextField(
    String label, String prefix, TextEditingController c, Function f) {
  return (Padding(
      padding: EdgeInsets.only(left: 10, right: 10, top: 15),
      child: TextField(
        controller: c,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: "$label",
          labelStyle: TextStyle(color: Colors.amber, fontSize: 15),
          border: OutlineInputBorder(),
          prefixText: "$prefix",
        ),
        style: TextStyle(color: Colors.amber, fontSize: 25),
        onChanged: f,
      )));
}

Future<Map> getData() async {
  var request = Uri.parse(
      "https://api.hgbrasil.com/finance?format=json-cors&key=f70bcb6b");
  var response = await http.get(request);
  return (json.decode(response.body)["results"]["currencies"]);
}
