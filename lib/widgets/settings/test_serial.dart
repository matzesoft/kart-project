import 'package:flutter/material.dart';
import 'package:kart_project/providers/motor_provider.dart';
import 'package:kart_project/providers/serial_port/serial_port.dart';
import 'package:provider/provider.dart';

class TestSerial extends StatefulWidget {
  @override
  _TestSerialState createState() => _TestSerialState();
}

class _TestSerialState extends State<TestSerial> {
  ControllerProvider motorProvider;
  List<DataPackage> dataPackagesOn = [
    DataPackage(
      cmd: Byte("02"),
      length: Byte("00"),
    ),
  ];
  List<DataPackage> dataPackagesOff = [];

  void echo() {
    motorProvider.getEcho();
  }

  Future everyCmd() async {
    motorProvider.everyCmd();
  }

  Future getBytesOn() async {
    setState(() {
      dataPackagesOn = motorProvider.getData();
    });
  }

  Future getBytesOff() async {
    setState(() {
      dataPackagesOff = motorProvider.getData();
    });
  }

  Widget element(DataPackage data) {
    return Card(
      child: Column(
        children: [
          Text("CMD: ${data.cmd.value}"),
          Text("Length: ${data.length.value}"),
          Builder(builder: (context) {
            if (!data.payloadAvailable) return Text("No payload");
            return Column(
              children: List.generate(
                data.payload.length,
                (index) => Text(data.payload[index].value),
              ),
            );
          }),
          Text("Verifiy: ${data.verification.value}"),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    motorProvider = Provider.of<ControllerProvider>(context);

    return Column(
      children: [
        RaisedButton(
          onPressed: () {
            everyCmd();
          },
          child: Text("Every CMD"),
        ),
        RaisedButton(
          onPressed: () {
            getBytesOn();
          },
          child: Text("Get Bytes with motor on"),
        ),
        RaisedButton(
          onPressed: () {
            getBytesOff();
          },
          child: Text("Get Bytes with motor off"),
        ),
        RaisedButton(
          onPressed: () {
            echo();
          },
          child: Text("Echo"),
        ),
        Row(
          children: [
            Column(
              children: [
                Text("Motor On"),
                Column(
                  children: List.generate(
                    dataPackagesOn.length,
                    (index) => element(dataPackagesOn[index]),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Text("Motor off"),
                Column(
                  children: List.generate(
                    dataPackagesOff.length,
                    (index) => element(dataPackagesOff[index]),
                  ),
                ),
              ],
            ),
          ],
        )
      ],
    );
  }
}
