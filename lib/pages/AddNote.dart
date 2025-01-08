import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Addnote extends StatefulWidget {
  const Addnote({super.key});

  @override
  State<Addnote> createState() => _AddnoteState();
}

class _AddnoteState extends State<Addnote> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  String _selectedVisibility = 'Public';

  FilePickerResult? _filePickerResult;

  void _openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        allowedExtensions: ["pdf"],
        type: FileType.custom);
    setState(() {
      _filePickerResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF90CAF9),
            Color(0xFF64B5F6),
            Color(0xFF42A5F5),
            Color(0xFF2196F3),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Text(
        'Add Note',
        style: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInputField(
            controller: titleController,
            hint: "Title",
            maxLines: 1,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: subjectController,
            hint: "Subject",
            maxLines: 1,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: contentController,
            hint: "Note Content",
            maxLines: 8,
          ),
          const SizedBox(height: 24),
          _buildVisibilitySection(),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required int maxLines,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.poppins(fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: Colors.black54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildVisibilitySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Visibility",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          _buildVisibilityOption('Public', Icons.public),
          _buildVisibilityOption('Private', Icons.lock),
          _buildVisibilityOption('Friends Only', Icons.group),
        ],
      ),
    );
  }

  Widget _buildVisibilityOption(String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1976D2)),
      title: Text(
        value,
        style: GoogleFonts.poppins(),
      ),
      trailing: Radio<String>(
        value: value,
        groupValue: _selectedVisibility,
        onChanged: (newValue) =>
            setState(() => _selectedVisibility = newValue!),
        activeColor: const Color(0xFF1976D2),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildButton(
          label: "Upload PDF",
          icon: Icons.picture_as_pdf,
          onPressed: () {
            // PDF upload functionality
          },
        ),
        const SizedBox(height: 16),
        _buildButton(
          label: "Add Note",
          icon: Icons.check,
          onPressed: _saveNote,
        ),
      ],
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1976D2),
            ),
          ),
          const SizedBox(width: 12),
          Icon(icon, color: const Color(0xFF1976D2)),
        ],
      ),
    );
  }

  void _saveNote() async {
    try {
      final title = titleController.text.trim();
      final subject = subjectController.text.trim();
      final content = contentController.text.trim();
      final user = FirebaseAuth.instance.currentUser;

      if (title.isEmpty || subject.isEmpty || content.isEmpty) {
        _showErrorDialog('Please fill all fields');
        return;
      }

      if (user == null) {
        _showErrorDialog('User not authenticated');
        return;
      }

      await FirebaseFirestore.instance.collection('notes').add({
        'title': title,
        'subject': subject,
        'content': content,
        'visibility': _selectedVisibility,
        'addedBy': user.email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showSuccessDialog();
      _clearFields();
    } catch (e) {
      _showErrorDialog('Error saving note: $e');
    }
  }

  void _showSuccessDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      title: 'Success',
      desc: 'Note Added Successfully',
      btnOkColor: const Color(0xFF1976D2),
      btnOkOnPress: () => Navigator.pop(context),
    ).show();
  }

  void _showErrorDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.scale,
      title: 'Error',
      desc: message,
      btnOkColor: const Color(0xFF1976D2),
      btnOkOnPress: () {},
    ).show();
  }

  void _clearFields() {
    titleController.clear();
    subjectController.clear();
    contentController.clear();
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
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
          padding: const EdgeInsets.all(16.0), // Suitable margins
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, top: 10),
                  child: TextField(
                    controller: namecontroller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.black.withOpacity(0.7), // Label color
                        fontSize: 20.0, // Label font size
                        fontWeight: FontWeight.bold, // Label font weight
                      ),
                      hintText: "Title",
                      fillColor: Colors.white, // Background color
                      filled: true, // Enable the background color
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, top: 8),
                  child: TextField(
                    controller: subjectController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.black.withOpacity(0.7), // Label color
                        fontSize: 20.0, // Label font size
                        fontWeight: FontWeight.bold, // Label font weight
                      ),
                      hintText: "Subject",
                      fillColor: Colors.white, // Background color
                      filled: true, // Enable the background color
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextField(
                    controller: Contentcontroller,
                    maxLines: 10, // Makes the TextField multiline
                    minLines: 5, // Initial height for the TextField
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.black.withOpacity(0.7), // Label color
                        fontSize: 20.0, // Label font size
                        fontWeight: FontWeight.bold, // Label font weight
                      ),
                      hintText: "Add Note Content",
                      fillColor: Colors.white, // Background color
                      filled: true, // Enable the background color
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Visibility",
                      style: GoogleFonts.poppins(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Public',
                        style: GoogleFonts.poppins(),
                      ),
                      leading: Radio<String>(
                        value: 'Public',
                        groupValue: _selectedVisibility,
                        onChanged: (value) {
                          setState(() {
                            _selectedVisibility = value!;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Private',
                        style: GoogleFonts.poppins(),
                      ),
                      leading: Radio<String>(
                        value: 'Private',
                        groupValue: _selectedVisibility,
                        onChanged: (value) {
                          setState(() {
                            _selectedVisibility = value!;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Friends Only',
                        style: GoogleFonts.poppins(),
                      ),
                      leading: Radio<String>(
                        value: 'Friends Only',
                        groupValue: _selectedVisibility,
                        onChanged: (value) {
                          setState(() {
                            _selectedVisibility = value!;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 10.0),
                    // Text(
                    //   'Selected: $_selectedVisibility',
                    //   style: GoogleFonts.poppins(
                    //     fontSize: 16.0,
                    //     fontStyle: FontStyle.italic,
                    //   ),
                    // ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () async {
                    _openFilePicker();
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
                                child: Text("Upload PDFF",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    )))),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: const Icon(
                            Icons.picture_as_pdf,
                            color: Colors.black,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      String title = namecontroller.text.trim();
                      String subject = subjectController.text.trim();
                      String content = Contentcontroller.text;
                      String visibility = _selectedVisibility;
                      User? user = FirebaseAuth.instance.currentUser;
                      print(user);
                      String uid = user!.uid;
                      String email = user.email!;
                      if (title.isNotEmpty &&
                          subject.isNotEmpty &&
                          visibility.isNotEmpty) {
                        FirebaseFirestore.instance.collection('notes').add({
                          'title': title,
                          'subject': subject,
                          'content': content,
                          'visibility': visibility,
                          'addedBy': email,
                        }).then((value) {
                          namecontroller.clear();
                          subjectController.clear();
                          Contentcontroller.clear();

                          AwesomeDialog(
                              context: context,
                              dialogType: DialogType.success,
                              animType: AnimType.scale,
                              title: 'Success',
                              desc: 'Note Added Successfully',
                              btnOkOnPress: () {
                                namecontroller.clear();
                                subjectController.clear();
                                Contentcontroller.clear();
                              }).show();
                        });
                      } else {
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.noHeader,
                          animType: AnimType.topSlide,
                          title: 'Error',
                          desc: 'Please fill all the fields',
                          btnOkOnPress: () {
                            namecontroller.clear();
                            subjectController.clear();
                            Contentcontroller.clear();
                          },
                          customHeader: const Icon(
                            Icons.error,
                            color: Colors.red,
                            size: 80,
                          ),
                        ).show();
                      }
                    } catch (e) {
                      print(e);
                    }
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
                                child: Text("Add Note",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    )))),
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
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
