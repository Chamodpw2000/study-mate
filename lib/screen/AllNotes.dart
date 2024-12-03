import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studymate/pages/AddNote.dart';

class AllNotes extends StatefulWidget {
  const AllNotes({super.key});

  @override
  State<AllNotes> createState() => _AllNotesState();
}

class _AllNotesState extends State<AllNotes> {
  List<Map<String, dynamic>> notes = []; // Array to store contacts
  List<Map<String, dynamic>> filteredNotes = []; // Array for filtered contacts
  TextEditingController searchController =
      TextEditingController(); // Controller for search input
  bool isLoading = true; // Variable to indicate if data is still loading

  @override
  void initState() {
    super.initState();
    fetchNotes(); // Fetch contacts when the page loads
  }

  Future<void> fetchNotes() async {
    setState(() {
      isLoading = true; // Set loading to true when fetching starts
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;

        FirebaseFirestore.instance
            .collection('notes')
            // .where('addedBy', isEqualTo: uid)
            .get()
            .then((QuerySnapshot querySnapshot) {
          setState(() {
            notes.clear(); // Clear the list before adding new contacts
            for (var doc in querySnapshot.docs) {
              notes.add({
                'id': doc.id,
                'name': doc['name'],
                'number': doc['number'],
              });
            }
            isLoading = false;
          });
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterContacts(String query) {
    List<Map<String, dynamic>> filtered = notes.where((contact) {
      return contact['name'].toLowerCase().contains(query.toLowerCase()) ||
          contact['number'].contains(query);
    }).toList();

    setState(() {
      filteredNotes = filtered;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/b.jpg'),
            fit: BoxFit.cover,
            alignment: Alignment(-0.21, 0),
            opacity: 0.7,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading) // Show loading indicator while loading
                const Center(
                  child: CircularProgressIndicator(),
                )
              else
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 50.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Addnote()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 20),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      "Add Note",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(8.0),
                                  child: const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.black,
                                    size: 30,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: TextField(
                              controller: searchController,
                              onChanged: (value) {
                                filterContacts(value);
                              },
                              decoration: InputDecoration(
                                labelText: 'Search Notes',
                                labelStyle: GoogleFonts.poppins(
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(
                                      color: Colors
                                          .black), // Border color set to black
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(
                                      color: Colors
                                          .black), // Black border when enabled
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(
                                      color: Colors.black,
                                      width:
                                          2), // Thicker black border on focus
                                ),
                              ),
                            ),
                          )),
                      if (searchController.text.isNotEmpty)
                        Expanded(
                          child: filteredNotes.isEmpty
                              ? const Center(
                                  child: Text("No Matching Notes"),
                                )
                              : buildContactList(filteredNotes),
                        )
                      else
                        Expanded(
                          child: notes.isEmpty
                              ? const Center(
                                  child: Text("No Notes Available"),
                                )
                              : buildContactList(notes),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildContactList(List<Map<String, dynamic>> contactList) {
    return ListView.builder(
      itemCount: contactList.length,
      itemBuilder: (context, index) {
        final contact = contactList[index];
        return ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(contact['name'],
                  style: GoogleFonts.poppins(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  )),
              Text(contact['number'],
                  style: GoogleFonts.poppins(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
          leading: CircleAvatar(
            backgroundColor: Color.fromARGB(255, 0, 0, 0),
            child: Text(contact['name'][0],
                style: GoogleFonts.poppins(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                )),
          ),
          trailing: const SizedBox(
            width: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
            ),
          ),
        );
      },
    );
  }
}
