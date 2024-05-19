import 'package:flutter/material.dart';
import '../helpers/contact_helper.dart';
import 'contact_page.dart';

enum OrderOptions { orderaz, orderza }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final ContactHelper helper = ContactHelper();
  List<Contact> contacts = [];
  List<Contact> filteredContacts = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getAllContacts();
    searchController.addListener(_filterContacts);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterContacts() {
    List<Contact> results = [];
    if (searchController.text.isEmpty) {
      results = contacts;
    } else {
      results = contacts
          .where((contact) =>
              contact.name!
                  .toLowerCase()
                  .contains(searchController.text.toLowerCase()) ||
              contact.phone!.contains(searchController.text) ||
              contact.email!
                  .toLowerCase()
                  .contains(searchController.text.toLowerCase()))
          .toList();
    }

    setState(() {
      filteredContacts = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                value: OrderOptions.orderaz,
                child: Text('Order from A to Z'),
              ),
              const PopupMenuItem<OrderOptions>(
                value: OrderOptions.orderza,
                child: Text('Order from Z to A'),
              ),
            ],
            onSelected: _orderList,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, phone',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showContactPage(),
        child: const Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: filteredContacts.length,
        itemBuilder: _contactCard,
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/images/person.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      filteredContacts[index].name ?? "",
                      style: const TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      filteredContacts[index].email ?? "",
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    Text(
                      filteredContacts[index].phone ?? "",
                      style: const TextStyle(fontSize: 18.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () => _showOptions(context, index),
    );
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          onClosing: () {},
          builder: (context) {
            return Container(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextButton(
                      child: const Text(
                        'Edit',
                        style: TextStyle(color: Colors.red, fontSize: 20.0),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _showContactPage(contact: filteredContacts[index]);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextButton(
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red, fontSize: 20.0),
                      ),
                      onPressed: () {
                        setState(() {
                          helper.deleteContact(filteredContacts[index].id!);
                          contacts.removeAt(index);
                          _filterContacts();
                          Navigator.pop(context);
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showContactPage({Contact? contact}) async {
    final recContact = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ContactPage(contact: contact)),
    );
    if (recContact != null) {
      if (contact != null) {
        await helper.updateContact(recContact);
      } else {
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  void _getAllContacts() {
    helper.getAllContacts().then((list) {
      setState(() {
        contacts = list.cast<Contact>();
        filteredContacts = contacts;
      });
    });
  }

  void _orderList(OrderOptions result) {
    switch (result) {
      case OrderOptions.orderaz:
        filteredContacts.sort(
            (a, b) => a.name!.toLowerCase().compareTo(b.name!.toLowerCase()));
        break;
      case OrderOptions.orderza:
        filteredContacts.sort(
            (a, b) => b.name!.toLowerCase().compareTo(a.name!.toLowerCase()));
        break;
    }
    setState(() {});
  }
}
