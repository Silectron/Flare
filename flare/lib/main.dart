import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flare',
      home: MyLoginPage(),
    );
  }
}

class MyLoginPage extends StatefulWidget{
  @override
  _MyLoginPageState createState(){
    return _MyLoginPageState();
  }
}

class _MyLoginPageState extends State<MyLoginPage>{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(),
            Container(
              alignment: Alignment.center,
              child:Image.asset('assets/logo.png',
              width: 300.0,
            ),
            ),
            Container(
                alignment: Alignment.center,
                child:Text("Flare", style: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Sans Serif',
                    fontSize: 75),
                )
            ),
            Container(),
            Container(),
            Container(),
            RaisedButton(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 40.0),
                child: Text('Sign In With Google', style: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w500,
                    //fontStyle: FontStyle.italic,
                    fontFamily: 'Open Sans',
                    fontSize: 30),
                ),
                  onPressed: () { Navigator.push( context, MaterialPageRoute(builder: (context) => MyHomePage()),
                );
              }
          ),
            Container(),
            Container(),
        ],
        ),
      ));
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {

  String _phoneString = '';
  String _selectedContact = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Flare Contacts'),
          actions: <Widget> [
            IconButton(
              icon: Icon(Icons.add_box),
              onPressed: () {
                showDialog(
                  context: context,
                    builder: (context) {
                      return Dialog(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              alignment: Alignment.center,
                              child: Text(
                                  'Add New Contact',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.italic,
                                      fontFamily: 'Open Sans',
                                      fontSize: 35
                                  )
                              )
                            ),
                            Text('Name'),
                            Container(
                                child: TextField(
                                  onChanged: (text) {
                                    _selectContactToUpdate(text);
                                  },
                                )
                            ),
                            Text('Phone Number'),
                            Container(
                                child: TextField(
                                  onChanged: (text) {
                                    _updatePhoneNumber(text);
                                  },
                                )
                            ),
                            Container(
                              child: FlatButton(
                                onPressed: () {
                                    _addNewContact(_selectedContact, _phoneString);
                                },
                                child: const Text(
                                  'Add',
                                  style: TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold, height: 10),

                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  );
                },

            ),

            Text('Add Contact'),
          ]
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('users/sarah/contact').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);

    return Padding(
      key: ValueKey(record.name),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(record.name),
          trailing: Text(record.phoneNumber),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return Dialog(

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text('Change Contact Information', style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Open Sans',
                      fontSize: 25),),
                      Text(record.name, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22),),
                      Text(record.phoneNumber, style: TextStyle(fontWeight: FontWeight.w500,fontSize: 22),),
                      Container(
                        child: TextField(
                          onChanged: (text) {
                            _updatePhoneNumber(text);
                          },
                        )
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 40.0),
                        child: RaisedButton(
                          onPressed: () => record.reference.updateData({'phone': _phoneString}),
                          child: const Text(
                          'Change Number',
                          style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),

                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 40.0),
                        child: RaisedButton(
                          onPressed: () => record.reference.delete(),
                          child: const Text(
                            'Remove Contact',
                            style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),

                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _updatePhoneNumber(String text) {
    setState(() {
      _phoneString = text;
    });
  }

  void _addNewContact(String name, String phone) {
    String documentName = name.toLowerCase();
    Firestore.instance.collection('users/sarah/contact')
        .document(documentName)
        .setData({'name': name, 'phone': phone});
  }

  void _selectContactToUpdate(String text) {
    setState( () {
      _selectedContact = text;
    });
  }
}

class Record {
  final String name;
  final String phoneNumber;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['phone'] != null),
        name = map['name'],
        phoneNumber = map['phone'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$phoneNumber>";
}

class Sms {

}

