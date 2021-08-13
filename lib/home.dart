import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/services.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController detailsController = TextEditingController();

  final CollectionReference database =
      Firestore.instance.collection("Augersoft");

  // final DocumentReference ref =

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Store and Fetch Data'),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: database.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          return !snapshot.hasData
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot doc = snapshot.data.documents[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.purple[50],
                            child: Text(snapshot.data.documents[index]['Name']
                                .toString()
                                .substring(0, 1)
                                .toUpperCase()),
                          ),
                          title: Text(
                            snapshot.data.documents[index]['Name'],
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(snapshot.data.documents[index]['Details']),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () async {
                                      _showDialog(2, doc.documentID);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      await deleteDetails(doc.documentID);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showDialog(1, null);
          // _showAlert();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  _showDialog(int option, String docID) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            'Enter Details',
          ),
          children: [
            SimpleDialogOption(
              child: TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Name Here..',
                ),
              ),
            ),
            SimpleDialogOption(
              child: TextField(
                controller: detailsController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Description..',
                ),
              ),
            ),
            SimpleDialogOption(
              // ignore: deprecated_member_use
              child: RaisedButton(
                onPressed: () {
                  if (nameController != null && detailsController != null) {
                    print(nameController.text);
                    print(detailsController.text);
                    if (option == 1) {
                      storeDetails();
                    } else {
                      updateDetails(docID);
                    }
                    nameController.clear();
                    detailsController.clear();
                    Navigator.pop(context);
                  }
                },
                color: Colors.purple,
                child: option == 1
                    ? Text(
                        'Enter',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Text(
                        'Update',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> storeDetails() async {
    var docId = database.document().documentID;
    print(docId);
    return await database.document(docId).setData({
      'Details': detailsController.text,
      'Name': nameController.text,
    });
  }

  Future<void> deleteDetails(String docID) async {
    print(docID);
    return await database.document(docID).delete();
  }

  Future<void> updateDetails(String docID) async {
    return await database.document(docID).updateData({
      'Details': detailsController.text,
      'Name': nameController.text,
    });
  }
}
