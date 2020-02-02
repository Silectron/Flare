import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twilio_voice/flutter_twilio_voice.dart';
import 'package:permission_handler/permission_handler.dart';

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
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 35.0),
                child: Text('Sign In', style: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w500,
                    //fontStyle: FontStyle.italic,
                    fontFamily: 'Open Sans',
                    fontSize: 30),
                ),
                  onPressed: () { handlePermission(); Navigator.push( context, MaterialPageRoute(builder: (context) => MyHomePage()),
                );
              }
          ),
            Container(),
            Container(),
        ],
        ),
      ));
  }

  Future<void> handlePermission() async {
    //Map<PermissionGroup, PermissionStatus> permissions =
    await PermissionHandler().requestPermissions([PermissionGroup.contacts]);

    //PermissionStatus permission =
    await PermissionHandler().checkPermissionStatus(PermissionGroup.contacts);
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
  String _nameString = '';
  List<String> contactList = ["Kim", "514-222-2222", "Alex", "513-999-9999"];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.redAccent,
          title: Text('Flare Contacts'),
          actions: <Widget> [
            Container(
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text('Add Contact',
              style: TextStyle(fontSize: 20, color: Colors.white),

              ),
            ),
            IconButton(
              icon: Icon(Icons.add_box),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                              alignment: Alignment.center,
                              child: Text(
                                  'Add New Contact',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.italic,
                                      fontFamily: 'Open Sans',
                                      fontSize: 35
                                  )
                              )
                            ),
                            Text('Name', style: TextStyle(fontSize: 22),),
                            Container(
                                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                                child: TextField(
                                  maxLength: 50,
                                  decoration: InputDecoration(
                                      hintText: "Enter a name",
                                      icon: Icon(Icons.border_color),
                                      border: OutlineInputBorder()
                                  ),
                                  onChanged: (text) {
                                    _selectContactToUpdate(text);
                                  },
                                )
                            ),
                            Text('Phone Number', style: TextStyle(fontSize: 22),),
                            Container(
                                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                                child: TextField(
                                  inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    icon: Icon(Icons.border_color),
                                      hintText: "Enter a phone number",
                                    border: OutlineInputBorder()
                                  ),
                                  onChanged: (text) {
                                    _updatePhoneNumber(text);
                                  },
                                )
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 50.0),
                              child: RaisedButton(
                                onPressed: () {
                                    _addNewContact(_selectedContact, _phoneString);
                                },
                                child: const Text(
                                  'Add',
                                  style: TextStyle(fontSize: 27, color: Colors.black45, fontWeight: FontWeight.bold),

                                ),
                                onChanged: (text) {
                                  _updatePhoneNumber(text);
                                },
                              )
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 40.0),
                            child: RaisedButton(
                              onPressed: () {
                                _addNewContact(_selectedContact, _phoneString);
                              },
                              child: const Text(
                                'Add',
                                style: TextStyle(fontSize: 25,
                                    color: Colors.black45,
                                    fontWeight: FontWeight.bold),

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


          ]
      ),

      body:
      _buildBody(context),

      bottomSheet: Container(
        margin: const EdgeInsets.all(10.0),
        padding: const EdgeInsets.all(10.0),
        //alignment: Alignment.bottomCenter,
        child: RaisedButton(
            padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 35.0),
            child: Text('Send Emergency Message', style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
                //fontStyle: FontStyle.italic,
                fontFamily: 'Open Sans',
                fontSize: 20),
            ),
            onPressed: () { Navigator.push( context, MaterialPageRoute(builder: (context) => MyEmergencyPage()),
            );
            }
        ),
      ),

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


//  Future<void> getImportedContacts() async {
//    //contactList = await ContactsService.getContacts(withThumbnails: false);
//    //contactList.toList()[0] = new Contact();
//    print(contactList.toList().length);
//  }


//  Widget display(String c) {
//    return Padding(
//        padding: const EdgeInsets.only(top: 20.0),
//      child: Container(
//        decoration: BoxDecoration(
//          border: Border.all(color: Colors.grey),
//          borderRadius: BorderRadius.circular(5.0),
//        ),
//        child: ListTile(
//          title: Text(c),
//          trailing: Text(c),
//          onTap: () {
//            showDialog(
//              context: context,
//              builder: (context) {
//                return Dialog(
//                  child: Column(
//                    mainAxisAlignment: MainAxisAlignment.start,
//                    crossAxisAlignment: CrossAxisAlignment.center,
//                    children: <Widget>[
//                      Container(child: Text(""),),
//
//
//                      Text('Change Contact Information', style: TextStyle(
//                          fontWeight: FontWeight.w800,
//                          fontStyle: FontStyle.italic,
//                          fontFamily: 'Open Sans',
//                          fontSize: 25),),
//                      Container(child: Text(""),),
//                      Text("Name: " + c, textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22),),
//                      Container(child: Text(""),),
//                      Text("Phone number: " + c, style: TextStyle(fontWeight: FontWeight.w500,fontSize: 22),),
//                      Container(
//                          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
//                          child: TextField(
//                            decoration: InputDecoration(
//                                hintText: "Enter a phone number",
//                                border: OutlineInputBorder()
//                            ),
//                            onChanged: (text) {
//                              _updatePhoneNumber(text);
//                            },
//                          )
//                      ),
//                      Container(
//                        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 50.0),
//                        child: RaisedButton(
//                          onPressed: () => {},//record.reference.updateData({'phone': _phoneString}),
//                          child: const Text(
//                            'Change Number',
//                            style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
//
//                          ),
//                        ),
//                      ),
////                      Container(child: Text(""),),
//                      Container(
//                        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 40.0),
//                        child: RaisedButton(
//                          onPressed: () => {},//record.reference.delete(),
//                          child: const Text(
//                            'Remove Contact',
//                            style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
//
//                          ),
//                        ),
//                      )
//                    ],
//                  ),
//                );
//              },
//            );
//          },
//        ),
//      ),
//    );
//  }


//  Widget _buildImportedList(context, List<String> contacts) {
//    //int size = contacts.toList().length;
//    if(contacts != null)
//    contacts.forEach((c) => display(c));
//
//    for(int i = 1; i < size; i++) {
//      print(contacts.toList()[i].displayName);
//    }
//    return(Container());
//  }

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
          trailing: Text(record.phoneNumber),//
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text('Edit Contact Information', textAlign: TextAlign.center, style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Open Sans',
                      fontSize: 30),),
                      Text(record.name, style: TextStyle(fontSize: 22),),
                      Container(
                          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                          child: TextField(
                            maxLength: 50,
                            decoration: InputDecoration(
                                hintText: "Edit name",
                                icon: Icon(Icons.border_color),
                                border: OutlineInputBorder()
                            ),
                            onChanged: (text) {
                              _updateName(text);
                              //_updateSelectedContact();
                            },
                          )
                      ),
                      Text(record.phoneNumber, style: TextStyle(fontSize: 22),),
                      Container(
                          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                        child: TextField(
                          inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              icon: Icon(Icons.border_color),
                            hintText: "Edit phone number",
                            border: OutlineInputBorder()
                          ),
                          onChanged: (text) {
                            _updatePhoneNumber(text);

                          },
                        )
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 50.0),
                        child: RaisedButton(
                          onPressed: () => record.reference.updateData({'phone': _phoneString, 'name': _nameString}),
                          child: const Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 25, color: Colors.black26, fontWeight: FontWeight.bold),


                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 40.0),
                        child: RaisedButton(
                          onPressed: () => record.reference.delete(),
                          child: const Text(
                            'Remove Contact',
                            style: TextStyle(fontSize: 25, color: Colors.black26, fontWeight: FontWeight.bold),

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

  void _updateName(String text){
    setState((){
      _nameString = text;
    });
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

class MyEmergencyPage extends StatefulWidget{
  @override
  _MyEmergencyPageState createState(){
    return _MyEmergencyPageState();
  }
}

class _MyEmergencyPageState extends State<MyEmergencyPage>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            title:Text('Emergencies')
        ),
        body:Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(child:Text("Select the emergency message you'd like to send.", style: TextStyle(fontSize: 20),)),
            Container(
              margin: const EdgeInsets.all(10.0),
              padding: const EdgeInsets.all(10.0),
              alignment: Alignment.center,
              child:RaisedButton(
                  onPressed: () {
                    //Send message
                  },
                  padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 150.0),
                  child: const Text('Police', style: TextStyle(fontSize: 20),
                  )
              )
            ),
            Container(child:Text("")),
            Container(
                margin: const EdgeInsets.all(10.0),
                padding: const EdgeInsets.all(10.0),
                alignment: Alignment.center,
                child:RaisedButton(
                    onPressed: () {
                      //Send message
                    },
                    padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 150.0),
                    child: const Text('Stroke', style: TextStyle(fontSize: 20),)
                )
            ),
            Container(child:Text("")),
            Container(
                margin: const EdgeInsets.all(10.0),
                padding: const EdgeInsets.all(10.0),
                alignment: Alignment.center,
                child:RaisedButton(
                    onPressed: () {
                      //Send message

                    },
                    padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 150.0),
                    child: const Text('Injury', style: TextStyle(fontSize: 20),)
                )
            ),
          ],
        )
      ),
    );
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

