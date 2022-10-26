// ignore_for_file: unnecessary_const

import 'dart:io';

import 'package:band_names_app/models/band.dart';
import 'package:band_names_app/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Band> bands = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket?.on('active-bands', _handleActiveBands);
    super.initState();
  }

  void _handleActiveBands(dynamic payload) {
    bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Band names',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        actions: [
          CircleAvatar(
            radius: 15,
            foregroundColor: Colors.white,
            backgroundColor: socketService.serverStatus == ServerStatus.online ? Colors.green[800] : Colors.red,
            child: Icon(
              socketService.serverStatus == ServerStatus.online ? Icons.cloud_done : Icons.cloud_off,
              size: 20,
            ),
          )
        ],
      ),
      body: Column(
        children: [
          if (bands.isNotEmpty)
            SizedBox(
                height: 200,
                child: PieChart(
                  dataMap: Map.fromEntries(bands.map((band) => MapEntry(band.name, band.votes.toDouble()))),
                  chartValuesOptions: const ChartValuesOptions(
                    showChartValuesInPercentage: true,
                    decimalPlaces: 0,
                    showChartValueBackground: false,
                  ),
                  chartType: ChartType.ring,
                )),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, index) => _BandTile(band: bands[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewBand,
        child: const Icon(Icons.add),
      ),
    );
  }

  _addNewBand() {
    final controller = TextEditingController();

    if (Platform.isAndroid) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: const Text('New band name'),
                content: TextField(
                  controller: controller,
                ),
                actions: [
                  TextButton(onPressed: () => _addBandToList(controller.text), child: const Text('Add')),
                ],
              ));
    } else {
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('New band name'),
          content: CupertinoTextField(controller: controller),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => _addBandToList(controller.text),
              child: const Text('Add'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(context),
              child: const Text('Dismiss'),
            )
          ],
        ),
      );
    }
  }

  void _addBandToList(String name) {
    if (name.isNotEmpty) {
      Provider.of<SocketService>(context, listen: false).socket?.emit('add-band', {'name': name});
    }
    Navigator.pop(context);
  }
}

class _BandTile extends StatelessWidget {
  const _BandTile({
    Key? key,
    required this.band,
  }) : super(key: key);

  final Band band;

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => socketService.socket?.emit('delete-band', {'id': band.id}),
      background: Container(
        padding: const EdgeInsets.only(left: 10),
        alignment: Alignment.centerLeft,
        color: Colors.red,
        child: const Text('Delete Band', style: const TextStyle(color: Colors.white)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(band.name.substring(0, 2)),
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}', style: const TextStyle(fontSize: 20)),
        onTap: () => socketService.socket?.emit('vote-band', {'id': band.id}),
      ),
    );
  }
}
