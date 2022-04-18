import 'package:flutter/material.dart';
// import 'package:poppos/Database/DatabaseHelper.dart';
import 'package:poppos/Model/OutletModel.dart';
import 'package:poppos/Networking/OfflineData.dart';
// import 'package:poppos/Networking/OfflineData.dart';
import 'package:poppos/Utills/Color.dart';
import 'package:poppos/View/ApiPage.dart';
import 'package:poppos/main.dart';

class OutletPage extends StatefulWidget {
  const OutletPage({Key key}) : super(key: key);

  @override
  _OutletPageState createState() => _OutletPageState();
}

class _OutletPageState extends State<OutletPage> {
  @override
  Widget build(BuildContext context) {
    int count = 2;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth > 700) {
          bool potrait =
              MediaQuery.of(context).orientation == Orientation.portrait;
          if (potrait) {
            count = 2;
          } else {
            count = 4;
          }
        }
        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              actions: [
                TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => ApiPage(),
                        )),
                    child: Text("back"))
              ],
              title: Text("Outlets"),
              backgroundColor: primary,
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: primary,
              onPressed: () {
                setState(() {});
              },
              child: Icon(Icons.refresh),
            ),
            body: FutureBuilder(
              future: getOutlet(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return Center(
                    child: Text(
                      "Something went wrong please try after sometime",
                    ),
                  );
                }
                if (snapshot.hasData) {
                  List<Outlets> data = snapshot.data;
                  if (data.length == 0) {
                    return Center(
                      child: Text(
                        "No outlet found for you",
                      ),
                    );
                  } else {
                    return GridView.count(
                        primary: false,
                        crossAxisCount: count,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        children: data.map((o) {
                          return GestureDetector(
                            onTap: () async {
                              await addOfflineData("outlet", o.id);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      LoginPage(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                color: secondary,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: FittedBox(
                                        fit: BoxFit.fitWidth,
                                        child: Text(
                                          o.name ?? " ",
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: light,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: FittedBox(
                                        fit: BoxFit.fitWidth,
                                        child: Text(
                                          o.address ?? " ",
                                          style: TextStyle(
                                            fontSize: 24,
                                            color: light.withOpacity(0.5),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList());
                  }
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: secondary,
                      valueColor: AlwaysStoppedAnimation(primary),
                    ),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}
